# Veille — Croisement de jeux de données : d'où vient le « aha », et les garde-fous que la rigueur impose

- Date : 2026-08-01
- Contexte : cadrage de la brique #6. Alex pose l'hypothèse que la valeur « aha » naît du
  **croisement** de datasets (spatial × socio-économique) — intuition SITG (vitesses/écoles/
  population). Deep-research multi-agent web (fan-out 6 angles → 26 sources → 110 claims extraits →
  **25 vérifiés en 3 votes adversariaux, 24 confirmés / 1 réfuté**). Sources majoritairement
  primaires (PMC, Springer, ScienceDirect, arXiv, Columbia Public Health).
- Statut : **référence durable**. Sert d'intrant de design à la future brique « croisement
  rigoureux » (Alex : rigueur d'abord — cf. décision de séquençage 2026-08-01, faire D/H3 avant).
- Méthode : chaque claim ci-dessous a survécu à 3 vérificateurs adversariaux (défaut = réfuté si
  doute). Le vote `n-m` = n confirment / m réfutent. Un claim réfuté (1-2) est listé en §5.

---

## 1. Croisements réels → le « aha » produit (et sa non-transférabilité)

| Croisement | Question de départ | Aha émergé | Source (vote) |
|---|---|---|---|
| Accidents piétons × bâti × défavorisation (Halifax) | Où/pourquoi les piétons sont blessés ? | **Signature composite** invisible variable par variable : logement bas-moyen SES séparé d'un pôle d'attraction par **≥4 voies** + virages/côtes aveugles | PMC7143108 (3-0) |
| (même étude) | La recette Vancouver se transporte-t-elle ? | **Non** : 2/10 hotspots seulement près de bars, contredisant l'étude Vancouver antérieure des mêmes auteurs (proximité bars = risque n°1 là-bas) | PMC7143108 (3-0) |
| Criminalité × strates socio-éco (Bogotá, 17 variables écologiques) | Le crime suit-il la géographie sociale ? | Forte corrélation — **mais inversée selon le type** : homicide/agression dans les zones les plus pauvres, vol au **centre** (activité éco = cibles). Même gradient, effet opposé | Springer s10610-018-9374-5 (3-0) |
| Accidents urbains × activité humaine (taxi GPS, réseaux sociaux, POI) | Le réseau routier + sociodémo expliquent-ils les accidents ? | **Non** : l'activité humaine façonne le pattern au-delà ; elle sert de **proxy d'exposition** au trafic/conflit. Méthode : GWPR (coefficients locaux variant dans l'espace) | ScienceDirect S096669232100171X (3-0 / 2-1) |

**Enseignement central** : la découverte naît du **croisement**, jamais d'une variable seule
(signature composite ; inversion par sous-type ; activité ≠ réseau). La non-transférabilité
Halifax/Vancouver **valide empiriquement « no hard-coded scenarios »** : une recette qui marche
dans une ville ne se transporte pas → le système doit **composer**, pas appliquer une recette.

## 2. Taxonomie des questions — à supporter vs à refuser

**Familles à supporter** (Jacquez, PMC3014613) — trois types canoniques :
- **Value** : « où sont les concentrations / zones auto-similaires ? » → *on l'a* (`concentration_test`).
- **Change** : « où sont les frontières / zones de rupture spatiale ? » → *on ne l'a pas*.
- **Association** : « deux variables géo-référencées covarient-elles ? » (ex. zones de leucémie ×
  sites de déchets dangereux) → *on ne l'a pas — **c'est là que vit le aha***.

Taxonomie complémentaire fine (**GeoRAG**, arXiv 2504.01458, 3-0) : 7 dimensions — compréhension
sémantique, localisation, morphologie géométrique, attributs, **relations entre entités**,
processus évolutifs, mécanismes opérationnels. Golledge 1992 (3-0) distingue savoir spatial
**« common-sense » vs « expert »** — un système honnête ne doit pas parler à l'expert comme au naïf.

**À refuser / nuancer** (garde-fous imposés par la littérature) :
- **Une carte de densité (KDE) n'est PAS une preuve de cluster** : belle surface, **aucun test de
  significativité** (Columbia PH, 3-0). Un joli rendu ≠ evidence.
- **Causalité depuis de l'observationnel** : « corrélation ≠ causalité » nécessaire mais insuffisant
  (Rohrer 2018, graphical causal models).
- **Conclusion sensible à la maille** présentée comme robuste (MAUP, cf. §3).
- **Lire de l'individuel dans de l'agrégé** (ecological fallacy — Robinson 1950, 3-0 ; caveat
  Halifax : le blessé ne réside pas forcément là où il est blessé, 3-0).

## 3. Modes d'échec du croisement — pourquoi la rigueur est indispensable

| Garde-fou | Ce que dit la littérature | Outillé chez nous ? | Source (vote) |
|---|---|---|---|
| **Null vs hasard spatial** | Un hotspot se définit par comparaison à une attente de randomité, **pas au comptage brut** ; Gi\* calcule un Z/p par unité | ✅ `concentration_test` déjà dans le vrai | Columbia PH (3-0) |
| **Autocorrélation spatiale sous le null** | « Presque toutes les données socio-démo/santé » en ont → modéliser sous le null, **pas** supposer la Complete Spatial Randomness, sinon significativité **surévaluée** | ❌ | PMC3014613 (3-0) |
| **Exposition / dénominateur** | Le risque d'un groupe **ne s'évalue pas** sans rapporter l'accident à son exposition (véhicule-km, personne-km) | ✅ exposition déclarée (brique #5), à généraliser | PMC8391987 (2-1) |
| **MAUP** | Changer **l'unité d'agrégation** peut fabriquer ou tuer une association. Cas NO₂/santé (Ottawa) : coef 76,2 (p=0,089, **non-sig**) → 134,3 (p=0,030) → 179,1 (p=0,002, **sig**) rien qu'en changeant la maille. Deux composantes : **échelle** (résolution) **et zoning** (placement des frontières — démo d'Openshaw) | ❌ **= la brique D** | PMC3245430 (2-1) ; mgimond |
| **Frontières thématiques** | Des unités admin/thématiques **coupent** de vrais clusters et supposent l'homogénéité intra-unité → limitent la détection locale | ❌ | Columbia PH (3-0) |
| **Fusion multi-résolution** | Fusionner des datasets à formats/résolutions différents introduit de l'**autocorrélation artificielle** via agrégation/lissage | ❌ **critique pour le croisement** | PMC3014613 (3-0) |
| **Simpson ≠ ecological fallacy** | Deux phénomènes distincts (tous deux biais de variable omise) ; l'agrégation peut **inverser le signe** d'une association. Cas OCDE fécondité×emploi féminin : corrélation **positive** au macro, **négative** au micro | ⚠️ à porter en charte | cs.brown Kögel (3-0 ×2) |
| **Garden of forking paths / p-hacking** | Tests multiples implicites → faux positifs (Gelman) | ⚠️ Q-0009 (FDR différé) | sites.stat.columbia Gelman |

## 4. Implications pour intreepid

**Ce que le système DEVRAIT pouvoir répondre** (à terme) : les trois familles Value / Change /
**Association** — l'Association croisée étant le générateur de découvertes. Chaque réponse
**normalisée par exposition** et **testée contre un null qui tient compte de l'autocorrélation**.

**Ce qu'il doit REFUSER ou nuancer** : présenter une carte de densité comme un cluster prouvé ;
sauter à la causalité depuis de l'observationnel ; livrer une conclusion sensible à la maille
comme robuste ; lire de l'individuel dans de l'agrégé.

**Conséquences directes pour la brique D (H3 / anti-MAUP)** :
1. D n'est pas du polissage : il introduit le **substrat H3 (grille commune multi-résolution)**,
   réutilisable par le croisement futur (garde-fou « fusion multi-résolution »).
2. Le null de D doit intégrer l'**autocorrélation spatiale** (garde-fou §3 ligne 2) — ne pas
   supposer la randomité complète.
3. MAUP a **deux composantes** (échelle **et** zoning) : D doit être honnête sur laquelle il teste
   (a priori l'échelle, via les résolutions H3).
4. **Foyer naturel de D = maille modifiable (H3)**, pas les unités admin (cantons) où le MAUP est
   moins aigu.

**Conséquence pour la future brique « croisement rigoureux »** : capability d'Association
**générique** (jointure de 2 datasets **déclarés dans la fiche**, jamais « accidents × écoles » en
dur) + test d'association à null spatial + garde-fous portés en **charte générique**. Nécessite un
2ᵉ dataset réel — SITG Genève (vitesses, `OTC_LIMITATIONS_VITESSE`) confirmé comme source primaire
disponible (cf. `2026-08-01-donnees-suisses-et-quarto.md` §1).

## 5. Claim réfuté (transparence)

- « Le risque routier **est défini** comme le ratio accidents/exposition, faisant de l'exposition
  le dénominateur **obligatoire** » — **réfuté 1-2** (PMC8391987). Les vérificateurs ont jugé la
  **forme forte** (définitionnelle, « obligatoire ») en surinterprétation : l'exposition est
  **nécessaire pour comparer des groupes** (claim voisin retenu 2-1) mais n'est **pas l'unique
  cadrage** valide du risque. *Écho direct à Q-0016 : l'exposition explicite l'hypothèse, elle ne
  s'impose pas par défaut.*

## 6. Pointeurs sources (sélection primaire)

- Halifax piétons : `ncbi.nlm.nih.gov/pmc/articles/PMC7143108`
- Bogotá crime × strates : `link.springer.com/article/10.1007/s10610-018-9374-5`
- Accidents × activité humaine (GWPR) : `sciencedirect.com/science/article/abs/pii/S096669232100171X`
- NO₂ × santé / MAUP : `ncbi.nlm.nih.gov/pmc/articles/PMC3245430`
- Taxonomie Value/Change/Association + autocorrélation + fusion : `pmc.ncbi.nlm.nih.gov/articles/PMC3014613`
- Hotspot vs null / Gi\* / KDE : `publichealth.columbia.edu/research/population-health-methods/hot-spot-spatial-analysis`
- Simpson ≠ ecological fallacy : `cs.brown.edu/courses/cs100/lectures/readings/Kgel_Simpsonsparadoxversusecologicalfallacy-TheTFRFLPpuzzle.pdf`
- GeoRAG (taxonomie 7-dim) : `arxiv.org/pdf/2504.01458`
- Golledge 1992 (primitives spatiaux) : `link.springer.com/chapter/10.1007/3-540-55966-3_1`
- Exposition/dénominateur : `pmc.ncbi.nlm.nih.gov/articles/PMC8391987` ; `openroadrisk.org/literature/exposure-and-traffic-volume.html`
- Causalité observationnelle : `journals.sagepub.com/doi/full/10.1177/2515245917745629` (Rohrer 2018)
- Forking paths : `sites.stat.columbia.edu/gelman/research/unpublished/p_hacking.pdf`
- Ancrage suisse : `opendata.swiss/en/dataset/strassenverkehrsunfalle-mit-personenschaden` ; `sitg.ge.ch/donnees/otc-limitations-vitesse`
