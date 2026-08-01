# 2026-08-01-01-brique5-notebook-session-reelle — Execution recap

## Scope

Cinquième brique livrable d'`intreepid` (palier A) : **le produit de session** — l'analyste
tourne sur la **vraie donnée OFROU** (267 761 lignes) via les outils MCP existants (**zéro
nouvel outil**), capturé par le greffier, et un **notebook Quarto déterministe** est généré
depuis la trace. Livre l'item v1 #6 (notebook de sortie, overview §10) et **valide la v1 de
bout en bout sur du réel** — substitut *contrôlé* à Q-0002 (pas encore de destinataire métier).
Exécution depuis le plan SHIP du cadrage 2026-08-01 (design + plan approuvés par 3 passes
advisor, **non refaits**). Shippé dans `<IMPL:src>`, mergé sur `main` (merge `a272884`),
release `v0.6.0` (commit `16e2c2f`, **tag annoté user-instructed**).

## Shipped artifacts

Dans `<IMPL:src>` (v0.6.0) :
- `intreepid/scribe/notebook.py` (NEW, **agnostique au domaine**) : `to_quarto(trace)` —
  fonction **pure et totale** projetant une `SessionTrace` figée en `.qmd` déterministe
  (front-matter HTML toc/code-fold/embed-resources ; appels d'outils en blocs `{.json}` +
  résultats agrégés ; observations en **callouts typés** `fait`→note / `hypothèse`→warning /
  `refusé`→caution avec IDs ; pied `meta`). `render_html` best-effort (CLI `quarto` absent →
  `.qmd` seul).
- **Fiche auto-descriptive** + serveur pointé par `INTREEPID_FICHE` : `catalog/accidents_seed.fiche.yaml`
  (fixture migrée + dataset renommé `accidents_route`→`accidents_seed`) et
  `catalog/accidents_route.fiche.yaml` (réelle) portent `data:` + `exposures.table` en chemins
  **relatifs-à-la-fiche** ; `server.py` résout depuis `FICHE.parent` (défaut = fixture).
  `concentration.py` : `exposure_model` = nom de fichier.
- **Ingestion réelle** (`prepare/`, scripts trackés, Parquet gitignorés) : `accidents_route.py`
  (projection OFROU brut `data/raw/…parquet` → analysis-ready, `geom` LV95 + `date`, aucune
  anomalie) ; `canton_population.py` (exposition = population cantonale BFS, proxy grossier
  assumé, réserve gravée dans la fiche).
- Driver `intreepid/demo_notebook.py` (NEW) + runbook `demo/brique-5-notebook.md` (NEW, sorties
  réelles) + ligne `demo/README.md`. Tests : `test_notebook` (golden `to_quarto`), `test_prepare`,
  `test_catalog`. **51→70 déterministes** verts.
- Ripple contrôlé du renommage : `conftest.py`, `test_server`, `test_concentration` (8×),
  `test_fixture`, `test_agent_eval`, `test_scribe_agent`, `intreepid/demo.py`, `build_fixture.py`.

## Deviations from plan (if any)

- **Source raw relocalisée en séance** (feedback Alex, Task 3) : la conversion CSV→Parquet est
  un **job ETL/FME amont, hors périmètre** de notre solution ; on consomme directement le
  Parquet raw sous `data/raw/`. `SRC` de `prepare/accidents_route.py` **et** `build_fixture.py`
  repointés ; le parquet racine bâtard supprimé. Fixture inchangée (mêmes bytes relocalisés).
- **Correctif console UTF-8** (`demo_notebook.py`) : le run réel (gate humain) a révélé un crash
  Windows cp1252 à l'impression du verdict (`≈`/`±` → `UnicodeEncodeError`). Fix :
  `sys.stdout.reconfigure(encoding="utf-8", errors="replace")`. Bug **hors portée de la fixture**
  (elle ne produit pas ces caractères) — valeur de la validation sur du réel.
- **Discipline commit projet** appliquée sur les 4 tâches : implémenteur *stage seul* → revue
  de tâche sur diff **stagé** → commit contrôleur **après Approved** (pas le flux commit-first du skill).

## Validation

- **Gate déterministe** : `70 passed` (`uv run pytest -m "not agent"`), ruff format/check + pyright
  standard 0 erreur — vérifié après chaque tâche et après le bump.
- **Revues** : revue par tâche (spec + qualité) sur diff stagé, 4/4 Approved ; **revue finale
  whole-branch sur `opus` : Ready to merge** (0 Critical/Important ; seams cross-tâches, P2/P3,
  défaut=fixture, secrets/PII, agnosticité tous vérifiés).
- **Démo (gate humain)** : run réel `opus` sur 267 761 lignes — **$0,19, 6 tours**. Verdict
  honnête sur donnée **propre** (posture P6, aucune anomalie hallucinée) ; **volume ≠ excès sur
  du réel** (BE sur-concentré vs population, std_excess 32,76 ; ZH plus gros comptage mais
  expliqué par l'exposition, +1279) ; **refus causal** motivé (« BE plus dangereux »). Notebook
  rendu en HTML via `quarto render` (Posit.Quarto 1.10.18) — validé visuellement.
- **Non-régression** : fixture = dataset par défaut ; suite existante inchangée.
- **Scan de domaine** : `notebook.py` sans terme métier (agnostique).

## Follow-ups

- **Q-0016** (raffiné en séance) : modèle nul **par défaut = abstention** (au lieu d'uniforme,
  probablement faux pour unités inégales) ; uniforme **opt-in** dans la fiche → **slice dédiée**
  (correction de `concentration.py`, hors brique #5). Exposition = proxy population, trafic réel = futur.
- **Q-0004** : la dette de charte (exemple `999`, tuning) est restée **inerte** sur le réel propre
  → pas de dé-tuning nécessaire ici ; matière pour l'extraction charte↔fiche future.
- **Cosmétique / v2** : `demo.py` nom de vue `accidents_route` (≠ dataset `accidents_seed`) ;
  bruit `ToolSearch` dans la trace (filtre au rendu) ; `demo_notebook.py` `reconfigure` suppose
  un vrai `TextIO` ; tables markdown jolies vs blocs `{.json}` ; rejouabilité-SQL vraie.
- **Q-0002** (inchangée, LE verrou) : vraie question métier / destinataire réel.
- **Promotion** : les 3 conventions workflow projet-local (démo-gate ; commit-dernier ;
  récap-checkpoint) restent candidates — arbitrage par revue d'usage de standards depuis `methods/spec`.

## Extensions différées (paliers B/C — pour cadrer la prochaine brique)

La brique #5 a shippé le **palier A** d'une décomposition en 3 (≈ 1/3). Les paliers B et C,
définis au cadrage (dans le design doc, éphémère supprimé), sont **différés** — consignés ici
pour alimenter le cadrage de la prochaine brique. **Ce n'était PAS un tout cohérent** : B et C
sont **deux axes distincts** ; la prochaine brique en choisira **un** (ou un sous-ensemble).

- **Palier B — profondeur anti-MAUP** : colonne **H3** pré-calculée + **1 nouvel outil MCP** de
  robustesse multi-résolution (la concentration tient-elle à H3 res 7→10 ? `esda.smaup`). Le
  différenciateur « anti-MAUP discipline » (personne ne l'outille). +dépendance `h3`/`esda`.
  Déjà tracé (épars) : **Q-0009** (roadmap rigueur) ; `research/2026-07-29-etat-de-lart-github.md`
  §2 (`esda.smaup`, `overnin/h3-mcp`) ; recaps brique #2/#3 (densité/NN spatiale différées).
- **Palier C — vitrine multi-tours complète** : B + **boucle de conversation multi-tours** (vrai
  arbre branchu, branches mortes réelles) + **enrichissement SITG Genève** (vitesses / écoles /
  OCSTAT population). Le plus proche de la vision (overview §8/§10). Déjà tracé (épars) :
  multi-tours → **Q-0002 / Q-0003** + recap brique #4 ; enrichissement →
  `research/2026-08-01-donnees-suisses-et-quarto.md` (faisabilité) + **Q-0011**.

Rappel du verrou : **Q-0002** (vraie question métier / destinataire) conditionne surtout le
palier C (une vraie session multi-tours n'a de sens qu'avec une vraie question).

## Temps

- **Engagé** : le bloc d'activité `2026-07-31 21:34` (engagé **2h12**, span 12h57 jusqu'au
  2026-08-01) couvre le session-end du cadrage **+** toute l'implémentation subagent-driven ;
  l'implémentation en est la majeure partie. Span git `src` : merge+release du 2026-08-01.

## Pointers

- Journal : `journal/2026-08-01-brique5-notebook-implementation.md`
- Cadrage amont : `journal/2026-08-01-brique5-notebook-cadrage.md` ; veille
  `research/2026-08-01-donnees-suisses-et-quarto.md`
- Livraison : `<IMPL:src>` `main` merge `a272884`, release `16e2c2f`, tag `v0.6.0`,
  `src/CHANGELOG.md [0.6.0]`
- Démo : `<IMPL:src>/demo/brique-5-notebook.md`
- OPEN-QUESTIONS : Q-0016 (raffinée), Q-0004/Q-0002 (touchées)
