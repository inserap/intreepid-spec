# 2026-08-05-01-brique-9-mesure-cout-et-temps — Execution recap

## Scope

Brique #9 — **instrumentation pérenne de la mesure** : rendre le **temps** et le **coût
financier** d'une session d'agent mesurables **pour tout rôle** et **rétroactivement**, sans
ajouter d'organe de télémétrie. Principe directeur : *la mesure n'est pas un organe, c'est une
lecture de la trace* — le greffier capturait déjà l'essentiel, mais personne ne le relisait.

Déclencheur : arbitrer sur des chiffres la décision D3 de la brique #8 (« la fiche n'est émise
qu'au tour final »), prise contre une latence de ≈ 2 min/tour. Demande explicite d'Alex :
« pouvoir mesurer les coûts autant financier que temps de toutes les actions pertinentes ».

Shippé dans `<IMPL:src>` : merge `e86c817`, release **v0.11.0** (`120fc16`) — **tag user-driven
en attente** (I-3).

## Shipped artifacts

Dans `<IMPL:src>` (v0.11.0) :

- `scribe/trace.py` (MODIF) — **nœud `turn_result`** : la fin de tour, jusqu'ici rangée dans une
  métadonnée de session **écrasée à chaque tour** (donc perdue en multi-tours sauf pour le
  dernier), devient un nœud **horodaté, durable dès la capture**, portant `duration_ms`,
  `duration_api_ms`, `num_turns`, `total_cost_usd`, `usage`, `terminal_reason`. Socle **agnostique
  du rôle** : `meta` vide, aucun vocabulaire métier. `result_meta` conserve son comportement (elle
  alimente `notebook.py`). Ajout de `TraceNode.ts`.
- `scribe/store.py` (MODIF) — `load` relit la colonne `ts`, **écrite depuis toujours mais jamais
  relue** : sans elle, la durée d'un appel d'outil était incalculable. `TraceBuilder` reste **pur
  et déterministe** (aucune horloge) — le store est l'unique autorité du temps.
- `scribe/metrics.py` (NEW, module **pur**) — `summarize` projette une trace : par tour (durée,
  durée API, **temps hors API**, coût, tokens), par appel d'outil (durée par **appariement des
  horodatages** `tool_call`/`tool_result`), et totaux ; `render_metrics` en donne le rendu texte.
  Ne dispatche que sur les kinds du socle (premier consommateur conforme au follow-up « rendu
  agnostique par kind » de #7c).
- `metrics_report.py` (NEW) — `uv run python -m intreepid.metrics_report <trace.duckdb>
  [session_id]` : relit **n'importe quelle trace déjà écrite**. C'est ce qui rend l'instrumentation
  rétroactive. Une trace antérieure se replie sur la méta de session et **se déclare dégradée**.
- `demo_curator.py` (MODIF) — trace **persistante** (`traces/`, gitignorée) au lieu d'un
  `TemporaryDirectory` détruit à la sortie ; mesures affichées en fin de séance ; chemin de
  relecture imprimé **même en cas d'interruption** (`try/finally`).
- `scribe/notebook.py` (MODIF, 1 ligne) — `turn_result` ajouté aux kinds ignorés, sinon un
  commentaire parasite par tour dans tous les notebooks.
- Tests : `test_metrics.py` (8), `test_metrics_report.py` (4), + garde notebook et adaptations
  `test_scribe_{mapping,store}.py`. **129 déterministes verts**, pyright 0.

## Deviations from plan (if any)

- **Découverte à l'écriture du plan** : le `ts` était écrit en base mais **non relu**, et
  `TraceNode` n'avait pas ce champ — le design affirmait « il suffit de soustraire deux
  horodatages déjà présents », vrai en base, **faux en mémoire**. Design amendé (§4bis) avant le
  plan.
- **Advisor passe 1** (4 MUSTs) : j'affirmais **deux fois** que `demo_greffier` n'appelle pas de
  LLM — **faux** (`run_analysis`, ligne 26). Preuve réelle remplacée par une trace fabriquée avec
  des messages SDK factices, à coût nul. Plus : `ruff format` rouge sur mon propre code, une
  comparaison `datetime | None` qui aurait cassé pyright, et un bloc `main()` **copié de la
  branche #8** qui aurait fait passer un changement de comportement clandestin.
- **Advisor passe 2** (2 MUSTs) : dont un E501 **réintroduit par les corrections de la passe 1**.
  Elle a aussi obtenu, en appliquant le repli sur une trace réelle antérieure, le premier chiffre
  utile — sans dépenser un centime.
- **Revue finale** (1 MUST + 6 SHOULDs) : les **totaux** affichaient `0` là où la valeur est
  **inconnue** (session avortée avant le premier `ResultMessage` : « 0,0000 USD » à côté de 200 s
  réelles) ; et surtout `tool_ms` **ne mesure pas les outils** — l'orchestrateur relance une
  requête neuve à chaque tour, donc démarrage du CLI et amorçage du serveur MCP y tombent.
  Renommé `non_api_ms`, avec décomposition « outils mesurés » / « reste ».

## Validation

- **Gate déterministe** : `ruff format --check` / `ruff check` / `pyright` (standard) / `pytest` —
  verts par tâche (diff **stagé**, commit après revue) et sur `main` post-merge. 129 tests.
- **Revues** : 3 revues de tâche (conformité + qualité, toutes *Approved*) + revue finale
  whole-branch (opus).
- **Preuve réelle sans LLM** — chemin complet capture → DuckDB → `load` → `ts` → `summarize` :
  ```
  Session preuve [closed]
    bout en bout : 1.3s · coût total : 0.0310 USD · 1 tour(s)
    dont API : 5.0s · hors API (sur tours mesurés) : 3.0s
      dont outils mesurés : 1.2s · démarrage processus/amorçage : 1.8s
  ```
  Les 1,2 s ne sont pas déclarées par le SDK : elles viennent de la **soustraction de deux
  horodatages réellement écrits puis relus**.
- **Usage réel** (run curateur, brique #8) : 98 % du temps en génération, 9 939 tokens de sortie,
  0,42 $ pour un tour, cache d'entrée déjà pleinement exploité (43 781 tokens relus, 6 facturés).
  **La slice a rempli son office** : elle a tranché D3.

## Follow-ups

- **Afficher les tokens de cache** dans `metrics.py` : le rapport annonce « in 6 » et tait 58 000
  tokens de cache — image fausse de l'entrée, alors que la donnée est dans la trace.
- **Supprimer le résidu négatif** (« démarrage : −0,7 s ») : durées d'outil (horodatages
  orchestrateur) et temps hors-API (SDK) ne sont **pas commensurables**, la soustraction n'est pas
  valide.
- **Commentaire DST inexact** dans `metrics.py` : DuckDB stocke en **heure locale naïve**, donc
  les écarts d'une session à cheval sur un changement d'heure sont faussés de ±1 h — le docstring
  affirme le contraire. Corriger la phrase, ou stocker de l'UTC naïf (au prix d'une incohérence
  avec les traces existantes).
- Encodage console Windows : `PYTHONIOENCODING=utf-8` pour un rendu propre (préexistant, tout le
  projet écrit en français).
- Tests de `_sessions()` sur un fichier qui n'est pas une base greffier (`duckdb.CatalogException`
  brute).

## Temps

- **Engagé** : ≈ **4h11** sur les sessions du 04/08 (partagé avec la brique #8, non shippée).
- **Span git #9** : `8a6c614` → `120fc16`, dans une session continue du 04/08 au 05/08 ;
  span global #8+#9 ≈ **9h** (04/08 16:01 → 05/08 01:06), gonflé par les advisors en arrière-plan.

## Pointers

- Journal : `journal/2026-08-05-brique8-gate-rate-et-mesure.md` (porte aussi la brique #8 et son
  pointeur de reprise)
- Livraison : `<IMPL:src>` merge `e86c817`, release `120fc16`, `src/CHANGELOG.md [0.11.0]`,
  **tag `v0.11.0` en attente** (I-3)
- OPEN-QUESTIONS : **Q-0007** (résolue par cette slice), **Q-0023** (ajout) ; Q-0013 / Q-0004
  (raffinées)
- Incident : un `git switch` interrompu par un verrou Windows (`unable to write .git/index`) a
  laissé HEAD et l'arbre de travail désaccordés ; récupéré sans perte après vérification que les
  commits étaient intacts.
