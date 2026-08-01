# 2026-08-02-01-brique6-robustesse-echelle-h3 — Execution recap

## Scope

Sixième brique livrable d'`intreepid` : **robustesse d'échelle spatiale** — l'outil MCP
`spatial_scale_robustness` agrège les points d'un dataset en cellules Uber **H3** à plusieurs
résolutions `[6,7,8]` et teste si une concentration (au-delà d'une **exposition population réelle**,
STATPOP hectare) **survit au changement de maille** : verdict `robuste`/`fragile`/`absente` + pic
descriptif + caveats d'honnêteté. Première **vraie jointure spatiale** du projet ; volume ≠ excès
porté au grain spatial (Q-0009). Inclut le **fix Q-0016** (`concentration_test` : abstention par
défaut). Exécution subagent-driven depuis le plan SHIP du cadrage 2026-08-01 (design + plan
approuvés par 4 passes advisor, **non refaits**). Shippé dans `<IMPL:src>`, mergé sur `main`
(merge `5cea2d9`), release `v0.7.0` (commit `92f2b07`, **tag user-driven**).

## Shipped artifacts

Dans `<IMPL:src>` (v0.7.0) :
- `intreepid/mcp_server/scale_robustness.py` (NEW, **agnostique au domaine**) : `spatial_col_of`,
  `h3_counts` (reprojection SRID→WGS84 en SQL DuckDB + `h3-py` v4), `h3_exposure` (grille→H3 par
  centroïde des mailles), `split_cells` (testables vs **non-peuplées**, Q-0016), entrypoint
  `spatial_scale_robustness` (null multinomial par résolution ∝ exposition, verdict, caveats
  **génériques**).
- `intreepid/mcp_server/concentration.py` (MODIF) : **fix Q-0016** — sans exposition déclarée ni
  opt-in uniforme explicite → **abstention** (`exposure_model: "abstention"`), fin du null uniforme
  silencieux ; docstring de module alignée.
- `intreepid/mcp_server/nullmodel.py` (MODIF) : `std_excess` **promu public** (source unique),
  importé par `concentration.py` et `scale_robustness.py` — dédup.
- `intreepid/mcp_server/catalog.py` (MODIF) : `load_referenced_fiche` (résout `fiche: <nom>`, garde
  anti-traversée) ; `server.py` (MODIF) : outil MCP `spatial_scale_robustness`.
- `intreepid/agent/runner.py` + `charter.md` (MODIF) : l'analyste **peut** appeler l'outil (allowlist
  + paragraphe de charte, honnêteté préservée) — **révélé manquant par le gate démo**.
- **Exposition population réelle** (`prepare/`, scripts trackés, Parquet gitignorés) :
  `prepare/statpop_population.py` (STATPOP hectare BFS 2024, 347 736 mailles, k-anonymat amont, lit
  le **raw parquet** transcodé) + fiche curée `catalog/statpop_population.fiche.yaml` (bloc `grid`).
  `catalog/accidents_route.fiche.yaml` : `exposures.geom` (clé = **colonne de jointure**) référence
  la fiche STATPOP.
- Fixtures synthétiques : `fixtures/build_fixture.py` (+`spatial_seed`/`population_seed` parquets),
  `catalog/{spatial_seed,population_seed}.fiche.yaml`. Dép nouvelle : **`h3`**.
- Driver `intreepid/demo_scale_robustness.py` + runbook `demo/brique-6-robustesse-echelle.md`
  (sorties réelles) + ligne `demo/README.md`. Tests : `test_scale_robustness.py` (golden),
  `test_concentration.py` (abstention), `test_server.py` (smoke). **84 déterministes verts**.

## Deviations from plan (if any)

- **`std_excess` promu dans `nullmodel.py`** au lieu d'être re-dupliqué dans `scale_robustness.py`
  (le plan dupliquait un helper identique à `concentration.py`) — décision Alex, dédup à la racine.
- **Caveats génériques** : `_CAVEATS` réécrit sans terme métier (« population »/« accidents » →
  « l'exposition déclarée ») ; le domaine vit dans la note de fiche. Docstring `h3_exposure`
  généralisée. Direction confirmée par Alex (design §10).
- **Raw STATPOP transcodé en live** (CSV→parquet fidèle, hors périmètre = ETL amont) ; le script
  tracké `prepare/` dérive le `prepared` depuis ce raw parquet (modèle brique #5). Colonne réelle
  `BBTOT` (pas `B24BTOT`), millésime 2024.
- **Clé d'exposition = colonne de jointure** (`geom`), après une fausse piste (`statpop_hectare`)
  corrigée : la clé descriptive cassait la résolution. Convention gravée ; multi-exposition
  différée (Q-0016).
- **Fix hors-plan (gate démo)** : allowlist runner + charte (l'outil était injoignable par l'agent).
- **Tests durcis post-revue** : verdict multi-résolution (mécanisme, pas label observé) + check P2
  réel (non-vacux) — discutés avec Alex.

## Validation

- **Gate déterministe** : `84 passed` (`uv run pytest -m "not agent"`), ruff format/check + pyright
  standard 0 erreur — vérifié après chaque tâche et sur `main` post-merge.
- **Revues** : revue par tâche (spec + qualité) sur diff **stagé**, 11/11 Approved ; **revue finale
  whole-branch sur `opus` : Ready to merge** (0 Critical/Important ; invariants data-agnostic/P2/P3/
  Q-0016/std_excess/déterminisme tous ✅ ; intégration tracée de bout en bout).
- **Démo (gate humain)** : run réel `opus` (accidents OFROU × STATPOP) — l'analyste appelle
  `spatial_scale_robustness`, verdict **`robuste`** ; smoke direct non-agent **5,3 s**, part
  `unpopulated` **4,18 %** à res 8. Le gate a **révélé** le bug d'allowlist (invisible aux 84 tests)
  puis la dérive d'isolation P3 (Q-0019).
- **Scan de domaine** : `scale_robustness.py`/`concentration.py`/`catalog.py`/`nullmodel.py` sans
  terme métier (`grep` domaine vide).

## Follow-ups

- **Q-0019** (nouvelle) : dérive d'isolation P3 du runner — méta-outils CLI récents hors
  `disallowed_tools` ; slice sécurité dédiée.
- **Q-0016** : abstention + exposition spatiale réelle **livrées** ; restent exposition **trafic**
  réelle + **plusieurs expositions par colonne de jointure** (dict→liste + sélection un-vs-tous).
- **Q-0009** : robustesse multi-résolution **livrée** ; différés Gi\*/LISA+FDR local, méthodes
  **réseau** (NKDE — méthode « propre » accidents), exposition trafic.
- Minors différés (revue finale) : annotations quotées `scale_robustness.py` ; `INSTALL spatial`
  réseau dans les helpers de test (candidate fixture `conftest`).
- **Promotion** : les 3 conventions workflow projet-local (démo-gate re-validée en force, commit-
  dernier, récap-checkpoint) restent candidates — arbitrage par revue d'usage de standards depuis
  `methods/spec`.

## Temps

- **Engagé** : ≈ **1h50** (bloc d'activité `2026-08-01 21:21`) ; span git ~4h (soirée 2026-08-01 →
  nuit 2026-08-02). Couvre l'exécution complète des 9 tâches + fixes + merge + release + session-end.

## Pointers

- Journal : `journal/2026-08-02-brique6-implementation.md`
- Cadrage amont : `journal/2026-08-01-brique6-cadrage-robustesse-echelle.md` ; veille
  `research/2026-08-01-h3-agregation-anti-maup-reseau.md`,
  `research/2026-08-01-croisement-donnees-garde-fous-spatiaux.md`
- Livraison : `<IMPL:src>` `main` merge `5cea2d9`, release `92f2b07`, tag `v0.7.0`,
  `src/CHANGELOG.md [0.7.0]`
- Démo : `<IMPL:src>/demo/brique-6-robustesse-echelle.md`
- OPEN-QUESTIONS : Q-0019 (ajout) ; Q-0016 / Q-0009 / Q-0004 (raffinées)
