# Journal — Brique #7a + #7b : socle orchestrateur générique + profil brut, et l'agnostisation du greffier

- Date : 2026-08-02
- Participants : Alex ; Claude
- Nature : **exécution** subagent-driven de deux sous-briques de #7, chacune shippée + taguée.
  Deux releases : **v0.8.0** (#7a) et **v0.9.0** (#7b). Le cadrage de #7 avait eu lieu en session
  antérieure (ADR-0009 ; cf. `journal/2026-08-02-brique7-cadrage-orchestrateur-generique.md`).
- Temps engagé : ≈ **1h32** (bloc `2026-08-02 14:12`) ; span git ~8h34 (14:22→22:56), gonflé par les
  advisors en arrière-plan (dont un > 5h).

---

## 1. #7a — le socle, et l'objection qui a fait émerger A3

Exécution nominale d'ADR-0009 Phase A : **A1** (orchestrateur générique `run_agent` + `Profile`),
**A2** (analyste = profil, `runner` en wrapper mince). Discipline projet tenue de bout en bout :
implémenteur frais → gate vert → `add` (stage seul) → revue de tâche sur diff **stagé** → commit
après *Approved* → récap plain-language en **checkpoint** (fin de tour, attente du « continue »).

Le moment fort n'était pas au plan : après A2, **Alex a pointé que le greffier n'était pas agnostique
des agents** — `store.record_verdict` / `TraceBuilder.verdict` connaissaient le schéma « observation »
(claim/statut/nature) de l'analyste. J'ai confirmé le couplage (le socle porte un rôle précis, à
rebours de l'orchestrateur qu'on venait de rendre générique) et proposé **A3** en séance :
- primitive générique `record_nodes(specs)` / `TraceBuilder.custom(specs)` — le socle enregistre des
  nœuds `(kind, content, meta)` **sans interpréter le vocabulaire** ;
- la **projection résultat→nœuds** (schéma observation) descend dans `analyst_profile`.
Refactor à **iso-comportement strict** (mêmes nœuds/ids/DB), prouvé par les tests e2e inchangés.
Nommage tranché avec Alex : **`record_nodes`/`custom`** (vs `record_result`/`result`, écarté — trop
étroit pour les kinds de curation à venir : `human_turn`, `fiche_draft`…).

**Leçon** : écouter l'objection de conception de l'humain *au bon moment* (juste avant que B/C/D
n'empilent des kinds de rôle) a évité la fuite d'agnosticité que la brique #7 combat. Le socle de
*capture* (`store`/`trace`) est désormais agnostique ; le couplage résiduel est côté *renderers*
(lecture), délibérément différé.

## 2. #7b — le découpage recoupé par le code

Le plan initial groupait « B (trace) + C (MCP) » en #7b. En **détaillant le code** pour écrire le
plan, un constat : la couche **B est entièrement l'infrastructure du curateur** — `actor` n'a pas de
tour humain à marquer, `open/append/seal` n'a pas d'appelant avant la boucle multi-tours de D. Seul
**C (`profile_raw`)** produit un livrable démontrable en propre. J'ai signalé l'inflation (mandat
anti-cathédrale) ; Alex a tranché **#7b = C seule**, B rejoint D en #7c. C'est *plus* walking-skeleton
que le plan, et ça rejoint le découpage d'origine du design (§4). Même raisonnement que pour A : ne
pas figer le code d'une phase en aval de ce qu'on apprendra en implémentant l'amont.

`profile_raw` réutilise les profileurs de `profile_stats` (DRY) + une **inférence de type** (Q-0015a :
un numérique de faible cardinalité = code déguisé). L'outil MCP ouvre par-appel, avec **garde
anti-traversée**. Plan porté à **SHIP en 2 passes advisor** (lecture seule, hors-repo — la leçon
d'outillage du cadrage a été appliquée : zéro pollution). Passe 1 : 3 MUSTs réels (cast `::INTEGER`
sur `range()`→BIGINT ; `is_file()` ; sanitisation du nom de table) matérialisés inline ; passe 2 :
SHIP (l'advisor a même exécuté `profile_raw` sur la fixture réelle → 7/7 colonnes correctes).

**Démo** validée sur la vraie donnée OFROU **brute** (267 761 lignes, 36 colonnes jamais fichées) :
types candidats sensés, et `AccidentUID` (card = nombre de lignes) illustre parfaitement le rôle du
curateur — l'inférence propose, l'humain corrige.

## 3. Deux redressements de jugement (le jugement reste humain)

- **A3** (agnostisation) n'existerait pas sans l'objection « le scribe connaît l'analyste ».
- **#7b = C seule** n'existerait pas sans la volonté de challenger l'inflation ; j'ai soulevé, Alex a
  tranché. Le questionnement d'Alex (« custom est-il le bon nom ? », « c'est sensé de faire un plan
  #7c maintenant ? ») a chaque fois amélioré la décision.

## 4. Discipline & releases

Deux slices, deux merges `--no-ff`, deux releases avec CHANGELOG + tag user-driven. Un **incident**
mineur au release 0.9.0 : un `git checkout -- uv.lock` mal placé a exclu `uv.lock` du commit de
release (recréant l'incohérence lock/pyproject) — **corrigé** par régénération + `commit --amend`.
La note défensive d'isolation (`tools=[]`) a été restaurée avant merge #7a (recommandation du
reviewer final).

## 5. Reprise #7c — POINTEUR RICHE (à re-cadrer à froid, brainstorming en tête)

> Le design v2 éphémère est supprimé (partiellement obsolète post-A). L'essence **actualisée** vit
> ici + dans **ADR-0009** (architecture, persistant). #7c se **re-cadre en brainstorming frais** —
> c'est le morceau à haute attention humaine (UX conversationnelle + maïeutique).

**Ce qui reste = le curateur conversationnel = couches B + D d'ADR-0009 :**

- **Couche B — trace à cycle ouvert** (`scribe/trace.py` + `store.py`) :
  - **B1** : `TraceNode.actor: str = "agent"` (défaut → non-régression). Persister **dans `meta`**
    (pas de colonne DDL) : `_insert` écrit `{**meta, "actor": actor}` ; `load` fait
    `actor = meta.pop("actor", "agent")`. Le champ fait autorité en mémoire, `meta` = véhicule.
    **Ne PAS câbler de kinds de curation dans le socle** (acquis A3 : le socle reste agnostique) —
    les kinds `human_turn`/`fiche_draft`/`curation_validated` vivent dans le profil curateur, émis
    via `record_nodes`.
  - **B2** : cycle ouvert `open_curation`/`append_nodes`/`seal_curation` (fonctions module-level,
    multi-invocations async). **`append_nodes` idempotent par id** (`INSERT … ON CONFLICT(id) DO
    NOTHING`) = garde-fou ADR-0009 (survivre crash mi-tour + reprise). `open_curation` idempotent
    (re-open d'une session `open` du même rôle ne lève pas ; `closed`/`aborted` → immuable).

- **Couche D — profil curateur** (`agent/curator/*`, `agent/curator_profile.py`, extension de
  `orchestrator.py`/`profile.py`) :
  - **D1** : **extension multi-tours de l'orchestrateur**. `Profile` gagne des champs **optionnels**
    (`is_terminal`, `next_input`, `build_prompt`) → défaut = one-shot = **non-régression A**.
    `run_agent` boucle tant que non-terminal, **rejoue le transcript** depuis le greffier
    (**record-then-substitute** : sorties passées ré-injectées, jamais recalculées ; **préfixe
    byte-stable** charte+profil pour le prompt caching). ⚠️ C'est le vrai morceau de conception.
  - **D2** : charte curateur (maïeutique : fait mesuré / hypothèse proposée / question ouverte ;
    hygiène anti-spoiler Q-0015c ; doc fournie = `untrusted_data`). ⚠️ **Recoupe Q-0020** (contrat
    d'interrogation / maïeutique) — *posture jugée bloquée en amont par Q-0002 (vrai destinataire)*.
    À trancher **en brainstorming** : que construit-on vs que diffère-t-on ? (ne pas câbler un
    scénario — `no-hard-coded-scenarios`).
  - **D3** : `curator_profile.py` — `parse → CuratorTurn(message, fiche_draft, proposes_completion)` ;
    `is_terminal` = clôture proposée **ET** validation humaine ; `next_input` = réponse humaine.
  - **D4** : `curator/surface.py` — transcript en fichier lisible + lecture de la réponse humaine
    (append). Éphémère ; la persistance est le greffier.
  - **D5** : `curator/fiche_writer.py` — `write_fiche` (dump YAML **à la validation seulement**) +
    nœud `curation_validated` portant le **hash** ; validation **idempotente** (anti-double-clic).
  - **D6** : démo + runbook — **gate humain avant merge** (curation réelle conversationnelle).

**Idée d'Alex conservée** (du cadrage) : l'humain peut verser une **doc** décrivant la donnée *avant*
l'interview (3 sources de curation : profiling MCP `profile_raw` + doc + interview réduite au
reliquat). La curation *est* conversationnelle par nature.

**Prérequis d'entrée en #7c** : `profile_raw` (livré #7b) est la brique d'amont — le curateur
l'appelle pour amorcer le profil du dataset non-fiché.

**Ordre pressenti** : brainstorming (surtout D1 multi-tours + D2 maïeutique, les deux incertains) →
design frais → plan → advisor → exec. Découpage possible : B+D1 (l'infra multi-tours) d'abord, puis
D2–D6 (le curateur proprement dit).

## 6. Pointeurs

- Recaps : `slices/2026-08-02-02-brique-7a-orchestrateur-greffier-execution.md` ;
  `slices/2026-08-02-03-brique-7b-profil-brut-execution.md`
- ADR : `decisions/0009-architecture-execution-agents.md` (Proposed — passera `Accepted` à #7
  complète)
- Amont : `journal/2026-08-02-brique7-cadrage-orchestrateur-generique.md` (cadrage + forks) ;
  `journal/2026-08-02-contrat-interrogation-mission.md` (Q-0020 maïeutique)
- Livraison : `<IMPL:src>` `main` — merge `2933ef6` / release `642b80e` / tag `v0.8.0` ;
  merge `fee4df3` / release `e3f632f` / tag `v0.9.0`
- OPEN-QUESTIONS : Q-0021 / Q-0015 / Q-0004 (raffinées)
