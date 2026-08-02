# 2026-08-02-03-brique-7b-profil-brut — Execution recap

## Scope

Deuxième sous-brique de #7, **couche M d'ADR-0009** : profiler un dataset **non encore fiché**
(ingestion) via MCP, avec un **type candidat** inféré par colonne (Q-0015a). Découpage
**walking-skeleton** décidé en séance : le plan initial groupait « B (trace cycle-ouvert) + C (MCP) »
en #7b, mais en détaillant le code il est apparu que la couche **B n'a aucun consommateur observable
avant le curateur D** — seul C produit un livrable démontrable en propre. #7b réduit à **C seule** ;
B rejoint D en #7c (construite avec son consommateur). Rejoint le découpage du design §4.

Deux tâches TDD (C1 fonction, C2 outil MCP), plan porté à **SHIP en 2 passes advisor**. Shippé,
mergé `main` (`fee4df3`), release **v0.9.0** (`e3f632f`, tag user-driven).

## Shipped artifacts

Dans `<IMPL:src>` (v0.9.0) :
- `intreepid/mcp_server/profiling_raw.py` (NEW, **agnostique au domaine**) :
  - `infer_type(con, table, col)` — heuristique SQL type → `categorical`/`numeric`/`temporal`/
    `spatial` ; un numérique de **faible cardinalité** (`≤ CARD_CATEGORICAL_MAX = 25`) = **code
    déguisé** (cf. sentinelle `999`).
  - `profile_raw(con, table)` — **réutilise** les profileurs de `profile_stats.py` (DRY, un seul
    `DESCRIBE` via `_schema`), marque chaque profil `type_inferred: True`.
- `intreepid/mcp_server/server.py` (MODIF, **additif**) : outil MCP `profile_raw(dataset_path)` —
  ouverture par-appel (`open_readonly`, CM court, P3), **garde anti-traversée** (`.parquet` existant
  sous `DATA_DIR` + stem sanitisé), sortie enveloppée **`untrusted_data`** (Q-0008). Bootstrap
  mono-fiche + 5 outils fichés **intacts**.
- Runbook `demo/brique-7b-profil-brut.md` + ligne `demo/README.md`. Tests : `test_profiling_raw.py`
  (golden inférence sur parquet synthétique + fixture réelle) + 2 tests serveur (outil MCP + rejet de
  traversée). **94 déterministes verts**.

## Deviations from plan (if any)

- **Périmètre recoupé en séance** : #7b = **M seule** (au lieu de B+C). B (actor + open/append/seal)
  différée à #7c — anti-cathédrale (ne pas figer les signatures de la trace cycle-ouvert avant que la
  boucle multi-tours de D ne les consomme).
- **Corrections advisor (3 MUSTs)** matérialisées inline au plan avant exécution : cast `::INTEGER`
  (range()→BIGINT sinon `DATE+BIGINT` plante) ; garde `is_file()` ; sanitisation du nom de table
  (stem `mon-dataset` sinon rejeté par `isalnum`). + refactor `_schema` (un seul DESCRIBE).
- `pytest.raises(Exception, match="dataset_path")` (ruff B017) — plus précis que le brief.

## Validation

- **Gate déterministe** : `94 passed`, ruff + pyright standard 0 erreur — après chaque tâche et sur
  `main` post-merge.
- **Revues** : par tâche (spec + qualité) sur diff **stagé**, Approved ; **revue finale whole-branch
  (opus) : Ready to merge** — garde de sécurité solide (3 conditions, chemins `.resolve()`,
  sanitisation + double filet `open_readonly`), non-régression serveur, DRY/agnostique, P2/P3.
- **Démo (gate humain)** : `profile_raw` sur la vraie donnée OFROU **brute** (`RoadTrafficAccident
  Locations.parquet`, 267 761 lignes, 36 colonnes, jamais fichée) — types candidats sensés (codes par
  faible cardinalité ; coordonnées E/N → numeric ; `AccidentUID` card 267 761 = signal « identifiant,
  pas catégorie » pour le curateur). Déterministe, sans LLM. **Validée par Alex.**

## Follow-ups

- **Q-0015** : facette (a) inférence de type **livrée** ; restent (b) sensibilité/k-anon, (c)
  anti-spoiler — au curateur #7c.
- SHOULDs advisor différés (non-bloquants) : docstring `infer_type` (appel répété O(n×DESCRIBE)) ;
  collision théorique de noms de table par sanitisation ; harmonisation d'imports de test.
- **#7c** : le curateur consommera `profile_raw` (profil du dataset non-fiché) puis affinera les
  types candidats avec l'humain (interview maïeutique).

## Temps

- **Engagé** : part de la session (14:12) ≈ **1h32** engagé au total (avec #7a) ; #7b couvre le plan
  + 2 passes advisor + exécution (span git exécution ~22:08→22:56). Advisors en arrière-plan (dont un
  très long) gonflent le span sans compter comme engagé.

## Pointers

- Journal : `journal/2026-08-02-brique7ab-socle-et-profil-brut.md`
- ADR : `decisions/0009-architecture-execution-agents.md` (Proposed)
- Livraison : `<IMPL:src>` merge `fee4df3`, release `e3f632f`, tag `v0.9.0`, `src/CHANGELOG.md [0.9.0]`
- Démo : `<IMPL:src>/demo/brique-7b-profil-brut.md`
- OPEN-QUESTIONS : Q-0015 / Q-0004 (raffinées)
