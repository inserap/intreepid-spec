# 2026-07-30-02-brique3-concentration-modele-nul — Execution recap

## Scope

Troisième brique livrable d'`intreepid` (walking skeleton v0.2) : le **premier organe de
preuve**. Un nouvel outil MCP read-only `concentration_test`, **agnostique au domaine**,
teste si une variable catégorielle (l'« unité ») est **sur-concentrée** par rapport à une
**exposition déclarée dans la fiche**, via un **modèle nul par permutation multinomiale**
(999 tirages, seed fixé). Passage de l'*honnêteté* (briques #1/#2, flair P6) à la *rigueur*
(preuve reproductible). Le LLM ne reçoit que des agrégats + un pseudo-p (P2), connexion
read-only (P3), sortie rejouable (P4). Shippé dans `<IMPL:src>`, mergé sur `main`
(merge `bd0499a`), release `v0.4.0` (release commit `155a63f` ; **tag user-driven**).

## Shipped artifacts

Dans `<IMPL:src>` (package `intreepid`) :
- `mcp_server/nullmodel.py` (NEW) : `pseudo_p(null_stats, observed)` = `(M+1)/(R+1)`,
  formule de permutation **générique** isolée (réutilisable par la rigueur future).
- `mcp_server/concentration.py` (NEW) : `concentration_test(con, table, fiche, unit_col, *,
  base_dir, n_permutations=999, seed=42)`. Écart de Poisson standardisé `(O−E)/√E` ; nul
  multinomial pondéré par l'exposition ; 2 volets — `most_concentrated` (pseudo-p du **max**,
  gère la multiplicité) et `highest_raw_count` (pseudo-p **marginal** du plus gros comptage).
  Exposition lue via la convention de fiche `exposures` ; à défaut → **uniforme** (signalé
  par `exposure_model`). Gardes : `unit_col` dans l'allowlist, `n_total>0`, exposition `>0`,
  cap `_MAX_PERMUTATIONS=9999`.
- `mcp_server/server.py` + `agent/runner.py` : outil MCP `concentration_test` exposé +
  ajouté à l'allowlist `_MCP_TOOLS` (4 outils ; isolation P2/P3 inchangée).
- `agent/charter.md` : paragraphe **générique** « preuve de concentration » (invoquer le nul
  avant tout `fait`, interpréter le pseudo-p, jamais conclure sur le comptage brut).
- `fixtures/build_fixture.py` + `canton_exposure.parquet` (NEW) : exposition par canton +
  vraie concentration plantée (A = 2ᵉ comptage, exposition ÷4 → excès réel) et fausse
  (B = plus gros comptage, exposition = comptage → volume, pas excès) ; `ground_truth.hotspot`
  + `exposures` dans la fiche (mécanique seule, **anti-spoiler**).
- `tests/` : `test_nullmodel.py` (formule + bornes), `test_concentration.py` (vrai p<0.05,
  faux p≥0.05, cas uniforme, P2 récursif, cap permutations, reproductibilité), `test_fixture.py`
  (exposition + hotspots), `test_server.py` (+outil MCP), `test_agent_eval.py`
  (`test_agent_eval_concentration`, N=5, matcher négation-aware).
- `demo/brique-3-concentration-et-preuve.md` (NEW, sorties réelles) + `demo.py` étendu +
  `demo/README.md`. `CHANGELOG.md [0.4.0]`, `pyproject`/`uv.lock` `0.4.0`.
- `chore` connexe : `.claude/settings.json` retiré du suivi + gitignoré (per-user).

## Deviations from plan (if any)

- **Fix subagent déraillé (stabilisé par le coordinateur)** : le fix du matcher oracle a été
  appliqué à moitié par un sous-agent qui a disserté au lieu d'exécuter, laissant le repo
  à moitié modifié + une modif parasite de `settings.json`. Repris à la main (le contrôleur
  détenait le code exact), scan de domaine + gate reverts inclus. Commit `e3eef03`.
- **Écart au design corrigé en amont (advisor #1, S1)** : le faux point chaud a un
  `std_excess` **négatif** (−3,28), pas « ≈ 0 » (renormalisation de l'attendu quand on réduit
  l'exposition du vrai) ; design + runbook narrent les **vrais chiffres**.
- **`n_permutations` dans le driver démo** : appel de l'outil dans le `with open_readonly`
  (besoin de `con`), collatéral attendu.

## Validation

- **Golden déterministes** : `36 passed` (`uv run pytest -m "not agent"`), dont
  `test_concentration` (BE `p=0.001` / ZH `p=1.0`), cas uniforme, cap, P2 récursif.
- **Oracle agent** : `1 passed` (N=5, ~5 min 50, vrai agent). L'agent **retient BE** comme
  excès réel `fait` (≥4/5) et **réfute ZH** (plus gros volume) — verdicts chiffrés, aucune
  ligne brute lue. Le 1ᵉʳ run rouge était un **faux positif du matcher** (il comptait la
  réfutation correcte de ZH comme hallucination) → fix négation-aware, re-lancé **vert**.
- **Gate qualité** : `ruff format`/`ruff check` verts ; `pyright standard` 0 erreur.
- **Reviews** : revue par tâche (spec + qualité + **scan de domaine**) sur les 6 tâches ;
  **2 passes advisor SHIP** sur le plan (0 MUST, 6 SHOULD tous appliqués) ; revue finale de
  branche **Ready to merge: Yes** (0 bloquant, 6 Minor triés en différé).
- **Chiffres fixture** : `n_total=4314`, 26 unités. BE obs=636 / att=178,77 / z=+34,2 /
  p=0,001. ZH obs=781 / att=878,09 / z=−3,28 / p=1,0.

## Follow-ups

- **OPEN-QUESTIONS** : **Q-0016** (choix/validation de l'exposition) ; **Q-0009** raffinée
  (mécanisme nul livré ; roadmap Gi\*/LISA, MAUP-H3, réseau NKDE, FDR, E-value, EB/RTM, dowhy).
- **Dette code (triage revue finale, différée)** :
  - `concentration.py` : chemin parquet d'exposition en f-string SQL — à paramétrer si la
    fiche devient éditable par un tiers non-confiance (aujourd'hui : aucune surface agent) ;
  - `build_fixture.py` : `INSERT` par f-string → `executemany` paramétré (dev-only) ;
  - oracle : matcher **FR-only** (mots-clés négation/excès) → migrer vers un champ structuré
    `polarity` dans `Observation` si l'agent répond multi-langue (recoupe la robustesse) ;
  - `_unit` sans annotations de types (candidat ratchet `strict`) ; cap permutations
    silencieux (valeur renvoyée dans la sortie = transparent).
- **Dette pré-existante (Q-0004)** : la charte porte encore l'exemple tuné brique #1
  (`vitesse_limite_kmh`/`999`) — à extraire vers la fiche/exemples neutres sur un 2ᵉ dataset.
- **`esda` non ajouté** (volontaire) : arrivera à la brique Gi\*/LISA (autocorrélation), là où
  il est irremplaçable — pas de dépendance morte (règle d'admission de composant).
- **Q-0002** (inchangée, LE verrou) : valeur métier à valider sur une vraie question / personne.

## Pointers

- Journal : `journal/2026-07-30-brique3-concentration-modele-nul.md`
- Livraison : `<IMPL:src>` `main` merge `bd0499a`, release `155a63f`, tag `v0.4.0` (user-driven),
  `src/CHANGELOG.md [0.4.0]`
- Démo : `<IMPL:src>/demo/brique-3-concentration-et-preuve.md`
- Amont : `journal/2026-07-29-etat-de-lart-et-revue-brique1.md` (veille §5 rigueur),
  brique #2 `slices/2026-07-30-01-brique2-profile-stats-temporel-spatial-execution.md`
