# Journal — Session de fondation

- Date : 2026-07-26 (session Claude.ai, mobile)
- Participants : Alex (Sensei) ; Claude (co-conception, rôle critique explicitement mandaté)
- Produits : architecture/overview.md v0.1 puis v0.2 ; ADRs 0001–0006 ; ce journal
- Nature : trace exhaustive de la conception, y compris pistes rejetées

---

## 1. Point de départ

Question initiale : « beaucoup de données à composante géographique ;
utiliser un LLM pour découvrir des informations non triviales et décider
avec de nouvelles connaissances — comment travailler ensemble, quels
outils, quelle préparation ? »

Premier cadrage posé : **un LLM ne "voit" pas la géométrie** ; il faut
transformer le spatial en features sémantiques (P1). Pattern en trois
couches : feature engineering déterministe (FME, GeoPandas, DuckDB
spatial, H3) → accès agentique par outils (MCP, jamais de données brutes
dans le contexte) → découverte guidée (hypothèses, anomalies expliquées).

Orientation choisie par Alex : ne pas commencer par un cas ponctuel mais
**concevoir le workspace complet** — outils, infrastructure, workflow —
capable de consommer n'importe quelles données et d'itérer librement.

## 2. Architecture cible initiale (5 couches)

1. Socle : GeoParquet/Parquet + DuckDB (extension spatiale) — lingua franca.
2. Catalogue sémantique : registre YAML versionné ; « le composant le plus
   sous-estimé et le plus décisif ».
3. Serveur MCP maison (Python 3.10+ typé, FastMCP) : list/describe/
   query_sql (read-only, limité)/sample/profile_stats + primitives spatiales.
4. Client agentique (boucle hypothèse → requête → résultat → reformulation).
5. Persistance des insights (journal → nourrira le catalogue ; boucle fermée).

Contrainte posée d'emblée : read-only strict, données sensibles hors
périmètre ou pseudonymisées en amont (FME).

## 3. Exigence fondatrice d'Alex : pas d'effet WOW

Demande explicite : un outil qui apporte un vrai plus par rapport aux
outils classiques sans IA, pas une démo. Modestie revendiquée. Contexte :
deux tentatives précédentes (Algiz, Henry) n'ont pas convaincu.

Composants de découverte ajoutés en réponse (tous retenus) :
- **Viz éphémère générée par le LLM** (dashboard adapté à la question du
  moment ; MapLibre GL JS, Plotly/Recharts) vs **viz persistante** pour
  les insights confirmés (Evidence.dev / Superset, BI-as-code).
- **Agent critique** : démolir les découvertes (corrélations fallacieuses,
  Simpson, biais d'échantillonnage, MAUP).
- **Découverte proactive** : jobs FME Flow qui profilent et ouvrent des
  *questions*, pas des alertes.
- **Graphe de connaissances** : insights, relations, statuts, liens vers
  les requêtes-preuves.
- **Recherche sémantique cross-datasets** (embeddings sur catalogue) — v2.

Principe unificateur formulé et adopté comme **règle d'admission** : un
composant doit accélérer l'itération ou solidifier la connaissance, sinon
il n'entre pas.

## 4. La session comme arbre ; fluidifier le chaos créatif

Constat d'Alex : les sessions exploratoires partent dans tous les sens,
comme nos discussions ; il faut libérer les cerveaux de la documentation.
Diagnostic partagé : **le coût de la documentation tue la découverte** —
le LLM peut le faire tomber à zéro (l'apport impossible-avant n°1).

Mécanismes conçus :
- **Session = arbre, pas ligne** (bifurcations, impasses documentées avec
  leurs raisons — une piste réfutée vaut une confirmation).
- **Greffier silencieux** : documente en arrière-plan, ne trie pas à chaud.
- **Parking d'idées** : garer d'un mot, revue en fin de session.
- **Notebook comme produit de sortie, pas espace de travail** (nuance vs
  Jupyter, dont on garde le principe de reproductibilité) : deux artefacts,
  trace brute exhaustive + synthèse curatée (Quarto pressenti), SQL
  rejouable.
- Reprise de session : « où en étions-nous ? » recharge hypothèses
  ouvertes, parking, dernières découvertes.

## 5. Sessions à plusieurs

Idée détaillée sur demande d'Alex. Valeur : écraser la boucle
métier ↔ technique (le LLM comme traducteur bidirectionnel) ; validation
métier instantanée des découvertes (« trivial » vs « bizarre, creusons » —
le filtre anti-WOW le plus précieux) ; agent facilitateur neutre
(relancer les silencieux, transformer les désaccords en hypothèses
testables) ; trace = objet de gouvernance (qui a validé quoi — contexte
décisionnel cantonal).

Remarque clé d'Alex : la question naïve d'un non-spécialiste ouvre
parfois une voie nouvelle → institutionnalisée plus tard dans le rôle
**candide**.

Deux modes retenus : synchrone léger (salle + écran, zéro dev) ;
asynchrone (annotations sur notebook → graphe). Pas de pilote identifié
à ce stade (Q-0002).

## 6. Enrichissements de la boucle (itération « quoi d'autre ? »)

- **Candide institutionnalisé** (complément du critique : l'un démolit,
  l'autre ouvre).
- **Biographie des données** : le savoir tacite capturé et réinjecté
  automatiquement dans le catalogue.
- **Cycle de vie des insights avec péremption** : re-tests automatiques
  (FME Flow planifié) ; un pattern qui s'évapore ouvre la question
  « pourquoi ? ».
- **Modèles nuls systématiques** avant de retenir un pattern spatial.
- **Playbook d'exploration** : capitaliser la méthode, pas seulement les
  résultats.

Fil rouge : chaque session laisse le système plus intelligent (données,
domaine, méthode) — deviendra P5/P9.

## 7. Visuels : que garder ?

Discipline demandée par Alex (« n'invente pas juste pour ajouter »).
Retenus : **carte de l'arbre d'exploration** (visuel de navigation de la
pensée) ; **vues liées / linked brushing** ; **small multiples** (pendant
visuel du critique, anti-Simpson/MAUP) ; **incertitude comme couche
affichable**. Rien d'autre — arrêt délibéré.

Exigence d'Alex sur les rôles : agents honnêtes et rigoureux, qui
challengent sans complaisance → **charte des agents** décidée comme
livrable versionné, avec obligation de **proportionnalité** pour le
critique (challenger tout = du bruit).

Premier avertissement cathédrale émis par Claude (la liste de composants
gonfle) ; accueilli favorablement — deviendra doctrine.

## 8. Le couplage arbre ↔ carte — la signature

Réaction enthousiaste d'Alex sur l'arbre (« peut-être la vraie
nouveauté ») + importance stratégique de la carte pour l'entreprise
(spécialistes géospatial).

Invention formulée : **chaque nœud porte une empreinte spatiale** ; arbre
et carte = deux projections du même objet (le raisonnement). Gestes
inédits : survol de branche → emprise illuminée ; lasso carte → filtrage
de l'arbre (« qu'a-t-on déjà testé ici ? ») ; **zones blanches du
raisonnement** (jamais visitées — générateur de questions naïves).
Grammaire visuelle minimale (forme = type, couleur = statut, épaisseur =
solidité) ; branches mortes estompées, jamais supprimées ; **sémantique
du zoom** (anti-hairball, comportement de carte — atout culturel SIG) ;
**mode replay**.

Trois pièges nommés : hairball (>50-80 nœuds), granularité des nœuds
(le vrai défi technique — jugement LLM du greffier), empreintes floues
(représentation dégradée, nœuds a-spatiaux assumés).

Verdict : potentiel de « signature » ; ordre de construction — trace
d'abord, arbre ensuite, couplage spatial en dernier.

## 9. Interface et question ArcGIS Pro

Composants récapitulés par Alex : arbre (nom accrocheur à trouver —
Q-0001), carte, dashboard BI, zone de chat avec les mêmes possibilités
d'échange que Claude.ai/Claude Code (réponses préparées, recommandations).

Agencement retenu : **chat = colonne vertébrale permanente ; canevas =
vues invoquées par la conversation** (pas de cockpit en grille) ; minimap
arbre persistante avec navigation temporelle bidirectionnelle
chat ↔ arbre. Backend : Claude Agent SDK ; frontend Vue.js avec blocs
structurés (squelette type PUMA).

**ArcGIS Pro rejeté comme hôte v1** (ADR-0003) : stack .NET hors
périmètre, chat citoyen de seconde zone dans un hôte lourd, adhérence
licence/poste anti-collaboratif. Besoin réel requalifié : rester connecté
à l'écosystème SIG → consommer le Portal + export vers Pro en un clic.
Add-in léger possible en v2+.

Noms proposés au passage : Ramure, Sylva, Dendrite, Arolle.

## 10. Multi-utilisateurs et post-mortem Algiz/Henry

Validation d'Alex : plusieurs personnes sur la même session (créer /
reprendre / critiquer des branches, pastilles par auteur). Décision :
**l'agent comme point de sérialisation** (ADR-0004) — pas de CRDT.

Question d'Alex : pourquoi Algiz et Henry n'ont pas convaincu ?
Recherche dans les conversations passées : aucune trace — pas de
spéculation. Trois causes statistiques types posées comme grille :
(1) résoudre un problème que personne n'a de manière aiguë
(« la même chose qu'avant, mais avec un LLM ») ; (2) fiabilité sous le
seuil de confiance (une hallucination = crédibilité grillée, abandon
silencieux) ; (3) rien ne se capitalise. Notre concept passe les trois
lentilles — potentiel réel mais conditionnel (greffier, adoption,
constance dans le temps).

## 11. Lecture de henry-spec (github.com/alexpillonel/henry-spec)

Spec lue (README + architecture/overview). Qualité remarquable :
séparation Agent/Runtime, Plans en DAG typés auditables, Adapters,
Registry, Traits, ADRs disciplinés ; le mode `critique` de l'Agent y
existait déjà (convergence indépendante).

Verdict aux trois lentilles : fiabilité excellente ; impossible-avant
faible (résultat = trois clics de géoportail ; valeur réelle =
accessibilité pour non-experts — autre objectif, qui ne convainc pas des
spécialistes) ; capitalisation absente (agent stateless).

**Décision : absorber, pas enterrer** (ADR-0005). Henry fournit le
substrat d'exécution (Plans = format pressenti des requêtes rejouables ;
Adapters ; Registry) ; le workspace fournit le pourquoi et la couche de
connaissance. Pattern nommé sans détour : 199 commits de spec, Tier 1
complet, Tier 2 jamais démarré = risque cathédrale sous sa forme la plus
séduisante. Règle dure adoptée : **pas de v0.4 de l'architecture avant
une première session réelle sur données réelles.**

## 12. Doctrine anti-cathédrale

Alex nomme son propre pattern (enthousiasme, impatience, tendance à ne
jamais montrer car l'objectif n'est jamais atteint) et délègue
explicitement la vigilance. Consigne enregistrée dans la mémoire
persistante de Claude. Trois règles mécaniques adoptées :
1. **Règle du montrable** (2–3 semaines, montrable à un tiers, même moche).
2. **Squelette qui marche d'abord** (traverser tout le système en minuscule).
3. **L'enthousiasme paie comptant** (nouvelle idée → v2+ par défaut ;
   entrée dans le cycle courant seulement par échange).

Propagation de la doctrine sur toutes les surfaces : mémoire Claude.ai +
préférences utilisateur ; `~/.claude/CLAUDE.md` (niveau utilisateur,
tous projets) + `CLAUDE.md` par repo (commité, partagé, prioritaire en
cas de conflit) ; ajout au CLAUDE.md de henry-spec et du futur repo.
Mise en garde retenue : les CLAUDE.md sont du contexte, pas de
l'enforcement — le garde-fou le plus fiable est le **rituel du montrable
inscrit dans l'agenda**. Le CLAUDE.md global git/gitro d'Alex a été
simplifié et traduit en anglais au passage.

## 13. Ajouts v0.2 (issus des questions de compréhension)

- **Catalogue sémantique détaillé** avec exemple complet (fiche
  accidents_route : sens, pièges, limites, relations, questions déjà
  explorées) + **rôle curateur** (profiling à l'ingestion + interview de
  l'humain ; corrections par merge request pendant la découverte).
- **`profile_stats`** : le profil statistique comme proxy des données
  (stats par type de colonne ; exemple `vitesse_limite` avec code
  sentinelle 999 détecté sans lire une ligne).
- **Maille H3** expliquée (voisins équidistants, ID texte → GROUP BY,
  hiérarchie multi-échelle = arme anti-MAUP). MAUP explicité (effet
  d'échelle + effet de zonage ; ex. gerrymandering).
- **Couche ML** (ADR-0006) : LLM stratège / modèle calculateur ; table
  d'apprentissage, entraînement, validation temporelle, explication.
  Cadrage honnête du cas accidents : carte de risque pour prioriser,
  jamais « prédiction d'accidents ». Pilote quasi idéal (OFROU open data,
  geo.admin.ch, destinataire métier réel — à confirmer, Q-0002).
- **P9** : les agents apprennent par leur contexte, pas par leurs poids.
- **Persistance mémoire trois étages** (ADR-0002) : épisodique
  (arbres immuables + notebooks) / sémantique (graphe + catalogue) /
  procédurale (playbook + charte) ; chargement paresseux.

## 14. Revue de l'écosystème IA (carte « Modern AI Ecosystem »)

Méthode : la carte est un inventaire, pas une architecture ; question
posée = « qu'a-t-on exclu sans le savoir ? ».
- Déjà couvert : LLM, agentic (Agent SDK ; PydanticAI noté comme
  alternative typée si besoin), MCP (FastMCP), automation (FME Flow).
- Exclu délibérément : composants mémoire génériques (Mem0/Zep/Letta) ;
  guardrails produits (nos garde-fous sont structurels).
- **RAG / vector DB tranché** : notre couche sémantique est structurée
  (fiches YAML, graphe typé) → récupération agentique par outils MCP
  supérieure au RAG classique à cette échelle. Embeddings utiles en v2
  (recherche cross-datasets, mapping terme flou → colonnes) via
  **DuckDB VSS** — pas de vector DB dédié (ADR-0001).
- **Angle mort identifié : observabilité technique** (coûts, latences,
  qualité du greffier). Décision calibrée : logging structuré maison
  dans DuckDB en v1 ; Langfuse auto-hébergé candidat v2 (Q-0007).
- Risque ajouté : **injection de prompt via colonnes textuelles** des
  données (Q-0008).

## 15. Discussion « potentiel / révolution »

Question d'Alex sur le potentiel d'offrir un principe nouveau au monde
(à la H3). Position tenue : on ne planifie pas un standard — H3 est né
d'un problème brûlant + primitive simple + open source. Une primitive
candidate identifiée chez nous : **l'empreinte spatiale du raisonnement**
(« tout acte de raisonnement sur des données porte une emprise —
spatiale, temporelle ou de sous-population — et ces emprises sont
indexables »), généralisable hors géospatial. Chemin balisé si un jour :
valider sur sessions réelles → spécifier petit → open-sourcer →
communauté (GEOSummit, OSGeo). Rien de tout cela dans les objectifs du
document — « l'ambition ne se déclare pas, elle se constate ».

## 16. État en fin de session

- Architecture v0.2 figée pour validation (aucune implémentation engagée).
- Repo spec créé (ce dépôt), conforme aux standards inserap/methods-standards.
- Prochaines étapes (§14 de l'overview) : valider le document, trancher le
  nom (Q-0001), confirmer le pilote (Q-0002), spécifier catalogue +
  modèle de trace (Q-0004), squelette MCP avec `profile_stats` en premier
  outil, première session réelle pour calibrer le greffier (Q-0003).

## Parking de session (non traité, à revoir)

- Post-mortem détaillé d'Algiz (jamais raconté — seule la grille générique
  a été appliquée ; le vécu d'Alex manque).
- Claude Tag / messagerie d'équipe comme canal du mode asynchrone.
- Add-in ArcGIS Pro « ouvrir cette emprise dans le workspace » (v2+).
- PydanticAI comme plan B typé du Claude Agent SDK.
- Préférences utilisateur Claude.ai à compléter avec la doctrine (action
  côté Alex).
