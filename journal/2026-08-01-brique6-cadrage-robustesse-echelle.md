# Journal — Brique #6 (robustesse d'échelle H3) : cadrage, 2 deep-research, design + plan advisor SHIP

- Date : 2026-08-01
- Participants : Alex ; Claude
- Nature : session de **cadrage** (recherche + brainstorming + design + plan + 4 passes advisor, **aucun code shippé**)
- Produits : 2 notes `research/` ; design + plan éphémères **conservés** (slice en vol, advisor SHIP) ;
  raffinements Q-0009/Q-0016 ; 4 mémoires ; ce journal.
- Temps engagé : ≈ 1h25 (blocs 11:01 + 11:45) ; span ~5h35 (les 2 deep-research en arrière-plan).

---

## 1. Le choix de la brique, et un recadrage en deux temps

Inventaire du périmètre v1 restant : **curateur/interview** et **interface** jamais traversés ;
paliers B (anti-MAUP) / C (multi-tours) différés depuis brique #5. J'ai proposé 3 pistes ; Alex a
retenu **D — anti-MAUP (H3)**, mais en posant une exigence de fond : *construire solide, sans courir
après le « aha »* (mémoire `build-solid-before-aha`). Il m'a aussi demandé de **contextualiser un
invariant de Henry** — « No hard-coded scenarios : les comportements émergent de la composition de
capabilities atomiques » — qui tombe pile sur nos alarmes récurrentes (surajustement de charte
Q-0004, glissade `std_excess` brique #5). Gravé en discipline (`no-hard-coded-scenarios`).

## 2. Deux deep-research web (multi-agent, adversarial)

Alex a demandé une **review multi-agent** avant de coder. Deux runs (harness deep-research durci
après un premier crash de synthèse — un `.catch` sur les étapes à sortie structurée + reprise avec
`args` : leçon d'outillage, pas de projet) :

- **Croisement de données → aha** (`research/2026-08-01-croisement-donnees-garde-fous-spatiaux.md`,
  24 claims vérifiés) : le « aha » naît du **croisement** (signature composite Halifax, inversion
  crime-type Bogotá, accidents×activité), la non-transférabilité Halifax/Vancouver **valide
  empiriquement no-hard-coded-scenarios**, et les garde-fous imposés (null vs hasard, autocorrélation,
  MAUP, ecological fallacy, exposition) sont ce qu'un outil honnête doit outiller **ou refuser**.
- **H3 anti-MAUP + réseau** (`research/2026-08-01-h3-agregation-anti-maup-reseau.md`, 21 claims) :
  la robustesse multi-résolution est **nécessaire** ; H3 **ne supprime pas** le MAUP (non-emboîtement
  ~14 %, cellules non équi-aires, 12 pentagones) ; Gi\*/FDR outillés (`esda`, `pygeoda`) ; et surtout
  un **verdict critique** — pour un phénomène **contraint au réseau** (accidents), le binning planaire
  H3 est **biaisé** (Xie & Yan 2008, NKDE plus approprié).

## 3. Le verdict planaire a redressé la brique — deux fois

D'abord j'ai été franc : **D = fiabilité, pas richesse**. Puis Alex a vu juste que *H3 à null-aire
serait analytiquement mince* (« les accidents sont là où il y a des routes » = trivial) et a demandé
si l'on ne manquait pas d'une **vraie exposition / d'un rattachement au réseau**. Il **convergeait
tout seul vers la conclusion de la recherche**. Décision : recadrer D en **voie B** — H3
multi-résolution **normalisé par la population réelle** (STATPOP hectare), pas l'aire. La concentration
devient signifiante (les corridors de transit ressortent), tout en restant un **garde-fou de
robustesse**, avec le caveat **population≠trafic** assumé — et c'est notre **première vraie jointure
spatiale**.

## 4. Trois redressements d'Alex qui ont façonné le schéma

- **Cellules 0-population** : au lieu d'un lissage arbitraire, **exclure + reporter à part** (Q-0016 :
  pas d'excès fabriqué ; ça *surface* le transit au lieu de le masquer).
- **Unité jamais dans le nom du champ** : `cell_size_m` → `cell_size`, l'unité **découle du SR**.
- **STATPOP = dataset à part entière** : sa fiche **auto-descriptive**, l'exposition la **référence**
  (`fiche: statpop_population`), jamais recopiée. D'où une **règle projet** neuve, gravée
  (`consumed-data-needs-curated-fiche`) : *toute donnée consommée (même en exposition) a sa propre
  fiche curée ; fait sur un dataset → sa fiche, interprétation d'un lien → le lien.* Candidate de
  promotion `standards/`.

## 5. Plan TDD porté à SHIP en 4 passes advisor

Plan 9 tâches (Q-0016 en premier, autonome). **4 passes advisor fraîches** (Alex : « on relance
jusqu'au ship ») :
- #1 → 2 MUSTs : signature `h3_exposure` incohérente (4 vs 5 args) ; artefact de test. **Confirme
  empiriquement** l'ordre d'axe `ST_Transform` (`always_xy` → ST_X=lng/ST_Y=lat) et l'API h3-py v4.
- #2 → 2 MUSTs : import `Path` mort (ruff) ; `exposures:` en double dans Task 8 (écraserait `canton`).
  Golden vérifié analytiquement (pic=E, pseudo_p≈0.001, sum expo=5020, unpopulated=10).
- #3 → 1 MUST : `Path` en forward-ref exige l'import **au scope module** (pyright standard). + SHOULD
  data-agnostic : clé `n_accidents` → `n_points` (terme métier proscrit dans un module agnostique).
- #4 → **SHIP** (0 MUST).
Leçon confirmée : les 4 passes n'ont trouvé que des défauts **mécaniques** — jamais un défaut de
conception. L'advisor *actif* (qui exécute DuckDB/vérifie l'API) vaut son coût (écho brique #4/#5).

## 6. État en vol + reprise

Aucune ligne de code écrite. Design + plan **conservés** (gitignorés, slice en vol) :
`docs/superpowers/specs/2026-08-01-brique-6-robustesse-echelle-h3-design.md` et
`docs/superpowers/plans/2026-08-01-brique-6-robustesse-echelle-h3.md`. **Décision** : exécution en
**session fraîche subagent-driven**. **Pré-requis humain** : télécharger STATPOP hectare (OPEN-BY-ASK,
dataset opendata.swiss `bevolkerungsstatistik-einwohner`) sous `data/raw/` + épingler l'URL et le nom
`BxxBTOT` (Task 8). T1→T7 + tests tournent sans le réel (fixtures synthétiques).

## 7. Leçons

- **Recadrer par la recherche, pas par principe** : c'est la deep-research (verdict planaire) qui a
  transformé un H3 mince en une brique honnête et valable — et validé l'intuition d'Alex sur le réseau.
- **Écouter l'objection méthodo de l'humain** a redressé le schéma 3× (0-pop, unité/SR, fiche
  référencée) — le jugement reste en amont.
- **Advisor jusqu'au SHIP** : 4 passes pour ne laisser passer aucun gate-breaker mécanique dans un
  plan auto-contenu que l'exécuteur suivra à la lettre.
- **Discipline de contrôle** : ne jamais enchaîner le session-end sans demande explicite d'Alex
  (mémoire `session-end-only-on-explicit-request`).

## 8. Pointeurs

- Recherche : `research/2026-08-01-croisement-donnees-garde-fous-spatiaux.md` ;
  `research/2026-08-01-h3-agregation-anti-maup-reseau.md`
- Design/plan (éphémères, en vol) : `docs/superpowers/specs/2026-08-01-brique-6-robustesse-echelle-h3-design.md` ;
  `docs/superpowers/plans/2026-08-01-brique-6-robustesse-echelle-h3.md`
- OPEN-QUESTIONS : Q-0009, Q-0016 raffinées
- Amont : `journal/2026-08-01-brique5-notebook-implementation.md` ; overview §7/§12
- Impl : `<IMPL:src>` — brique #6 à exécuter (branche `feat/brique-6-robustesse-echelle` à créer, base v0.6.0)
