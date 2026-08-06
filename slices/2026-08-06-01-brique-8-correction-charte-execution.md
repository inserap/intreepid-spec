# 2026-08-06-01-brique-8-correction-charte — Execution recap

## Scope

Brique #8 — **correction post-gate**. Le gate humain de #8 avait échoué sur la **forme** : questions du
niveau du transcript de référence, mais un tour illisible (« mur de texte »). Correction **par
retrait**, pas par mécanisme nouveau. S'y ajoute le solde des défauts de mesure de la brique #9, plus
ceux d'un audit demandé par Alex sur `v0.11.0`.

**La décision inscrite au journal §8 a été révisée au cadrage**, sur deux constats factuels :

1. Le transcript de référence pose **une question par tour** et n'en a demandé que **7 pour 36
   colonnes** — la réserve « une à la fois = beaucoup de tours » est réfutée par le transcript
   lui-même. La charte #8 prescrivait 1 à 3 questions, arbitrage construit contre une peur de latence
   que la donnée contredit. Le mur était la **somme de deux écarts** au transcript, pas un seul.
2. `orchestrator.py` activait le raisonnement étendu **du seul fait que la session était tracée**
   (`thinking=trace_to is not None`, né en brique #4). Les 141 s et 0,42 $ qui avaient tranché D3
   incluaient donc un coût qu'une exécution non tracée ne paierait pas : **la mesure portait sur un
   objet qu'elle altérait**.

Conséquence : le **brouillon incrémental** (accumulation par Python) est **différé** — Q-0023 reste
intacte, la fiche reste opaque pour Python. Ce que la slice livre à la place, c'est la mesure qui
permet de l'arbitrer.

Shippé dans `<IMPL:src>` : merge `931e010`, release **v0.12.0** (`671f25d`) — **tag user-driven en
attente** (I-3).

## Shipped artifacts

Dans `<IMPL:src>` (v0.12.0) :

- `agent/curator/charter.md` (MODIF, **158 → 138 lignes**, par retrait) — **une question par tour** ;
  la ligne « Tranché seul : » disparaît avec les **quatre rustines** qu'elle avait entraînées ; retour
  au contrat de sortie de v0.10.0 (`fiche_draft` **complet, tenu à jour, émis à chaque tour**,
  invisible car `_next_input` n'affiche que `message`, cumulatif par construction). **Conservé** :
  verrou par sa conséquence, les cinq éléments de la question, les quatre amorces type-level, « je ne
  sais pas » → piège documenté, résumé des pièges coûteux, gabarit sur dataset fictif, garde
  anti-spoiler. **Zéro ligne de logique** côté curateur (`turn.py`/`profile.py` : un docstring et un
  commentaire, rien d'autre).
- `agent/orchestrator.py` (MODIF) — **nœud `agent_turn`**, miroir exact de `human_turn` : la trace
  d'une conversation n'enregistrait **qu'une des deux voix** (le socle écarte les `TextBlock` à
  dessein, ce qui convient au one-shot mais pas à un rôle conversationnel où `on_result` ne se
  déclenche qu'à la validation). Multi-tours seulement, enregistré **avant** l'appel bloquant à
  `next_input`. Et `thinking` devient un **paramètre déclaré par l'appelant**, sans changement de
  comportement (`run_analysis` conserve `thinking=trace_to is not None`, `demo_curator` passe
  `thinking=True`).
- `scribe/store.py` (MODIF) — la trace **stockait de l'heure locale en croyant stocker de l'UTC** :
  `_now()` produisait bien de l'UTC, mais la colonne `TIMESTAMP` faisait convertir vers le fuseau de
  session **puis** dépouiller le fuseau (vérifié : inséré `06:26 UTC`, relu `08:26` naïf). On insère
  de l'**UTC naïf** ; `load` rattache `timezone.utc`. `TIMESTAMPTZ` **écarté sur mesure** (le client
  Python de DuckDB exige `pytz` pour le relire).
- `scribe/metrics.py` (MODIF, gros) — **union des intervalles** au lieu de la somme (4 appels
  parallèles sur ~2 s donnaient 8 000 ms) ; appariement par **parenté** au lieu d'un second dict ;
  fin de la soustraction entre **deux horloges non commensurables** ; `wall_ms` à `None` et non `0.0` ;
  un appel **réussi** ne s'affiche plus `[sans résultat]` ; `totals_partial` (cérémonie) et une
  branche morte retirés ; **tokens de cache** affichés ; **attribution de la sortie**
  (`prose_chars`/`thinking_chars`, en caractères, totaux de session).
- `demo_curator.py` (MODIF) — la fin de séance **ne se tait jamais** : bloc extrait en fonction qui
  **retourne du texte** (donc testable sans agent), appelée **dans** le `finally`, enveloppée pour ne
  pas avaler l'interruption clavier.
- `scribe/notebook.py` (MODIF, 1 ligne) — `agent_turn` **et** `human_turn` ignorés (ce dernier
  produisait un commentaire parasite par tour depuis v0.10.0).
- `demo/brique-8-curateur-naturel.md` + `demo/README.md` (MODIF) — runbook aligné : relevés « une
  question par tour », nombre de tours vs référence, ligne d'attribution ; trois résidus de l'ancien
  contrat corrigés (dont un `Plan B` qui proposait comme repli le comportement livré).
- Tests : `test_demo_curator.py` (NEW), `test_curator_charter.py` (+5), `test_orchestrator.py` (+4),
  `test_metrics.py` (+12), `test_scribe_store.py`, `test_notebook.py`. **166 déterministes verts**,
  pyright 0.

## Deviations from plan (if any)

- **La décision de reprise a été révisée avant l'implémentation** (cf. Scope). Le plan livré n'est
  pas celui que le journal §8 annonçait.
- **4 passes d'advisor : 9 MUSTs, 21 SHOULDs, tous appliqués.** La progression est le fait notable —
  passe 2 : 3 MUSTs dont **deux créés par les corrections de la passe 1** ; passe 3 : 3 MUSTs dont
  **un créé par la passe 2** ; passe 4 : SHIP, mais un SHOULD qui était une **contradiction créée par
  la passe 3** (une section interdisait ce qu'une étape ajoutée par cette même passe demandait — un
  sous-agent obéissant aurait sauté l'étape).
- **Trois défauts valaient les quatre passes** : un test de charte qui aurait échoué *après* le
  correctif (son interdiction `"tranche seul"` matchait le texte de remplacement que le plan écrivait
  lui-même) ; un `NameError` qui aurait empêché `metrics.py` de s'importer ; et une cascade de numéros
  de ligne périmés — la tâche 1 retire 3 lignes, la tâche 4 en ajoute 30. Le plan repère désormais par
  **ancres verbatim**.
- **Audit de `v0.11.0`** (demandé par Alex, doute « château de cartes ») : verdict **DÉFAUTS
  MINEURS**, architecture saine, ratio tests/code 1:1, aucune abstraction prématurée. Mais **tous**
  les défauts dans une seule couche — l'agrégation et le rendu des totaux, **la seule sans aucun
  test**. Un troisième défaut de la même famille trouvé (le double-comptage). Pas de revert : le
  « château de cartes » qu'Alex avait nommé au journal visait la **charte**, que cette slice démonte.
- **Deux fois le correctif proposé par un reviewer était faux, son diagnostic juste** : (a) regrouper
  les appels « partageant le même `ts` » — or `_insert` appelle `_now()` **par nœud**, les
  horodatages ne sont jamais égaux ; seule l'union d'intervalles corrige ; (b) `is_error=None` traité
  comme « non apparié » alors que c'est le **succès** normal (le SDK ne pose le champ que sur erreur).
  Le (b) **est passé en production** et le gate l'a exposé — les six appels réussis s'affichaient
  `[sans résultat]`. Corrigé (`e745434`), avec le test qui manquait.
- **L'implémenteur de T7 a rendu `DONE_WITH_CONCERNS` à juste titre** : il a trouvé un résidu que le
  plan **et les quatre passes** avaient manqué — la consigne du **premier tour** disait encore
  « enchaîne directement sur *les questions* » (pluriel), trois lignes au-dessus de « une seule
  question ». C'est le tour que le gate juge.

## Validation

- **Gate déterministe** : `ruff format --check` / `ruff check` / `pyright` (standard) / `pytest` —
  verts par tâche (diff **stagé**, commit après revue) et sur `main` post-merge. **166 tests.**
- **Revues** : 9 revues de tâche (conformité + qualité, toutes *Approved*) + revue finale
  whole-branch — *Changes requested* → 2 MUSTs et 6 SHOULDs appliqués (`8cd7c33`). La revue de T4 a
  **éprouvé** l'algorithme d'union : 14 cas limites à la main + 3 000 cas aléatoires contre un oracle
  indépendant (écart max 0,0 ms), et a prouvé la discriminance du test en remontant l'ancienne somme.
- **Gate humain PASSÉ** — OFROU brut (267 761 lignes, 36 colonnes), 4 questions / 5 tours d'agent /
  4 tours humains, fiche 36 colonnes validée (`60a7d3bc6058…`). Critères a (premier tour au niveau),
  b (**zéro consigne de style** — réponses `1a/2a/3b/4a/o`), c, e, f, g : tous passés. Alex a
  **contredit le penchant** en Q3 ; l'agent a verrouillé « contre mon penchant » et inscrit son
  observation comme **piège non résolu** au lieu de l'abandonner.
- **Deux trouvailles absentes de v0.10.0** : `AccidentSeverityCategory` est **ordinale à l'envers**
  (`as1` = le plus grave, un `max` numérique inverse la gravité) et **aucun comptage de victimes
  n'existe** — on ne peut jamais sommer des victimes.

## Mesures obtenues (la vraie sortie de la slice)

```
bout en bout 734.4s · 1.8033 USD · 5 tours · dont API 460.6s
#1..#5 : 90.0 / 97.4 / 88.5 / 101.7 / 90.3 s · out 6193 → 8494 tokens
Sortie écrite : tour d'agent 69 628 car. (prose + bloc de métadonnées) · thinking 9 829 car.
```

- **79 % de ce que l'agent écrit est le brouillon** (55 544 car. sur 69 628). Prose : 2 130 → 3 367
  car./tour, contre ~700 au transcript de référence. **Le levier de coût est le brouillon, pas la
  charte** — la décision différée a désormais son chiffre.
- **Deux prédictions réfutées** : « une question à la fois allonge la séance » (4 questions / 5 tours
  contre 7 / 8) et « la latence par tour croîtra » (quasi plate). La seconde était **la mienne**, et
  je l'avais fait écrire au runbook.
- **Le cache d'entrée ne tient pas en multi-tours** : lectures plafonnées à 14 137 dès le tour 3,
  créations croissantes (10 014 → 16 122 → 23 327). `build_prompt` sérialise tout l'historique en
  **un** message, donc le préfixe cacheable s'arrête à la charte. → **Q-0024**.
- **Deux fois j'ai annoncé à Alex un ratio prose/thinking inventé** (« le thinking pèse 7× la
  prose »), calculé sur une valeur de prose que j'avais fabriquée faute de nœud `agent_turn` dans la
  vieille trace. Le run réel dit l'inverse : la sortie de l'agent domine ~7×.

## Follow-ups

- **Q-0024** — primitive du SDK pour un rôle conversationnel : `query()` est documenté *stateless*,
  `ClaudeSDKClient` l'est pour les « REPL-like interfaces ». Touche la boucle d'ADR-0009 → mérite son
  propre cycle.
- **Brouillon incrémental** (Q-0023) — 79 % de la sortie, chiffre en main.
- **Longueur des questions** — commencer par le **gabarit** : c'est l'exemple qui porte la longueur,
  pas la consigne. Leviers : « trois à quatre phrases », indice contraire conditionnel, un seul
  mécanisme.
- **Nom complet de l'outil MCP dans la charte** — supprime les 4 appels `ToolSearch` (symptôme de
  Q-0019, sans refermer le trou).
- Mineurs différés de la revue finale : flottants epoch vs `timedelta` (~72 ns, casserait un futur
  invariant « union ≤ total ») ; init morte `debut_courant = 0.0` ; décomposition « attente humaine »
  (`wall − Σ duration_ms`, autre horloge) ; `charter.md` « le VERROU des point**s** » — **à ne pas
  corriger seul**, le pluriel est aligné sur le gabarit qui ouvre sur deux points.
- **Brique #9 n'a pas de runbook de démo**, alors que la convention projet l'exige pour toute slice
  démontrable. Constat à consigner, pas à rattraper.
- ADR-0009 `Proposed` → `Accepted` : toujours bloqué par la friction Q-0017.

## Temps

- **Engagé** : ≈ **0h45** (instrument). Chiffre honnête mais trompeur seul — le compteur approxime la
  **présence humaine**, et la session a été dominée par de longues exécutions autonomes (12
  sous-agents, dont un advisor à 21 min). Alex n'était pas au clavier pendant.
- **Span session** : 05/08 15:52 → 06/08 09:30 ≈ **17h40**. **Span git de la slice** : `9c29105`
  (05/08 22:28) → `671f25d` (06/08 09:28) ≈ **11h**.

## Pointers

- Journal : `journal/2026-08-06-brique8-correction-et-mesure-arbitrable.md`
- Matériel : `research/2026-08-06-curateur-gate-materiel.md` (**pendant du matériel de #7c** —
  transcript complet de la séance, mesures, distinction cible/base atteinte) ;
  `research/2026-08-06-RoadTrafficAccidentLocations.fiche.v2.yaml` (fiche du gate, 301 lignes) ;
  `research/2026-08-04-curateur-gate-humain-materiel.md` (la cible, référence de concision)
- Livraison : `<IMPL:src>` merge `931e010`, release `671f25d`, `src/CHANGELOG.md [0.12.0]`,
  **tag `v0.12.0` en attente** (I-3)
- ADR : `decisions/0009-architecture-execution-agents.md` (`Proposed` — sa boucle est désormais
  questionnée par la preuve, cf. Q-0024)
- OPEN-QUESTIONS : **Q-0024** (ajout), **Q-0022** (résolue) ; Q-0023 / Q-0013 / Q-0019 / Q-0010 /
  Q-0004 (raffinées)
- Amont : `journal/2026-08-05-brique8-gate-rate-et-mesure.md` §8 (le pointeur de reprise, dont la
  décision a été révisée)
