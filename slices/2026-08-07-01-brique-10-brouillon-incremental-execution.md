# 2026-08-07-01-brique-10-brouillon-incremental — Execution recap

## Scope

Brique #10 — **le brouillon de fiche quitte l'agent pour l'application**. L'agent curateur
ré-émettait sa fiche entière à chaque tour : **55 604 caractères sur 69 628**, soit 79 % de tout ce
qu'il écrit, ré-injectés en plus dans l'historique du tour suivant. La slice le fait n'émettre que
ses **deltas**, rapatrie les jugements de périmètre métier à la ratification humaine, nomme l'outil
MCP par son identifiant enregistré, et livre l'instrument qui rend le gate mesurable.

**Le gate humain a ÉCHOUÉ** (2 critères sur 5) et le mécanisme s'est révélé **neutre sur le temps**.
La branche a été **mergée sur décision d'Alex, non comme livrable mais comme prérequis** de la
structure en deux appels à venir — sans le mécanisme de delta, la révision finale de cette structure
ré-émettrait la fiche entière.

Shippé dans `<IMPL:src>` : merge `fe091aa`, release **v0.13.0** (`2d46473`) — **tag user-driven en
attente** (I-3), tout comme `v0.12.0`.

## Shipped artifacts

Dans `<IMPL:src>` (v0.13.0) :

- `agent/curator/draft.py` (**NEW**, 60 lignes) — deux fonctions **pures**. `merge_delta` fusionne par
  clé (dernière écriture gagne, `columns` **entrée par entrée** et jamais en bloc) ; `inventory_line`
  rend à l'agent l'inventaire de ce que l'application détient. La valeur d'une colonne reste un objet
  **opaque** jamais inspecté : Python n'en connaît que la clé `columns`, les noms et `dataset`.
  **Propriété de sûreté** : la fusion donne le même résultat que l'agent envoie un delta ou la fiche
  entière — le mécanisme ne peut pas produire une fiche fausse, au pire pas d'économie, et c'est
  visible au gate.
- `agent/curator/turn.py` (MODIF) — `fiche_draft` → **`fiche_delta`**, **sans repli** sur l'ancienne
  clé. La clé JSON est lue par le modèle : elle fait partie du prompt. Un modèle qui ignorerait la
  consigne doit être exposé par le gate, pas rattrapé silencieusement.
- `agent/curator/profile.py` (MODIF) — câblage par les trois hooks du `Profile`, **zéro ligne
  d'orchestrateur** : `next_input` fusionne, `build_prompt` ajoute l'inventaire, `on_result` écrit
  l'**accumulateur**. La garde de validation se déplace du delta vers l'accumulateur (un dernier tour
  sans nouvelle colonne devient le cas **normal**), et les deux gardes portent littéralement la même
  expression. L'inventaire transite **exclusivement** par `build_prompt` : l'orchestrateur grave la
  valeur retournée par `next_input` en nœud `human_turn` / `actor: "human"`, et on y inscrirait des
  mots que l'humain n'a pas dits.
- `agent/curator/charter.md` (MODIF, 138 → 150 lignes) — cinq éditions. Contrat de sortie en delta ;
  phrase sur la mémoire réécrite ; **distinction information / autorité** dans la phrase de seuil (un
  jugement de périmètre n'est jamais tranchable depuis un profil, il se **ratifie**) ; règle de prose
  énoncée en **principe** et non en interdiction assortie d'exceptions ; outil MCP nommé par son
  identifiant enregistré (3 occurrences). Le **gabarit n'est pas touché** (vérifié par hash).
- `demo_curator.py` (MODIF) — 4ᵉ occurrence du nom nu corrigée dans le **prompt initial**, et
  `_attribution` : par tour et en totaux, les caractères de prose contre ceux de brouillon, plus le
  ratio brouillon ÷ fiche. `scribe/metrics.py` **n'est pas touché** — séparer prose et bloc de
  métadonnées est une connaissance du rôle, le socle reste agnostique (acquis de #7a).
- `demo/brique-10-brouillon-incremental.md` (**NEW**) + `demo/README.md` — runbook du gate, critères
  arrêtés **avant** l'implémentation ; quatre statuts périmés du catalogue rattrapés.
- Tests : `test_curator_draft.py` (NEW, 9), plus `test_curator_profile.py` (+5, dont le discriminant),
  `test_curator_charter.py` (+4, −1), `test_curator_turn.py` (+1), `test_demo_curator.py` (+3).
  **188 déterministes verts**, pyright 0.

## Deviations from plan (if any)

- **4 passes d'advisor pour atteindre SHIP**, dont la 4ᵉ a **simulé les cinq tâches dans le repo**
  puis restauré, mesurant chaque décompte au lieu de le calculer.
- **Le plan contenait sa propre commande de gate fausse** : `pytest -q` au lieu de
  `pytest -q -m "not agent"`, ce qui aurait lancé trois tests réseau consommant du quota. Trouvé en
  mesurant la base plutôt qu'en recopiant le recap précédent (166 annoncé, **165** réel).
- **Onze docstrings du plan violaient `D205`/`D209`** — vérifié en exécutant `ruff` sur une sonde, pas
  en raisonnant. Le gate serait tombé rouge dès la tâche 1.
- **Trois tests existants devenaient faux** avec le câblage, dont deux non prévus. Traités au Step 1
  de la tâche, pas découverts au Step 4.
- **Un commentaire que j'avais écrit était factuellement faux** (« `nonlocal` serait inutilisable
  depuis `_serialize` »). La passe 3 l'a réfuté **en exécutant du code** : huit lignes de mécanique
  défensive supprimées, remplacées par un `nonlocal` de deux mots.
- **Le pattern « diagnostic juste, correctif faux » s'est reproduit** : passe 1, l'advisor avait
  raison sur la base de tests fausse et tort sur la correction (il proposait la commande qui lance
  les tests réseau). Vérifié avant application.
- **La revue finale a trouvé deux bloquants qu'aucun test ne pouvait attraper** — voir Validation.
- **Convention de commit arbitrée en cours de session** : les messages dérivaient vers 20 lignes,
  j'écrivais l'execution recap dans le commit. Règle retenue : proportionné à ce qui a été fait, mais
  **dense** ; le récit va au journal, les mesures au recap.

## Validation

- **Gate déterministe** : `ruff format --check` / `ruff check` / `pyright` (standard) /
  `pytest -q -m "not agent"` — verts par tâche (diff **stagé**, commit après revue) et **rejoués par
  le contrôleur** à chaque fois, pas seulement rapportés. **188 tests**, pyright 0.
- **Revues** : 6 revues de tâche + 1 revue finale + 1 re-revue. **Trois revues sur six ont trouvé un
  vrai défaut**, dont deux invisibles aux tests.
- **Deux bloquants de revue finale, arbitrés par Alex** :
  1. **La garde de prose supprimait une seconde prescription.** « Ne redocumente jamais une colonne
     déjà transmise » n'exemptait que le verrou — or la charte impose aussi, au tour de validation, de
     **résumer les pièges les plus coûteux**, qui portent sur des colonnes transmises. Un modèle
     obéissant aurait supprimé la **dernière protection avant que l'humain valide 36 colonnes**.
     Corrigé en énonçant la **règle** plutôt qu'en ajoutant une seconde exception.
  2. **Un critère de gate était arithmétiquement impossible.** « Part du delta ≤ 50 % » exige
     `delta ≤ prose` ; si le mécanisme fonctionne, delta ≈ 17-22 k face à une prose de base de 14 k.
     **L'illustration du runbook le démontrait six lignes plus haut** et quatre passes d'advisor ne
     l'avaient pas vu. Descendu en « observé, non exigé ».
- **La re-revue a fait tourner l'instrument sur la trace réelle du 06/08** et découvert que le
  comptage manuel de la base était faux de 60 caractères — douze par tour, les délimiteurs de fence,
  rangés du côté prose. **Toutes les bases sont passées aux valeurs mesurées par l'instrument**, ce
  qui fait que le gate compare enfin la même échelle des deux côtés.
- **Discriminance prouvée par mutation** : j'ai injecté le mauvais dénominateur dans `_attribution`
  → 1 failed ; restauré → 5 passed. Idem pour le test de canal `human_turn`, où chaque mutation tue
  exactement un des trois chemins.

## Gate humain — ÉCHOUÉ (2 critères sur 5)

Séance réelle sur l'OFROU brut, 4 questions, 5 tours, fiche validée (`ca40080edb96`).

| # | Critère | Mesuré | Base | |
|---|---|---|---|---|
| 1 | delta ÷ fiche écrite ≤ 1,5 | **1,2** | 3,3 | ✅ |
| 2 | aucun tour > 3 355 car. de prose | 2614 · 2636 · 2860 · **3388** · **3479** | max 3 355 | ❌ |
| 3 | premier tour aux cinq éléments, zéro consigne de style | tous présents | acquis | ✅ |
| 4 | fiche complète (36 colonnes), validée | 36/36 | acquis | ✅ |
| 5 | zéro appel `ToolSearch` | **× 4** | 4 | ❌ |

**Le critère 1 est flatté par son dénominateur** : la fiche a grossi de 72 %. À taille constante le
ratio vaut **2,1**, pas 1,2. Le seul chiffre honnête est le brouillon émis, **−36 %**.

## Mesures — la vraie sortie de la slice

```
2,0652 $ · 961,2 s bout en bout · 5 tours · dont API 462,7 s · hors API 3,4 s
prose 14 977 car. · brouillon 35 837 car. (71 %) · thinking 13 638 car.
```

| | 06/08 matin | 06/08 soir | |
|---|---|---|---|
| coût | 1,8033 $ | 2,0652 $ | **+14,5 %** |
| sortie écrite | 69 628 car. | 50 814 car. | −27 % |
| dont brouillon | 55 604 car. | 35 837 car. | **−36 %** |
| tokens de sortie | 37 709 | 33 410 | −11 % |
| **temps de génération** | **460,6 s** | **462,7 s** | **+2 s** |

**Le modèle de temps, construit sur les deux traces**, explique tout à la seconde près :

| ce que l'agent écrit | matin | soir | |
|---|---|---|---|
| la fiche | 322 s · 70 % | 257 s · 56 % | −65 s |
| la prose | 81 s · 18 % | 107 s · 23 % | +26 s |
| le raisonnement | 57 s · 12 % | 98 s · 21 % | +41 s |
| **total** | **460 s** | **462 s** | **+2 s** |

Les 65 s économisées sur la fiche ont été **intégralement reprises**. `temps ≈ tokens générés ÷ 72` ;
le hors-API pèse **3,4 s sur 961** — le cache et l'entrée sont des sujets de **coût**, jamais de temps.

## Follow-ups

- **Deux régressions à réparer dans la slice suivante**, inscrites au CHANGELOG : la fiche a perdu ses
  **clés racine de connaissance transversale** (12 en `0.10.0` → 3 ici ; d'où une colonne fantôme pour
  loger une note transversale), et la charte porte un **plafond déguisé** (« quelques questions
  structurantes suffisent ») qui contredit le principe posé au design.
- **Plan de reprise complet** : `research/2026-08-06-brique10-gate-materiel.md` § 8 — structure en
  deux appels, charte ramenée au transcript de référence, fiche dense + schéma, `thinking=False`.
- **`thinking=False`** : 98 s, 21 % du temps, une ligne, jamais éprouvé.
- Mineurs différés : `draft.py` porte une branche **morte** (`or "columns" in out`, inatteignable) ;
  la ligne de total de `_attribution` n'a pas d'unité ; `max(0, …)` inatteignable ;
  `test_crlf_line_endings_parsed` n'assert que `proposes_completion`.

## Temps

- **Engagé** : ≈ **2h31** (instrument), span session ≈ **15h22**, 62 événements.
- **Span git de la slice** : `e72fb25` (06/08 14:09) → `2d46473` (07/08 01:23) ≈ **11h15**.

## Pointers

- Journal : `journal/2026-08-07-le-mecanisme-marche-le-temps-ne-bouge-pas.md`
- Matériel : `research/2026-08-06-brique10-gate-materiel.md` (verdict, mesures, transcript, **§ 8 =
  plan de reprise**) ; `research/2026-08-06-RoadTrafficAccidentLocations.fiche.v3.yaml` (fiche du
  gate, préservée dans le spec — `catalog/` reste réservé aux fiches consommées, précédent #7c)
- Livraison : `<IMPL:src>` merge `fe091aa`, release `2d46473`, `src/CHANGELOG.md [0.13.0]`,
  **tags `v0.12.0` et `v0.13.0` en attente** (I-3)
- OPEN-QUESTIONS : **Q-0025** (ajout), **Q-0023** (résolue) ; Q-0019 / Q-0024 / Q-0013 / Q-0004 /
  Q-0015 (raffinées)
- Amont : `journal/2026-08-06-brique8-correction-et-mesure-arbitrable.md`
