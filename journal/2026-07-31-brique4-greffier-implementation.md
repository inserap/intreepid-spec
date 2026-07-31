# Journal — Brique #4 (le greffier) : implémentation, ship v0.5.0, et deux leçons de process

- Date : 2026-07-31
- Participants : Alex ; Claude
- Nature : session d'**implémentation** (exécution subagent-driven du plan SHIP du cadrage 2026-07-30)
- Produits : brique #4 shippée dans `<IMPL:src>` (merge `c594e64`, release `v0.5.0`) ; execution recap ;
  2 conventions workflow nouvelles dans `CLAUDE.md` ; raffinements Q-0003/Q-0004 ; ce journal.
- Temps engagé : ≈ 0h45 ; span git src 07:55 → 09:53.

---

## 1. Ce qui a été livré

Le **greffier** : la première traversée de la couche mémoire. `run_analysis(…, trace_to=db)`
duplique le flux de l'analyste vers un `Scribe` (context manager DuckDB, écriture incrémentale,
scellement `closed`/`aborted`) et active le **thinking summarized** — le « pourquoi » que la
littérature dit incapturable automatiquement est capté ici parce que l'agent le verbalise déjà.
L'arbre se recharge (`load`) et se lit (`render`) : 💭 raisonnement, 🔧 appels+agrégats,
observations avec statuts — le `[refusé]` est une branche morte *documentée*. Sans `trace_to`,
rien ne change (oracle intact). La démo a montré le tout sur un run réel : verdict exemplaire
(999 découvert seul, BE prouvé/ZH réfuté, refus causal) puis l'arbre rejoué depuis le store.

Exécution disciplinée : 6 tâches (implémenteur frais + revue par tâche + scan de domaine),
revue finale de branche « With fixes » → vague de fixes unique → re-revue **Ready to merge** →
démo (gate humain validé) → merge → release `v0.5.0` en commit final post-merge.

## 2. Leçon n°1 : un récap non remis n'existe pas (→ checkpoint par tâche)

Alex n'a reçu **aucun** des récaps de fin de tâche que je pensais lui donner. Diagnostic : je les
rédigeais **entre deux appels d'outils**, au milieu de longs tours autonomes — or seul le message
*final* d'un tour est remis de façon fiable. Ce n'était pas un problème de subagents (leurs
reports sur disque contenaient bien leur section « Récap par fichier ») mais de **mécanique de
livraison**. Correction gravée en convention `CLAUDE.md` (choix explicite d'Alex parmi 3 options) :
le récap plain-language fichier-par-fichier est un **checkpoint turn-final** — je termine le tour
après chaque tâche, la suivante n'est dispatchée qu'après son « continue ». Compréhension et
possibilité de correction au fil de l'eau, au prix d'un « continue » par tâche.

## 3. Leçon n°2 : le commit est la DERNIÈRE étape d'une tâche

Deuxième correction d'Alex : le flux du skill (l'implémenteur committe, la revue vient après)
inversait la validation. Nouvel ordre gravé : implémentation TDD → gate qualité → `git add`
(stage seul) → revue sur le diff stagé → fixes/re-revue → **commit après Approved seulement**.
Aucun commit, même trivial (un reliquat de reformatage ruff a déclenché la leçon), sans gate et
revue préalables. Appliqué dès la tâche 3 ; le contrôleur committe avec le message du plan.

## 4. La revue finale a payé : l'invariant-titre n'était pas testé

Les revues par tâche étaient toutes vertes, et pourtant la revue de branche a trouvé le trou
que personne ne pouvait voir à l'échelle d'une tâche : la **non-intrusion** (« une panne du
greffier n'interrompt jamais l'analyste »), garantie centrale du design, n'avait **aucun test**
qui la traverse de bout en bout. Trois tests ajoutés (panne de capture → verdict quand même ;
échec d'ouverture → capture désactivée ; exception analyste → propagée ET session `aborted`
avec nœuds pré-crash). Aussi : garde `__enter__` contre la fuite de connexion — la classe de
bug Windows déjà rencontrée en brique #2 (`bounds.py`), que le code du plan répétait. Plusieurs
findings venaient d'ailleurs **du plan lui-même** (erratum : connexions non fermées, import
local, docstring `opus` perdue) — le plan est un point de départ, pas une évidence de qualité.

## 5. Session ≠ analyse (Q&A du gate, gravé en Q-0004)

Question d'Alex : si une session scellée est immuable, comment reprendre une analyse qui dure
des semaines ? Réponse clarifiée et consignée : la **session est l'épisode de capture**
(un run, minutes) ; l'**analyse est le fil** qui traverse plusieurs sessions. On reprend une
analyse **par référence** (`wasInformedBy`, vocabulaire PROV-DM allégé du cadrage), jamais en
réécrivant l'histoire — sémantique git : on branche sur un commit, on ne l'édite pas. Les nœuds
sont immuables ; la seule transition d'une session est son scellement. Le raccrochage
inter-sessions est l'étage suivant (Q-0004), démontrable sur une vraie session multi-tours (Q-0002).

## 6. Leçons

- **Un récap écrit mais non remis n'existe pas** : la valeur d'une explication se mesure à sa
  réception ; le checkpoint turn-final est la seule livraison fiable en exécution autonome.
- **Commit après revue, toujours** — y compris pour un reliquat « trivial ».
- **La revue de branche voit ce que les revues de tâche ne peuvent pas voir** (invariants
  transverses non testés) ; la dispatcher sur le modèle le plus capable vaut son coût.
- **Vérifier un rapport de fix suspect avant de faire confiance** (compteur d'outils incohérent
  → contrôle direct de l'état git ; cette fois le travail était réel, contrairement au fix
  déraillé de brique #3 — mais le réflexe reste le bon).
- Les **erreurs du plan se propagent en aval** (3 findings plan-mandatés) : le TDD-transcription
  reproduit fidèlement, y compris les défauts — la revue doit juger le code, pas sa provenance.

## 7. Pointeurs

- Execution recap : `slices/2026-07-31-01-brique4-greffier-capture-execution.md`
- Livraison : `<IMPL:src>` `main` merge `c594e64`, release `db3f36c`, tag `v0.5.0` (user-driven)
- Démo : `<IMPL:src>/demo/brique-4-greffier.md` (sorties réelles)
- Amont : `journal/2026-07-30-brique4-greffier-cadrage.md` ; `research/2026-07-30-greffier-provenance.md`
- OPEN-QUESTIONS : Q-0004, Q-0003 (raffinées)
- Conventions : `CLAUDE.md` § « Project workflow conventions » (commit-dernier ; récap-checkpoint)
