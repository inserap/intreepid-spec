# Matériel — gate humain du curateur (#7c) : la qualité conversationnelle

> Note de référence produite au session-end du 2026-08-04. **Input de la slice
> conversationnelle dédiée** (Q-0022). Capture le finding + le transcript réel
> (gold-standard) + un pointeur vers la fiche produite.
>
> **Suite (2026-08-06)** : Q-0022 est **résolue** — le niveau décrit ici est désormais actif par
> défaut, sans précision live. Voir le pendant de cette note :
> [`2026-08-06-curateur-gate-materiel.md`](2026-08-06-curateur-gate-materiel.md). Distinction à
> garder : **ce document reste la référence de concision** (~678 car. par tour) ; le v2 est la
> référence de ce que la charte délivre **seule** (2 130-3 367 car. de prose par tour). Les faire
> converger est l'objet de la slice de tuning.

## 1. Le finding : une hiérarchie claire de qualité conversationnelle

Le gate humain de la brique #7c (curation réelle de l'OFROU **brut**,
`RoadTrafficAccidentLocations.parquet`, 267 761 lignes, 36 colonnes) a établi
trois niveaux :

1. **Charte terse (livrée v0.10.0)** → questions **robotiques**, télégraphiques,
   batchées ; l'humain (non-expert de la donnée) ne comprend pas ce qu'on lui
   demande ni quoi répondre.
2. **Charte « naturelle » (patch v0.10.1, abandonné)** → *mieux* mais *insuffisant* :
   l'ajout de directives abstraites (« auto-suffisante », « explique pourquoi »,
   options candidates) ne change pas fiablement le ton, et un premier essai
   restait dense. (Tweak retiré avant merge : jamais shippé.)
3. **Charte + précision live de l'humain** → **excellent** (cf. transcript §3).
   Quand l'humain écrit en cours de conversation « pose-moi les questions les unes
   après les autres et sois moins succinct et plus langage naturel avec des
   exemples », le curateur bascule **immédiatement** vers une curation experte.

**Delta à comprendre pour la slice** : ce que la *précision live* ajoute que la
charte par défaut (même « naturelle ») ne capture pas encore. L'objectif est de
rendre le style du niveau 3 **actif par défaut** (charte et/ou modèle
d'interaction : une question à la fois, langage naturel, exemples **générés au
runtime depuis le profil** — jamais câblés —, options A/B/C, dosage du détail).

## 2. Pourquoi ça compte (valeur cœur, pas polish)

La personne métier travaille souvent sur un jeu **qu'elle n'a pas produit / ne
connaît pas** — c'est justement l'intérêt de **croiser** des données neuves. Sa
compréhension fine est ce qui lui permet de savoir **comment croiser**. Donc la
pédagogie du curateur *est* le livrable. Le transcript le prouve : au point 4, le
curateur **révèle un piège que l'humain n'avait pas identifié** (le millésime des
codes communaux) — la maïeutique *réalisée* (Q-0020), pas théorique.

## 3. Transcript réel (gold-standard) — 8 tours, fiche validée

> **« Gold-standard », dit autrement : le transcript de référence.** Terme d'évaluation désignant une
> sortie validée par un humain, contre laquelle on compare les suivantes. Ici : **cette** conversation
> — celle où, après la précision live d'Alex, le curateur a basculé vers une curation experte. C'est
> le niveau qu'on cherche à rendre actif **par défaut**. Les artefacts postérieurs au 2026-08-06
> écrivent « transcript de référence » (le projet converse en français) ; le terme anglais subsiste
> dans les documents antérieurs, dont celui-ci.

> `>` = saisie humaine. Modèle : opus. Fiche validée (`curation_validated`,
> hash `48e4743a79fb…`). La fiche produite est en
> [`RoadTrafficAccidentLocations.fiche.example.yaml`](RoadTrafficAccidentLocations.fiche.example.yaml)
> (exemple de référence, **pas** une fiche de production).

```
Profil obtenu : 267 761 lignes, 36 colonnes. Draft initial rédigé avec hypothèses. 3 questions prioritaires : (1) SRID/unité des coordonnées CHLV95 — EPSG:2056 en mètres ? (2) le périmètre ne couvre-t-il que les accidents corporels, sans les dégâts matériels ? (3) at0 et at00 sont-ils bien deux modalités distinctes ? Répondez par numéro ou en texte libre ; « je ne sais pas » est valide et sera inscrit comme piège à confirmer.
> Pose moi les questions les unes après les autres et soit moins succints et plus language naturel avec des exemples pour que je comprenne bien tes question.
Question 1 sur le référentiel spatial : les colonnes AccidentLocation_CHLV95_E (2 486 335 → 2 832 028) et _N (1 075 625 → 1 294 423) sont typées 'numérique' par le profileur, mais ce sont des coordonnées projetées — une moyenne n'y a aucun sens. Les ordres de grandeur (Est ≈ 2,6 M / Nord ≈ 1,2 M) correspondent au système suisse moderne CH1903+/LV95 (EPSG:2056), où la gare de Zurich vaut E=2 683 000 / N=1 247 000, alors que l'ancien LV03 (EPSG:21781) donnerait 683 000 / 247 000. L'enjeu : si l'unité est le mètre, les distances se calculent directement par Pythagore et un rayon de 500 m s'écrit 500 ; sinon tout buffer est faux d'un facteur 1000. Choisissez : (a) EPSG:2056 en mètres, (b) EPSG:21781, (c) autre, ou « je ne sais pas ».
> a
Point 1 verrouillé : coordonnées en EPSG:2056 (CH1903+/LV95), unité mètre. Question 2, sur le périmètre : AccidentSeverityCategory ne contient que 3 modalités (as3 blessés légers 77,9 %, as2 blessés graves 20,8 %, as1 tués 1,3 %), toutes impliquant au moins une victime. Aucune catégorie « dégâts matériels uniquement » sur 267 761 lignes, alors que ces accrochages sans blessé sont en réalité les plus nombreux. L'enjeu : si le périmètre est corporel-seulement, alors « 1,3 % d'accidents mortels » doit se dire « 1,3 % des accidents CORPORELS », sinon le chiffre est faux d'un facteur 5 à 10. Choisissez : (a) périmètre corporel uniquement, (b) 4e modalité filtrée en amont, (c) autre, ou « je ne sais pas ».
> a
Point 2 verrouillé : périmètre corporel uniquement — aucun taux ici n'est un taux tous accidents. Question 3, sur AccidentType : at0 = « dérapage ou perte de maîtrise » (33,1 %, dominante) et at00 = « autres » (0,9 %). Un seul zéro les sépare comme chaîne. Trois manipulations banales les fusionnent silencieusement : LIKE 'at0%' donne 34,0 % au lieu de 33,1 % ; une extraction numérique donne 0 pour les deux et la perte est IRRÉVERSIBLE ; une troncature CHAR(3) transforme at00 en at0. Mais si at00 était un doublon mal encodé de at0, il faudrait au contraire les fusionner. Indice : les libellés des 4 langues diffèrent pour les deux codes → deux catégories réelles. Choisissez : (a) deux modalités distinctes, (b) at00 = doublon à fusionner, (c) autre, ou « je ne sais pas ».
> a
Point 3 verrouillé : at0 et at00 distincts — ne jamais les fusionner. Question 4, sur MunicipalityCode : 2 091 codes distincts, en TEXTE avec zéro de tête (« 0261 » ≈ Zurich, 6,98 %). Le cast en entier casse la jointure (261 ≠ « 0261 ») et fait disparaître Zurich et Berne (~9 %). Ce que je ne peux pas trancher : le MILLÉSIME. Les communes suisses fusionnent constamment. Exemple : trois villages à 2 accidents/an fusionnent en 2018 sous le code du premier ; la courbe de ce code triple en 2018 alors que rien n'a changé sur la route. Choisissez : (a) codes harmonisés sur un millésime récent ; (b) codes historiques à la date de l'accident — séries cassées aux fusions ; (c) autre ; ou « je ne sais pas ».
> je ne sais pas et tu relève un bon point que je n'avais pas identifié
Point 4 enregistré comme NON TRANCHÉ : millésime communal inscrit comme piège explicite avec procédure de vérification (croiser MunicipalityCode × AccidentYear pour repérer apparitions/disparitions de codes = signature d'une fusion ; mesurer le taux de correspondance de toute jointure). Repli : pour une série longue, préférer la maille cantonale (stable) ou les coordonnées. Question 5, sur les piétons : AccidentInvolvingPedestrian = vrai sur 11,53 % (≈ 30 870), tandis que at8 « piétons » couvre 11,26 % (≈ 30 150) — ≈ 720 d'écart. Trop régulier pour être du hasard. Le booléen coche une présence ; at8 impose UN déroulement principal parmi onze. Une voiture qui dérape et heurte un piéton = at0 + booléen coché. Choisissez : (a) booléen plus large que le type, (b) censés équivalents (incohérence), (c) autre, ou « je ne sais pas ».
> a
Point 5 verrouillé : booléen piéton = SUR-ENSEMBLE de at8. Booléen pour compter, at8 pour analyser, jamais additionnés. Question 6, vélo/moto : AccidentInvolvingBicycle 24,70 %, AccidentInvolvingMotorcycle 20,91 %. Vélos électriques décisifs : comptés comme vélos, une hausse 2011-2025 peut refléter l'explosion du parc plutôt qu'une dégradation. « Motocycliste » peut inclure/exclure scooters et 50 cm³. La somme des trois booléens = 57,1 % (majorité = usagers vulnérables). Choisissez (séparément vélo/moto) : (a) périmètres larges (e-bikes/scooters inclus) ; (b) stricts ; (c) modifié en cours de période ; ou « je ne sais pas ».
> a
Point 6 verrouillé : périmètres LARGES. Piège nouveau : colonnes hétérogènes en interne, aucune colonne « type d'engin » → une hausse « vélo » mêle inséparablement croissance e-bike, vitesses, accidentalité. Question 7 (dernière), AccidentHour : 24 valeurs (« 00 »-« 23 »), aucun null, tranches d'une heure. Couverture 100 % = affirmation forte (une voiture retrouvée au petit matin sans témoin n'a pas d'heure connue). Trois traitements indistinguables : heure toujours estimée ; ou inconnus rattachés à une tranche (« 00 »/« 12 » artificiellement grosse) ; ou exclus. Un pic « 00 » pourrait être un artefact. Choisissez : (a) toujours connue/estimée ; (b) sentinelle déguisée dans une tranche ; (c) inconnus exclus ; ou « je ne sais pas ».
> a
Point 7 verrouillé : heure toujours renseignée (au besoin estimée), couverture réelle. Nuance : certaines heures sont estimées et rien ne les distingue → analyse des tranches nocturnes moins précise. LA FICHE EST COMPLÈTE : 36 colonnes. Six points structurants tranchés. Un point non tranché (millésime communal) porté en procédure de vérification. Trois pièges les plus coûteux : le dénominateur (rien n'est un taux tous accidents), les codes textuels à zéro de tête (un cast efface Zurich/Berne), at0/at00. Validez-vous cette fiche ?
[Valider ? 'o' = valider, sinon tape une correction]
> o
✓ fiche écrite (sha256 48e4743a79fb…) — statut closed, 8 tours humains, 1 nœud curation_validated.
```

## 4. Pistes pour la slice (à confirmer au design)

- Graver le style niveau 3 par défaut : **une question à la fois**, langage naturel,
  **exemple runtime tiré du profil**, options A/B/C, « je ne sais pas » → piège.
- Comprendre le delta live : peut-être la charte doit *montrer* le niveau de détail
  attendu (sans câbler d'exemple métier — garde `no-hard-coded-scenarios`).
- Tester si le format de sortie (`message` en string JSON) tire vers la compression,
  et si un champ dédié aux questions changerait le ton.
- Réserve : « une à la fois » sur 36 colonnes = beaucoup de tours ; priorisation +
  regroupement des points vraiment liés.
```
