# Matériel — gate du curateur (#8 corrigé) : le niveau atteint par défaut

> Note de référence produite au session-end du 2026-08-06. Pendant de
> [`2026-08-04-curateur-gate-humain-materiel.md`](2026-08-04-curateur-gate-humain-materiel.md), qui
> capturait la **cible** ; celle-ci capture ce que la charte **délivre sans aide**. Résout Q-0022 ;
> alimente Q-0023 (volume de sortie) et Q-0024 (cache multi-tours).

## 1. Deux transcripts, deux natures — ne pas les confondre

| | 2026-08-04 (v1) | 2026-08-06 (v2, ce document) |
|---|---|---|
| Comment obtenu | charte v0.10.0 **+ précision live d'Alex** en cours de séance | charte v0.12.0 **seule**, zéro consigne de style |
| Statut | la **cible** — ce qu'on voulait rendre automatique | la **base atteinte** — ce qui sort par défaut |
| Tours agent / questions | 9 / 7 | 5 / 4 |
| Longueur d'un tour | ~678 car. en moyenne | **2 130 → 3 367 car. de prose** (+ le brouillon JSON, invisible) |

Le v1 **reste la référence de concision**. Le v2 est la référence de ce que le mécanisme produit
seul. Ils ne se remplacent pas : la slice de tuning à venir vise à les **faire converger** — garder
le premier tour du v2 et la longueur du v1.

## 2. Le finding : le mécanisme est acquis, le calibrage ne l'est pas

**Acquis.** Le **premier tour** porte les cinq éléments attendus sans qu'on ait rien demandé — objet,
ancrage chiffré tiré du profil, enjeu rendu tangible par un **mécanisme concret**, options fermées,
« je ne sais pas » déclaré valide, penchant assumé **avec son indice contraire**. Les réponses d'Alex
tiennent en `1a` / `2a` / `3b` / `4a` / `o` : aucune correction de forme. C'est exactement ce que
v0.10.0 ne savait pas faire, et c'est ce qui résout Q-0022.

**Non acquis, deux points.**

1. **Les questions font 3 à 5 fois la longueur de la cible.** Cause identifiée : la charte prescrit
   **plus** que le v1 ne contenait — le mécanisme rendu tangible, le signalement d'irréversibilité,
   *et* un indice contraire systématique. La question 1 ci-dessous donne **deux** mécanismes (lecture
   WGS84 *et* offset retranché) là où un seul suffirait.
2. **Moins de ratifications humaines** : 4 questions au lieu de 7. En v1 l'agent avait interrogé Alex
   sur le booléen piéton et les périmètres vélo/moto — deux jugements **métier** où sa réponse
   comptait. En v2 il les a tranchés seul. Le levier n'est pas un nombre de questions mais la
   **phrase de seuil** de la charte (« ne pose une question QUE si… »).

**À noter, contre-intuitif** : retirer la ligne « Tranché seul : » n'a **pas** fait disparaître
l'information. Le tour 1 résume ses arbitrages solitaires en **une phrase** (« J'ai déjà tranché seul
tout ce bloc de traductions, la granularité…, la complétude des années… »). Ce qui a disparu, c'est
l'**énumération** colonne par colonne — c'est-à-dire le mur, pas le contenu.

## 3. Ce que le fond a gagné par rapport au v1

Deux trouvailles absentes du v1, toutes deux structurantes pour une analyse :

- **`AccidentSeverityCategory` est ordinale à l'envers** — `as1` = tués, `as3` = blessés légers. Un
  tri ou un `max` numérique **inverse** la gravité. Et elle qualifie l'**accident**, pas des
  victimes : aucun comptage de victimes n'existe dans le jeu, on ne peut donc **jamais** sommer des
  victimes.
- **Le millésime communal a été tranché contre le penchant de l'agent.** Alex a répondu `3b` là où
  l'agent penchait pour `(a)`. L'agent a verrouillé « **contre mon penchant** » et, au lieu
  d'abandonner son observation, l'a inscrite comme **piège non résolu** avec sa procédure de
  vérification (compter les codes distincts année par année). C'est le comportement que la puce
  PENCHANT visait : permettre la contradiction sans perdre l'information.

## 4. Transcript réel (base atteinte) — 5 tours d'agent, 4 questions, fiche validée

> `>` = saisie humaine. Modèle : `opus`, `thinking` activé. Fiche validée (`curation_validated`,
> hash `60a7d3bc6058…`), conservée en
> [`2026-08-06-RoadTrafficAccidentLocations.fiche.v2.yaml`](2026-08-06-RoadTrafficAccidentLocations.fiche.v2.yaml)
> (301 lignes, 36 colonnes). Les blocs JSON de métadonnées ne sont pas affichés à l'humain et
> n'apparaissent donc pas ici — ils représentent pourtant **79 %** de ce que l'agent écrit (cf. §5).

```
I'll start by profiling the dataset.

J'ai profilé le jeu : 267 761 lignes, 36 colonnes, sans aucune valeur nulle sur les colonnes
numériques. Le contenu est manifestement un recensement d'accidents de la route en Suisse (26 codes
de canton, 2 091 communes, années 2011 à 2025), avec un jeu massif de colonnes redondantes : chaque
variable catégorielle existe en code technique plus quatre libellés traduits (de/fr/it/en). J'ai déjà
tranché seul tout ce bloc de traductions, la granularité (une ligne = un accident, AccidentUID unique
à 100 %) et la complétude des années (chaque millésime pèse entre 6,3 % et 7,1 %, aucun n'est
tronqué). Reste ce que le profil ne peut pas décider.

Question 1, sur le couple AccidentLocation_CHLV95_E / AccidentLocation_CHLV95_N. Le profileur les
type « numérique », avec E entre 2 486 335 et 2 832 028 et N entre 1 075 625 et 1 294 423, zéro
valeur nulle et zéro valeur à 0 — donc aucun point n'est manquant ni codé par un zéro parasite.
L'enjeu est brutal et parfois invisible : ces nombres à sept chiffres ne sont pas des degrés, et si on
les passe tels quels à une bibliothèque cartographique qui présuppose du WGS84 (latitude/longitude),
les 267 761 points atterrissent hors de toute carte plausible sans qu'aucune erreur ne soit levée ;
symétriquement, si quelqu'un retranche l'offset de 2 000 000 / 1 000 000 en croyant « nettoyer » les
colonnes, il bascule silencieusement les points dans l'ancien système national et décale tout le jeu
— et si le fichier est réécrit ainsi, la perte est irréversible. Le nom même de la colonne et les
plages observées pointent vers le système national suisse actuel en mètres ; l'indice qui pousserait
dans l'autre sens serait que le producteur ait exporté des coordonnées déjà converties tout en gardant
l'ancien nom de colonne. Choisissez : (a) CH1903+ / LV95, EPSG:2056, unité mètre, géométrie
ponctuelle ; (b) ancien CH1903 / LV03, EPSG:21781 ; (c) autre référentiel que vous préciseriez ; ou
« je ne sais pas », qui est une réponse pleinement valide.

Répondez par numéro et lettre (« 1a ») ou en texte libre.
> 1a

Point 1 verrouillé : les coordonnées sont en CH1903+ / LV95, EPSG:2056, unité mètre, géométrie
ponctuelle. Conséquence pour l'analyse : toute carte ou jointure spatiale avec une couche en WGS84
exige une reprojection explicite EPSG:2056 → EPSG:4326 — sans elle, rien ne plante mais les 267 761
points sortent du monde ; en revanche les distances, tampons et grilles se calculent directement en
mètres sans facteur de conversion, et l'offset 2 000 000 / 1 000 000 fait partie intégrante du
système : il ne doit jamais être retranché.

Question 2, sur le périmètre couvert par AccidentSeverityCategory. Cette colonne ne prend que trois
modalités, et elles se répartissent la totalité des lignes : as3 blessés légers 77,92 %, as2 blessés
graves 20,78 %, as1 tués 1,30 % — il n'existe aucune modalité « dégâts matériels seulement », alors
que ce type d'accident constitue habituellement le gros des constats de police, et le volume observé
(≈ 17 850 accidents par an sur quinze ans) est nettement inférieur au total des accidents recensés en
Suisse. L'enjeu est celui d'un dénominateur invisible : si l'on prend ce fichier pour « tous les
accidents », alors la part d'accidents avec blessés y vaut mécaniquement 100 %, tout taux de gravité
par canton, type de route ou heure devient un taux conditionnel aux accidents corporels présenté à
tort comme absolu, et une comparaison avec une statistique nationale « tous accidents » divise par un
dénominateur deux à trois fois trop petit sans qu'aucun contrôle ne s'en aperçoive. Je penche pour
(a) : l'absence totale d'une modalité « dégâts matériels » dans une nomenclature par ailleurs
exhaustive et codée (as1/as2/as3 consécutifs, sans trou) est le signe d'un périmètre restreint à la
source, et non d'un filtrage accidentel ; l'indice contraire serait qu'un extracteur ait appliqué un
filtre en amont sans le documenter, cas où la restriction serait un artefact de l'export plutôt
qu'une propriété du référentiel. Choisissez : (a) le fichier ne couvre que les accidents corporels
(avec blessés ou tués), les accidents à dégâts matériels seuls sont hors périmètre à la source ;
(b) le fichier prétend couvrir tous les accidents, l'absence de dégâts matériels seuls résulte d'un
filtre appliqué en amont ; (c) autre périmètre que vous préciseriez ; ou « je ne sais pas », qui est
une réponse pleinement valide.

Répondez par numéro et lettre (« 2a ») ou en texte libre.
> 2a

Point 2 verrouillé : le fichier couvre uniquement les accidents corporels (avec blessés légers,
blessés graves ou tués), les accidents à dégâts matériels seuls étant hors périmètre à la source.
Conséquence directe pour l'analyse : la part d'accidents corporels y vaut mécaniquement 100 %, donc
tout indicateur du type « gravité moyenne », « taux de blessés » ou « % d'accidents graves » calculé
sur ce fichier est un taux conditionnel aux accidents corporels et ne doit jamais être présenté comme
un taux « tous accidents » ; toute comparaison avec une statistique nationale, un dénominateur de
trafic ou un fichier d'assurance exige de vérifier que l'autre source est restreinte au même
périmètre, faute de quoi le rapport est faussé d'un facteur deux à trois. En positif, le périmètre
est stable et homogène sur les quinze millésimes : les évolutions annuelles sont interprétables sans
correction de champ.

Question 3, sur le millésime de MunicipalityCode. Cette colonne porte 2 091 codes OFS distincts sur
l'ensemble des quinze années (« 0261 » Zurich 6,98 %, « 6621 » 2,91 %, « 5586 » 1,99 %), or la Suisse
comptait environ 2 600 communes en 2011 contre environ 2 130 aujourd'hui : le fichier contient donc
moins de codes distincts que le nombre de communes actuelles, ce qui est incompatible avec
l'accumulation de quinze ans de codes historiques. L'enjeu porte sur les séries communales et les
jointures : si les codes sont ceux en vigueur à la date de l'accident, une commune absorbée par
fusion en 2016 voit sa série tomber à zéro du jour au lendemain pendant qu'une autre naît de rien —
on lit une « disparition des accidents » de 100 % qui n'est qu'un changement de découpage — et un
inner join avec un référentiel millésimé 2025 laisse silencieusement orphelines toutes les lignes
anciennes, sans message d'erreur ; si à l'inverse les codes sont harmonisés, le passé est
rétro-attribué à des périmètres qui n'existaient pas encore, ce qui est acceptable pour une carte
mais doit être écrit noir sur blanc. Je penche pour (a) : le compte de 2 091 codes, inférieur au
nombre de communes actuelles, s'explique bien par une harmonisation sur un millésime récent où
quelques petites communes n'ont connu aucun accident corporel, et très mal par un empilement
historique qui devrait en produire nettement plus de 2 600 ; l'indice contraire serait que le
producteur n'ait mis à jour les codes qu'à partir d'une certaine année, cas hybride où les millésimes
coexisteraient. Choisissez : (a) codes harmonisés sur un millésime récent unique, identique pour
toutes les années ; (b) codes en vigueur à la date de l'accident, donc millésimes mélangés ;
(c) autre situation que vous préciseriez ; ou « je ne sais pas », qui est une réponse pleinement
valide.

Répondez par numéro et lettre (« 3a ») ou en texte libre.
> 3b

Point 3 verrouillé, et contre mon penchant : MunicipalityCode porte les codes OFS en vigueur à la
date de l'accident, donc des millésimes mélangés sur les quinze années. Conséquence lourde pour toute
analyse communale : une série temporelle par code est structurellement discontinue — une commune
absorbée par fusion voit ses accidents tomber à zéro sans qu'aucune valeur ne manque, et une commune
créée apparaît ex nihilo, ce qui produit de fausses ruptures de tendance de −100 % ou +∞ ; un inner
join avec un référentiel communal millésimé 2025 laisse silencieusement orphelines les lignes des
années anciennes, sans erreur ni avertissement, et un left join les remplit de libellés nuls qu'on
prendra pour des codes invalides. La procédure correcte est de passer par la table des mutations de
communes de l'OFS pour rétro-harmoniser sur un millésime unique avant toute série longue ; le repli
praticable, si cette table n'est pas disponible, est d'agréger au niveau CantonCode, stable sur toute
la période. J'inscris aussi comme piège non résolu l'anomalie de comptage : 2 091 codes distincts est
inférieur à ce qu'un empilement de quinze millésimes laisserait attendre, ce qui suggère soit de
nombreuses petites communes sans aucun accident corporel, soit une mise à jour partielle des codes
par le producteur — à vérifier en comptant les codes distincts année par année.

Question 4, sur la nature horaire de AccidentHour et AccidentHour_text. Le profil montre 24 modalités
textuelles à zéro de tête (« 00 » à « 23 »), aucune valeur manquante ni code sentinelle du type
« 99 », et un profil journalier très marqué : pic à 17h (10,67 %), puis 16h (8,76 %) et 18h (7,27 %),
creux nocturne — la forme classique d'une pointe pendulaire locale. L'enjeu apparaît dès qu'on croise
ce fichier avec une autre source horodatée : les données météo, les comptages de trafic et la plupart
des API sont en UTC, et si l'heure d'ici est en heure légale suisse, un croisement naïf décale tout
d'une heure en hiver et de deux en été — décalage variable selon la saison, donc impossible à
corriger après coup par une constante, et qui déplace mécaniquement une partie du pic de 17h vers 15h
ou 16h dans l'analyse croisée ; le même flou fait basculer les accidents de nuit d'un jour de semaine
à l'autre autour de minuit et fausse toute définition de « nuit du samedi au dimanche ». Je penche
pour (a) : les libellés AccidentHour_text sont rédigés en format local (« 17h-18h ») et le pic à 17h
correspond exactement à la sortie de bureau en heure locale, alors qu'en UTC ce pic apparaîtrait à
16h l'hiver et 15h l'été, ce qui n'est pas ce qu'on observe ; l'indice qui pousserait dans l'autre
sens serait un producteur ayant normalisé ses horodatages en UTC avant d'extraire l'heure, cas où la
cohérence apparente ne serait qu'un artefact du décalage d'une heure. Choisissez : (a) heure légale
locale suisse (CET/CEST, avec changement d'heure), tranche fermée à gauche [h, h+1[ ; (b) heure UTC ;
(c) autre convention que vous préciseriez, par exemple une heure d'enregistrement du constat plutôt
que de survenue ; ou « je ne sais pas », qui est une réponse pleinement valide.

Répondez par numéro et lettre (« 4a ») ou en texte libre.
> 4a

Point 4 verrouillé : AccidentHour est exprimée en heure légale locale suisse (CET/CEST, changement
d'heure inclus), et désigne une tranche fermée à gauche [h, h+1[. Conséquence pour l'analyse : les
profils journaliers, les définitions de « nuit » et les comparaisons heures de pointe / heures creuses
se lisent directement, sans décalage — mais tout croisement avec une source en UTC (météo, comptages
de trafic, API) exige de convertir explicitement en tenant compte de la saison, +1 h en hiver et
+2 h en été. Comme le décalage n'est pas constant, il ne peut pas être corrigé après coup par une
soustraction unique : si le croisement est fait sans conversion, une partie du pic de 17 h se
retrouve attribuée à 15 h ou 16 h selon le mois, et les accidents de fin de nuit basculent d'un jour
de semaine à l'autre, faussant toute analyse « nuit du samedi au dimanche ». J'inscris aussi que le
changement d'heure crée deux heures locales atypiques par an (une heure inexistante en mars, une
heure doublée en octobre) : négligeable sur 267 761 lignes, mais à ne pas confondre avec une anomalie
de collecte.

La fiche couvre désormais les 36 colonnes du profil. Avant de vous demander de valider, voici les
pièges les plus coûteux — ceux qui faussent une analyse sans jamais lever d'erreur :

- Le périmètre est restreint aux accidents corporels. La part d'accidents avec blessés y vaut 100 %
  par construction. Tout « taux de gravité » ou « % d'accidents graves » calculé ici est conditionnel ;
  comparé à une statistique « tous accidents », le dénominateur est deux à trois fois trop petit.
- Les coordonnées sont en EPSG:2056, en mètres. Passées telles quelles à un outil qui présuppose du
  WGS84, les 267 761 points sortent de la carte sans erreur ; et retrancher l'offset 2 000 000 /
  1 000 000 pour « nettoyer » bascule silencieusement tout le jeu en LV03 — irréversible si le
  fichier est réécrit.
- MunicipalityCode mélange les millésimes OFS. Une série communale y est structurellement discontinue
  (fusion = chute à −100 % sans valeur manquante), et une jointure sur un référentiel récent laisse
  les années anciennes orphelines sans avertissement. Repli : agréger au canton, seul niveau stable.
- MunicipalityCode et AccidentHour sont du texte à zéro de tête. Un cast en entier détruit « 0261 »
  et « 07 » et casse les jointures.
- AccidentSeverityCategory est ordinale à l'envers (as1 = le plus grave) : un tri ou un max numérique
  inverse la sévérité. Elle qualifie l'accident, pas des victimes — aucun comptage de tués ou de
  blessés n'existe, on ne peut donc jamais sommer des victimes.
- at0 et at00 sont deux modalités distinctes : toute normalisation de code fusionne ~2 460 lignes dans
  la modalité majoritaire.
- Deux points restent non tranchés et sont inscrits comme tels : l'anomalie de comptage des codes
  communaux (2 091 codes distincts, moins que le nombre de communes actuelles, alors qu'un empilement
  de quinze millésimes devrait en produire davantage — à vérifier en comptant les codes distincts
  année par année), et le fait qu'aucune date calendaire ni minute n'existe, ce qui interdit toute
  chronologie fine ou tout délai entre deux accidents.

Si cette lecture vous paraît fidèle, validez la fiche ; sinon, dites-moi quel point corriger ou
approfondir et je rouvre une question.

[Valider ? 'o' = valider, sinon tape une correction]
> o
✓ fiche écrite (sha256 60a7d3bc6058…) — statut closed, 4 tours humains, 1 nœud curation_validated.
```

## 5. Les mesures de la séance — ce que le v1 ne pouvait pas donner

```
bout en bout 734.4s · 1.8033 USD · 5 tours · dont API 460.6s · hors API 7.2s
#1  90.0s · 0.3261 USD · in 8 (cache 58059 lus / 14222 créés) / out 6193 tokens
#2  97.4s · 0.3470 USD · in 6 (cache 53236 lus / 14676 créés) / out 6943 tokens
#3  88.5s · 0.2967 USD · in 2 (cache 14137 lus / 10014 créés) / out 7579 tokens
#4 101.7s · 0.3808 USD · in 2 (cache 14137 lus / 16122 créés) / out 8500 tokens
#5  90.3s · 0.4527 USD · in 2 (cache 14137 lus / 23327 créés) / out 8494 tokens
Sortie écrite : tour d'agent 69 628 car. (prose + bloc de métadonnées) · thinking 9 829 car.
Appels d'outil : ToolSearch × 4, mcp__intreepid__profile_raw × 2
```

Ce que ces chiffres établissent :

- **79 % de ce que l'agent écrit est le brouillon de fiche** — 55 544 caractères sur 69 628, ré-émis
  entier à chaque tour et croissant (7 764 → 19 242 car. par tour). Le levier de coût n'est ni la
  charte ni le raisonnement. → **Q-0023**.
- **Le cache d'entrée ne tient pas en multi-tours** : les lectures plafonnent à 14 137 dès le tour 3
  (la charte seule) tandis que les créations croissent. L'historique est **re-créé** à chaque tour.
  → **Q-0024**.
- **98 % du temps est de la génération** (460,6 s d'API sur 467,8 s hors attente humaine). Le
  démarrage de processus et l'amorçage MCP pèsent 7,2 s au total.
- **Deux prédictions réfutées** : « une question à la fois allonge la séance » (5 tours contre 9) et
  « la latence par tour croîtra au fil de la séance » (90,0 / 97,4 / 88,5 / 101,7 / 90,3 s — plate).
- Les **4 appels `ToolSearch`** sont un artefact de la charte, qui nomme `profile_raw` là où l'outil
  est enregistré `mcp__intreepid__profile_raw`. → **Q-0019**.

## 6. Pistes pour la slice de tuning (à confirmer au design)

- **Raccourcir en commençant par le gabarit** : c'est l'exemple qui porte la longueur, pas la
  consigne — sa question restante fait 12 lignes. Puis « quatre à six phrases » → **trois à quatre**,
  indice contraire rendu **conditionnel** à un doute réel, **un seul** mécanisme par enjeu.
- **Revoir la phrase de seuil** si l'on veut plus de ratifications humaines : le nombre de questions
  est une conséquence, pas un réglage.
- **Nommer l'outil MCP par son identifiant complet** dans la charte (supprime 4 appels).
- Les deux gros leviers (brouillon incrémental, primitive du SDK) relèvent de Q-0023 et Q-0024 et
  méritent leur propre cycle.
