# Veille — H3 comme substrat multi-résolution : bonnes pratiques, pièges, et adéquation aux accidents (réseau vs planaire)

- Date : 2026-08-01
- Contexte : cadrage de la brique D (anti-MAUP). Deep-research multi-agent web (5 angles → 23 sources
  → 103 claims → **25 vérifiés en 3 votes adversariaux, 21 confirmés / 4 réfutés**). Sources : docs
  officielles H3/Uber, h3geo.org, académique (PMC, IJGI, ScienceDirect), esda/pygeoda (code source).
- Statut : **référence durable**, intrant de design de la brique D. À lire avant tout code.
- Verdict d'ensemble : **H3 est un bon substrat multi-résolution générique, mais son adéquation à une
  analyse de concentration d'ACCIDENTS doit être NUANCÉE — le binning planaire est biaisé pour un
  phénomène contraint au réseau.**

---

## 1. Le test de robustesse multi-résolution est NÉCESSAIRE, pas optionnel (3-0)

Les mesures de concentration **dépendent fortement de l'échelle** → conclure depuis une seule
résolution est méthodologiquement fragile (IJGI 15(2):72, 2026 : « strong scale dependency…
necessity of multiscale approaches »). Fonde la raison d'être de D. *Nuance : ce papier mesure la
concentration de zones bâties (Lorenz), pas des événements ponctuels — extrapolation modeste,
soutenue par la littérature MAUP (Openshaw).*

## 2. H3 n'élimine pas le MAUP — il en déplace les artefacts (tous 3-0)

| Piège | Fait vérifié | Implication d'implémentation |
|---|---|---|
| **Hiérarchie non-emboîtante** (aperture-7) | Les hexagones ne se subdivisent pas exactement en 7 : **~14 % de l'aire d'un parent est non-congruente** avec ses enfants (7 % dedans/dehors). Uber : « only approximately contained within a parent cell » | L'agrégation hiérarchique (roll-up) **injecte un biais** ; ne pas traiter le parent comme l'union exacte des enfants |
| **Cellules NON équi-aires** | L'aire varie selon la position vs sommets de l'icosaèdre : ratio ~1,21 à res 0, jusqu'à ~2× en fine résolution (h3geo.org officiel) | **Normaliser les comptages par l'aire réelle de cellule** (`cell_area`), jamais supposer l'équi-aire |
| **12 pentagones** par résolution | Feature structurelle permanente (12 sommets icosaèdre), orientés **vers les océans** | Risque faible pour la Suisse, mais code robuste doit les détecter (`h3.is_pentagon`) — 6 voisins, brisent l'hypothèse de voisinage uniforme |
| **Avantage hexagone** | **Une seule distance** centre-voisin (vs 2 carrés, 3 triangles) → supprime l'ambiguïté de voisinage (rook/queen) pour Gi\*/LISA | Vrai bénéfice pour hotspot/autocorrélation vs grille carrée |

## 3. Hotspot / autocorrélation sur maille H3 — outillage (tous 3-0)

- **Gi\* par cellule H3 via `esda.G_Local`** (`star=True` inclut la cellule focale ; `star=False` = Gi).
  esda est **agnostique à la géométrie** : on encode l'adjacence **k-ring H3** en poids `libpysal`
  (`Graph`/`W` depuis `h3.grid_disk`) et on le passe à esda. *(La claim « esda n'a aucun support H3 »
  a été réfutée 0-3 : esda est simplement neighborhood-agnostic, le bridge H3→libpysal est trivial.)*
- **Modèle nul par permutation** : `p_sim` (défaut 999 permutations, randomisation conditionnelle,
  null = aléa spatial) **et** `p_norm` (analytique). Cohérent avec notre `concentration_test`.
- **PIÈGE MAJEUR — tests multiples (3-0)** : scanner Gi\*/LISA sur des milliers de cellules →
  **~5 % de faux positifs** (~500 pour 10 000 cellules). Pire, les tests locaux sont
  **non-indépendants** (cellules voisines partagent des voisins → l'autocorrélation gonfle
  artificiellement la significativité). **Correction FDR/Bonferroni indispensable.** Outillé :
  `esda.fdr()` (standalone, **non automatique**), pygeoda `lisa_fdr()`/`lisa_bo()`. Réf. canonique :
  Caldas de Castro & Singer 2006.

## 4. VERDICT CRITIQUE — H3 planaire est biaisé pour les accidents routiers (3-0)

Les accidents sont contraints à un **espace 1-D (le réseau routier)**, pas à un plan 2-D homogène.
Le KDE planaire (et par extension le **binning aréal planaire**, dont H3) **surestime la densité** en
étalant la masse dans l'espace hors-réseau où aucun accident ne peut survenir. La **Network KDE**
(Xie & Yan 2008, *Computers, Environment and Urban Systems* 32(5), >1000 citations) est plus
appropriée : « the planar KDE may not be suited for characterizing certain point events, such as
traffic accidents… the roadway network ».

**Ce que ça implique pour intreepid** (et c'est aligné sur notre posture d'honnêteté) :
- H3 reste une **lentille exploratoire multi-échelle** légitime et un bon outil de **robustesse**.
- Mais une conclusion de concentration d'accidents sur maille H3 **doit porter le caveat planaire** :
  soit croiser avec une méthode réseau, soit **signaler explicitement le biais** comme limite.
- C'est du **fait/hypothèse/refusé** appliqué à la *méthode*, pas seulement au résultat — un
  différenciateur : l'outil est honnête sur ses propres limites d'agrégation.

## 5. Caveats de cette veille (à ne pas surinterpréter)

1. **Biais planaire prouvé sur KDE, pas directement sur binning H3** : transfert logique solide (les
   deux étalent la densité 2-D hors-réseau) mais **aucune comparaison quantitative publiée H3-vs-NKDE
   sur accidents** dans le corpus.
2. **Extrapolation MAUP** : la source empirique de dépendance d'échelle porte sur des zones bâties.
   **3 claims de ce papier ont été RÉFUTÉES (0-3)** — notamment « la scale domine la zonation » et
   « hexagones ≈ carrés » → **ne pas** s'appuyer dessus pour hiérarchiser scale/zonation ni assimiler
   H3 à une grille carrée.
3. **Blog Uber = marketing** : les faits géométriques load-bearing (1/7 aire, 1/2/3 distances) sont
   vérifiés indépendamment (h3geo.org, ESRI, papiers) ; les cadrages « bénéfice » sont son argumentaire.
4. **API instables** : URLs pysal.org en 404 (claims vérifiées contre le **code source** esda main /
   v2.8–2.9, août 2026) ; **migration h3-py v3→v4** (ex. `geo_to_h3`→`latlng_to_cell`) **non couverte**
   → vérifier contre la doc officielle avant impl.
5. **14,375 %** cité par une seule source ; magnitude ~14 % (~1/7) = consensus. Ordre de grandeur.
6. **Non documentés par claim vérifiée** : les **résolutions H3 recommandées pour accidents** (res 7-9 ?),
   la règle « centaines de points/cellule », la **performance de l'extension DuckDB H3 / h3ronpy** à
   grande échelle. → à valider en impl, pas depuis cette veille.

## 6. Questions ouvertes soulevées (candidates OPEN-QUESTIONS)

- Existe-t-il une étude comparant **quantitativement** H3 vs méthode réseau (NKDE, segmentation) sur
  des accidents réels ? (corpus : biais établi par analogie KDE, pas de comparaison directe).
- Quelles **résolutions H3 concrètes** pour des accidents à l'échelle nationale ? Règle heuristique ?
- Comment construire un **modèle nul Gi\*** tenant compte **à la fois** de l'autocorrélation **et** de
  la contrainte réseau (les permutations conditionnelles d'esda supposent un support 2-D homogène) ?
- Maturité/performance réelle de l'**extension DuckDB H3** et de `h3ronpy`/`h3pandas` à grande échelle ;
  patterns d'intégration LV95→WGS84 éprouvés.

## 7. Pointeurs sources (sélection)

- Dépendance d'échelle (concentration) : `doi.org/10.3390/ijgi15020072`
- Non-emboîtement 14,375 % : `ncbi.nlm.nih.gov/pmc/articles/PMC8958999` ; Uber `uber.com/en/blog/h3` ; `h3geo.org/docs/core-library/overview`
- Aire non-constante / pentagones / résolutions : `h3geo.org/docs/core-library/restable` ; `observablehq.com/@nrabinowitz/h3-area-stats`
- Gi\*/permutation esda : `pysal.org/esda` ; code `github.com/pysal/esda` (getisord.py)
- FDR spatial (tests multiples) : Caldas de Castro & Singer 2006 (Geographical Analysis 38(2):180-208) ; `geodacenter.github.io/pygeoda/spatial_auto.html` ; `esda.fdr`
- **Biais réseau (verdict)** : Xie & Yan 2008, `sciencedirect.com/science/article/abs/pii/S0198971508000318`
