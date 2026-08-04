# Journal — Brique #7c : le curateur conversationnel, et le gate humain qui sépare le fond de la forme

- Date : 2026-08-03 → 2026-08-04
- Participants : Alex ; Claude
- Nature : cycle complet **brainstorming → design → plan → 2 passes advisor →
  exécution subagent-driven (5 tâches + 1 refactor) → gate humain → ship**.
  Release **v0.10.0** (merge `f834e3c`, release `4f9088a`, tag poussé).
- Temps engagé ≈ 3h+ (03-04/08) ; span git #7c ≈ 9h (gonflé par advisors en
  arrière-plan + nuit).

---

## 1. Cadrage : cinq décisions qui tiennent le walking-skeleton

Reprise de #7c en brainstorming frais (comme prévu au pointeur #7ab §5). Cinq
tranches, toutes dans le sens anti-cathédrale : (1) **en-process** (un seul
`Scribe` vit la conversation → la couche B2 cycle-ouvert se *dissout*, différée
avec la résilience crash) ; (2) **surface REPL** ; (3) charte maïeutique sobre ;
(4) bloc **`columns` seul**, `exposures` = **découverte** (précision d'Alex : les
exposures émergent à la découverte, pas à la curation — premier cas concret du
mode découverte §4.3) ; (5) **`fiche_draft` LLM-owned**, Python transporteur
opaque — c'est ce choix qui rend la **fiche extensible par simple append pour
toujours** (question d'Alex sur le schéma figé : « ce n'est pas de la branlette »
— non, ça touche l'agnosticité, invariant projet). Deux découvertes de code ont
aussi *simplifié* : `profile_raw` (#7b) est auto-porté → **aucun refactor MCP**
nécessaire.

## 2. Exécution : discipline tenue, deux passes advisor utiles

5 tâches TDD subagent-driven, checkpoint plain-language après chacune (attente du
« continue »), commit **après** revue de tâche sur diff stagé. Modèles calibrés
(haiku pour la transcription pure, sonnet pour l'intégration, opus pour la revue
finale). **Advisor** : passe 1 a rattrapé un vrai défaut — le transcript
re-injecté ne portait pas les tool_results (curateur amnésique) → re-fetch
`profile_raw` assumé (design aligné) ; passe 2 a trouvé des gate-breakers pyright
(`reportOptionalCall`) que la lecture ratait. **Revue finale opus : Ready to
merge**, avec une vérification que je n'avais pas explicitée — la garde
anti-path-traversal du nom de fiche LLM-owned (`../../etc/passwd` → `passwd`).

Deux inflexions d'Alex en cours de route, toutes deux justes : **génériciser le
`999`** de la charte (agnosticité + validité de la démo — ne pas pré-orienter
l'agent vers l'anomalie qu'il doit trouver seul) ; et **regrouper le package**
(`curator/{profile,charter,surface,turn,fiche_writer}`, préfixe supprimé) — le
mélange plat/packagé était bâtard ; l'analyste suivra en session future.

## 3. Le gate humain : le fond spectaculaire, la forme robotique

C'est ici que la démo a fait ce que les tests ne font pas. Sur l'OFROU **brut**
(267 761 lignes, 36 colonnes jamais fichées), le curateur a trouvé, **seul**, une
curation de niveau expert : EPSG:2056 déduit des plages de coordonnées, périmètre
« corporel uniquement » (donc aucun taux ici n'est un taux tous accidents),
`at0`/`at00` distincts avec le piège `LIKE 'at0%'` **irréversible**, booléen
piéton sur-ensemble d'`at8` (écart de 720 « trop régulier pour être du hasard »),
périmètres vélo/moto larges (e-bikes ⇒ une hausse ≠ dégradation), sentinelle
horaire possible. **Et surtout** : au point 4, il a **révélé un piège qu'Alex
n'avait pas identifié** — le millésime des codes communaux et sa signature de
fusion. La maïeutique *réalisée* (Q-0020), pas sur le papier.

**Mais** ce niveau ne s'active pas *par défaut* : la première série de questions
était robotique, télégraphique, batchée — Alex ne comprenait pas quoi répondre.
Le déclic est venu d'**une précision live** d'Alex (« pose-moi les questions une à
la fois, moins succinct, langage naturel, avec des exemples ») → bascule
immédiate vers l'excellence. J'ai d'abord cru à un plafond du modèle ; Alex a
corrigé en montrant que c'est un défaut de **charte par défaut**, pas de capacité.

## 4. La décision : ne pas sur-polir au gate, faire une slice dédiée

J'ai tenté deux fois de rapprocher le défaut du niveau live par tweak de charte.
Le premier (retiré avant merge) était insuffisant ; le second (patch v0.10.1,
formulé sur la recette prouvée d'Alex) était *mieux mais moins bien que le vécu
live*. Décision d'Alex, anti-cathédrale : **merger le skeleton prouvé** (charte
revue, `be18053`), et traiter la naturalité comme une **slice dédiée** — d'autant
qu'on tient maintenant du **matériel réel** (le transcript gold-standard + la
fiche produite) pour fine-tuner sur exemples plutôt que deviner. Les deux tweaks
de charte non aboutis n'ont **pas** été shippés (restauration de la charte revue
avant merge — on ne merge pas une UX non validée / non revue).

## 5. Leçons

- **La démo est le gate qui sépare le fond de la forme.** Tests verts + revue opus
  = mécanisme et non-régression prouvés ; seule la démo humaine a montré que la
  *valeur cœur* (curation experte) était là **et** que l'*ergonomie* ne l'était
  pas par défaut. Leçon brique #2 re-confirmée.
- **Distinguer plafond-de-modèle et défaut-de-charte.** Mon diagnostic « robotique
  = limite du modèle » était faux : une précision live a suffi. Écouter l'humain
  qui *voit* le système marcher autrement.
- **Ne pas sur-polir au gate.** Une UX subjective se *conçoit* (slice, sur
  exemples), elle ne se *tune* pas en réaction au merge. Capturer le matériel,
  différer proprement.
- **Le walking-skeleton a délivré sa valeur cœur** (2ᵉ profil, Q-0021 exercée par
  deux profils réels ; curation honnête qui révèle des pièges) — imparfait et
  montré vaut mieux que parfait et jamais fini.

## 6. Pointeurs

- Recap : `slices/2026-08-04-01-brique-7c-curateur-conversationnel-execution.md`
- Matériel slice : `research/2026-08-04-curateur-gate-humain-materiel.md` +
  `research/RoadTrafficAccidentLocations.fiche.example.yaml`
- ADR : `decisions/0009-architecture-execution-agents.md` (Proposed — mûr pour
  Accepted, cf. Q-0017)
- Amont : `journal/2026-08-02-brique7ab-socle-et-profil-brut.md` (§5 pointeur #7c) ;
  `journal/2026-08-02-contrat-interrogation-mission.md` (Q-0020 maïeutique)
- Livraison : `<IMPL:src>` merge `f834e3c`, release `4f9088a`, tag `v0.10.0`
- OPEN-QUESTIONS : **Q-0022** (ajout) ; Q-0021 / Q-0004 / Q-0016 / Q-0015 /
  Q-0019 / Q-0017 / Q-0013 (raffinées)
