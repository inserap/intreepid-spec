# État de l'art — le greffier : provenance analytique, arbre de trace, capture & distillation

> **Objet** : veille ciblée pour préparer le brainstorming de la **brique #4 — le greffier** (capture du
> raisonnement d'une session de découverte en arbre immuable, distillation ultérieure vers graphe/biographie).
> **Méthode** : recherche 2026-07-30 par **cinq agents parallèles** (1 analyse de code du repo identifié n°1,
> 4 recherches domaine). Chaque repo cité **vérifié via `gh api`** ; jugement sur le **code réel + la littérature
> empirique**, pas sur les étoiles. Licences relevées.
> **Référentiel** : la vision du greffier (`<IMPL:src>/docs/architecture/overview.md` §4.3, §6, §10 ; P4/P5/P9)
> + Q-0003 (granularité des nœuds) + Q-0004 (modèle de données de la trace).
> **Statut** : document de veille (process artifact). **N'engage aucune décision** — alimente le brainstorming ;
> les « décisions candidates » (§9) sont des propositions à instruire, pas des choix gravés. Amont : la veille
> `research/2026-07-29-etat-de-lart-github.md` §6 (greffier & arbre) et §7 (mémoire).

---

## 0. Corrections factuelles à la veille du 2026-07-29 (verify-don't-invent)

- **PROV-AGENT a bien un repo vérifiable et vivant** : c'est un sous-système de **`ORNL/flowcept`** (MIT, actif).
  La veille du 2026-07-29 le classait « paper sans repo » — à corriger (aucun repo ne s'appelle « prov-agent »).
- **Les conventions OpenTelemetry GenAI ont migré** hors de `open-telemetry/semantic-conventions` vers
  **`open-telemetry/semantic-conventions-genai`** (les anciens `docs/gen-ai/*.md` sont des stubs de redirection).
- **`Arize-ai/phoenix` est sous Elastic License 2.0 (ELv2), PAS OSI open-source** — à écarter/valider juridiquement
  avant tout usage produit (interdit de service managé, clés de licence).
- **Ragan et al. 2016 = 5 types de provenance, pas 6** (pas de type « cognitive » distinct).
- **`ishandhanani/forky` : ABSENCE de licence confirmée** (`gh api .../license` → 404) → tous droits réservés,
  lecture conceptuelle seulement, zéro copie de code.

---

## 1. Synthèse exécutive (le fil qui émerge des 5 agents)

**La littérature valide massivement le pari d'intreepid — mais inverse l'ordre naïf.** Le *quoi* (data / visualisation
/ interaction) se logge automatiquement et sans douleur ; le ***pourquoi*** (insight + rationale + abandons) est
précisément ce qui **ne se capture PAS automatiquement** (Ragan 2016) et dont **quarante ans de « design rationale »**
montrent qu'il **meurt de son coût de capture** dès qu'on le rend manuel-et-bloquant. La reconstruction du raisonnement
depuis les seuls logs **plafonne à 60–79 %** (Dou et al. 2009, étude contrôlée) — le reste, c'est le « pourquoi »,
absent des logs.

**La carte inédite du greffier agentique** : dans intreepid, **l'agent verbalise déjà son raisonnement** (hypothèses,
raisons d'abandon) dans son flux. Le greffier récolte ce rationale *en langage naturel, non-bloquant, informel*, puis
le **structure à la distillation** (formalisation incrémentale). Aucun des systèmes historiques (VisTrails, Trrack,
Verdant) n'avait cette carte : ils devaient soit inférer le pourquoi (échec à 60 %), soit le demander à l'humain
(échec par coût). C'est **exactement** le trou que le greffier comble — et il passe le test de plus-value : un client
LLM générique + MCP DuckDB loggue le *quoi*, jamais le *pourquoi structuré en arbre*.

**Cinq convergences fortes entre agents indépendants** (haute confiance, car recoupées) :
1. **Indexer par artefact/entité, PAS par chronologie** (Verdant, code ; Kery et al. CHI 2018, empirique : le versioning
   chronologique *dégrade* la lisibilité). Le temps devient un attribut, pas l'axe primaire.
2. **Deux natures de nœud** : le *pas de raisonnement* (topologie de l'arbre, façon Trrack) **et** l'*artefact versionné*
   (une hypothèse/requête/résultat qui évolue, façon Verdant). Elles ne sont pas la même chose ; le greffier a besoin des deux.
3. **Immuabilité append-only + branches mortes conservées** (Trrack : `freeze`, aucun prune ; langgraph : append par
   re-parent). forky est le **contre-exemple** (mutable : UPSERT + delete + full-flush).
4. **Facets extensibles** (OpenLineage) pour porter empreinte spatiale / raison d'abandon / attribution **sans muter le
   schéma de nœud** — schémas de facets côté fiche (agnosticité), pas dans le code.
5. **Distiller à la clôture, en 2 temps** : épisodique immuable = source de vérité rejouable (P4) ; sémantique
   (graphe/biographie) = dérivé **recompilable**, jamais source de vérité (non-déterminisme LLM).

**Le mécanisme de capture est déjà fourni par notre stack** : le **Claude Agent SDK expose un `SessionStore` custom**
— un tap immuable, ordonné, hors chemin critique, **garanti non-bloquant par contrat**. L'interdit du greffier
(« ne jamais interrompre le flow ») est tenu *par construction du SDK*, pas par discipline.

---

## 2. forky — analyse de code (le repo identifié n°1) : inspiration cadre, contre-exemple cœur

`ishandhanani/forky` — Python + `dataclasses` + `sqlite3` (stdlib) + FastAPI + React. **SANS LICENCE** (tous droits
réservés → lecture pour l'idée, **zéro copie**). Actif il y a ~6 mois. Stack alignée à la nôtre (sauf DuckDB vs SQLite).

**Ce qui se transpose (cadre) :**
- **`nodes` / `edges` en tables séparées, edge = PK `(parent_id, child_id)`** — la bonne fondation d'un DAG multi-parent.
  Répond à Q-0004 : le contrat = *deux relations*, pas une colonne `parent_id` unique.
- **Merge 3-voies = distillation LLM structurée.** `StateSummary(facts, assumptions, decisions, constraints,
  open_questions, definitions, context_notes)` — **quasi exactement l'ontologie de distillation** dont le greffier a
  besoin à la clôture. `MergeRejectionReason` (enum) + `MergeConflict.rationale` = **modèle direct pour « abandon + sa
  raison » typée** (ne pas laisser la raison en texte libre). `MergeProvenance{from_a, from_b, from_base}` = germe
  d'attribution par item.
- **Auto-fork anti-branche-anonyme** : toute divergence est matérialisée par un nœud nommé — bon principe.

**Ce qui NE se transpose PAS (divergences dures) :**
- ⛔ **Mutabilité** : `save_node` = UPSERT (réécrit le contenu en place), `delete_node` supprime + recâble le graphe,
  `save_to_db` = full-flush. **Frontalement incompatible** avec notre arbre immuable/append-only (P4). *Le principal
  « à ne pas imiter ».*
- ⛔ **Granularité = 1 nœud/message, aucun critère d'admission** : forky prend le grain le plus fin possible et ne filtre
  jamais → le régime « trop fin = bruit » que redoute notre CLAUDE.md. **forky ne résout pas Q-0003.**
- ⛔ Orienté **chat**, pas analyse de données : un nœud = `content:str`. Aucune notion de requête SQL/MCP, de résultat,
  d'empreinte spatiale, d'attribution multi-acteurs, de branche morte documentée.

**Verdict** : inspiration forte (nodes/edges + merge-as-distillation) ; **contre-exemple** (immuabilité, granularité) ;
écarter comme code (sans licence) et comme produit. On **réécrit** ; on ne porte pas. Fichiers réels lus :
`core/{conversation_node,conversation_tree,database,merge_utils,state_summary,semantic_diff,merge_executor}.py`.

---

## 3. Modèles de données de provenance (4 patrons, licences permissives → réutilisables)

| Projet | Licence / état | Contribution nette au greffier |
|---|---|---|
| **Trrack/trrackjs** | BSD-3, actif | Forme de l'**arbre immuable** : map plate `{nodes, current, root}` + `children[]` + **append-only + branches mortes gardées** + `meta` **ouvert** (préfigure les facets). State **full-vs-patch par nœud** (checkpoint OU JSON-Patch). `ephemeral:bool` (nœuds à sauter en navigation) + `group_id` (agrégation) = leviers anti-hairball. |
| **mkery/Verdant** | MIT, dormant (CHI'19) | **Indexation par artefact** : `Nodey` = *une version d'un artefact* (chaque artefact a sa lignée `versions[]`) ; `Checkpoint` = *événement temporel* qui ne stocke **que quels artefacts ont changé**. La question fréquente (« l'histoire de CETTE chose ») est O(1) ; le temps est rétrogradé en index dérivé. **La leçon de granularité, prouvée par le code.** |
| **langchain-ai/langgraph** | MIT, très actif | **Schéma de persistance disque** (le seul des 4) : PK `(thread_id, ns, checkpoint_id)` + **`parent_checkpoint_id`** (lignée par pointeur) + **append-only** (id UUID6 frais/pas) + **fork = re-parent** ; dédup blob par `(channel, version)`. Sur SQLite = notre stack. L'historique **suit la lignée parent, pas un scan temporel**. |
| **OpenLineage** | Apache-2.0, très actif | **Facets** : map ouverte, chaque facet requiert `_producer` + `_schemaURL` (auto-descriptif) + `additionalProperties:true`. Attacher `spatial_footprint` / `abandonment_reason` / `attribution` comme **facets custom** est l'usage *prévu* — sans muter le cœur du nœud. `_deleted` (tombstone) pour maj incrémentales. |

**Schéma composite recommandé (esquisse, à trancher au brainstorming) — DEUX types de nœud :**
- **`ThoughtNode`** (topologie de l'arbre) — *obligatoire* : `id` (ULID/UUID time-ordered → tri = chrono),
  `session_id`, `parent_id` (null=racine), `created_on`, `kind ∈ {root, hypothesis, query, observation, decision,
  dead_end, merge}`, `label`, `status ∈ {active, abandoned, superseded}`. *Optionnel* : `artifact_refs[]`,
  `attribution{human|agent, who, model, prompt_ref}`, `facets{}` (map ouverte OpenLineage), `meta{annotation[],
  bookmark[]}`, `ephemeral`, `group_id`.
- **`Artifact`** (indexé par artefact, Verdant) — `name` (identité stable), `kind ∈ {hypothesis, sql, mcp_call,
  aggregate, profile, spatial_footprint}`, `versions[]` (chacune : `state` = checkpoint OU patch, `created_on_node`,
  `origin?`). Un `ThoughtNode` **référence** des versions d'artefacts, il ne les inline pas.
- **Arêtes** : table `edges(parent_id, child_id)` séparée si l'on veut le DAG multi-parent (merge). Sinon `parent_id`
  suffit pour l'arbre pur.

**GAPS (aucun des 4 ne les porte — ce sont NOS contributions)** : empreinte spatiale (aucune notion géo nulle part) ;
raison d'abandon **réfléchie** (langgraph marque `fork`/`update` mais pas le *pourquoi* ; OpenLineage a `ErrorMessageRunFacet`
= erreur ≠ décision d'abandonner) ; attribution **humain-vs-agent-vs-prompt** par nœud ; **taxonomie sémantique de
raisonnement** (`kind`) — les 4 n'ont que des nœuds techniques. Ces gaps = exactement Q-0003/Q-0004.

---

## 4. Provenance analytique — la littérature & les retours d'expérience (le socle de la granularité)

**Taxonomies à adopter** : **Ragan et al. 2016** (TVCG) pour le *quoi* — 5 types **data / visualization / interaction /
insight / rationale** (les 3 premiers auto-capturables ; les 2 derniers non) — **×** **Gotz & Zhou 2009** pour le *grain*
— hiérarchie `Task → Sub-Task → Action → Event`, le niveau **Action** étant *« the semantic building blocks for insight
provenance »*. Les 5 types de Ragan ne sont **pas 5 sortes de nœuds** : ce sont **5 dimensions qu'un même nœud porte**.

**Heuristiques de granularité (publiées, actionnables) → politique par défaut proposée :**
> **Un nœud naît quand (a) une Action sémantique produit un résultat interprétable, OU (b) l'hypothèse/le sujet courant
> change (bifurcation).** Les *Events* bruts (tool call brut, re-render, tri) restent capturés mais **repliés sous l'Action**
> (multi-couches : fin en stockage, agrégé en lecture). Actions consécutives sur le même artefact → **coalescées**
> (chunking, Heer 2008). **Vocabulaire de `kind` petit et fermé** (inférabilité > richesse ; le texte-libre optionnel
> échoue — Goyal/Leshed/Fussell 2013). Tri/scroll/re-render ≠ nœud.

**Retours d'expérience empiriques (ce qui marche / échoue) :**
- **Dou et al. 2009** (contrôlé) : reconstruire le raisonnement depuis les logs seuls plafonne à **60 % stratégies /
  60 % méthodes / 79 % findings**. Non récupérable : les décisions par **reconnaissance visuelle de motif** → *notre
  empreinte spatiale par nœud attaque exactement ce trou*.
- **Heer et al. 2008** (logs Tableau réels) : **undo ≈ 12,5× redo** → **on ne revient quasi jamais sur les branches
  mortes** → investir dans leur **résumé**, pas leur ré-exécution.
- **Kery et al. CHI 2018** (21 entretiens + 45 survey) : les data scientists cherchent par **artefact/paramètre/variante**,
  pas par timestamp ; le versioning chronologique **dégrade la lisibilité**.
- **Pimentel MSR 2019 / Rule CHI 2018** (corpus ~1,2–1,45 M notebooks) : **4 % reproductibles**, **27,6 % sans aucun
  texte explicatif** → *le laissez-faire produit du non-narratif : la discipline de capture EST la valeur ajoutée du greffier.*
- **Goyal/Leshed/Fussell CHI 2013** (N=40, contrôlé) : une zone de **notes libres n'améliore PAS** le sensemaking →
  bannir le texte-libre optionnel, préférer une structure légère et typée.

**Abandons + rationale (le cœur du pari) :**
- Le rationale/insight **ne se capture pas automatiquement** (Ragan §5.1). La capture **manuelle** de rationale meurt de
  son coût (40 ans : IBIS/gIBIS/QOC ; Shipman & Marshall *« Formality Considered Harmful »* : cognitive overhead, tacit
  knowledge, premature structure). → **confirme l'interdit du greffier** (ne pas interrompre, ne pas trier à chaud) comme
  *non-négociable*, prouvé empiriquement.
- **Remède : formalisation incrémentale** (Shipman & McCall 1994) — capturer **informel d'abord** (l'agent verbalise
  gratuitement dans son flux), **structurer plus tard** (à la distillation). Ne jamais bloquer sur un formulaire.
- **Branche morte = nœud-résumé léger** (hypothèse + verdict + raison), **PAS** un état/kernel ré-exécutable (coût
  prohibitif — cf. *Fork It*, CHI 2021). On ne ré-exécute pas les morts ; on les **raconte**.
- L'exploration **EST** arborescente (Derthick & Roth 2001) : le linéaire *« force l'utilisateur à reconnaître les points
  de bifurcation dans un historique linéaire »* et à s'appuyer sur sa mémoire → valide « session = arbre ».

**Repos vérifiés réutilisables** : `Trrack/trrackjs` (BSD-3, actif) ; **`gems-uff/noworkflow`** (MIT, très actif — capture
**non-intrusive** de provenance Python par AST/reflection, pertinent si le greffier instrumente du code). Réf. dormantes :
`mkery/Verdant` (MIT), `VisTrails` (BSD-3, Python 2 mort).

---

## 5. Ontologie : PROV-DM — emprunter le vocabulaire, rejeter la stack

**Mapping raisonnement → PROV-DM** (le concept tient parfaitement) :

| Élément greffier | Type PROV | Relation clé |
|---|---|---|
| Hypothèse / résultat / insight / fiche | `Entity` | `wasGeneratedBy`, `wasDerivedFrom` (lignée preuve = **P4**), `wasAttributedTo` |
| Requête SQL/MCP · appel LLM | `Activity` | `used`, **`wasInformedBy` (Activity→Activity) = l'arête parent→enfant de l'arbre** |
| Abandon + raison | `Entity` **invalidée** | **`wasInvalidatedBy`** (+ raison en attribut — PROV n'a pas de primitive dédiée) |
| Empreinte spatiale | attribut `prov:location` | — |
| Auteur (humain / agent) | `Agent` | `wasAttributedTo`, `wasAssociatedWith`, `actedOnBehalfOf` |
| Session (l'arbre) | `Bundle` | conteneur (provenance-de-provenance) |

**Verdict : s'inspirer de PROV en version allégée.** Emprunter le *vocabulaire* (Entity/Activity/Agent + `used`,
`wasGeneratedBy`, `wasDerivedFrom`, `wasAttributedTo`, `wasInformedBy`) comme **discipline de nommage d'un modèle maison
DuckDB**. **Rejeter** PROV-O/RDF/OWL et PROV-JSON. Raisons :
- **RETEX net** : *PROV a gagné les specs, perdu les SDK*. OpenLineage / MLflow / DVC / Google ML-Metadata **ne l'utilisent
  pas** ; CWLProv (PROV natif) a une **adoption faible reconnue** → remplacé par RO-Crate (« lightweight » par choix
  explicite). PROV survit là où une autorité impose l'interop top-down (FHIR, IVOA). En bottom-up, systématiquement
  contourné (réification RDF verbeuse : « 4-5 triplets/assertion »).
- **Test de plus-value** : RDF n'apporte **rien** que des tables DuckDB typées ne donnent → théâtre WOW sémantique,
  exclu par la règle d'admission de composant.
- **PROV-AGENT** (`ORNL/flowcept`, MIT) valide le mapping (sous-classement `AIAgent⊂Agent`, `AgentTool⊂Activity`,
  `AIModelInvocation⊂Activity`, `Prompt`/`ResponseData⊂Entity`) — à réutiliser *conceptuellement*, pas comme dépendance
  (Flowcept = plomberie HPC/Redis/Kafka, anti-P7).

**Sérialisation** : tables DuckDB immuables (nœuds + arêtes append-only + facets JSON), **pas** PROV-JSON (Member
Submission 2013, non-Recommendation). Pont futur gratuit : conversion PROV-O *a posteriori* via `trungdong/prov` (MIT)
**si/quand** un consommateur externe l'exige — jamais dans le walking skeleton.

---

## 6. Capture mécanique — le Claude Agent SDK fournit déjà le seam (implémentabilité)

`anthropics/claude-agent-sdk-python` (MIT, actif). Le SDK **pilote le CLI en sous-processus** et expose un flux de
messages typés + des hooks. **Trois seams d'observation non-intrusifs :**

1. **`SessionStore` custom** (colonne vertébrale recommandée) — `ClaudeAgentOptions.session_store` + `session_store_flush`.
   Protocole `append/load/...`. Garanties **vérifiées** : `append()` appelé **APRÈS** la durabilité disque locale (le
   greffier reçoit une **copie secondaire** ; son échec est non-fatal, 3 retries) → **le greffier ne peut structurellement
   pas interrompre l'analyste**. Ordonné, idempotent (`uuid`), flush `batched` (défaut, 1×/tour) ou `eager` (hors boucle
   de lecture). `SessionKey.subpath` distingue les transcripts de **sous-agents** → **attribution native**. `load()` =
   rejouabilité (P4). *C'est littéralement un tap immuable, ordonné, hors chemin critique, du transcript complet.*
2. **Hooks rendant `{}`** (observation pure) — `PreToolUse` (intention d'appel MCP), `PostToolUse` (résultat),
   **`PostToolUseFailure`** (`error`, `is_interrupt` = **abandons + raisons**), **`PreCompact`** (⚠️ **le contexte va être
   compacté → persister AVANT**, sinon perte silencieuse), `Stop`/`SubagentStop` (bornes de tour). Variante `include_hook_events=True`
   → tout capté via le seul flux de messages, sans callbacks.
3. **Tee du flux `Message`** — `ThinkingBlock` (raisonnement/hypothèses), `ToolUseBlock`/`ToolResultBlock` (requête/résultat
   MCP, corrélés par `tool_use_id`), `ResultMessage` (coûts, `num_turns`, terminaison).

**⚠️ Pièges vérifiés** : sur **Opus 4.7+, `thinking` par défaut = `"omitted"`** → activer `thinking={"type":"adaptive",
"display":"summarized"}` sinon le raisonnement est perdu. Sous-agents parallèles : hooks entrelacés → **indexer par
`agent_id`, pas par ordre d'arrivée**. Ne pas utiliser `can_use_tool` pour observer (court-circuité par `allowed_tools`).

**OTel GenAI** (`open-telemetry/semantic-conventions-genai`, Apache-2.0) : topologie `invoke_agent → chat / execute_tool /
plan` **isomorphe à l'arbre de session** ; vocabulaire utile (`conversation.id`, `agent.id`, `tool.call.id`,
`mcp.session.id`). **MAIS le contenu (messages, tool args/results, thinking) est classé Opt-In** → OTel-par-défaut est
**sous-spécifié** pour un greffier centré raisonnement, et le `ThinkingBlock` n'a pas d'attribut dédié. **Verdict** :
emprunter le vocabulaire/la forme d'arbre ; **store maison** pour les payloads lourds (P4) ; projection OTel *optionnelle*
en surcouche pour l'export/visu — jamais la source de vérité.

**Tracing tools** : Langfuse (**MIT** + carve-out `ee/` à éviter), Phoenix (**ELv2 non-OSI** ⚠️), LangSmith (propriétaire,
couplage LangChain). Patron commun = collecte async + batching hors chemin critique — **déjà fourni par `SessionStore`**.
Ne pas embarquer en v1 ; Langfuse = candidat d'export/visu si besoin UI (v2+).

---

## 7. Distillation épisodique → sémantique — 2 temps, à la clôture

- **`getzep/graphiti`** (Apache-2.0, très actif) — patron de référence : `EpisodicNode` **préserve la source brute** ;
  `add_episode` → extraction LLM entités/arêtes **bi-temporelles** (`valid_at`/`invalid_at`) ; **contradiction = invalidation
  (`invalid_at`), pas écrasement** (historique préservé) ; **incrémental** (pas de recalcul batch). Pièges : Structured
  Output requis, `SEMAPHORE_LIMIT=10` (429 providers), extraction **non-déterministe**.
- **`letta-ai/letta`** (Apache-2.0) — mémoire éditée par l'agent via outils (`memory_rethink`, `memory_finish_edits`) +
  **sleep-time compute** (agent secondaire consolide **hors flux**) = le pendant exact de « distiller à la clôture » sans
  gêner l'analyste.
- **`sanonone/kektordb`** (Apache-2.0, Go) — `session_summary` **recompilé sur invalidation de source** (cache < 50 ms,
  zéro token si source stable) = biographie à jour sans re-tokeniser à chaque lecture.

**Patron recommandé** : (1) **épisodique immuable, jamais distillé en place** (source de vérité rejouable P4) ; (2)
**sémantique dérivé recompilable** à la clôture (graphe = patron Graphiti extract→dedupe→temporal-invalidate ; biographie
= patron kektordb recompilable + Letta sleep-time). **Distiller à la clôture, pas en continu** (walking skeleton : capter
d'abord). **Piller les patrons, pas embarquer les runtimes** (Neo4j / process Go / plateforme Letta = anti-P7 en v1).

---

## 8. Pièges & garde-fous (à traiter comme invariants du greffier)

1. **Ne jamais interrompre le flow ni forcer une structure a priori** (40 ans d'échecs de la capture de rationale). Tenu
   *par construction* via `SessionStore` (post-commit, non-fatal) + hooks rendant `{}`.
2. **Ne pas parier sur la ré-ouverture des branches mortes** (undo ≈ 12,5× redo) → investir dans le **résumé léger**, pas
   la ré-exécution.
3. **Non-déterminisme LLM de la distillation** → le graphe/biographie n'est **jamais** la source de vérité ; toujours
   régénérable depuis l'épisodique immuable ; versionner les distillations, ne pas les muter.
4. **Perte de contexte silencieuse** : `PreCompact` (auto) + `thinking="omitted"` (Opus 4.7+) amputent la trace →
   à gérer *avant* toute distillation (sinon on distille du vide).
5. **Confidentialité (P2 + instruction org)** : la distillation LLM envoie le raisonnement/résultats à un modèle — vérifier
   que l'épisodique ne contient **que des agrégats** (P2 : l'agent ne voit pas les lignes → la trace ne devrait pas en
   contenir ; à re-vérifier à l'implémentation).
6. **Dépendance charte↔greffier** : le greffier ne capte le « pourquoi » que si l'analyste **verbalise** hypothèses et
   raisons d'abandon dans son flux. → un ajout à la charte de l'analyste (générique, pas domaine — cf. frontière charte↔fiche Q-0004).

---

## 9. Décisions candidates pour le brainstorming (À INSTRUIRE, non gravées)

1. **Modèle de données (Q-0004)** : deux relations DuckDB immuables append-only — `nodes` (ThoughtNode) + `edges`
   `(parent_id, child_id)` — **+ artefacts versionnés** (indexés par artefact, Verdant) **+ facets** (OpenLineage) pour
   spatial/abandon/attribution (schémas côté fiche). Arêtes nommées en **vocabulaire PROV-DM allégé** (`was_informed_by`,
   `was_derived_from`, `was_attributed_to`, `used`). Sérialisation DuckDB, **pas** RDF/PROV-JSON.
2. **Granularité (Q-0003)** : grain-cible = **Action sémantique** ; nœud à (a) résultat interprétable ou (b) changement
   d'hypothèse ; Events repliés sous l'Action ; coalescence ; `kind` petit et fermé. **À calibrer sur session réelle**
   (Dou/Gotz-Zhou + doctrine : le grain se valide empiriquement, pas sur le papier).
3. **Capture** : `SessionStore` custom du Claude Agent SDK = colonne vertébrale (non-intrusion par construction) + hooks
   `PostToolUseFailure` (abandons) et `PreCompact` (alerte) + activer `thinking display="summarized"`.
4. **Rationale/abandons** : formalisation incrémentale — capter le NL verbalisé (gratuit), structurer à la distillation ;
   branche morte = nœud-résumé léger (hypothèse + verdict + raison), pas un état ré-exécutable.
5. **Distillation** : 2 temps, à la clôture ; patrons Graphiti (bi-temporel) + Letta sleep-time + kektordb (recompilable) ;
   **à trancher** si la brique #4 inclut une distillation minimale ou seulement la **capture** (walking skeleton).
6. **Périmètre brique #4** (proposé) : **capture en données** (SessionStore → tables DuckDB immuables) + modèle de nœud
   minimal + exercé sur le banc accidents ; distillation graphe/biographie = couche ultérieure. Ontologie `StateSummary`
   (forky) = brouillon de la future distillation.

---

## 10. Repos & sources — licences vérifiées

| Repo | Licence | État | Usage |
|---|---|---|---|
| `Trrack/trrackjs` | BSD-3 | actif | réutiliser (patron arbre immuable, ephemeral/groups) |
| `langchain-ai/langgraph` | MIT | très actif | réutiliser (schéma persistance/lignée SQLite) |
| `OpenLineage/OpenLineage` | Apache-2.0 | très actif | réutiliser (patron facets) |
| `mkery/Verdant` | MIT | dormant | inspiration (indexation par artefact) |
| `gems-uff/noworkflow` | MIT | très actif | inspiration (capture non-intrusive Python) |
| `anthropics/claude-agent-sdk-python` | MIT | actif | **réutiliser (SessionStore + hooks)** |
| `open-telemetry/semantic-conventions-genai` | Apache-2.0 | actif | inspiration (vocabulaire/forme d'arbre) |
| `getzep/graphiti` | Apache-2.0 | très actif | inspiration (distillation bi-temporelle) |
| `letta-ai/letta` | Apache-2.0 | actif | inspiration (sleep-time, mémoire par outils) |
| `sanonone/kektordb` | Apache-2.0 | actif | inspiration (résumé recompilable) |
| `ORNL/flowcept` (PROV-AGENT) | MIT | actif | inspiration conceptuelle (mapping PROV agents) |
| `trungdong/prov` | MIT | — | option future (export PROV-O a posteriori) |
| `ishandhanani/forky` | **SANS LICENCE** | actif | inspiration cadre + contre-exemple — **zéro copie** |
| `Arize-ai/phoenix` | **ELv2 (non-OSI)** ⚠️ | actif | écarter/valider juridiquement |

**Littérature clé** (empirique = ★) : ★ Dou et al. 2009 (TVCG/CG&A, reconstruction 60–79 %) · ★ Heer et al. 2008 (undo
12,5× redo) · ★ Kery et al. CHI 2018 (par-artefact) · ★ Pimentel MSR 2019 / Rule CHI 2018 (repro notebooks) · ★
Goyal/Leshed/Fussell CHI 2013 (notes libres inutiles) · Ragan et al. 2016 (5 types) · Gotz & Zhou 2009 (grain Action) ·
Xu et al. 2020 (survey provenance) · Shipman & Marshall 1999 / Shipman & McCall 1994 (formalisation incrémentale) ·
Derthick & Roth 2001 (branching history). W3C : PROV-DM, PROV-O (Recommendations) ; PROV-JSON (Member Submission).
