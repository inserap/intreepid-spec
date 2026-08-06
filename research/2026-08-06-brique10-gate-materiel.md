# Matériel — gate de la brique #10 : le mécanisme marche, le coût monte

> Note produite à chaud après le gate du 2026-08-06 (23:07 → 23:20). Troisième d'une série :
> [`2026-08-04-curateur-gate-humain-materiel.md`](2026-08-04-curateur-gate-humain-materiel.md) capture
> la **cible** (obtenue avec redirection live), [`2026-08-06-curateur-gate-materiel.md`](2026-08-06-curateur-gate-materiel.md)
> la **base atteinte sans aide** (v0.12.0), celle-ci le **premier essai de réduction de coût**.
> Fiche produite : [`2026-08-06-RoadTrafficAccidentLocations.fiche.v3.yaml`](2026-08-06-RoadTrafficAccidentLocations.fiche.v3.yaml)
> (hash `ca40080edb96`). Trace : `<IMPL:src>/traces/curator-785a2ccd.duckdb`.
> Branche `brique-10-brouillon-incremental`, **non mergée** (garde-fou D5).

## 1. Verdict : échoué, 2 critères sur 5

| # | Critère | Mesuré | Base 06/08 | |
|---|---|---|---|---|
| 1 | delta ÷ fiche écrite ≤ 1,5 | **1,2** | 3,3 | ✅ |
| 2 | aucun tour > 3 355 car. de prose | 2614 · 2636 · 2860 · **3388** · **3479** | max 3 355 | ❌ |
| 3 | premier tour aux cinq éléments, zéro consigne de style | tous présents | acquis | ✅ |
| 4 | fiche complète (36 colonnes), validée | 36/36 | acquis | ✅ |
| 5 | zéro appel `ToolSearch` | **× 4** | 4 | ❌ |

Le critère 2 échoue de peu (+1,0 % et +3,7 % sur deux tours). Le critère 5 échoue sur une **prémisse
fausse** — voir §4.

## 2. Le résultat qui compte : le coût a augmenté

```
2,0652 $ · 961,2 s bout en bout · 5 tours · dont API 462,7 s
#1 157,6s · 0,5417 $ · in 6 (cache 31469 lus / 24424 créés) / out 11268 tok
#2  73,5s · 0,3417 $ · in 6 (cache 62044 lus / 18402 créés) / out  5065 tok
#3  87,0s · 0,4036 $ · in 6 (cache 67638 lus / 21131 créés) / out  6336 tok
#4  94,3s · 0,4661 $ · in 6 (cache 76827 lus / 26029 créés) / out  6695 tok
#5  53,7s · 0,3121 $ · in 2 (cache 14443 lus / 20370 créés) / out  4046 tok
Sortie écrite : tour d'agent 50 814 car. · thinking 13 638 car.
prose 14 977 · delta 35 837 (71 %)   |   fiche 28 953 car. → delta ÷ fiche = 1,2
Appels d'outil : ToolSearch × 4, mcp__intreepid__profile_raw × 4
```

Confronté à la base du 06/08 (mesurée par le **même** instrument) :

| | 06/08 | 06/08 soir | écart |
|---|---|---|---|
| Coût | 1,8033 $ | **2,0652 $** | **+14,5 %** |
| Sortie écrite totale | 69 628 car. | 50 814 car. | −27 % |
| dont **brouillon** | 55 604 car. | **35 837 car.** | **−36 %** |
| dont prose | 14 024 car. | 14 977 car. | +7 % |
| Tokens de sortie | 37 709 | 33 410 | −11 % |
| **Créations de cache** | 78 361 | **110 356** | **+41 %** |
| Lectures de cache | 153 706 | 252 421 | +64 % |
| Thinking | 9 829 car. | 13 638 car. | +39 % |
| Appels `profile_raw` | 2 | **4** | ×2 |

**Le mécanisme fait exactement ce qu'on lui demandait** — le brouillon perd 36 % — et le coût monte
quand même. Décomposition de l'écart aux tarifs Opus 4.x : l'économie de sortie vaut **−0,11 $**, la
hausse des créations de cache **+0,20 $** (6,25 $/M), et le thinking supplémentaire environ **+0,12 $**.
L'économie est plus qu'avalée par deux postes qu'on ne surveillait pas.

## 3. La cause probable, et le trou de design qu'elle expose

**Hypothèse, pas mesure** — mais son support est net : **quatre appels `profile_raw` au lieu de deux**,
et l'agent dit pourquoi au tour 4 :

> « En reprenant le profil pour boucler l'inventaire, je constate qu'une 36ᵉ colonne restait non
> documentée : `MunicipalityCode`. »

**`inventory_line` dit à l'agent ce qu'il A, jamais ce qui lui MANQUE.** Il reçoit « 31 colonnes
documentées — *noms* », sans savoir si le dataset en compte 31, 36 ou 40. Les résultats d'outil
n'étant pas réinjectés entre les tours (la charte le dit), il n'a aucun moyen de vérifier sa
complétude autrement qu'en re-profilant — et chaque appel réinjecte le profil des 36 colonnes dans le
contexte, ce qui gonfle le cache à créer.

Avant la brique #10, l'agent portait implicitement la liste complète : son brouillon entier la
contenait. En passant aux deltas, **on lui a retiré cette liste sans la lui rendre**.

> **Mise à jour du 07/08** : cette section cadre le problème en **coût**, et le désigne comme piste
> n°1. Les deux sont dépassés. La mesure a montré que les re-profilages n'expliquent qu'un quart de
> la hausse de cache, et surtout que **le coût n'est pas l'objectif** — c'est le **temps** et la
> maîtrise du contenu. Le plan de reprise qui fait foi est le **§ 8**.

## 4. Q-0019 : le diagnostic du 06/08 était incomplet

Le nom complet **a agi**, mais pas comme annoncé :

| | appels `profile_raw` | appels `ToolSearch` | ratio |
|---|---|---|---|
| 06/08 (nom nu) | 2 | 4 | **2 par outil** |
| 06/08 soir (nom complet) | 4 | 4 | **1 par outil** |

Le **repli par mots-clés a disparu** — c'était bien lui, la moitié des appels. Mais `ToolSearch` reste
appelé **une fois par usage d'outil**, parce que les outils MCP sont **différés** dans ce CLI : leur
schéma doit être chargé avant appel. Le nom n'était pas la cause, c'était l'**aggravation**.

Conséquence : le critère 5 (« zéro `ToolSearch` ») reposait sur une prémisse fausse. Il ne pouvait pas
être atteint par un renommage.

## 5. Q-0024 s'est améliorée sans qu'on la traite

Les lectures de cache **ne plafonnent plus** :

```
06/08       : 58 059 → 53 236 → 14 137 → 14 137 → 14 137   (plafond dès le tour 3)
06/08 soir  : 31 469 → 62 044 → 67 638 → 76 827 → 14 443   (croissantes)
```

L'historique est donc bien étendu en cache, et non re-créé. La chute du tour 5 s'explique par le
**TTL de 5 minutes** : il y a eu une pause avant la validation. Effet de bord positif du delta — un
préfixe de prompt plus stable — non anticipé, à confirmer sur un second run.

## 6. Sur le fond, la séance est bonne

Quatre questions, cinq tours, fiche validée, **zéro consigne de style** (réponses `1a`, `2a`, `3a`,
`4a`, `o`). La réserve du reviewer sur le deux-points du § Méthode 2 — « les CONSÉQUENCES et les
RISQUES » lu comme une énumération exhaustive — **ne s'est pas matérialisée** : options fermées et
penchant sont bien présents au premier tour.

**Les deux trouvailles du 06/08 sont retrouvées seules** : gravité hiérarchique (les lignes `as1`
comptent des accidents mortels, jamais des morts) et absence de tout comptage de victimes.

~~**Une trouvaille neuve** : `at0` contre `at00`.~~ **FAUX, corrigé le 07/08** : ce piège figure déjà
mot pour mot dans la fiche du 06/08 matin, avec le même mécanisme (« tout cast numérique fusionne
~2 460 lignes »). **Aucune trouvaille neuve** dans cette séance. Je l'avais annoncée comme telle sans
vérifier — troisième occurrence ce mois-ci du même défaut : présenter comme acquis ce qui ne l'est
pas.

**Temps de réponse humain décroissant** : 113 s → 78 s → 75 s → 35 s entre les tours. Les questions
étaient tranchables d'un coup d'œil.

**Défaut de fiche** : 37 entrées sous `columns` — les 36 vraies **plus** `_indicateurs_usagers`, une
note transversale que l'agent a rangée là faute d'un autre endroit. Un consommateur qui itère
`columns` trouve une colonne fantôme. La fiche a besoin d'un emplacement pour les notes qui ne portent
pas sur une colonne.

## 7. Transcript

> `>` = saisie humaine. Modèle `opus`, thinking activé. Les blocs JSON de métadonnées ne sont pas
> affichés à l'humain et n'apparaissent donc pas ici — ils pèsent **71 %** de ce que l'agent écrit
> (contre 79 % au 06/08).

```
I'll start by loading the profiling tool, then profile the dataset.

Le jeu compte 267 761 lignes et 36 colonnes, soit environ 17 850 enregistrements par an sur les
millésimes 2011 à 2025 (aucune année n'est tronquée : 2025 pèse 6,73 %, exactement le poids moyen
d'une année). La structure est très régulière : un identifiant unique, un noyau de six variables
métier (type, gravité, trois indicateurs d'usagers, type de route), une paire de coordonnées, deux
niveaux administratifs, et quatre dimensions temporelles — chacune des variables codées étant
redoublée par ses libellés en allemand, français, italien et anglais. J'ai tranché seul tout ce qui
est déductible du profil ; il me reste quatre points de périmètre qui ne se déduisent pas
d'agrégats et que je dois vous faire ratifier.

Question 1, sur le périmètre couvert par AccidentSeverityCategory — et donc par le jeu entier.
Cette colonne ne prend que trois modalités : as3 « blessés légers » (77,9 %), as2 « blessés graves »
(20,8 %) et as1 « tués » (1,3 %). Autrement dit, il n'existe aucune modalité pour un accident sans
victime — pas de « dégâts matériels seuls ». Deux lectures très différentes en découlent, et l'enjeu
est celui du dénominateur de toute analyse : si le jeu ne retient que les accidents corporels, alors
chaque ligne implique au moins une personne blessée, et un taux « accidents pour 10 000 habitants »
calculé ici n'est pas comparable à une statistique nationale qui compte aussi les accidents
matériels — en Suisse ceux-ci sont environ deux à trois fois plus nombreux, donc un rapprochement
naïf sous-estimerait le risque d'un facteur 3 sans qu'aucun contrôle ne le signale. Le mécanisme
concret du second piège : quelqu'un qui lit as3 comme « accident léger, sans gravité » et le filtre
pour « ne garder que les accidents sérieux » écarterait 78 % des lignes qui toutes comportent un
blessé. Je penche pour (a) : trois modalités dont la moins grave est déjà « blessés légers » est la
signature d'une collecte restreinte aux accidents corporels ; l'indice contraire serait qu'un jeu
« toutes gravités » ait vu sa classe matérielle filtrée en amont sans trace, ce que je ne peux pas
exclure depuis le profil. Choisissez : (a) le jeu ne contient que des accidents avec victimes, toute
ligne implique au moins un blessé ; (b) le jeu couvre tous les accidents enregistrés par la police,
les accidents purement matériels étant présents mais codés ailleurs ou absents de cette colonne ;
(c) un autre périmètre que vous connaissez ; ou « je ne sais pas ».

Répondez par numéro et lettre (« 1a ») ou en texte libre.
> 1a

Point 1 verrouillé : le jeu est restreint aux accidents corporels — chacune des 267 761 lignes
implique au moins une personne blessée. Conséquence directe pour l'analyse : le dénominateur n'est
pas « tous les accidents de police » mais « les accidents avec victimes », donc tout rapprochement
avec une statistique nationale incluant les accidents à dégâts matériels seuls sous-estimerait le
risque d'un facteur 3 environ ; et as3 ne doit jamais être filtré comme « accident sans gravité »,
puisque ces 208 640 lignes comportent toutes un blessé. J'ai inscrit ce périmètre dans la fiche, sur
la colonne de gravité comme sur le dataset lui-même.

Question 2, sur ce que compte exactement AccidentSeverityCategory. La colonne répartit les lignes en
trois classes — as1 « accident avec tués » (1,30 %, soit environ 3 480 lignes), as2 « blessés
graves » (20,78 %, ≈ 55 640) et as3 « blessés légers » (77,92 %, ≈ 208 640) — et je dois savoir si
ces classes décrivent la victime la plus gravement atteinte de l'accident (classement hiérarchique,
un accident mortel pouvant aussi compter des blessés légers) ou des catégories exclusives au niveau
des personnes. L'enjeu est un contresens de comptage qui ne laisse aucune trace : dans la lecture
hiérarchique, les 3 480 lignes as1 ne donnent pas le nombre de tués (un accident peut en compter
plusieurs) mais le nombre d'accidents mortels, et les blessés légers présents dans les accidents as1
et as2 sont invisibles — publier « 208 640 blessés légers » serait alors faux deux fois, par
confusion accident/victime et par troncature hiérarchique. Le mécanisme banal qui casse : quiconque
somme les modalités pour reconstituer un bilan de victimes obtient un total qui ressemble à un bilan
officiel, tombe dans le bon ordre de grandeur, et est pourtant structurellement incomparable. Je
penche pour (a) : les libellés qualifient l'accident et non la personne (« accident avec tués », pas
« tué »), et l'absence totale de colonne de dénombrement de victimes indique un fichier au grain de
l'accident, où la gravité ne peut être qu'un agrégat du pire cas ; l'indice qui pousserait dans
l'autre sens serait l'existence d'une source de détail par personne dont ce fichier serait une
projection ligne-à-ligne, ce que le profil ne permet pas d'exclure. Choisissez : (a) gravité
hiérarchique = gravité de la victime la plus atteinte, une ligne = un accident, aucun comptage de
victimes possible ici ; (b) catégories exclusives portant sur les personnes ; (c) autre lecture que
vous connaissez ; ou « je ne sais pas ».

Répondez par numéro et lettre (« 2a ») ou en texte libre.
> 2a

Point 2 verrouillé : la gravité est hiérarchique et porte sur l'accident, pas sur la personne.
Conséquence pour l'analyse : les ~3 480 lignes as1 comptent des accidents mortels, jamais des tués —
le nombre de décès leur est supérieur et n'est pas reconstituable ici ; et les blessés légers
présents dans les accidents as1 et as2 sont définitivement invisibles, si bien qu'un bilan
« 208 640 blessés légers » est faux deux fois (grain accident ≠ grain victime, et troncature au pire
cas). J'ai corrigé la colonne de gravité en conséquence : ce jeu répond à « combien d'accidents
mortels », jamais à « combien de morts ».

Question 3, sur ce que recouvrent les trois indicateurs d'usagers AccidentInvolvingPedestrian,
AccidentInvolvingBicycle et AccidentInvolvingMotorcycle. Ce sont trois booléens vrais respectivement
pour 11,53 %, 24,70 % et 20,91 % des lignes — leur somme ne fait que 57 %, donc ils ne partitionnent
rien et « aucun drapeau » ne signifie pas « accident entre voitures » de façon fiable, faute d'un
indicateur pour les automobilistes ; surtout, le drapeau piéton (11,53 %) dépasse légèrement le type
d'accident at8 « impliquant des piétons » (11,26 %), soit environ 720 lignes d'écart, ce qui montre
que ces drapeaux ne recopient pas le type d'accident et suivent une règle propre que je ne peux pas
déduire du profil. L'enjeu porte sur les séries temporelles et il est coûteux : si le vélo
électrique est compté sous Bicycle, alors la hausse des accidents cyclistes entre 2011 et 2025
mélange un vrai changement d'exposition et un changement de composition du parc, et s'il bascule
sous Motorcycle selon la puissance, la même hausse se retrouve mécaniquement dans les deux courbes.
Le mécanisme banal qui casse : quelqu'un publie « +X % d'accidents de vélo en quinze ans » et
l'attribue à la politique cyclable, alors qu'une part de l'effet vient de la définition de la
catégorie ; l'erreur est invisible parce que les deux lectures produisent une courbe crédible. Je
penche pour (a) : le nom « Involving » et le fait que le drapeau piéton excède le type at8 suggèrent
une implication large — tout usager de ce mode présent dans l'accident, quel que soit son rôle et
qu'il soit blessé ou non — tandis que l'indice contraire serait que ces drapeaux soient dérivés d'un
fichier de victimes, auquel cas ils ne marqueraient que les usagers effectivement blessés.
Choisissez : (a) implication large, tout usager du mode présent dans l'accident, vélos électriques
inclus sous Bicycle et cyclomoteurs sous Motorcycle ; (b) le drapeau ne se lève que si un usager de
ce mode fait partie des victimes ; (c) une règle de périmètre différente que vous connaissez (par
exemple e-bikes rapides classés en motocycle, ou trottinettes exclues) ; ou « je ne sais pas ».

Répondez par numéro et lettre (« 3a ») ou en texte libre.
> 3a

Point 3 verrouillé : les trois drapeaux marquent une implication large — tout usager du mode présent
dans l'accident, blessé ou non, responsable ou non, vélos électriques comptés sous Bicycle et
cyclomoteurs sous Motorcycle. Conséquence concrète : les 66 140 lignes « vélo » forment une
catégorie dont la composition interne s'est déplacée sur quinze ans avec l'essor de l'e-bike, si
bien qu'une courbe « accidents de vélo 2011→2025 » mélange un effet d'exposition et un effet de
définition — elle reste publiable, mais jamais sans mentionner que les vélos électriques y sont
inclus. Conséquence symétrique côté Motorcycle : ce drapeau agrège motos lourdes et cyclomoteurs,
deux populations de risque très différentes, non séparables ici. Et puisque l'implication n'est pas
la victimisation, ces colonnes ne diront jamais qui a été blessé : croiser
AccidentInvolvingPedestrian avec as1 donne des accidents mortels impliquant un piéton, pas des
piétons tués.

En reprenant le profil pour boucler l'inventaire, je constate qu'une 36ᵉ colonne restait non
documentée : MunicipalityCode. Je viens de l'inscrire, mais un point de périmètre s'y attache que je
ne peux pas trancher seul.

Question 4, sur le millésime de référence de MunicipalityCode. Cette colonne porte 2 091 codes
distincts, en texte à quatre positions avec zéro de tête (0261 pèse 6,98 % des lignes, 0351 1,95 %),
sur quinze années d'accidents. Or les communes suisses fusionnent en continu : le pays en comptait
environ 2 500 en 2011 contre environ 2 130 aujourd'hui, et je dois savoir si le code inscrit est
celui de la commune au moment de l'accident (référentiel historique, donc mouvant d'une année à
l'autre) ou s'il a été rétro-harmonisé sur un état de référence unique. L'enjeu est un biais de
dénominateur invisible : jointe à une table de population d'un millésime donné, la lecture
historique laisse sans correspondance toutes les communes disparues depuis — un LEFT JOIN produit
alors des populations nulles et des taux d'accidents infinis ou tronqués sur plusieurs centaines de
communes, tandis qu'un INNER JOIN fait silencieusement disparaître les lignes concernées, surtout
les plus anciennes, ce qui fabrique une fausse tendance à la baisse en zone rurale. Symétriquement,
dans la lecture harmonisée, une série communale longue est cohérente mais les territoires fusionnés
absorbent l'historique de leurs prédécesseurs, ce qui crée des « sauts » d'effectif qui ne sont pas
des sauts d'accidentalité. Je penche pour (b) : 2 091 codes distincts est très proche du nombre
actuel de communes, alors qu'un cumul de codes historiques sur 2011–2025 devrait en faire apparaître
nettement plus, plusieurs centaines de codes ayant été retirés sur la période ; l'indice contraire,
qui m'empêche de trancher seul, est que beaucoup de très petites communes n'ont probablement connu
aucun accident corporel en quinze ans, ce qui peut suffire à ramener un cumul historique dans cet
ordre de grandeur. Choisissez : (a) code historique, tel qu'en vigueur à la date de l'accident ;
(b) code harmonisé sur un état de référence unique et récent ; (c) une autre règle que vous
connaissez ; ou « je ne sais pas », qui est une réponse pleinement valide — je l'inscrirai alors
comme piège avec sa procédure de vérification et son repli.

Répondez par numéro et lettre (« 4b ») ou en texte libre.
> 4a

Point 4 verrouillé : MunicipalityCode porte le code historique, celui de la commune telle qu'elle
existait à la date de l'accident. Conséquence lourde, et c'est probablement le piège le plus
opérationnel de la fiche : sur quinze ans, un même territoire peut apparaître sous plusieurs codes
successifs, et plusieurs centaines de codes présents dans les millésimes anciens n'existent plus
aujourd'hui. Jointe telle quelle à une table de population d'un millésime unique, la donnée produit
soit des populations nulles et des taux aberrants en LEFT JOIN, soit — bien plus dangereux — la
disparition silencieuse des lignes concernées en INNER JOIN, disparition qui frappe
préférentiellement les années anciennes et les petites communes rurales et fabrique une fausse
tendance à la baisse. La contrepartie positive : les effectifs par code sont fidèles au territoire
réellement en vigueur au moment des faits. La procédure obligatoire avant toute analyse communale
longitudinale est donc de remapper les codes sur un millésime cible via la liste historisée des
mutations de communes de l'OFS, puis de vérifier que le total d'accidents est conservé après
remappage.

L'inventaire est désormais complet : les 36 colonnes du profil sont documentées, plus une note
transversale sur les indicateurs d'usagers. Avant de vous demander la validation, voici les pièges
les plus coûteux — ceux qui faussent une analyse sans jamais se signaler :

- Le grain. Une ligne est un accident, jamais une victime, et la gravité est celle du pire cas. Les
  ~3 480 lignes as1 comptent des accidents mortels, pas des morts ; les blessés légers d'un accident
  mortel ne sont comptés nulle part. Sommer les modalités donne un total crédible et
  structurellement faux.
- Le périmètre. Le jeu ne contient que des accidents corporels. Tout rapprochement avec une
  statistique incluant les dégâts matériels seuls sous-estime le volume d'un facteur ~3, et as3
  n'est pas un « accident sans gravité » : le filtrer écarte 78 % des lignes, toutes avec blessé.
- at0 contre at00. Deux modalités opposées — « perte de maîtrise » (33 %) et « autres » (0,9 %) —
  que tout cast en entier ou strip de zéros fusionne silencieusement.
- Les codes textuels à zéro de tête (MunicipalityCode sur 4 positions, AccidentHour sur 2) : le cast
  numérique casse les jointures sans lever d'erreur, et pour les communes s'y ajoute la dérive
  historique du référentiel.
- Les coordonnées. LV95 en mètres (EPSG:2056), pas du WGS84 : sans reprojection explicite, tous les
  points sortent de la Terre ou sont rejetés en masse ; et E doit toujours excéder N.
- Les drapeaux d'usagers. Ils ne partitionnent pas (somme 57 %), il n'existe aucun indicateur
  automobile, l'implication n'est pas la victimisation, et les vélos électriques sont noyés dans
  Bicycle — ce qui rend toute tendance « accidents de vélo » sur quinze ans dépendante d'un effet de
  composition.
- Un point resté non tranché, inscrit comme tel : AccidentHour n'a que 24 modalités, sans valeur
  « heure inconnue ». Soit les accidents à heure indéterminée sont exclus, soit ils ont été imputés
  sans marqueur ; procédure de vérification auprès du producteur, repli en attendant : considérer le
  profil horaire comme légèrement biaisé et ne pas en tirer de conclusion fine.

La fiche me paraît complète et fidèle à ce que la donnée montre. La validez-vous en l'état, ou
souhaitez-vous corriger ou préciser un point avant clôture ?

[Valider ? 'o' = valider, sinon tape une correction]
> o
✓ fiche écrite : catalog/RoadTrafficAccidentLocations.fiche.yaml (sha256 ca40080edb96…)
```

## 8. POINTEUR DE REPRISE — la structure en deux appels

> État : branche `brique-10-brouillon-incremental` **ouverte, non mergée**, 7 commits sur `671f25d`,
> gate déterministe vert (188 tests, pyright 0). `main` intacte à v0.12.0.
> Cette section **remplace** un premier pointeur écrit le même jour, qui cadrait le problème en
> termes de **coût**. Alex a recadré : l'objectif n'est ni l'économie ni le prix, c'est **la maîtrise
> des appels et de leur contenu**, et **le temps** — parce que le travail vise des **centaines** de
> couches, où douze minutes par jeu est impossible.

### 8.1 Le modèle de temps, mesuré sur les deux traces

`hors-API = 3,4 s` sur une séance de 961 s. **Le temps est intégralement de la génération** :
`temps ≈ tokens générés ÷ 72`. L'entrée, le cache, les appels d'outil, le démarrage : négligeables.
Le cache et les dollars sont un **autre** problème, à ne plus confondre avec celui-ci.

Décomposition du temps de génération, qui tombe juste à la seconde :

| Ce que l'agent écrit | 06/08 matin | 06/08 soir | |
|---|---|---|---|
| la **fiche** (le livrable) | 322 s · 70 % | 257 s · 56 % | −65 s |
| la **prose** (le dialogue) | 81 s · 18 % | 107 s · 23 % | +26 s |
| le **raisonnement** | 57 s · 12 % | 98 s · 21 % | +41 s |
| **total** | **460 s** | **462 s** | **+2 s** |

La brique #10 a bien économisé 65 s sur la fiche. Elles ont été **intégralement reprises** par le
raisonnement et la prose. **La brique #10 est neutre sur le temps.**

### 8.2 Le pattern à connaître : on déplace la charge, on ne la réduit pas

- **#8** : on retire le brouillon intermédiaire → la mémoire passe en prose (le mur de texte).
- **#8 corrigée** : on le remet → il pèse 79 % de la sortie.
- **#10** : on le rend incrémental → le raisonnement (+39 %), le re-profilage (2 → 4 appels) et la
  verbosité de la fiche (+72 %) prennent le relais.

**Trois fois, on a contraint un canal et le système a compensé par un autre.** L'agent a un travail à
faire ; lui retirer un moyen ne retire pas le besoin. Toute slice future qui contraint **un** canal
sans borner le total reproduira ce résultat.

### 8.3 L'architecture qui casse la boucle — proposée par Alex, validée par les chiffres

Elle s'attaque à la **cause** (le nombre d'allers-retours) et non plus à ce qui transite dans chacun.
Elle est fondée sur une observation du transcript du 04/08, dont le **tour 1** dit déjà :
« Draft initial rédigé avec hypothèses. 3 questions prioritaires : (1)… (2)… (3)… » — l'agent prépare
tout **avant** la première réponse.

1. **Phase 1, un appel LLM** : profil, réflexion, fiche complète pour tout ce qui se tranche seul,
   **et toutes les questions préparées**.
2. **Phase 2, ZÉRO appel LLM** : l'application sert les questions une par une ou en liste numérotée,
   collecte les réponses. **Latence nulle** — c'est là qu'est le gain.
3. **Phase 3, un appel LLM** : toutes les réponses en append, l'agent révise, complète, résume les
   pièges coûteux, propose la validation.
4. *(Conditionnel)* un tour de plus **seulement** si la phase 3 soulève un point neuf.

| | aujourd'hui | structure en 2 appels |
|---|---|---|
| appels LLM | 5 | **2** |
| génération | 462 s | ~250 s |
| bout en bout | 961 s | **~400 s** |
| 300 couches | 80 h | **~33 h** |

**Ce que ça change pour la brique #10** : elle n'était pas fausse, elle était **incomplète**. Le
mécanisme de delta est ce qui rend la phase 3 bon marché — sans lui, la révision finale ré-émettrait
la fiche entière. Elle devient le **prérequis** de cette structure, et se justifie par elle.

**Le seul vrai travail de conception** : comment l'application récupère les questions. Deux voies —
dans le bloc JSON (propre, mais un bloc malformé fait perdre **toutes** les questions, et la prose
libre avait été choisie exactement pour ça, cf. Q-0014) ; ou découpage de la prose sur le motif
`Question N, sur X :` que l'agent produit **déjà**. Penchant : le second, JSON en secours.

**Deux risques nommés.** L'adaptivité : une question peut naître d'une réponse — la phase 4
conditionnelle la récupère. Et le batch, qui a déjà échoué en #8 — mais la cause diagnostiquée était
la ligne « Tranché seul : », et ici c'est l'**application** qui affiche une liste, pas l'agent qui
déverse trois questions en prose.

### 8.4 La charte : revenir au transcript de référence, par retrait

Un tour du 04/08 fait **~850 caractères**. Un tour du 06/08 soir en fait **2 600 à 3 500**. Même
contenu utile : objet, ancrage chiffré, enjeu rendu tangible par un mécanisme, options fermées.

Ce que la charte a ajouté et que le transcript de référence **n'a pas** : le **penchant
systématique**, l'**indice contraire**, la **signalisation d'irréversibilité**. Trois prescriptions
qui ne servaient pas la compréhension — au 04/08 l'humain répondait déjà « a » instantanément.

**Faire du gabarit un vrai tour du 04/08**, et retirer ces trois prescriptions. C'est un retrait, et
il attaque directement les 107 s de prose.

### 8.5 La fiche : une régression à réparer, et un contrat qui n'a jamais existé

**Régression causée par la brique #10.** Comparaison des livrables :

| | clés à la racine | vocabulaire des colonnes |
|---|---|---|
| #7c 04/08 | **12** — `grain`, `perimetre`, `srid`, `pieges_transversaux`, `points_non_tranches`, `points_confirmes`… | `sens`, `type`, `pieges`, `profil` |
| #8 06/08 matin | **10** — `grain`, `perimetre`, `referentiel_spatial`/`temporel`/`territorial`, `non_tranche`… | `role`, `note`, `tranche_sans_question` |
| #10 06/08 soir | **3** — `columns`, `dataset`, `titre` | `description`, `pieges`, `type_retenu` |

**Toute la connaissance transversale a disparu.** Cause : le § Format de sortie réécrit en #10 dit
« `dataset` et `titre` s'émettent une fois » — cela se lit comme une **liste fermée**, et l'agent a
obéi. C'est aussi ce qui explique la colonne fantôme `_indicateurs_usagers` : l'agent avait une note
transversale et **aucun endroit où la mettre**.

**Et le vocabulaire dérive à chaque run** (`sens` → `role` → `description`). La fiche est un dict
opaque pour Python — décision assumée de #7c — mais personne n'avait vu que cela laissait le
**contrat de la fiche** entièrement indéfini. Sans schéma, il n'y a ni notion de *complet*, ni notion
de *trop long*.

**Verbosité : réductible d'environ deux tiers sans perte.** Exemple réel, 420 → 150 caractères :

> *avant* — PIÈGE MAJEUR de code voisin : `at0` (33 % des lignes) et `at00` (0,92 %) sont DEUX
> modalités distinctes et sémantiquement opposées — « perte de maîtrise » contre « autres ». Toute
> normalisation qui strippe les zéros, caste en entier (`at0` → 0 et `at00` → 0) ou tronque à 3
> caractères fusionne silencieusement ~2 460 lignes « Autres » dans la catégorie la plus fréquente.
> Traiter exclusivement en texte, comparaison exacte.
>
> *après* — `at0` (33 %) ≠ `at00` (0,92 %), sens opposés. Strip de zéros, cast int, troncature
> 3 car. → fusionne 2 460 lignes. Texte strict, égalité exacte.

Ce qui part est de l'emphase et des connecteurs. **Un LLM reconstruit tout cela ; il n'a besoin que
des faits.**

**Le point de doctrine** : la fiche a **deux lecteurs aux besoins opposés**. Le LLM la relit verbatim
à **chaque** analyse future via `describe` — il paie la taxe de prose à chaque fois. L'humain ne la
lit qu'**une fois**, à la validation, et il valide surtout sur le résumé en prose du dernier tour. On
écrit aujourd'hui pour l'humain et on facture au LLM.

**Position retenue : une fiche dense, le résumé de validation restant la porte d'entrée humaine.**
Écrire deux projections serait une cathédrale pour un lecteur qui passe une fois.

**Schéma minimal à prescrire dans la charte** — pas dans Python, l'opacité côté transporteur est
préservée : un bloc racine pour la connaissance transversale (grain, périmètre, référentiels, pièges
transversaux, points non tranchés) et un vocabulaire de colonne **fixe**. C'est ce qui rend la
maîtrise : une notion de complet, une notion de trop long, un contrat sur lequel `describe` peut
s'appuyer.

| | aujourd'hui | dense + schéma |
|---|---|---|
| contenu de la fiche | 26 278 car. | ~9 000 car. |
| bloc transversal | perdu | restauré |
| vocabulaire | réinventé à chaque run | fixé |

### 8.6 Le troisième levier, gratuit à essayer

**`thinking=False`.** Le raisonnement pèse **98 s, 21 % du temps**. `demo_curator.py` passe
`thinking=True` et personne ne l'a jamais remis en question. La brique #8 corrigée a précisément fait
de `thinking` un paramètre déclaré par l'appelant pour que ce soit décidable. **Une ligne, à éprouver
au gate.**

### 8.7 Combien de slices : une, et ce sont des retraits

1. Structure en **deux appels** + questions servies par l'application (§ 8.3)
2. Charte alignée sur le transcript de référence — **retrait** (§ 8.4)
3. Fiche **dense** + schéma minimal restaurant le bloc transversal (§ 8.5)
4. `thinking=False` éprouvé au passage (§ 8.6)

Après cela il ne reste qu'une **décision produit** — combien de documentation par colonne — et aucun
mécanisme. Ce n'est pas un château de cartes : les quatre leviers **enlèvent** quelque chose.

Cumul attendu : **462 s → ~250 s de génération**, **961 s → ~400 s bout en bout**, et à l'échelle de
300 couches **80 h → ~33 h**.

### 8.8 Ce qu'il ne faut PAS refaire

- **Ne pas confondre temps et argent.** Trois sessions ont optimisé des dollars pendant que
  l'objectif était le temps et la maîtrise. Le cache et Q-0024 sont des sujets de **coût** ; ils ne
  font gagner **aucune** seconde.
- **Ne pas bâtir un critère de gate sur un diagnostic de recap.** Le critère « zéro `ToolSearch` »
  reposait sur une prémisse fausse : les outils MCP sont **différés** dans ce CLI, aucun renommage ne
  peut les supprimer (§ 4).
- **Ne pas contraindre un canal isolé** sans borner le total (§ 8.2).
- **Vérifier qu'un critère est atteignable** avant de l'arrêter : l'ancien critère « part du delta
  ≤ 50 % » était arithmétiquement impossible, et l'illustration du runbook le démontrait.
- **Le critère « delta ÷ fiche » est flatté par un dénominateur qui grossit** : à taille de fiche
  constante, le ratio du 06/08 soir vaut **2,1** et non 1,2. Le seul chiffre honnête est le brouillon
  émis, **−36 %**.
