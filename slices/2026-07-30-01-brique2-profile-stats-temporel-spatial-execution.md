# 2026-07-30-01-brique2-profile-stats-temporel-spatial — Execution recap

## Scope

Deuxième brique livrable d'`intreepid` (walking skeleton v0.2) : compléter l'outil MCP
read-only `profile_stats` aux **4 types de colonnes** de l'overview §4.2 — ajout des types
**temporel** (`_temporal`) et **spatial** (`_spatial`, via l'extension DuckDB `spatial`) —
et solder **2 dettes** de la brique #1 (`skewness` manquant dans `_numeric` ; fuite de
dossier temporaire dans `bounds.py`). Le LLM ne reçoit que des agrégats (P1/P2) ; la
connexion reste read-only (P3). Shippé dans `<IMPL:src>`, mergé sur `main` (`e1297ac`),
taggé `v0.3.0`.

## Shipped artifacts

Dans `<IMPL:src>` (package `intreepid`) :
- `mcp_server/profile_stats.py` : `_numeric` + `skewness` ; **`_temporal`** (bornes,
  `series_gaps_months`, `seasonality_by_month`, `volume_by_year` — clés str) ; **`_spatial`**
  (noyau type-générique : `geometry_types`, `srid_declared` depuis la fiche, `extent` via
  `ST_XMin/XMax/YMin/YMax`, `out_of_envelope_rate` = null-island + hors bbox CH `CH_BBOX`,
  `null/empty/invalid/has_z_rate`, `max_length/max_area` ; `nearest_neighbor` + `density_by_cell`
  = `_DEFERRED` « prévu … H3 anti-MAUP ») ; message explicite « prévu / non implémenté »
  pour tout type non couvert ; garde `n==0`.
- `mcp_server/bounds.py` : `open_readonly` → `@contextlib.contextmanager` (`TemporaryDirectory`,
  `INSTALL`/`LOAD spatial`, `con.close()` avant nettoyage). `mcp_server/server.py` : `ExitStack`
  + `atexit` (connexion long-lived).
- `fixtures/build_fixture.py` : colonnes `date` (make_date), `geom` (`ST_Point`, GeoParquet WKB),
  `canton` ; anomalies plantées (années 2018-2019 retirées → trou 24 mois + rupture de volume ;
  null-island `(0,0)` + points hors-CH E/N inversés) ; `ground_truth` recalculé depuis le
  **Parquet relu**. `fixtures/accidents.fiche.yaml` + `fixtures/ground_truth.yaml` régénérés.
- `agent/charter.md` : paragraphe générique blocs temporel/spatial (fait qualité-donnée vs
  refus causal), **sans valeur de fixture** (Q-0004).
- `tests/` : golden `_temporal`/`_spatial`/skewness + message « prévu » ; `test_bounds` (context
  manager + non-fuite) ; oracle `test_agent_eval` (4 faits ≥4/5 + 2 faux patterns ==0).
- `demo/brique-2-temps-et-espace.md` (runbook, sorties réelles) + `demo.py` (QUESTION alignée
  oracle) + `demo/README.md` (tableau). `CHANGELOG.md` `[0.3.0]`, `pyproject`/`uv.lock` 0.3.0.

## Deviations from plan (if any)

- **Ordre ship inversé** (leçon) : merge + tag faits **avant** la démo et le Q&A, d'où un
  **retag `v0.3.0`** sur HEAD et des commits post-tag (runbook `5f7f1b2`, fix Q-0004 `7fb866d`).
  Corrigé en convention workflow projet (`CLAUDE.md`) : démo avant merge, CHANGELOG/tag en dernier.
- **Fix Q-0004 post-démo** : le champ `note` « À DESSEIN… 999 » ajouté à la fiche (fix M-1 de la
  Task 3) fuyait à l'agent via `describe` → retiré de la fiche, remis en commentaire dev ; oracle
  **re-validé vert** sans le spoiler.
- `demo.py` adapté au context manager (Task 2, collatéral nécessaire au gate pyright).

## Validation

- **Tests :** 23 déterministes verts (`uv run pytest -m "not agent"`) ; oracle agent
  `1 passed` (N=5, ~360 s) — sentinelle/concentration/temporel/spatial ≥4/5, faux patterns
  (gravité×mois ; volume→sûreté) **0** ; oracle **re-lancé vert** après retrait du spoiler.
- **Gate qualité :** `ruff format`/`ruff check` verts ; `pyright standard` 0 erreur.
- **Reviews :** revue par tâche (spec + qualité) sur les 6 tâches — fixes Important sur T3
  (commentaire trompeur), T4 (assertion trous ancrée sur ground_truth), T5 (garde `n==0` + doc
  emprise points/polygones), T6 (matcher spatial resserré, re-oracle vert) ; **2 passes advisor**
  sur le plan (NEEDS_CHANGES → SHIP) ; revue finale de branche **Ready to merge: Yes** (0 bloquant).

## Follow-ups

- **OPEN-QUESTIONS** : **Q-0015** (politique de curation de la fiche : inférence de type,
  sensibilité/k-anonymat, hygiène anti-spoiler) ; Q-0004 recentrée sur le schéma ; Q-0008
  (échantillon-drill-down). Q-0014 (verdict) toujours ouverte, non traitée.
- **Grooming Q-0004** : sortir les fils « biographie/fait-vs-insight » et « frontière charte↔fiche »
  vers des questions dédiées (Q-0004 encore trop chargée).
- **Gouvernance** : instruire une **revue d'usage de standards depuis `methods/spec`** (pull) pour
  arbitrer la promotion des conventions projet-local ; porter la convention démo-gate/CHANGELOG-tag
  comme candidat.
- **Dette code (triage revue finale)** : garde `n==0` seulement dans `_spatial` — `_numeric`/
  `_categorical`/`_temporal` partagent le gap (cas dégénéré hors-contrat) ; `CH_BBOX` dupliquée
  par valeur build/test/profile ; densité/NN spatiale = brique ultérieure (H3 anti-MAUP).
- **Q-0002** (inchangée, LE verrou) : valeur métier à valider sur une vraie question / vraie personne.

## Pointers

- Journal : `journal/2026-07-30-brique2-profile-stats-temporel-spatial.md`
- Livraison : `<IMPL:src>` `main` merge `e1297ac`, tag `v0.3.0`, `src/CHANGELOG.md` `[0.3.0]`
- Démo : `<IMPL:src>/demo/brique-2-temps-et-espace.md`
- Brique #1 : `slices/2026-07-28-01-brique1-profile-stats-execution.md`
