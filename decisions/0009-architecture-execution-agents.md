# ADR-0009 — Architecture d'exécution des agents : orchestrateur générique, historique application-owned, MCP multi-dataset

- **Status:** Proposed
- **Date:** 2026-08-02
- **Decision-makers:** Alexandre Pillonel, Claude (co-conception)

## Context

L'architecture d'exécution actuelle est **mono-agent** : `run_analysis`
(`agent/runner.py`) pilote *un* analyste via `claude_agent_sdk.query()` en
**one-shot** (question → verdict), et le serveur MCP (`mcp_server/server.py`)
est **bootstrapé autour d'UNE fiche** (`INTREEPID_FICHE` au démarrage). Le
greffier (`scribe/`) capture le flux et **scelle** la session en un seul
context manager. Cette forme convenait à l'analyste seul.

L'ajout du **curateur** (2ᵉ agent, brique #7 — curation conversationnelle
d'ingestion) casse trois uniformités que la forme mono-agent masquait :

1. **Accès à la donnée.** Le curateur opère sur un dataset **non encore
   fiché** ; le MCP mono-fiche et `profile_stats` (qui *lit* la fiche pour son
   allowlist et ses types) ne s'y appliquent pas. → deux chemins d'accès
   possibles à la donnée.
2. **Orchestration.** Le curateur a une boucle **conversationnelle
   multi-tours human-in-the-loop**, radicalement différente du one-shot de
   l'analyste. → duplication de driver, ou orchestrateur générique.
3. **Gestion de l'historique.** Une conversation async (le processus peut
   mourir entre deux tours humains) exige de décider *qui possède
   l'historique* : le SDK (session/resume) ou nous (trace append-only rejouée).

Ces choix sont **au cœur du système** et durables → ils méritent un ADR, pas
un choix enfoui dans un plan. Deux veilles ont informé la décision : une revue
du corpus interne (`research/`, journaux) et une deep-research web ciblée
(durable execution, checkpointing, HITL async ; 24 claims vérifiés
adversarialement 3-0, cf. References).

Invariants encadrants : P2/P3 (accès read-only par agrégats via MCP,
jamais de lignes brutes), P4 (rejouabilité), P9 (les agents apprennent par
leur contexte), append-only immuable, reprise **par référence** jamais par
réécriture (sémantique git, ADR de trace brique #4), anti-cathédrale.

## Decision

**1. Un orchestrateur générique + un « profil de rôle » par agent.** Le code
de la boucle est unique et agnostique au rôle ; chaque agent est un **profil**
= (charte / system-prompt + allowlist d'outils MCP + contrat de sortie +
critère de terminaison). L'analyste devient un **profil one-shot** (terminaison
= verdict émis, pas de reprise humaine) de cette boucle ; le curateur un
**profil multi-tours human-in-the-loop** (terminaison = validation humaine).
L'analyse *conversationnelle* multi-tours partage le profil-boucle du curateur
mais reste **différée** côté déclenchement (Q-0002). Au lancement, le profil
est choisi explicitement (dispatch explicite maintenant, auto-identification
plus tard). Ceci matérialise Q-0021 (« la charte est la config du rôle ; un
agent est un profil, pas qu'un `.md` »).

**2. L'historique de conversation est « application-owned », rejoué en
record-then-substitute.** La source de vérité de l'historique est **notre trace
append-only** (le greffier, tables `sessions`+`nodes`) — la couche applicative
fait autorité —, **pas** l'état de session du SDK. À chaque tour on reconstruit le fil depuis le greffier et on le
**ré-injecte** au LLM (via `prompt` = séquence de messages) ; à la reprise on
**rejoue les sorties LLM enregistrées** — on ne re-appelle **jamais** le LLM
pour un tour passé. Le « resume » opaque du SDK est **écarté** : même les
frameworks matures (LangGraph) ré-exécutent les nœuds au replay, et le SDK ne
rend pas l'historique d'une session reprise (issue #109) → un mode SDK-owned
créerait un **double store** (CLI opaque + le nôtre) divergeable. Le coût du
rejeu (re-traitement du préfixe) est atténué ~90 % par le **prompt caching**,
conditionné à un **préfixe byte-stable** (charte + profil en tête, transcript
volatile en fin).

**3. Le serveur MCP devient multi-dataset (A1).** L'accès à la donnée reste
**exclusivement** via MCP (P2/P3, porte unique) — **pas** de porte latérale
en-process pour le curateur. Le MCP expose de quoi **profiler un dataset sans
fiche préalable** (profil brut + inférence de type, cas d'ingestion), en plus
de servir des datasets déjà fichés. La clé sémantique reste **le nom de la
colonne de jointure** du dataset (convention brique #6).

**4. Garde-fous minimaux empruntés à la durable execution (sans en adopter la
lourdeur).** Un moteur durable (Temporal/Restate/LangGraph+checkpointer) serait
de la sur-ingénierie pour un système **read-only sans mutation externe** (nos
seules « écritures » : un journal append-only et une fiche validée). On emprunte
seulement :
   a. **append idempotent par `id`** dans le store (survivre à un crash mi-tour
      + reprise sans doublon) ;
   b. **validation humaine = nœud durable** portant le **hash de la fiche
      validée** (pas une réponse « chat » transitoire), idempotent
      anti-double-clic ;
   c. **appel LLM isolé comme étape enregistrée** — la boucle d'orchestration
      reste déterministe ; le non-déterminisme LLM est journalisé, jamais
      re-calculé (neutralise le version-drift des tours passés) ;
   d. **reprise par référence** (`wasInformedBy`), jamais réécriture ; session
      non terminée gérée par statut (`open`/`aborted`), pas de timeout strict
      (async-fichier : aucun compute ne tourne pendant l'attente).

En cohérence, le **modèle de nœud** de la trace est raffiné (contrat de trace,
Q-0004/Q-0003) : grain **Action sémantique** (l'outil replié dessous),
**attribution par acteur** (humain / agent / prompt — aussi l'item v1 #7), et
**indexation par artefact** (le champ de fiche / la requête touchés).

## Consequences

### Positive

- **Une seule boucle pour N agents** : l'analyste et le curateur (et, plus
  tard, critique/candide/facilitateur) partagent l'orchestrateur ; on ne
  duplique pas de driver. Réponse concrète à Q-0021.
- **Historique droit et rejouable** (P4) : une seule source de vérité
  (greffier), pas de dépendance à un état CLI opaque ni au `cwd`, cohérent
  append-only / git-semantics ; le mode SDK-opaque et sa double-source sont
  évités.
- **Accès donnée uniforme** (P2/P3) : le MCP reste la porte unique ; pas de
  fracture d'invariant au 2ᵉ agent (dette qui aurait grossi avec chaque rôle).
- **Léger par choix** : verdict de recherche — pour du read-only, le
  rejeu-depuis-store-maison suffit ; on emprunte 4 garde-fous ciblés, pas un
  moteur.

### Negative / costs accepted

- **Refonte de l'existant** : `run_analysis` (one-shot) et le cycle de vie du
  `Scribe` (crée+scelle en un run) sont **restructurés** vers la boucle
  générique + un store à cycle ouvert (open/append/seal). Non purement additif.
- **Coût de rejeu** : ré-injecter le transcript à chaque tour a un coût en
  tokens croissant (quadratique par session), accepté car atténué ~90 % par le
  prompt caching et borné (une curation n'est pas 1000 tours).
- **Généralisation du MCP** : le serveur n'est plus bootstrapé autour d'une
  fiche unique ; surface accrue (multi-dataset, profil sans fiche) à durcir
  (untrusted_data, isolation P3 — Q-0019).
- **Spec avant impl** : cet ADR spécifie une architecture d'exécution ; le
  walking skeleton reste la **brique curateur** qui l'exerce *minimalement*
  (2 profils, pas un framework pour 6 agents). Red flag anti-cathédrale à
  tenir : ne pas construire au-delà de ce que curateur + analyste exigent.

## Alternatives considered

- **Moteur de durable execution (Temporal / Restate / LangGraph +
  checkpointer)** — Rejeté : conçu pour l'idempotence d'effets de bord risqués,
  quasi absents d'un système read-only ; couple la reprise à un pinning de
  version + déterminisme de journal (anti-pattern documenté). Sur-ingénierie
  ici (deep-research, verdict Section 5).
- **Historique SDK-owned (`resume` / `ClaudeSDKClient` vivant)** — Rejeté : le
  SDK ne rend pas l'historique d'une session reprise (issue #109) ; on devrait
  capturer *de toute façon* → double store divergeable, couplé au `cwd` et à un
  état CLI opaque. Le « resume » n'est même pas déterministe (re-exécution des
  nœuds).
- **Porte latérale en-process pour le curateur (A2)** — Rejeté : fracture
  l'invariant d'accès unique par MCP (P2/P3) ; dette structurelle qui grossit à
  chaque nouveau rôle. (« bricolage » — décision Alex.)
- **Driver dédié dupliqué par agent** — Rejeté : deux (puis six) boucles
  quasi-identiques à maintenir ; le mécanisme est le même, seul le profil
  diffère.

## Supersedes

None. (Premier ADR formalisant l'architecture d'exécution des agents ; raffine
en cohérence le contrat de trace posé en brique #4 sans le contredire.)

## References

- Design (éphémère) : `docs/superpowers/specs/2026-08-02-brique-7-curateur-ingestion-design.md`
- Veille interne (corpus) : `research/2026-07-30-greffier-provenance.md`,
  `research/2026-07-29-etat-de-l-art-github.md`
- Deep-research (à consigner) : orchestration d'agents sans état — durable
  execution / checkpointing / HITL async (24 claims vérifiés 3-0, 1 réfuté :
  mécanisme du prompt caching = mémoïsation de préfixe KV, pas snapshot d'état).
- Questions ouvertes : **Q-0021** (config/séparation des agents — matérialisée
  ici), Q-0019 (isolation P3 — garde-fou c/durcissement), Q-0004/Q-0003
  (modèle de nœud : Action/artefact/acteur), Q-0002 (verrou de l'analyse
  conversationnelle).
- Vision à porter après acceptation : `<IMPL:src>/docs/architecture/overview.md`
  §3 (couches / agents), §4.2–4.3 (profiling sans fiche, curateur) — nouvelle
  version + changelog.
- ADR liées : brique #4 (contrat de trace `sessions`+`nodes`, sémantique git) ;
  ADR-0005 (anti-pattern Henry/Algiz — spec sans impl).
