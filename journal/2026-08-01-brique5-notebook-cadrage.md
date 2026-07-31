# Journal — Brique #5 (le produit de session) : cadrage complet, advisor SHIP, impl à reprendre

- Date : 2026-08-01 (démarrée le 2026-07-31 au soir)
- Participants : Alex ; Claude
- Nature : session de **cadrage** (recherche + design + plan + passes advisor, **aucune implémentation shippée**)
- Produits : `research/2026-08-01-donnees-suisses-et-quarto.md` ; raffinements Q-0002/Q-0004/Q-0016 ;
  design + plan éphémères **conservés** (slice en vol) ; ce journal.
- Temps engagé : ≈ 1h05 (blocs 20:56 + 21:34) ; span ~3h. Aucun commit spec pendant la session (tout au session-end).

---

## 1. Choix de la brique #5, puis un recadrage qui change tout

Inventaire du périmètre v1 (overview §12) : quatre briques ont creusé l'axe MCP/mémoire ;
restent non traversés **curateur/interview**, **interface** et **notebook**. J'ai posé le drapeau
anti-cathédrale d'entrée — quatre briques, et Q-0002 (vraie question métier / destinataire) n'a
pas bougé — puis recommandé, si on enchaîne, **le notebook (palier A)** : il se branche sur la
trace du greffier (brique #4), délivre le différenciateur n°1 (« produit de session rejouable »),
et se ship sans données réelles ni stack UI.

**Le recadrage d'Alex** a transformé la petite brique en **banc de validation end-to-end de la
v1** : profiter du notebook pour imaginer un **scénario d'analyse complet** exerçant toutes les
fonctionnalités fortes, avec un vrai « aha », sur **donnée réelle** (au besoin enrichie). Ma
condition de rigueur, posée en retour : l'inattendu doit **émerger de l'exécution réelle**, pas
être scripté — sinon c'est le WOW-theatre que le projet interdit. Décision : **vraie donnée OFROU**
comme socle (déjà dans le repo : 267 761 lignes), enrichissement *au besoin*.

## 2. Recherche (agents parallèles)

Trois volets, tous vérifiés. **(a)** Corpus interne : notre veille **sur-documente** déjà le
scénario accidents — chaque piège a son outil nommé (MAUP→`esda.smaup`, causalité→`dowhy`,
normalisation→`concentration_test`, forking paths→`statsmodels` FDR) — et le volet notebook
(indexation par artefact façon Verdant, `marimo`/`Quarto`, « 96 % des notebooks LLM non
reproductibles → notre discipline de capture EST la valeur »). **(b)** Faisabilité données
suisses : quick-wins **STATPOP hectare + maille H3** ; SITG Genève riche mais cantonal ; **TJM
national écarté** (≈500 stations, couverture pauvre — le « bon » dénominateur est hors de portée
d'une découverte). **(c)** Prior art Quarto : `hermes-agent` (`sessions export`) et `agenttrace`
font *exactement* trace→Quarto ; verdict technique net — **templating texte, résultats figés,
aucun engine** (blocs `{.sql}`/`{.json}` display-only + callouts fait/hypothèse/refusé). Détail
durable dans `research/2026-08-01-donnees-suisses-et-quarto.md`.

## 3. Design (palier A) — trois décisions structurantes

**(1) Levier caché** : `concentration_test` fait *déjà* un modèle nul normalisé par exposition
déclarée → tourner sur le réel avec une exposition **population-par-canton** ne demande **aucun
nouvel outil**, juste un CSV + pointer le serveur + une vraie fiche. **(2) Modèle de données en
3 états** (clarification décisive d'Alex) : `raw`/`prepared` gitignorés (bytes régénérables),
`fixtures` tracké (petit, déterministe), et la frontière **tracked/ignored** qui dicte tout — la
*connaissance* (fiches) et le *code* (scripts de build) restent dans git, jamais sous `data/`.
D'où le layout `catalog/` (fiches) + `prepare/` (ingestion) + `data/` (bytes). **(3) Fiche
auto-descriptive** (idée d'Alex) : la fiche porte `data:` + `exposures` en **chemins relatifs-à-
la-fiche** → on pointe le serveur sur **une seule chose** (`INTREEPID_FICHE`), tout en découle.
Le générateur `to_quarto` est **pur/total/golden-testable** (miroir de `render.py`). Convergence
notée : ce run réel EST le « 2ᵉ dataset réel » que Q-0004 réclame pour extraire le sur-ajustement
de charte — on l'**observe et documente**, on ne le corrige pas ici.

## 4. Plan (4 tâches TDD) + 3 passes advisor → SHIP

Plan writing-plans sans placeholder (code + interfaces exacts, vérifiés contre le vrai code :
`SessionTrace`/`TraceNode`, signatures serveur/scribe/runner, schéma du parquet réel). **Trois
passes advisor fraîches** (doctrine : frais par passe, MUSTs bloquants, correctifs inline) :
- **#1 — NEEDS_CHANGES** : MUST — le `git mv` de la fiche casse `intreepid/demo.py` (driver des
  runbooks brique-1/2/3), invisible au gate car non importé par les tests. + 3 SHOULDs (prompts
  oracle périmés, sortie figée brique-4, mode d'échec `parse_verdict`).
- **#2 — NEEDS_CHANGES** : MUST — ordre d'import de `test_catalog.py` (`I001` gate-rouge). L'agent
  a **exécuté** le vrai code : `to_quarto` → 13/13 asserts verts ; SQL d'ingestion → 267 761
  lignes, flags BOOLEAN. + 4 SHOULDs (packaging `prepare/`, redondance `*.duckdb`, etc.).
- **#3 — SHIP** (0 MUST) : re-vérifie les correctifs intégrés inline + 2 SHOULDs triviaux (un
  comptage « 6× »→« 8× », une docstring). Confirme héritage d'env du serveur stdio, 26 cantons
  couverts, `exposure_model` basename gardant les tests verts.

## 5. État en vol + reprise

Aucune ligne de code écrite (pas de branche créée cette fois). Design + plan **conservés** sur
disque (gitignorés, slice en vol) :
`docs/superpowers/specs/2026-07-31-brique-5-notebook-session-reelle-design.md` et
`docs/superpowers/plans/2026-07-31-brique-5-notebook-session-reelle.md`. **Décision** : exécution
en **session fraîche + subagent-driven** (contexte propre pour une exécution longue ; le plan
auto-contenu porte tout). Prompt de démarrage préparé (voir §7 pointeurs).

## 6. Leçons

- **L'advisor qui exécute le vrai code voit ce que le gate ne voit pas** : le MUST `demo.py` (un
  driver cassé par un `git mv`, hors suite de tests) et le SQL d'ingestion validé grandeur nature
  (267 761 lignes) — deux confirmations qu'une passe advisor *active* (pas juste lecture) vaut son
  coût. Écho direct de la leçon brique #4 « les erreurs du plan se propagent en aval ».
- **La clarification d'Alex sur les états de la donnée a redressé l'architecture** avant impl :
  sans la frontière tracked/ignored explicitée, fiches et scripts de build finissaient sous
  `data/` gitignoré = travail de curation perdu. Le gate humain sur le *design des chemins* a payé.
- **Vérifier `.gitignore` avant de nommer un dossier** : `build/` y est (build Python) → un
  `data/build/` aurait été silencieusement ignoré. D'où `prepare/`. Verify, don't invent.
- **Recadrer une petite brique en banc de validation** est un bon substitut *contrôlable* à Q-0002
  tant que le verrou métier tient — à condition que l'inattendu émerge du réel, pas d'un script.

## 7. Pointeurs

- Veille : `research/2026-08-01-donnees-suisses-et-quarto.md`
- Design/plan (éphémères, en vol) : `docs/superpowers/specs/2026-07-31-brique-5-notebook-session-reelle-design.md`,
  `docs/superpowers/plans/2026-07-31-brique-5-notebook-session-reelle.md`
- OPEN-QUESTIONS : Q-0002, Q-0004, Q-0016 raffinées
- Amont : `journal/2026-07-31-brique4-greffier-implementation.md` ; overview §12 (périmètre v1)
- Impl : `<IMPL:src>` — brique #5 à exécuter (branche `feat/brique-5-notebook` à créer, base v0.5.0)
