# Journal — Brique #6 (robustesse d'échelle H3) : exécution subagent-driven + release v0.7.0

- Date : 2026-08-02 (session démarrée le 2026-08-01 en soirée)
- Participants : Alex ; Claude
- Nature : **exécution** du plan SHIP cadré la session précédente — subagent-driven-development,
  9 tâches TDD + 2 fixes, merge, release `v0.7.0`.
- Temps engagé : ≈ 1h50 (bloc `2026-08-01 21:21`) ; span git ~4h.

---

## 1. Le déroulé nominal, et ce qu'il confirme

9 tâches, chacune : implémenteur TDD (sous-agent frais) → gate vert → `git add` (stage seul) →
revue de tâche sur diff **stagé** (sous-agent frais) → commit seulement après *Approved* → récap
plain-language en **checkpoint** (message final du tour, attente du « continue » d'Alex). La
discipline projet a tenu de bout en bout : aucun commit sans gate+revue, `add`/`commit` toujours
disjoints, un tour = une tâche. Les revues n'ont trouvé, sur le corps du plan, que des défauts
**mécaniques** ou des **faiblesses de test héritées du plan** — jamais un défaut de conception
(écho brique #4/#5 : l'advisor *actif* en amont paie).

## 2. Trois redressements en séance (le jugement reste humain)

- **`std_excess` : promotion, pas duplication.** Le plan faisait ré-implémenter dans
  `scale_robustness.py` un helper **identique** à celui de `concentration.py` — la duplication
  verbatim que la revue sanctionne. Surfacé *avant* T6 ; Alex a tranché : promotion en public dans
  `nullmodel.py` (la maison des stats de null, avec `pseudo_p`), importé par les deux. Dédup à la
  racine.
- **Caveats génériques + docstring.** Le `_CAVEATS` du plan nommait « population résidente » et
  « accidents » **en dur** dans un module agnostique. Alex a confirmé la direction : caveats
  **méthodologiques génériques** (« l'exposition déclarée ») dans le code, la réserve **domaine**
  (population ≠ trafic) dans la **note de fiche**. `h3_exposure` : docstring « population » →
  « exposition ».
- **Clé d'exposition = colonne de jointure.** Fausse piste puis convergence : d'abord renommer la
  clé spatiale en `statpop_hectare` (descriptive), ce qui **cassait** la résolution
  (`exposures[spatial_col]` → abstention sur le réel) ; Alex a retourné le raisonnement — la clé
  **doit être** le nom de la colonne du dataset servant de jointure (`geom` spatial, `canton`
  catégoriel), convention cohérente. Le « plusieurs expositions par colonne » (dict→liste +
  sélection) est **différé, documenté, non construit** (YAGNI, Q-0016).

## 3. Le gate démo a fait son travail — deux fois

La démo (gate humain **avant** merge) a révélé ce que **84 tests verts ne voyaient pas** :

- **Bug bloquant** : l'analyste ne pouvait pas appeler `spatial_scale_robustness` (« permission non
  accordée »). Cause : l'outil manquait de l'allowlist `_MCP_TOOLS` du runner. Un nouvel outil MCP
  exige **trois** câblages — enregistrement serveur (T7) **+ allowlist runner + charte** — et seuls
  les deux premiers étaient au plan. Corrigé (allowlist + paragraphe de charte, honnêteté préservée).
- **Dérive d'isolation P3** (creusée sur questions d'Alex) : la trace montre l'agent appelant
  `ToolSearch` — donc `bypassPermissions`+`allowed_tools` **n'empêche pas** l'appel d'outils
  hors-liste ; `disallowed_tools` est la vraie barrière, et elle ne couvre que les **anciens**
  built-ins, pas les méta-outils récents du CLI (`ToolSearch`, `TaskCreate`, `Cron*`). Le double
  `ToolSearch` de l'analyste s'explique proprement (forme `select:<noms exacts>` avec les noms
  **nus de la charte** → échec ; repli sur la forme mots-clés → succès). Environnemental (CLI
  2.1.187), pré-existant. → **Q-0019**, slice sécurité dédiée.

## 4. Un durcissement de test discuté, pas subi

Deux tests hérités du plan étaient faibles : le verdict multi-résolution n'excluait que « absente »
(vacux), et le check P2 `_no_seq` retournait **toujours** `True` (no-op). Alex a demandé si le
durcissement était « influencé par les données de test » — bonne alarme. Distinction posée : le
check P2 est couplé au **schéma de sortie** (int/str/dict), pas au domaine ; le verdict a été
réécrit pour tester le **mécanisme** (`all(significant)` → robuste) plutôt qu'un label observé.
Rigueur sur la rigueur.

## 5. Résultat

Outil MCP `spatial_scale_robustness` en production : agrégation H3 multi-résolution normalisée par
population réelle (STATPOP hectare), verdict robuste/fragile/absente, décomposition non-peuplé,
caveats honnêtes. Smoke réel (267K accidents × 347K hectares) : **5,3 s, verdict `robuste`**,
part `unpopulated` 4,18 %. Fix Q-0016 (abstention par défaut) livré. Revue finale opus = Ready to
merge. Merge `5cea2d9`, release `92f2b07`, **`v0.7.0`** (tag user-driven).

## 6. Leçons

- **La démo attrape ce que les tests ne voient pas.** 84 verts, feature-phare inutilisable par
  l'agent : sans le gate humain, on aurait mergé un outil que l'analyste ne peut pas appeler.
  Re-validation forte de la convention démo-gate.
- **Trois câblages pour un outil agentique** : serveur + allowlist + charte. À intégrer aux plans
  futurs qui ajoutent un outil MCP.
- **Écouter l'objection méthodo** (clé=jointure, durcissement de test) a redressé le contrat et la
  rigueur — le jugement reste en amont, comme au cadrage.

## 7. Pointeurs

- Slice : `slices/2026-08-02-01-brique6-robustesse-echelle-h3-execution.md`
- Cadrage amont : `journal/2026-08-01-brique6-cadrage-robustesse-echelle.md`
- Recherche : `research/2026-08-01-h3-agregation-anti-maup-reseau.md` ;
  `research/2026-08-01-croisement-donnees-garde-fous-spatiaux.md`
- OPEN-QUESTIONS : Q-0019 (ajout) ; Q-0016 / Q-0009 / Q-0004 (raffinées)
- Livraison : `<IMPL:src>` `main` merge `5cea2d9`, release `92f2b07`, tag `v0.7.0`,
  `src/CHANGELOG.md [0.7.0]`
- Démo : `<IMPL:src>/demo/brique-6-robustesse-echelle.md`
