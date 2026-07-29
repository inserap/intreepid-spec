# État de l'art — projets GitHub en lien avec intreepid

> **Objet** : veille technologique — projets open source similaires ou adjacents à intreepid
> (workspace de découverte analytique agentique, données géospatiales ou non).
> **Méthode** : recherche menée le 2026-07-29 par **huit agents de recherche parallèles**, un par
> capacité de la vision architecturale (overview v0.2). Chaque repo cité a été **vérifié existant via
> l'API GitHub** (aucune hallucination) ; les projets sont jugés **sur leurs idées et leur
> implémentation réelle (README + structure de code), pas sur leurs étoiles** — beaucoup de repos de
> recherche récents et très pertinents ont 0-5★. Étoiles / licence / activité relevées à cette date.
> **Référentiel d'évaluation** : la **vision complète** d'intreepid (`<IMPL:src>/docs/architecture/overview.md`,
> P1-P9, les six rôles d'agents, les cinq couches, la mémoire à trois étages) — **et non l'état
> courant de l'implémentation** (une seule brique livrée à ce jour). C'est la correction principale
> par rapport à la première version de ce document, qui sous-pondérait les briques futures.
> **Statut** : document de veille (process artifact, d'où sa place dans le `spec`) — n'engage aucune
> décision d'architecture ; les recommandations sont des pistes à instruire (ADR le cas échéant).

---

## Synthèse exécutive

**1. La niche d'intreepid est réelle — et confirmée par une recherche plus large.** Aucun projet, sur
plus d'une centaine examinés, ne combine les quatre signatures : (a) le LLM ne voit que des
**profils/agrégats** servis par MCP, jamais les lignes ni la géométrie (P1/P2) ; (b) la **session
comme arbre d'exploration** persistant couplé à la carte ; (c) une **épistémologie multi-agents**
(critique, candide, greffier — des *rôles de délibération*, pas des pipelines techniques) ; (d) la
**mémoire distillée** (catalogue/biographie, graphe d'insights, playbook). Chaque pièce existe
isolément ; personne ne les soude, et personne n'ajoute l'empreinte spatiale par nœud de raisonnement.

**2. Le pari architectural est dans le sens du courant (2024→2026).**
- **Bascule code-gen → tool-calling** : la 1ʳᵉ génération géo-LLM (LLM-Geo, ChatGeoPT) faisait générer
  du code (~80 % de réussite, non reproductible, GPL) ; la génération actuelle expose des **primitives
  déterministes** (gis-mcp, h3-mcp, openassistant, geo-perception) — exactement P1/P2/P7.
- **Consolidation brutale du « chat devant une BDD »** : Vanna **archivé** (02.2026), TaskWeaver
  **archivé** (03.2026), Dataherald abandonné, DataLine en déclin, Chat2Geo passé en SaaS. L'anti-objectif
  d'intreepid est validé par le marché.
- **Le centre de gravité est le contexte sémantique gouverné** : WrenAI, Cube, SuperSonic, dbt-MCP,
  OpenMetadata donnent au LLM un modèle sémantique, pas le schéma brut — validation directe du
  catalogue YAML (C2).
- **MCP est devenu l'interface universelle**, y compris **MCP Apps (SEP-1865)**, première extension
  officielle MCP (26.01.2026, co-signée Anthropic/OpenAI) pour du rendu UI en chat.

**3. Corrections factuelles à la première version de ce document.**
- **H3-en-MCP existe** — `overnin/h3-mcp` (11 outils, `cellset_id`, `return_mode="summary"`),
  `iamvibhorsingh/bbox-mcp-server` (binning H3 côté serveur), `geodaai/openassistant` et
  `kevics1/geo-perception` en exposent aussi. L'affirmation « aucun serveur H3 n'existe » est **fausse**.
- **Le MAUP est déjà outillé** — `pysal/esda` embarque `smaup.py` (test statistique de sensibilité au
  MAUP, Duque et al.) et `significance.py` (pseudo-p par permutation = modèle nul spatial).
- **Le read-only DuckDB spatial en MCP existe déjà**, formalisé par un tiers
  (`afterrealism/duckdb-spatial-docsbox-mcp`) — c'est littéralement la brique #1. Corollaire pour le
  test de plus-value : cette couche est reproductible par n'importe qui ; le « vrai plus » d'intreepid
  doit vivre **au-dessus** (greffier, capitalisation, critique/candide), pas dedans.

**4. Ce qui n'existe nulle part — la plus-value défendable (chaque niche confirmée vide par la recherche).**
- **`profile_stats` comme proxy statistique exclusif** : tous les MCP data renvoient soit des lignes
  brutes (incompatible P2), soit du schéma technique. Aucun ne produit une carte d'identité statistique
  par colonne comme outil premier.
- **Couplage arbre ↔ carte + zones blanches du raisonnement** : introuvable en OSS.
- **Test anti-MAUP multi-résolution H3 automatisé** (« un pattern doit tenir à toutes les résolutions
  7-10 ») : personne ne l'implémente comme discipline.
- **ML classique générique exposé en outils MCP** (`train_model`/`predict`/`explain` + validation
  temporelle) : quasi désert (`gh search "scikit-learn MCP" / "xgboost MCP"` ≈ 0).
- **Collaboration multi-agent sérialisée par l'agent + attribution native** : uniquement académique.

**5. Briques réutilisables prioritaires** (licences permissives sauf mention).

| Besoin intreepid | Brique candidate | Licence | Usage |
|---|---|---|---|
| Serveur MCP | **jlowin/fastmcp** (déjà choisi) | Apache-2.0 | middleware garde-fous transverses, composition `mount` |
| Read-only DuckDB/PostGIS (blueprint) | **afterrealism/duckdb-spatial-docsbox-mcp**, **…/postgres-postgis-docsbox-mcp** | MIT | `read_only=True` moteur + validateur `sqlglot` + auto-`LIMIT` + timeouts + rollback |
| Primitives H3 en MCP | **overnin/h3-mcp** | MIT | `cellset_id` en handle + `return_mode="summary"` (P2) ; à forker |
| Feature engineering H3 amont | **kraina-ai/srai** | Apache-2.0 | régionalisation H3 multi-résolution, embeddings Hex2Vec |
| Modèles nuls spatiaux + **MAUP** | **pysal/esda** | BSD-3 | permutation (`significance.py`) + **`smaup.py`** (test MAUP) |
| Réfutation causale | **py-why/dowhy** | MIT | refuters (placebo, subset, random common cause) → outil MCP `refute_insight` |
| Sensibilité confondeur caché | **DoubleML/doubleml-for-py** | BSD-3 | complément dowhy (bornes de biais, robustness values) |
| Corrections multi-tests | **statsmodels** (`stats.multitest`) | BSD-3 | garden of forking paths — remplace pingouin (GPL) |
| Validation spatiale anti-leakage | **SamComber/spacv** | BSD-3 | spatial CV / spatial leave-one-out avec buffers |
| Taxonomie d'alertes profiling | **ydata-profiling** (`AlertType` ×20) | MIT | inspiration de la sortie `profile_stats` (faits) |
| Profil versionnable / dérive | **whylabs/whylogs**, **ing-bank/popmon** | Apache-2.0 / MIT | dérive = diff de profils ; drift temporel time-sliced |
| Contexte suisse | **malkreide/swisstopo-mcp** | MIT | MCP amont ; **n° BFS = clé de jointure sémantique** ; à vendorer (facteur bus = 1) |
| Semantic layer (référence) | **Canner/WrenAI** (MDL, dry-plan), **dbt-labs/dbt-mcp** | Apache-2.0¹ | modèle du catalogue gouverné + validation SQL |
| Mémoire graphe temporel | **getzep/graphiti** ; **sanonone/kektordb** | Apache-2.0² | invalidation sans perte (`valid_at`/`invalid_at` ; « Semantic Git ») |
| Arbre/DAG persistant + merge | **ishandhanani/forky** ; **Trrack/trrackjs** | sans licence³ / BSD-3 | nœud/DAG SQLite + merge 3-voies (LCA) ; provenance non-linéaire |
| Replay / checkpoint | **langchain-ai/langgraph** | MIT | time-travel / fork durable (substrat, pas la signature) |
| Viz en chat (carte, charts) | **modelcontextprotocol/ext-apps** (MCP Apps), **MCP-UI-Org/mcp-ui**, **antvis/mcp-server-chart** | Apache-2.0 / MIT | rendu MapLibre + charts dans la conversation |
| BI-as-code / notebook réactif | **evidence-dev/evidence**, **marimo-team/marimo** | MIT / Apache-2.0 | matérialisation d'insights ; notebook `.py` diffable sûr en génération LLM |
| ML comme outils MCP (patron) | **LGDiMaggio/predictive-maintenance-mcp** | MIT | archi `train`/`predict`/`explain` via FastMCP (autre domaine) |
| Explicabilité pour LLM | **explainX/explainx** | MIT | outil MCP `explain` (SHAP/importances formatés pour le LLM) |

¹ WrenAI porte à la fois Apache-2.0 et AGPL-3.0 (dual par composant) → vérifier composant par composant.
² kektordb : badge Apache mais fichier LICENSE en NOASSERTION → à clarifier avant emprunt de code.
³ forky, loom, GitChat : **aucune licence** → lire pour l'idée, ne pas copier de code.

**6. Points de vigilance licences** : AGPL (Mundi.ai, nveil-toolkit, Rath, `ViVi141/china-1m-geodata-postgis-mcp`),
GPL (LLM-Geo, SpatialAnalysisAgent, Pingouin, `geoai-lab/spatialCV`, Quarto en pratique GPL-2), RAIL
(AI-Scientist), **sans licence** (forky, loom, GitChat, `llm_multiagent_debate`, `mcp-vegalite-server`,
impl OSS de Kosmos, plusieurs MCP PostGIS) → inspiration seulement, pas d'embarquement.

**7. À suivre en veille** : MCP Apps (SEP-1865), WrenAI (trajectoire semantic-layer), graphiti / kektordb
(mémoire temporelle), FutureHouse Kosmos (world model + traçabilité claim→source), les listes
`HKUSTDial/awesome-data-agents`, `NirDiamant/Agent_Memory_Techniques`, `punkpeye/awesome-mcp-servers`.

---

## 1. Analyste-traducteur & catalogue sémantique (C2, P2, P9)

> Traduire métier ↔ SQL/spatial en donnant au LLM un **contexte gouverné** (fiche/catalogue) plutôt
> qu'un schéma brut, et capitaliser les requêtes validées.

**Ce qui existe / ce qui manque.** La couche sémantique-comme-contexte est un P2 quasi résolu par
l'état de l'art (WrenAI, Cube, SuperSonic, dbt, OpenMetadata) ; la traduction question→SQL gouvernée et
vérifiée est mûre (dry-plan, correcteur sémantique). Ce qui manque partout : le greffier, la
capitalisation multi-artefacts et la rigueur adversariale. Aucun de ces projets n'est un « workspace de
découverte » — ce sont des chatbots BI / assistants text-to-SQL (l'anti-objectif).

**Canner/WrenAI** — <https://github.com/Canner/WrenAI> — ~16,7k★ — Apache-2.0 **+ AGPL-3.0 (dual par composant)** — actif — déjà connu
- Idée : « GenBI » — les agents raisonnent sur une **couche de contexte ouverte** (semantics MDL,
  définitions maison `instructions.md`, « memory of what worked »), pas sur les tables brutes.
- Implémentation : pipeline « correctness as primitives » — retrieval schéma riche, **planning MDL,
  dry-plan validation, structured errors avec hints, value profiling, eval runner**. Contexte versionné
  en fichiers Git, evidence-linked. DuckDB par défaut, agent-driven via MCP.
- Lien intreepid : le projet le plus aligné sur « contexte gouverné reviewable » — C2 (catalogue MDL),
  P2, P4 (contexte Git reviewable), P9 (memory of what worked = embryon de playbook), analyste-traducteur.
- Verdict : **inspiration de premier plan** — étudier MDL, dry-plan validation, format `instructions.md`.
  Attention licence dual → inspiration architecturale libre, emprunt de code composant par composant.

**tencentmusic/supersonic** — <https://github.com/tencentmusic/supersonic> — ~5k★ — NOASSERTION — actif — déjà connu
- Idée : unifie Chat BI (LLM) et Headless BI ; le chat n'accède qu'aux modèles sémantiques gouvernés.
- Implémentation : pipeline explicite **Knowledge Base → Schema Mapper → Semantic Parser → Semantic
  Corrector → Semantic Translator** ; « Chat Memory » = trajectoires rappelées en few-shot. Java.
- Lien intreepid : le couple **Semantic Parser + Semantic Corrector** est transposable au duo
  analyste-traducteur / critique + P4 ; Chat Memory ↔ mémoire de requêtes validées.
- Verdict : **inspiration/pattern** (meilleure décomposition d'un text-to-SQL gouverné+corrigé). Java →
  pas de réutilisation de code ; licence à clarifier.

**cube-js/cube** — <https://github.com/cube-js/cube> — ~20,5k★ — Apache-2.0/MIT — actif — déjà connu
- Idée : semantic layer headless avec **endpoint MCP** — l'agent demande mesures/dimensions par nom,
  n'écrit jamais de SQL brut ; row-level + role-based appliqués avant exécution.
- Lien intreepid : C2 + C3 (exposition MCP, P3) + P2 ; référence du « select from a governed set ».
- Verdict : **inspiration** de référence pour « semantic layer via MCP », mais orienté métriques
  d'entreprise → c'est de la BI qu'intreepid s'adosse sans réinventer. À citer comme le « bare semantic
  layer » du benchmark WrenAI.

**open-metadata/OpenMetadata** — <https://github.com/open-metadata/OpenMetadata> — ~14,6k★ — Apache-2.0 — actif — NOUVEAU
- Idée : « Open Context Layer » — catalogue de métadonnées unifié en **graphe de connaissances**
  (lineage, glossaires, classifications, data contracts) exposé via un serveur MCP.
- Lien intreepid : le plus proche pour modéliser **catalogue + graphe** (C2) et son exposition MCP —
  mais orienté gouvernance/lineage d'entreprise, pas découverte d'insights.
- Verdict : **inspiration** pour la modélisation C2 et l'API MCP ; trop large/opérationnel pour être
  réutilisé — regarder le schéma de métadonnées comme référence.

**zjunlp/DataMind** — <https://github.com/zjunlp/DataMind> — ~125★ — Apache-2.0 (à confirmer) — très actif — NOUVEAU
- Idée : recherche (ICLR/AAAI/KDD 2026) sur les agents d'analyse open source. **DataCOPE** = découverte
  non-supervisée de « skills » réutilisables ; **DataPRM** = process-level reward ; **LongDS-Bench** =
  échec des agents en analyse long-horizon multi-tours.
- Lien intreepid : DataCOPE ↔ **playbook / mémoire procédurale** (comment fabriquer et capitaliser des
  coups analytiques) ; DataPRM ↔ rôle **critique** (récompenser le *processus*, pas la réponse).
- Verdict : **inspiration** (recherche, pas produit). Lecture prioritaire de DataCOPE/DataPRM pour la
  mécanique greffier→playbook. Licence à clarifier avant tout emprunt.

**vanna-ai/vanna** — <https://github.com/vanna-ai/vanna> — ~23,8k★ — MIT — **archivé 02.2026** — déjà connu
- Idée : text-to-SQL par RAG sur DDL + docs + **paires question↔SQL validées** — l'ancêtre le plus pur
  de « capitaliser des paires Q/SQL ».
- Verdict : **inspiration** (le RAG de paires Q/SQL reste le baseline) mais **écarter comme dépendance**
  (archivé). Sa limite illustre l'écart avec intreepid : RAG de paires ≠ mémoire sémantique traçable au
  nœud avec abandons capturés.

**eosphoros-ai/DB-GPT** — <https://github.com/eosphoros-ai/DB-GPT> — ~19,6k★ — MIT — actif — déjà connu
- Verdict : **contre-exemple instructif** — plateforme agentique data « tout-en-un » (AWEL, multi-agents,
  sandbox) ; surface énorme, contre P7 et la doctrine anti-cathédrale. Piocher l'idée de sandbox, sinon écarter.

**HKUSTDial/awesome-data-agents** — <https://github.com/HKUSTDial/awesome-data-agents> — ~660★ — sans licence — actif — NOUVEAU
- Verdict : **source de veille** (companion du survey « A Survey of Data Agents: Emerging Paradigm or
  Overstated Hype? » — dont le titre rejoint sainement la doctrine anti-WOW).

**À écarter** : sinaptik-ai/pandas-ai (chat sur DataFrames, code arbitraire), microsoft/lida (viz,
dormant), microsoft/data-formulator (viz — cf. §8), microsoft/TaskWeaver (archivé), Dataherald (abandonné),
defog-ai/sqlcoder (dormant, apprentissage par poids ⇒ contre P9), RamiAwar/dataline (GPL, chatbot),
Chat2DB (GUI SQL), MindsDB / tablegpt-agent (hors focus catalogue).

**Pistes non creusées** : papiers 2025-2026 sans repo dominant (*ToolSQL*, *NL2SQL-BUGs*, *SIRIUS-SQL*) ;
benchmark dbt « Semantic Layer vs Text-to-SQL » (chiffrer le gain d'une couche sémantique) ; couches
sémantiques légères (Sidemantic, MetricFlow, Lightdash) comme alternatives à Cube pour C2.

---

## 2. Géospatial : primitives spatiales en outils, H3, feature engineering (P1, C3 spatial)

> Exposer des opérations spatiales déterministes **comme outils** (vs code-gen), outiller H3, respecter
> P1 (le LLM ne voit pas la géométrie), discipliner l'anti-MAUP multi-résolution.

**Ce qui existe / ce qui manque.** Deux familles nettes : (a) MCP qui exposent des primitives spatiales
(gis-mcp, gdal-mcp, h3-mcp, geo-perception, openassistant) — le pattern C3 ; (b) agents code-gen
(LLM-Geo, SpatialAnalysisAgent) — antithèse de P2/P7, souvent GPL. Existent : binning H3 côté serveur,
read-only DuckDB spatial, feature engineering H3 amont (srai), et même un **outil MCP dédié au risque
MAUP** (geo-perception). Manque : le couplage explicite avec P1 + capitalisation, et l'anti-MAUP
multi-résolution comme test automatique.

**kevics1/geo-perception** — <https://github.com/kevics1/geo-perception> — ~1★ — MIT — actif — NOUVEAU
- Idée : agents en **3 couches (perception L1 → compréhension L2 → raisonnement L3)**, 18 outils MCP +
  3 Skills, double-piste « **Skill = flux cognitif / MCP = calcul** ».
- Implémentation : FastMCP, `uv`. Outils remarquables : **`geo_scale_analysis`** (inférence d'échelle +
  **évaluation du risque MAUP** en outil dédié), `geo_all_relations` (DE-9IM), Moran/LISA/Getis-Ord,
  **`geo_causal_check`** (auto-corrélation + taille d'échantillon + support commun avant toute assertion
  causale). Calculs lents (GWR, DID, RDD, IV) volontairement hors MCP, en guides offline.
- Lien intreepid : C3 (primitives en tools), **rôle critique** (MAUP + garde-fou causal), P7, et surtout
  le split **Skill÷MCP = frontière charte↔fiche** (Q-0004) sous un autre nom. Le plus aligné de l'axe.
- Verdict : **inspiration forte** malgré 1★ (jugé sur l'idée). Deep-read de `geo_scale_analysis` (balaie-t-il
  plusieurs résolutions H3 ?) et `geo_causal_check`. Géocodage lié à l'API Amap (Chine) — non bloquant.

**geodaai/openassistant** — <https://github.com/geodaai/openassistant> — ~57★ — MIT — actif — déjà connu
- Idée : bibliothèque JS de *tools* IA d'analyse spatiale (GeoDa) : LISA, Moran's I, régression spatiale,
  viz (Kepler.gl/ECharts/Leaflet).
- Implémentation : tools convertibles Vercel AI SDK/LangChain ; **DuckDB-WASM in-browser**, **H3 natif**,
  OSM. Le tool reçoit un **`getValues(dataset, variable)`** — la donnée reste côté hôte, le LLM ne
  manipule que des références/résultats.
- Lien intreepid : C1+C3+C5, **P2** (le pattern `getValues` = données locales, LLM aveugle à la géométrie),
  rôle critique (LISA/Moran).
- Verdict : **réutiliser / inspiration** — le contrat de tool `getValues`/`onToolCompleted` est un modèle
  d'API « données locales, LLM ne reçoit que métadonnées/agrégats ». Stack JS → inspiration d'archi.

**mahdin75/gis-mcp** — <https://github.com/mahdin75/gis-mcp> — ~173★ — MIT — actif — déjà connu
- Idée : serveur MCP mature, **92 fonctions** (Shapely, PyProj, GeoPandas, Rasterio, **PySAL** — spatial
  weights, autocorrélation, clustering, régression).
- Verdict : **inspiration** — le référentiel le plus complet de « quelles opérations exposer en tools ».
  Écarter comme dépendance : orientation « chatbot GIS générique » sans read-only ni P1. Manque H3/DuckDB
  spatial/GeoParquet — à ajouter soi-même.

**JordanGunn/gdal-mcp** — <https://github.com/JordanGunn/gdal-mcp> — ~72★ — MIT — actif — déjà connu
- Idée : MCP GDAL/Rasterio avec **middleware de « réflexion »** exigeant une justification structurée
  avant toute opération dont la méthodologie compte (CRS, rééchantillonnage, étendue).
- Lien intreepid : le pattern « forcer la justification méthodologique » ≈ honnêteté P6 + rigueur — pertinent
  contre le MAUP et le choix de résolution H3 (rôle critique/greffier).
- Verdict : **inspiration/pattern** — retenir le *reflection middleware*. Écarter comme dépendance (raster/GDAL).

**kraina-ai/srai** — <https://github.com/kraina-ai/srai> — ~383★ — Apache-2.0 — actif — déjà connu
- Idée : « Spatial Representations for AI » — régionalisation (**H3**, S2, Voronoï), chargeurs
  OSM/Overture/GTFS, jointures région-features, embedders (Hex2Vec).
- Lien intreepid : **P1** (feature engineering spatial déterministe amont — le rôle « H3 avant le LLM »),
  maille H3, C1.
- Verdict : **réutiliser** pour la couche amont H3/régionalisation (Apache-2.0). Complémentaire : srai
  produit les mailles, intreepid les fait raisonner.

**afterrealism/duckdb-spatial-docsbox-mcp** — <https://github.com/afterrealism/duckdb-spatial-docsbox-mcp> — ~0★ — MIT — actif — NOUVEAU
- Idée : serveur MCP **read-only** vers DuckDB + extension `spatial`, avec validateur SQL statique et
  corpus de doc offline. Thèse : « un MCP DuckDB générique à accès CLI brut est un footgun ».
- Implémentation : validation via `sqlglot` (dialecte duckdb), connexion `read_only=True` au niveau storage,
  timeout par requête, introspection spatiale.
- Lien intreepid : C1+C3+**P3** — littéralement la brique #1 formalisée par un tiers.
- Verdict : **inspiration/blueprint** du garde-fou read-only + validateur SQL — **et contre-exemple utile
  au test de plus-value** : « DuckDB MCP read-only » est faisable par tout tiers ⇒ le plus d'intreepid
  vit au-dessus.

**iamvibhorsingh/bbox-mcp-server** — <https://github.com/iamvibhorsingh/bbox-mcp-server> — ~3★ — MIT — actif — NOUVEAU
- Idée : MCP « 6 tools, zero config » ; `aggregate_overpass_h3` = requête Overpass → **binning H3 côté
  serveur** → analyse de densité ; le LLM reçoit des hex agrégés, pas la géométrie.
- Verdict : **inspiration/pattern canonique** « binning H3 server-side, le LLM ne voit que l'agrégat »
  (P1/P2), carte vérifiable (anti-hallucination). Micro-repo à lire, pas à réutiliser.

**pothos-dev/geoagentbench** — <https://github.com/pothos-dev/geoagentbench> — ~0★ — Apache-2.0 — actif — NOUVEAU
- Idée : banc d'éval *black-box* d'agents géo (36 tâches, CRS/analyse/format GeoParquet, graders déterministes).
- Verdict : **inspiration** (méthode d'éval déterministe rejouable, P4) — utile quand intreepid voudra
  mesurer ses agents. Voir aussi GeoBenchX, GeoAnalystBench (§5).

**Mentions** : `89nisham/geolibre-cli` (CLI+MCP DuckDB spatial « sorties assez petites pour être lues par
un agent » — recoupe P2), `mbzuai-oryx/OpenEarthAgent` (registre de tools + orchestrateur qui valide/caches —
sans licence, EO raster).

**À écarter** : gladcolor/LLM-Geo & Teakinboyewa/SpatialAnalysisAgent (code-gen, GPL — contre-exemples),
GeoRetina/chat2geo (archivé, démo WOW), BuntingLabs/mundi.ai (AGPL, web-GIS PostGIS), opengeos/geoai (deep
learning imagerie, pas LLM conversationnel), rohinmanvi/GeoLLM, AGI-GIS/MapGPT, iamtekson/GeoAgent &
MahdiFarnaghi/intelli_geo & BuntingLabs/kue-qgis-plugin (plugins QGIS — voir §5 QGIS).

**Pistes non creusées** : **test anti-MAUP multi-résolution H3** comme discipline automatisée — aucun repo
ne le fait (trou de marché, plus-value propre) ; `chrislyonsKY/geoflow-stac-mcp` (STAC + Rust + DuckDB edge).

---

## 3. Serveurs MCP data & géo : read-only, garde-fous, fiche-contexte, geoportails (C3, P2/P3, P7)

> Imposer le read-only au moteur, borner les ressources, exposer un **schéma/fiche comme contexte de
> vérité** avant génération (anti-hallucination), brancher les geoportails (dont suisses).

**Ce qui existe / ce qui manque.** Le read-only imposé au niveau *moteur* (transaction READ ONLY +
`statement_timeout`) plus validation statique (`sqlglot`/denylist, auto-`LIMIT`) est un pattern mûr et
copiable (meilleur exemplaire : `afterrealism/postgres-postgis-docsbox-mcp`). **H3-en-MCP existe**
(`overnin/h3-mcp`). Le geoportail suisse est couvert et vivant (swisstopo-mcp). Manque : **`profile_stats`
(carte d'identité sans lignes) n'existe nulle part** — tous renvoient lignes ou schéma technique ; et
**GeoParquet read-only en MCP** semble inexistant.

**afterrealism/postgres-postgis-docsbox-mcp** — <https://github.com/afterrealism/postgres-postgis-docsbox-mcp> — ~0★ — MIT — actif — NOUVEAU
- Idée : accès read-only *borné* PostgreSQL/PostGIS, defence-in-depth explicite.
- Implémentation : (1) validation `sqlglot` + denylist (refuse hors `SELECT/WITH/EXPLAIN`, bloque
  multi-statements, **auto-injecte `LIMIT`**) ; (2) transaction READ ONLY + `statement_timeout`/`lock_timeout`
  + rollback inconditionnel ; (3) row/byte caps, géométrie en GeoJSON ; (4) `pick_interesting_tables`
  (score log10(rows)+densité géom+FK-hub), `postgis_help` (recettes curées), docstrings avec exemple JSON.
- Lien intreepid : cœur de C3 read-only (P3) ; `pick_interesting_tables` + SRID/geom-flag préfigurent une
  fiche ; `postgis_help` = « contexte de vérité ». Couche `query_sql`/`describe`.
- Verdict : **inspiration forte (quasi-blueprint)** — modèle pour dé-halluciner `query_sql` (moteur +
  sqlglot, pas regex). Réserve : renvoie des lignes → durcir vers profils/agrégats pour P2.

**overnin/h3-mcp** — <https://github.com/overnin/h3-mcp> — ~0★ — MIT — actif — NOUVEAU
- Idée : raisonnement spatial par opérations ensemblistes H3 composables (« primitives, pas workflows figés »).
- Implémentation : ~11 outils (`h3_geo_to_cells`, `h3_k_ring`, `h3_change_resolution`, `h3_compare_sets`,
  `h3_aggregate`, `h3_find_hotspots` z-score, `h3_distance_matrix`…). Anti-hallucination : ingestion GeoJSON
  par batch (jamais de lat/lng au prompt), **handles `cellset_id` passés entre outils**, `return_mode="summary"`
  par défaut. Livré avec des `skills/` enseignant le chaînage.
- Lien intreepid : réponse directe aux primitives spatiales H3 de C3 ; le pattern **handle + summary** EST
  P2 (le LLM manipule des références/agrégats). Invalide « H3-en-MCP n'existe pas ».
- Verdict : **réutiliser / inspiration majeure** (MIT) — à deep-forker pour nos primitives spatiales.

**malkreide/swisstopo-mcp** — <https://github.com/malkreide/swisstopo-mcp> — ~4★ — MIT — actif — déjà connu (re-jugé à la hausse)
- Idée : toute l'infra géodonnées fédérale suisse via MCP, sans auth.
- Implémentation : 20 outils (REST 500+ couches, géocodage, altitude/profils, STAC, WMTS, cadastre OEREB,
  geodienste.ch OGC/WFS, Overpass, OpenPLZ). Point clé : **résolution PLZ → commune/n° BFS → district →
  canton**, le **n° BFS étant la clé de jointure officielle** vers d'autres MCP statistiques.
- Lien intreepid : contexte suisse ; la clé BFS = pattern « relations entre datasets » de la fiche YAML ;
  STAC/OEREB = sources réelles de session.
- Verdict : **réutiliser** comme MCP amont read-only + **inspiration** pour la clé de jointure sémantique
  dans `describe`. À vendorer (facteur bus = 1).

**stuzero/pg-mcp-server** — <https://github.com/stuzero/pg-mcp-server> — ~540★ — MIT — dormant 09.2025 — déjà connu
- Idée : MCP Postgres « resource-oriented » pour agents.
- Implémentation : **MCP Resources** pour la découverte de schéma (descriptions du catalogue + row counts,
  contraintes, index) ; `pg_query` read-only + `pg_explain` ; **contexte d'extensions en YAML** (PostGIS,
  pgvector : types, fonctions, exemples, best practices) ajoutable par fichiers.
- Lien intreepid : le **contexte-extension YAML** est le plus proche parent de la **fiche de connaissance
  YAML** (`describe`) trouvé ; Resources catalogue = schéma-comme-vérité.
- Verdict : **inspiration forte** pour la fiche YAML + MCP Resources. Fournit `sample table data` (lignes) →
  ne pas reprendre pour P2. Idée durable malgré le statut dormant.

**motherduckdb/mcp-server-motherduck** — <https://github.com/motherduckdb/mcp-server-motherduck> — ~504★ — MIT — actif — déjà connu
- Implémentation : **read-only par défaut**, caps `--max-rows`/`--max-chars`/`--query-timeout`, `--init-sql`
  (durcissement « Securing DuckDB »), connexions éphémères. Avertit : « read-only seul ne suffit pas »
  (filesystem, settings DuckDB).
- Verdict : **inspiration** (caps + durcissement) mais **contre-exemple sur P2** : renvoie du JSON de
  **lignes brutes** → un client LLM générique + ce MCP = exactement le « chatbot devant une BDD » refusé.

**crystaldba/postgres-mcp** (« Pro ») — <https://github.com/crystaldba/postgres-mcp> — ~3,1k★ — MIT — actif — déjà connu
- Implémentation : read-only/read-write configurable, **safe SQL parsing**, health checks, simulation
  d'index hypothétiques via EXPLAIN, « Schema Intelligence ».
- Verdict : **inspiration** (safe SQL parsing + schema-aware generation, EXPLAIN ≈ P4) mais orienté
  DBA/tuning (hors-scope). Garder les patterns, écarter la dépendance.

**dbt-labs/dbt-mcp** — <https://github.com/dbt-labs/dbt-mcp> — ~596★ — Apache-2.0 — actif — déjà connu
- Implémentation : `list_metrics`/`query_metrics`/`get_dimensions`/**`get_dimension_values`** (métriques
  gouvernées, pas de SQL libre), `get_metrics_compiled_sql` (SQL sans exécution = rejouable).
- Lien intreepid : **couche sémantique gouvernée** (anti chatbot-BDD) ; `get_dimension_values` ≈ valeurs
  distinctes sans lignes brutes (aligné P2) ; `compiled_sql` = P4.
- Verdict : **inspiration conceptuelle forte** (« expose des agrégats/dimensions, pas des lignes ») ;
  dépendance dbt Cloud = plomberie lourde (contre P7). Retenir le pattern.

**teaguesterling/duckdb_mcp** — <https://github.com/teaguesterling/duckdb_mcp> — ~61★ — Apache-2.0 — actif — NOUVEAU
- Idée : MCP **en tant qu'extension DuckDB** (`PRAGMA mcp_server_start`), + publication de **requêtes SQL
  paramétrées comme outils** découvrables, sorties JSON/JSONL/**Markdown token-efficient**/CSV.
- Verdict : **inspiration** (custom tools = agrégats curés ; format token-aware). Renvoie des lignes par
  défaut → durcir pour P2.

**Mentions** : `chirikuuka/mlit-geospatial-mcp` (~183★, geoportail national japonais via MCP — **précédent
direct de swisstopo**, valide l'approche), `diogocosme/geodados-mcp-server` (géoportail Lisbonne — **MCP
Resources schéma/CRS avant code-gen + MCP Elicitation** qui *demande* en cas d'ambiguïté ; répond au mode
d'échec mesuré par geoagenteval), `audityourcontracts/livefire-mcp` (MCP volontairement *narrow* + méthode
d'éval agent-vs-CLI), `modelcontextprotocol/servers` (référence Resources/schéma ; licence NOASSERTION).

**À écarter** : reading-plus-ai/mcp-server-data-exploration (charge CSV + exécute Python arbitraire —
double violation P2/P3), ktanaka101/mcp-server-duckdb (un seul outil, ni caps ni timeout), jagan-shanmugam/
open-streetmap-mcp (redondant avec swisstopo), et divers MCP PostGIS 0★ sans licence ou AGPL
(`KogniTEra/postgis-mcp`, `ViVi141/china-1m-geodata-postgis-mcp` AGPL).

**Pistes non creusées** : **`profile_stats` comme outil MCP premier** — trou blanc confirmé (les plus
proches sont `get_dimension_values`, `list_srids`) → creuser côté DuckDB `SUMMARIZE` + profilers §4 ;
**GeoParquet read-only en MCP** = `gh search "geoparquet mcp"` ≈ 0 → implémentation vierge pour C3 ; **MCP
Elicitation** (dialogue clarifiant `describe`) à investiguer côté spec MCP 2026.

---

## 4. Profiling, `profile_stats`, découverte/scoring d'insights, dérive (P2 §4.2, découverte proactive)

> Le LLM lit une **carte d'identité statistique** (jamais les lignes) ; scorer/prioriser les insights ;
> détecter la dérive comme diff de profils (jobs FME Flow proactifs).

**Ce qui existe / ce qui manque.** Modèle de sortie mûr : **ydata** (taxonomie d'alertes de 20 types),
**whylogs** (profils **mergeables/versionnables** = dérive-par-diff), **evidently** (report JSON +
test-suites pass/fail auto-générées), **popmon** (dérive temporelle par time-slices). Le **scoring
d'insights** reste théorique (QuickInsights/MetaInsight, papers ; réimplémentations OSS anecdotiques).
**Aucun profiler mainstream ne couvre le spatial** — angle mort à combler maison. `profile_stats` reste à
écrire en SQL DuckDB pushdown ; on emprunte la *forme* de sortie et les alertes.

**ydataai/ydata-profiling** — <https://github.com/ydataai/ydata-profiling> — ~13,7k★ — MIT — actif — déjà connu
- Implémentation : `model/alerts.py`, enum `AlertType` de **20 membres** — `CONSTANT, ZEROS, HIGH_CORRELATION,
  HIGH_CARDINALITY, DUPLICATES, NEAR_DUPLICATES, SKEWED, IMBALANCE, MISSING, INFINITE, UNIQUE, DIRTY_CATEGORY,
  UNIFORM, NON_STATIONARY, SEASONAL, EMPTY…`. Sortie `to_json()`.
- Lien intreepid : **la référence directe pour la taxonomie d'alertes de `profile_stats`** (les « faits » ;
  le LLM ajoute le « regard » : 999 sentinelle, nulls concentrés). `UNIQUE`, `NON_STATIONARY`, `SEASONAL`,
  `SKEWED`, `HIGH_CARDINALITY` recoupent la spec.
- Verdict : **inspiration forte** (reprendre la liste d'alertes, MIT). Ne pas embarquer (Pandas, pas de
  pushdown DuckDB, pas de spatial).

**whylabs/whylogs** — <https://github.com/whylabs/whylogs> — ~2,8k★ — Apache-2.0 — ralenti — déjà connu
- Idée : le **profil** comme objet de première classe, compact, **mergeable** (streaming/distribué) et
  **diffable** (drift report) ; `Constraints` pass/fail.
- Lien intreepid : **« dérive = diff de profils »** = socle de la découverte proactive (reprofilage FME
  Flow vs profil de référence) ; mergeabilité = agrégation multi-partitions.
- Verdict : **inspiration structurante** du design de profil (compact/mergeable/diffable) — à copier dans
  `profile_stats`. Écarter comme dépendance (couplé au SaaS WhyLabs).

**evidentlyai/evidently** — <https://github.com/evidentlyai/evidently> — ~7,8k★ — Apache-2.0 — actif — déjà connu
- Idée : Reports (100+ métriques, drift) → Test Suites avec **auto-génération des conditions depuis une
  baseline** ; sortie **JSON/dict** consommable par un LLM.
- Lien intreepid : le cycle *report exploratoire ↔ test suite de régression auto-générée* = « profil de
  référence → détection de dérive → ouverture de QUESTION ». Format JSON = cible pour la carte d'identité.
- Verdict : **inspiration forte** (format de sortie + auto-seuils). Écarter comme dépendance (lourd, ML-obs).

**ing-bank/popmon** — <https://github.com/ing-bank/popmon> — ~512★ — MIT — actif — NOUVEAU
- Idée : stabilité d'un dataset dans le **temps** — histogrammes binnés en time-slices, comparés dans le
  temps ET vs référence, **traffic-light** automatique.
- Lien intreepid : couvre directement les alertes temporelles (ruptures de volume, trous de série,
  saisonnalité) et la logique reference-vs-current de la découverte proactive.
- Verdict : **inspiration** ciblée sur la dérive temporelle (plus abouti qu'ydata sur ce point). Pas de spatial.

**QuickInsights / MetaInsight** (Microsoft Research, SIGMOD 2019/2021 — papers) — déjà connu
- Idée : scoring d'insight sur **impact × significance** (par type d'insight) + ranking par utilité
  (MetaInsight : commonness/exception).
- Verdict : **inspiration théorique** — le cadre à réimplémenter sur DuckDB pour scorer/prioriser les
  insights. Réimplémentations OSS (`Kinigopoulos/metainsight`, `qwerty-aditya/QuickerInsights`) **vérifiées
  vides/sans licence → écartées**.

**DataSage** (arXiv 2511.14299, ByteDance — pas de repo) — NOUVEAU (non-code)
- Idée : découverte d'insights multi-agents par **boucle QA divergente-convergente** ; un *judge agent*
  sélectionne les questions à fort potentiel (« non-trivial or surprising », diversité, complémentarité) ;
  « Negative Reasoning ».
- Verdict : **inspiration algorithmique** pour la **priorisation de questions** (curateur/greffier) et le
  couple candide/critique. Pas de code.

**À écarter** : Kanaries/Rath (AGPL, auto-EDA viz — réinvention BI), Kanaries/pygwalker (Tableau-like, WOW),
man-group/dtale (visualiseur humain), lux-org/lux (viz, abandonné), sfu-db/dataprep (stagnant), sweetviz/
AutoViz (auto-EDA visuel HTML), great-expectations (validation d'attentes connues ≠ découverte — utile
plus tard pour figer un profil en contrat).

**Pistes non creusées** : profiling **spatial** (emprise, densité/région, plus-proche-voisin, taux de
géométries invalides) → maison en SQL DuckDB spatial, source d'algos côté geopandas/pysal/esda ; schéma de
sortie JSON précis d'evidently/whylogs à calquer pour `profile_stats` ; AgentAda (« skill-adaptive insight
discovery », repo non confirmé).

---

## 5. Rigueur : modèles nuls, causalité, validation spatiale, agents adverses, honnêteté (critique/candide, P6, Q-0009)

> Valider statistiquement **avant** de retenir un insight ; modèles nuls spatiaux ; réfutation causale ;
> anti-leakage ; agents adverses ; savoir s'abstenir.

**Ce qui existe / ce qui manque.** Briques solides directement réutilisables comme outils MCP : `dowhy`
(réfutation causale), `esda` (modèles nuls spatiaux + **test MAUP tout fait**), `spacv`/`statsmodels`
(validation, multi-tests). Sur les agents adverses, la littérature 2025-2026 est **sceptique** : le débat
multi-agents naïf coûte cher et *dégrade* souvent (sycophantie, consensus prématuré) — à cadrer comme
contre-exemple. Le repo le plus inspirant est `hsd2514/geoagenteval` (opérationnalise P6 sur données géo).

**py-why/dowhy** — <https://github.com/py-why/dowhy> — ~8,2k★ — MIT — actif — déjà connu
- Implémentation : `causal_refuters/` — `placebo_treatment_refuter`, `data_subset_refuter`, `bootstrap_refuter`,
  `dummy_outcome_refuter`, `add_unobserved_common_cause`, `random_common_cause`, `linear_sensitivity_analyzer`.
- Lien intreepid : cœur de l'**agent critique**. Le refuter `placebo`/`dummy_outcome` EST un modèle nul
  générique (permute le traitement → l'effet doit s'effondrer) ; la sensibilité chiffre P6 ; répond au piège
  pilote « trafic ≠ danger » (confounding).
- Verdict : **réutiliser comme outil MCP `refute_insight`** — le candidat le plus direct.

**pysal/esda** — <https://github.com/pysal/esda> — ~255★ — BSD-3 — actif — déjà connu
- Implémentation : `significance.py` → pseudo-p par **permutation conditionnelle** ((M+1)/(R+1)) = « générer
  le contrefactuel aléatoire » ; **`smaup.py`** (classe `Smaup`) = **test statistique dédié à la sensibilité
  au MAUP** ; `crand.py` (moteur de randomisation numba).
- Lien intreepid : **modèles nuls spatiaux + MAUP outillé** (rare) + autocorrélation. Directement branché
  sur le cas H3 (l'agrégation hexagonale EST une instance de MAUP).
- Verdict : **réutiliser comme outil MCP** — la brique la plus alignée avec la « rigueur spatiale à
  instruire » (Q-0009). BSD.

**SamComber/spacv** — <https://github.com/SamComber/spacv> — ~52★ — BSD-3 — inactif 2024 — NOUVEAU
- Idée : validation croisée spatiale (grid CV, cluster CV, **spatial leave-one-out avec buffers**).
- Lien intreepid : réponse directe à la **prévention de fuite spatiale (spatial leakage)** en validation ML
  (Q-0009) — les buffers SLOO empêchent qu'un point autocorrélé fuite entre train/test.
- Verdict : **inspiration / réutiliser prudemment** (petit, inactif, BSD). Alternative DIY : GroupKFold +
  clusters spatiaux. Voir aussi `geoai-lab/spatialCV` (matériel pédagogique, GPL — *quand* la CV spatiale
  sur-corrige : nuance P6).

**statsmodels/statsmodels** — <https://github.com/statsmodels/statsmodels> — ~11,5k★ — BSD-3 — actif — NOUVEAU
- Idée : `stats.multitest` (Bonferroni, Benjamini-Hochberg FDR, Holm).
- Verdict : **réutiliser** pour les **corrections multi-tests** (garden of forking paths quand un agent teste
  des dizaines d'hypothèses) — substitut licence-safe à Pingouin (GPL).

**DoubleML/doubleml-for-py** — <https://github.com/DoubleML/doubleml-for-py> — ~765★ — BSD-3 — actif — NOUVEAU
- Idée : double ML + `sensitivity_analysis()` (bornes de biais, robustness values) face au confondeur non observé.
- Verdict : **réutiliser en complément de dowhy** pour la sensibilité causale (chiffre l'incertitude, P6). BSD.

**hsd2514/geoagenteval** — <https://github.com/hsd2514/geoagenteval> — ~0★ — MIT — actif — déjà connu (re-jugé nettement à la hausse)
- Idée : benchmark d'agents géo sur **create/audit/repair/abstain**, scoring **uniquement sur l'état final
  PostGIS, jamais LLM-judge**.
- Implémentation : `TrialRecord.silent_spatial_error` (l'agent « réussit » en produisant du GIS silencieusement
  faux : CRS traps, layers périmés, prédicats de frontière, multiplicité de jointure) ; abstention gradée sur
  un **`reason_code` d'enum fixe** ; métriques pass@1, silent-error-rate, abstention-accuracy. Finding : tous
  les modèles résolvent silencieusement une requête ambiguë (« la rivière » quand 3 existent) au lieu de
  demander clarification ; ground truth accessible seulement au vérifieur.
- Lien intreepid : **coïncidence quasi parfaite avec P6** — erreur silencieuse à détecter, abstention gradée,
  « jamais LLM-judge » = pas de complaisance ; **réplique du parti pris de l'oracle brique #1** (assertions
  déterministes). Meilleure incarnation de « détecter les questions non répondables ».
- Verdict : **inspiration majeure / harnais d'éval à adapter** — adopter `silent_spatial_error` +
  abstention-sur-enum comme métriques. Se pense avec `diogocosme/geodados` (§3, Elicitation = la parade au
  mode d'échec mesuré ici).

**facebookresearch/AbstentionBench** — <https://github.com/facebookresearch/AbstentionBench> — ~87★ — NOASSERTION — actif — NOUVEAU
- Idée : benchmark d'abstention (20 datasets, 6 scénarios : sous-spécifié, mal posé, données périmées…).
  Finding : le fine-tuning de raisonnement **dégrade** l'abstention.
- Verdict : **inspiration** (taxonomie d'abstention + protocole d'éval P6). Vérifier la licence NOASSERTION.

**Multi-agents / débat** — **Skytliang/Multi-Agents-Debate** (~599★, GPL), **composable-models/llm_multiagent_debate**
(~544★, sans licence), **thunlp/ChatEval** (~340★, Apache-2.0), **microsoft/autogen** (~60k★, CC-BY-4.0),
**SakanaAI/AI-Scientist** (~14,3k★, RAIL).
- Lien/verdict : archétypes writer/critic + juge, mais la littérature 2025-26 **contredit** le « N agents ×
  R rounds = mieux » (souvent battu par un agent seul). **Contre-exemples documentés** : déclencher le
  critique **sélectivement** (sur les découvertes candidates), pas en continu — converge avec la
  proportionnalité de la charte. ChatEval (Apache-2.0) = seule licence propre pour un module juge ;
  autogen/AI-Scientist = poids/over-engineering ou WOW-theatre à écarter comme socle.

**SihengLi99/LLM-Honesty-Survey** — <https://github.com/SihengLi99/LLM-Honesty-Survey> — ~66★ — sans licence — inactif — NOUVEAU
- Verdict : **piste bibliographique** (self-knowledge + self-expression, « Don't Hallucinate, Abstain ») pour
  formaliser P6. Pas de code.

**À écarter** : raphaelvallat/pingouin (GPL contaminant → statsmodels), vectara/FaithJudge (fidélité RAG
texte ≠ validité statistique, sans licence), stpku/GeoTask & kyle-gao/SecuringGISAgent (vérifiés mais hors
axe E strict — voir §6/§7 et vigilance sécurité Q-0008).

**Pistes non creusées** : littérature « débat sélectif » (DOWN « Debate Only When Necessary », « Debate or
Vote ») ; `pysal/spopt` (régionalisation → MAUP) et `pysal/spreg` (régression spatiale, tests LM
d'autocorrélation résiduelle) ; modèles nuls écologiques (curveball/swap sur matrices de présence)
transposables aux mailles H3.

---

## 6. Greffier & arbre d'exploration : provenance, canvas branchant, replay (greffier, arbre-carte, mémoire épisodique)

> Capturer tout le raisonnement (y compris abandons + raisons), la session comme **arbre** immuable, le
> **couplage arbre ↔ carte** et les **zones blanches**, le **mode replay**, l'anti-hairball.

**Ce qui existe / ce qui manque.** Trois familles, aucune ne couvre la signature seule : (1) provenance-viz
académique (Trrack, VisTrails, Verdant) = meilleurs *modèles de nœud/état non-linéaires* + anti-hairball par
sédimentation/collapse ; (2) canvas de chat branchant 2025-2026 (forky, GitChat, llm-canvas, loom) = valident
arbre+fork+merge, forky va le plus loin (DAG SQLite + merge 3-voies) ; (3) standards de lineage (OpenLineage,
kedro-viz) = lignée données, pas raisonnement. **Le couplage arbre↔carte et les zones blanches n'existent
nulle part** : le vrai delta intreepid.

**ishandhanani/forky** — <https://github.com/ishandhanani/forky> — ~36★ — **sans licence** — actif — déjà connu (re-jugé)
- Idée : gestion git-style des chats LLM en **DAG** avec fork ET **merge 3-way sémantique** (LCA + résumé
  d'état + détection de conflits).
- Implémentation : `conversation_node.py` (nœud + métadonnées de merge), `conversation_tree.py` (DAG + logique
  merge), `database.py` (**persistance SQLite**), `merge_utils.py` (LCA). Web UI (clic=checkout, multi-select=merge).
- Lien intreepid : **le modèle de données de nœud le plus directement réutilisable** — DAG persisté SQLite,
  checkout/fork/merge, attribution ; le merge sémantique (extraction faits/décisions/hypothèses) ≈ distillation
  du greffier. Recoupe la mémoire épisodique.
- Verdict : **inspiration prioritaire** — deep-read du schéma nœud/DAG et du merge LCA. **Réserve : aucune
  licence** → lire, ne pas copier.

**visdesignlab/trrack** → **Trrack/trrackjs** — <https://github.com/Trrack/trrackjs> — ~25★ — BSD-3 — actif — déjà connu (re-jugé)
- Idée : graphe de provenance **non-linéaire** de l'état d'une viz (branches, métadonnées/annotations par
  nœud, undo/redo/checkout), avec composant `trrack-vis`.
- Lien intreepid : le patron le plus proche de la **mémoire épisodique** (arbre immuable sérialisable) et du
  **greffier** (métadonnées/annotations par nœud) ; `trrack-vis` inspire la sémantique de zoom.
- Verdict : **inspiration forte** (schéma nœud=état+action+annotation transposable au format épisodique
  DuckDB/JSON ; BSD). Écarter le code (JS/viz web).

**langchain-ai/langgraph** — <https://github.com/langchain-ai/langgraph> — ~38,4k★ — MIT — actif — déjà connu (re-jugé)
- Idée : **checkpointing durable** par super-step + **time-travel/replay/fork** (reprise depuis un checkpoint
  = nouveau fork de timeline).
- Implémentation : `SqliteSaver`/`PostgresSaver`, `update_state`, invocation par `checkpoint_id`.
- Lien intreepid : la **mécanique replay/fork de référence** — checkpoints = nœuds immuables, fork =
  bifurcation. Substrat candidat pour matérialiser l'arbre persistant + le **mode replay**.
- Verdict : **réutiliser (infrastructure)** pour replay/checkpointing (MIT). **Contre-exemple sur l'UX** : ni
  viz d'arbre, ni anti-hairball, ni couplage carte — fournit le substrat, pas la signature. (Bug connu #4987
  sur checkpoint_id de fork — à vérifier.)

**mkery/Verdant** — <https://github.com/mkery/Verdant> — ~152★ — MIT — dormant 2023 — déjà connu
- Idée : capture **automatique** de l'historique d'un notebook Jupyter, indexée **par artefact** (cellule,
  output, snippet), pas par chronologie ; « Version Inspector » au survol → diff historique.
- Lien intreepid : capture-par-artefact + projection lisible = greffier non-intrusif + projection Quarto ;
  le survol→diff préfigure survol→emprise.
- Verdict : **inspiration forte** (modèle de fichier historique JSON par artefact, CHI'19). Écarter le code
  (JupyterLab, dormant).

**socketteer/loom** — <https://github.com/socketteer/loom> — ~1,4k★ — **sans licence** — dormant — déjà connu
- Idée : arbre multivers d'écriture ; état **« visited »** par nœud, expand/collapse, combine trees, I/O JSON.
- Lien intreepid : l'état **« visited » préfigure les zones blanches / territoire jamais visité** ;
  expand/collapse = anti-hairball ; combine trees = merge d'arbres.
- Verdict : **inspiration** (visited-state + collapse). Écarter le code (Tkinter, dormant, sans licence).

**LittleLittleCloud/llm-canvas** — <https://github.com/LittleLittleCloud/llm-canvas> — ~22★ — MIT — actif — NOUVEAU
- Idée : canvas infini de flux LLM (arbres, chemins parallèles, **viz des tool calls**), **package Python +
  UI embarquée** (`CanvasClient`, `add_message`, branchement).
- Lien intreepid : **Python + API programmatique** (un agent alimente le canvas comme le greffier alimenterait
  l'arbre) + **viz des tool calls** (les requêtes MCP de l'agent). MIT.
- Verdict : **inspiration / candidat viz** — le duo « lib Python qui pousse des nœuds + UI de rendu » est
  architecturalement proche de la cible. Maturité faible → inspiration d'API.

**Mentions** : `DrustZ/GitChat` (~97★, sans licence — branch/merge/minimap + **régénération en cascade** des
enfants quand un parent est édité), `tldraw/branching-chat-template` (~15★, MIT — squelette canvas tldraw :
pan/zoom/minimap gratuits), `OpenLineage/OpenLineage` (~2,6k★, Apache-2.0 — **facets extensibles** = patron
élégant pour attacher empreinte spatiale/attribution/raison d'abandon aux nœuds ; orienté lignée données),
`VisTrails` (BSD, Python 2 mort — ancêtre conceptuel du « version tree »).

**À écarter** : kedro-viz (graphe *statique* de pipeline, couplé Kedro), OpenLineage/Marquez comme dépendance
(lignée, pas raisonnement), micro-repos immatures (`benkohcc/branching-chat-tree`), papers sans repo
(GitOfThoughts, PROV-AGENT — idées notées, pas de code vérifiable).

**Pistes non creusées** : **couplage arbre↔carte + zones blanches** = delta introuvable (passe le test de
plus-value) ; **anti-hairball prêt à l'emploi** absent des libs OSS (React Flow/tldraw + Louvain/Leiden pour
collapse de communautés — Ogma le fait mais commercial) ; croiser facets OpenLineage × nœud Trrack pour un
schéma DuckDB/JSON d'arbre immuable ; PROV-DM (W3C) comme ontologie du greffier (Entity/Activity/Agent =
résultat/requête/auteur).

---

## 7. Mémoire & capitalisation : graphe temporel, biographie, playbook, scoutisme (P5/P9, mémoire sémantique/procédurale, curateur)

> Un agent frais hérite du contexte (P9) ; graphe d'insights avec **invalidation sans perte** ; biographie
> des données ; playbook ; **scoutisme** de datasets curé par agents.

**Ce qui existe / ce qui manque.** Le graphe temporel bi-temporel avec invalidation sans perte est mûr
(graphiti, kektordb) ; le clivage 2026 est architectural (Neo4j lourd vs vecteur seul vs single-binary
embarqué), avec Mem0 v3 qui *retire* le graphe comme contre-point. Côté scoutisme/catalogue curé et
capitalisation scientifique, l'espace est plus jeune : geodata-atlas et Kosmos sont les miroirs les plus directs.

**getzep/graphiti** — <https://github.com/getzep/graphiti> — ~29,3k★ — Apache-2.0 — actif — déjà connu
- Idée : « context graph » **bi-temporel** pour agents — chaque fait (edge) a `valid_at`/`invalid_at` +
  `created_at`/`expired_at` ; superseded, jamais supprimé ; traçabilité native via `EpisodicNodes` (source brute).
- Implémentation : extraction LLM à chaque `add_episode` ; **invalidation conflict-driven** (le LLM compare la
  nouvelle edge aux edges proches et détecte les contradictions) ; backend Neo4j/FalkorDB/**Kuzu (embarqué)** ;
  serveur MCP fourni ; ontologie custom Pydantic.
- Lien intreepid : couvre **directement** graphe temporel + invalidation (« réfuté par le critique » →
  `invalid_at` sans perte) + insight→source + cycle de vie/péremption.
- Verdict : **inspiration forte / réutiliser le modèle de données** (edge bi-temporel = référence). Réserve
  P7 : Neo4j lourd ; **Kuzu** atténue. Étudier comme spec de référence même sans l'adopter.

**sanonone/kektordb** — <https://github.com/sanonone/kektordb> — ~83★ — Apache-2.0 (LICENSE à clarifier) — actif — NOUVEAU
- Idée : « cognitive memory layer » en **un binaire Go** (vecteur HNSW + graphe temporel + moteur cognitif).
  Miroir presque 1:1 de la vision mémoire d'intreepid malgré ses faibles étoiles.
- Implémentation : **Epistemic Engine** (score de confiance classant chaque fait *crystallized/stable/volatile/
  contested* = statuts/cycle de vie des insights) ; **Semantic Git** (`VEvolve` : edges `superseded_by`/
  `evolves_from`, historique préservé, time-travel = **invalidation sans perte réifiée**) ; **contradiction
  detection** LLM (le critique) ; **decay** par couche (épisodique/sémantique/procédurale, Ebbinghaus + pin =
  péremption) ; **Knowledge Engine** (artefacts pré-compilés `entity_card`/`timeline`/`session_summary`,
  recompilés quand la source change = fiches biographie + chargement paresseux).
- Lien intreepid : P9, graphe temporel + invalidation + statuts + decay + provenance + playbook (couche
  procédurale). Backend **léger** (single-binary, pas de Neo4j) → aligné P7.
- Verdict : **inspiration majeure** (banc d'idées d'implémentation). Vigilance : jeune, mainteneur unique,
  licence à clarifier (NOASSERTION) → ne pas en dépendre en dur ; deep-read prioritaire du « Semantic Git ».

**FutureHouse Kosmos** (impl OSS **jimmc414/Kosmos**) — <https://github.com/jimmc414/Kosmos> — ~556★ — **sans licence** — actif — NOUVEAU
- Idée : AI scientist autonome tenant la cohérence sur ~200 rollouts via un **structured world model**
  partagé entre agent d'analyse et agent de littérature ; chaque claim du rapport est **tracé jusqu'à la
  source**.
- Implémentation (impl jimmc414) : compression de contexte 20:1, **KG Neo4j persistant** (hypothèse/expérience/
  finding survivent entre sessions), sandbox Docker, clients littérature, module `world_model`. (Implémente
  l'archi, ne reproduit pas encore les résultats du papier.)
- Lien intreepid : miroir direct du **partage de mémoire entre agents** + **insight→source traçable** +
  capitalisation cross-session (P5/P9).
- Verdict : **inspiration forte** (world model partagé + traçabilité claim→source). Réserves : impl **sans
  licence** (bloquant pour le code), Neo4j lourd. Lire pour l'architecture. Voir aussi `Future-House/robin`
  (~641★, Apache-2.0, prédécesseur).

**lust0yixiong/geodata-atlas** — <https://github.com/lust0yixiong/geodata-atlas> — ~0★ — données CC-BY-4.0 / code MIT — actif — déjà connu
- Idée : atlas de **7 565 entrées** de datasets géo/télédétection open data (12 catégories), **curé par un
  pipeline d'agents LLM**, bilingue, avec statut de vérification et preuves de source.
- Implémentation : agent LLM (découverte/jugement) + **lychee** (vérif URL) + dédup règles/probabiliste
  (Splink) + **Frictionless Data Package** + **Croissant** + Crawl4AI + dashboard Observable ; playbook
  documenté (`PIPELINE_PLAYBOOK.md`).
- Lien intreepid : miroir **direct** du **scoutisme de données** (ADR-0007, Q-0011) et du catalogue curé par
  agents avec provenance + dédup + vérification. Frictionless/Croissant = pistes de format pour les fiches biographie.
- Verdict : **inspiration majeure / réutiliser la méthode + les standards**. 0★ = ignorer le signal social ;
  l'artefact et la méthode sont le **blueprint méthodologique** du scoutisme. Pas une dépendance logicielle.

**mem0ai/mem0** — <https://github.com/mem0ai/mem0> — ~62k★ — Apache-2.0 — actif — déjà connu
- **Contre-point architectural** : algo passé (04.2026) en **ADD-only, une passe LLM, sans UPDATE/DELETE** ;
  **graphe retiré de l'OSS v3** (jugé rarement rentable vs vecteur : ~3× plus lent, ~2× tokens sur LOCOMO).
- Verdict : **contre-exemple instructif** (documente le coût du graphe) + inspiration retrieval multi-signal.
  Mais ADD-only sans invalidation ne gère PAS « réfuté sans perte » requêtable dans le temps — donc mem0 v3
  OSS ne suffit pas seul. À citer dans l'arbitrage graphe vs vecteur.

**letta-ai/letta** (ex-MemGPT) — <https://github.com/letta-ai/letta> — ~24k★ — Apache-2.0 — actif — déjà connu
- Idée : agents *stateful*, mémoire hiérarchique auto-gérée (l'agent édite sa mémoire via des outils),
  backend Postgres.
- Verdict : **inspiration** (gestion mémoire pilotée par l'agent — utile pour les MR de curation ; P9/P5 ;
  backend léger). Écarter comme cœur graphe temporel (pas son fort).

**Mentions** : `zjunlp/DataMind` (skill discovery = **playbook** généré, cf. §1), `NirDiamant/Agent_Memory_Techniques`
(~822★, Apache-2.0 — 30 notebooks comparatifs = carte de référence pour arbitrer les choix mémoire),
`mnemon-dev/mnemon` (~392★, Apache-2.0 — mémoire graphe single-binary, moins de garanties temporelles que kektordb).

**À écarter** : `ardhaecosystem/synapse` & `clawdbrunner/openclaw-graphiti-memory` (dérivés graphiti sans apport),
`Technion-Kishony-lab/data-to-paper` (~814★, MIT — re-jugé **stagnant** depuis 07.2025 ; l'idée « backward-
traceable » reste alignée mais projet gelé → inspiration conceptuelle), catalogues d'entreprise lourds
(OpenMetadata déjà en §1, Unity Catalog MCP, IBM Fusion — retenir les standards PROV-O/DCAT/Croissant, écarter
les produits), divers 0★ démos (dataset-discovery-agent, DATASCOUT…).

**Pistes non creusées** : deep-read du `world_model` de Kosmos (matérialisation claim→source) et du « Semantic
Git » de kektordb ; **Frictionless + Croissant** comme format cible des fiches biographie YAML ; **graphe
temporel de mémoire directement sur DuckDB** — aucun projet trouvé (gap/opportunité pour le backend léger,
aligné P7/C1) ; papers MemStrata (supersession déterministe = alternative au coût de l'invalidation LLM), ATOM.

---

## 8. Restitution & ML-as-MCP : BI-as-code, viz éphémère, ML spatio-temporel, multi-user (C5, C3bis, §9)

> Chat pilotant un canevas ; viz éphémère (MapLibre + charts) rendue **dans la conversation** ; insights
> validés → BI-as-code ; ML classique exposé en **outils MCP** (`train_model`/`predict`/`explain`) ;
> collaboration sérialisée par l'agent.

**Ce qui existe / ce qui manque.** La restitution (BI-as-code, notebooks réactifs, chart-specs sérialisables)
et le rendu en chat (**MCP Apps / MCP-UI**, spec officielle depuis 01.2026) sont **mûrs** — s'y adosser.
Restent **quasi vides** : (1) l'exposition de **modèles ML classiques comme outils MCP** (un seul exemple
concret, autre domaine) ; (2) la **collaboration multi-agent sérialisée** avec attribution native (académique
seulement). Ce sont les zones de plus-value d'intreepid.

**modelcontextprotocol/ext-apps** (MCP Apps, SEP-1865) — <https://github.com/modelcontextprotocol/ext-apps> — ~2,6k★ — Apache-2.0 — actif — NOUVEAU
- Idée : repo **officiel** de la spec + SDK **MCP Apps**, première extension officielle MCP (26.01.2026,
  fusion mcp-ui + OpenAI Apps SDK). UI (`ui://`, `text/html;profile=mcp-app`) inline dans Claude/ChatGPT/VS Code.
- Lien intreepid : la **norme à viser pour C5** (carte MapLibre, small multiples, graphes en chat) — plus
  stable que mcp-ui car standardisée et co-signée Anthropic/OpenAI.
- Verdict : **réutiliser (standard cible)**.

**MCP-UI-Org/mcp-ui** — <https://github.com/MCP-UI-Org/mcp-ui> — ~5k★ — Apache-2.0 — actif — déjà connu
- Idée : SDK communautaire pour UI interactives via MCP (HTML/URL/remote-DOM en iframe sandboxé, postMessage).
  Terrain de jeu de ce qui est devenu la spec.
- Verdict : **réutiliser** — base de la brique viz éphémère en chat (une carte MapLibre GL s'insère dans une
  resource `ui://`). Voir aussi `digitarald/mcp-apps-playground` (~73★, MIT — squelette copiable).

**antvis/mcp-server-chart** — <https://github.com/antvis/mcp-server-chart> — ~4,3k★ — MIT — actif — NOUVEAU
- Idée : serveur MCP générant **25+ types de graphiques** (@antvis) — l'agent choisit type + spec, le serveur rend.
- Verdict : **inspiration forte / réutiliser partiellement** (MIT) pour la viz éphémère non-carto. À arbitrer
  vs Vega-Lite comme format pivot LLM→viz (cf. `isaacwasserman/mcp-vegalite-server` — patron du **format pivot
  sérialisable/diffable**, mais **sans licence** + dormant → prendre l'idée).

**LGDiMaggio/predictive-maintenance-mcp** — <https://github.com/LGDiMaggio/predictive-maintenance-mcp> — ~60★ — MIT — actif — NOUVEAU
- Idée : **le seul exemple concret du pattern C3bis** — serveur MCP (FastMCP, Python 3.11+, `uvx`) exposant un
  workflow ML complet en outils : chargement signal → analyse spectrale → détection de défaut → sévérité →
  **rapport HTML interactif**. Positionné « augmente l'expert, ne le remplace pas ».
- Lien intreepid : **C3bis** — modèle déterministe invoqué comme outil MCP, LLM en amont/aval, jamais boîte
  noire. Stack Python/FastMCP identique. Domaine (vibration) transposable au risque d'accidents H3.
- Verdict : **inspiration forte** (MIT, testé) — patron d'architecture pour `train_model`/`predict`/`explain`.

**explainX/explainx** — <https://github.com/explainX/explainx> — ~452★ — MIT — actif — NOUVEAU
- Idée : API unifiée SHAP/LIME/surrogate/counterfactuals ; **structure la sortie pour qu'un LLM la lise** et
  propose des correctifs ; résumés en langage naturel.
- Lien intreepid : **C3bis aval** — explicabilité formatée pour le LLM = « traduire les importances en métier ».
- Verdict : **réutiliser en dépendance** (MIT) — candidat pour l'outil MCP `explain` à wrapper (aucun
  « SHAP-as-MCP » prêt à l'emploi n'existe → ce wrapper serait de la plus-value).

**alteryx/evalml** — <https://github.com/alteryx/evalml> — ~852★ — BSD-3 — semi-actif — NOUVEAU
- Idée : AutoML avec **splitters de validation temporelle** (TimeSeriesSplit), importances intégrées.
- Verdict : **candidat / inspiration** (BSD) pour la **validation croisée TEMPORELLE** reproductible + GBM/GLM
  (C3bis) — à comparer à scikit-learn + splitters spatio-temporels maison.

**Confirmations « s'adosser »** (déjà connus, re-jugés OK) :
- **evidence-dev/evidence** (~6,8k★, MIT) — **réutiliser** : LA cible BI-as-code (SQL+markdown, diffable,
  générable par LLM), alignée GitLab.
- **marimo-team/marimo** (~22,1k★, Apache-2.0) — **réutiliser** : notebook **réactif** en `.py` pur (diffable/
  git), SQL intégré ; le graphe réactif évite les états incohérents d'un Jupyter généré par LLM. Meilleur
  candidat « notebook curaté rejouable ».
- **quarto-dev/quarto-cli** (~5,9k★, licence à vérifier — GPL-2 en pratique) — **inspiration/réutiliser** :
  cible de l'artefact « notebook curaté ». Lever la licence avant dépendance dure.
- **mapbox/mcp-server** (~351★, MIT) — **inspiration** pour le patron MCP-UI+carte (`docs/mcp-ui.md`), mais
  **contre-choix techno** (Mapbox GL propriétaire ≠ MapLibre) → reprendre le pattern, pas la dépendance.

**À écarter** : rilldata/rill (BI packagée, s'adosse mais pas brique diffable), apache/superset (BI classique
lourde), nveil-ai/nveil-toolkit (2★, **AGPL** — concept P2 proche mais licence + immaturité ; surveiller
l'idée), `mcp-use/mcp-maps-explorer` (0★, sans licence, Leaflet), hyungkwonko/chart-llm (dataset de recherche,
dormant).

**Ponts vides (plus-value potentielle)** : **ML classique en outils MCP** — `gh search "scikit-learn MCP" /
"xgboost MCP"` ≈ 0 (seul predictive-maintenance-mcp incarne le pattern) ; **SHAP-as-MCP** inexistant (explainX
à wrapper) ; **collaboration multi-agent sérialisée sans CRDT + attribution native** — uniquement académique
(S-Bus, EvoGit) → le choix intreepid « agent = point de sérialisation » est cohérent avec l'état de l'art mais
sera maison.

**Pistes non creusées** : lire `docs/mcp-ui.md` de mapbox (transposer à MapLibre) ; **couches H3 rendues via
MCP-UI** (niche probablement vide) ; arbitrage **Vega-Lite vs AntV** comme sérialisation LLM→viz ; garde-fous
d'exécution de marimo pour du code LLM non fiable.

---

## Enseignements transverses & trous blancs

1. **Le différenciateur défendable** n'est ni le chat ni la carte (banalisés : DuckDB-spatial-MCP read-only,
   H3-en-MCP, canvas branchant existent tous en OSS). C'est la **conjonction** : validation statistique
   outillée **avant** matérialisation (esda/permutations + `smaup`, dowhy/refuters, corrections multi-tests) +
   **provenance cliquable** (à la data-to-paper/Kosmos) + **mémoire distillée avec invalidation sans perte**
   (graphiti/kektordb) + **empreinte spatiale par nœud**. Aucun concurrent n'outille les quatre.
2. **Granularité de capture du greffier** (risque n°2 de l'overview) : Verdant et Mem0 convergent — capturer
   automatiquement mais **indexer par artefact/entité, pas par chronologie**. À graver dans le modèle de
   données de l'arbre.
3. **Anti-hairball** : collapse hiérarchique + focus (kedro-viz) et double vue linéaire/topologique + visited-
   state (loom). Prévoir l'agrégation de nœuds dès la conception (« sémantique du zoom »).
4. **Coût du critique** : la littérature du débat multi-agents est unanime — le gain plafonne (souvent battu
   par un agent seul) → **déclenchement sélectif** sur les découvertes candidates (proportionnalité de la charte).
5. **Trous blancs = feuille de route de la plus-value** (chacun confirmé vide par la recherche) :
   `profile_stats` comme proxy exclusif · couplage arbre↔carte + zones blanches · test anti-MAUP
   multi-résolution H3 automatisé · ML classique générique en outils MCP · multi-user sérialisé par l'agent ·
   graphe temporel de mémoire sur DuckDB. Chacun passe le test de plus-value (« qu'un client LLM générique +
   MCP DuckDB n'obtiendrait pas »).
6. **Corrections à intégrer aux questions ouvertes du spec** : Q-0004 (frontière charte↔fiche ← split
   Skill÷MCP de geo-perception ; fiche YAML ← pg-mcp-server + swisstopo clé BFS ; empreinte de reproductibilité
   ← specs rejouables) ; Q-0008 (durcissement de prompts ← SecuringGISAgent) ; Q-0009 (esda `smaup` + spacv +
   statsmodels multi-tests) ; Q-0011 (scoutisme ← geodata-atlas, Frictionless/Croissant).

---

## Repos écartés pour cause de non-existence / non-vérifiabilité

Aucun repo cité dans ce document n'a été retenu sans vérification `gh api`. Les éléments issus des sources
initiales qui **n'ont pas de repo GitHub vérifiable** (papers seulement) sont signalés comme tels et **ne
sont pas comptés comme repos** : GISclaw, GitOfThoughts, PROV-AGENT, DataSage, DOWN/« Debate or Vote »,
HalluLens, AgentAda. Ils figurent en « pistes » à titre bibliographique.
