# Veille — Orchestration d'agents LLM sans état partagé entre invocations

- Date : 2026-08-02
- Méthode : deep-research web (harness multi-agent, fan-out → fetch → vérification adversariale 3-votes → synthèse). 20 sources fetchées, 98 claims extraits, **24 confirmés (3-0)**, 1 réfuté. Synthèse finale du harness renvoyée vide (bug) → rapport **reconstruit depuis les transcripts** (source : prompt d'entrée de l'agent de synthèse + review du claim réfuté).
- Cible : décider l'architecture d'exécution des agents d'`intreepid` (orchestrateur générique conversationnel, historique application-owned rejoué, MCP read-only). Alimente **ADR-0009**.

---

## Verdict actionnable (pour intreepid)

> **Pour un système read-only sans mutation externe — notre cas (historique append-only immuable + accès données read-only via MCP) — le rejeu-depuis-store-maison SUFFIT. Un moteur de durable execution (Temporal / Restate / LangGraph+checkpointer) serait de la sur-ingénierie.**

Argument mécanique confirmé : la durable execution existe **surtout pour l'idempotence des effets de bord** (record-once / pull-on-replay, [C16]). Nos seules « écritures » = un journal append-only et une fiche validée. Le risque premier que ces moteurs neutralisent (duplication d'effets non-idempotents) est **largement absent**.

**6 garde-fous à emprunter sans la lourdeur** (repris en ADR-0009 §4) :
1. **Record-then-substitute** : rejouer les sorties LLM enregistrées, jamais re-appeler le LLM pour un tour passé ([C1]/[C16]). Neutralise le version-drift ([C20]) des tours déjà enregistrés.
2. **Journal d'étapes append-only + substitution** ([C16]) ; **append idempotent** par id.
3. **Idempotence des effets pré-interrupt / des signaux d'approbation** ([C8]/[C12], at-least-once → double-clic).
4. **Approbation humaine = événement durable** (avec l'artefact/hash sous revue), pas une réponse chat transitoire ([C21]).
5. **Timeout / repli** sur toute attente humaine ([C13]).
6. **Reprise par référence append-only, jamais réécriture** ([C7], modèle LangGraph `update_state` : branche, n'écrase pas).

Quand un moteur durable **se justifierait** (pas ici) : effets de bord risqués non-idempotents, attentes de jours avec libération de compute serverless ([C17] Restate), boucles longues à durabilité par-itération ([C11]). Mais leur reprise **couple recovery à un pinning de version + déterminisme du journal** ([C17]/[C20]) — coût, pas bénéfice, pour notre cas.

---

## Section 1 — Durable execution (idempotence, reprise, non-déterminisme LLM)

- **[C0]** Ligne de démarcation Temporal : **LLM/tool dans les Activities, orchestration déterministe dans le Workflow** — permet une décision LLM sans casser le replay. *(temporal.io, primaire.)*
- **[C1]** Reprise par **replay contre l'Event History**, pas ré-exécution (décisions passées rejouées depuis l'historique). *(docs.temporal.io.)*
- **[C10]** Appeler un LLM **dans le code workflow** (pas une activity) casse le replay déterministe — LLM non-déterministe **même à température 0** (non-associativité flottante). Anti-pattern #1. *(xgrid.co + docs.)*
- **[C11]** Envelopper **toute la boucle d'agent dans une seule activity** détruit la durabilité granulaire (échec à l'itération 47/60 → redémarre à 1). *(xgrid.co.)*
- **[C14]** Un mismatch au replay déclenche une **erreur bloquante mais retryable** (Workflow Task Failure, retry ~10 s) — **pas** un hard/terminal failure. *(resonatehq.io — correction de sévérité imposée par le vérificateur.)*
- **[C16]** L'**idempotence à travers les crashes** = enregistrer les résultats d'étapes + tirer la valeur stockée au replay au lieu de ré-exécuter. *Définition-manuel de la durable execution.* *(resonatehq.io + primaires convergents.)*
- **[C19]** Les opérations non-déterministes (LLM, shell, API, écritures, aléa, wall-clock) = **frontières externes**, jamais dans la logique déterministe. « Not a LangGraph problem; a general replay problem. » *(zylos.ai.)*
- **[C20]** Le replay ré-exécutif est **fragile** (dépend de version modèle/prompt/tool/index/mémoire…) — mais **neutralisé en modèle record-then-substitute** (sortie substituée verbatim). « Versioning is part of replay correctness. »

## Section 2 — Checkpointing / persistance (replay vs resume, coût)

- **[C2]/[C3]** LangGraph checkpointers persistent l'état du graphe **par `thread_id`** (framework-owned) — contraste exact avec l'historique **application-owned** ; le Store applicatif est un système séparé. *(docs.langchain.com, primaire.)*
- **[C4]** `MemorySaver` **perd tout au restart** → reprise durable exige un backend persistant.
- **[C5]** Le **time-travel LangGraph RÉ-EXÉCUTE les nœuds** (ne lit pas un cache) — LLM/interrupts se re-déclenchent, peuvent diverger. **« resume » n'est PAS déterministe/opaque.** *(primaire + issue mainteneur #6208 : double-création de tickets.)*
- **[C7]** `update_state` **ne réécrit pas l'historique** : crée un nouveau checkpoint qui **branche** ; l'historique original reste intact — **append-only, branch-by-reference** (aligné invariant git d'intreepid).
- **[C22]** Sans prompt caching, coût en tokens **quadratique par session** (re-traiter tout le préfixe) — **le modèle de coût exact du rejeu application-owned**.
- **[C23]** Le prompt caching réduit ~**90 %** (Anthropic cache reads 0,1× input ; OpenAI 90 % sur modèles récents ; Google implicite ~75 %) → mitige le rejeu.

### Claim RÉFUTÉ (0-3) — mécanisme du prompt caching
« Le prompt caching stocke un *snapshot de l'état du modèle* et le *reprend* » → **faux**. Doc primaire Anthropic : pas de snapshot d'état, mais **mémoïsation du prefill (KV-cache) sur un préfixe de tokens EXACT**. Conséquence pratique : le cache exige un **préfixe byte-stable** (charte + profil en tête) — pas un état repris. *(métaphore marketing du blog vendeur, contredite par la doc primaire.)*

## Section 3 — Human-in-the-loop asynchrone

- **[C8]** Reprendre après `interrupt()` LangGraph **relance le nœud entier depuis le début** → effets pré-interrupt doivent être **idempotents**.
- **[C9]** Les interrupts exigent **checkpointer durable + `thread_id`** ; **pas** de détection auto d'échec ni de coordination anti-duplication intégrée (Diagrid : « Checkpoints Are Not Durable Execution »).
- **[C12]** Signaux d'approbation **at-least-once** (double-clic humain) → handlers **idempotents** obligatoires (clé d'idempotence).
- **[C13]** **HITL sans timeout = anti-pattern** documenté (attente infinie) → timer + repli (escalate/auto-approve).
- **[C17]** Restate : handlers durables **suspendent** en attente d'une approbation, réinvoqués à l'arrivée du résultat (awakeable) — mais la reprise exige la **même version de code** (URLs immuables ; « version drift breaks replay »).
- **[C21]** Approbation humaine = **événement durable dans le log** (avec l'artefact/hash exact), pas une réponse transitoire.

## Section 4 — Modes d'échec / anti-patterns (distribués dans les mécanismes)

LLM dans le flux déterministe ([C10]) · boucle entière dans une activity ([C11]) · signaux non-idempotents ([C12]) · HITL sans timeout ([C13]) · version-drift comme hazard de replay ([C20]) · couplage à un état de session **opaque/framework-owned** ([C3]) vs trace **application-owned** · « session memory ≠ durable execution » (Diagrid).
> *Non-vérifié 3-0 (cadrage) : taxonomie MAST (14 modes), « LLMs approximate structured state → drift » (augmentcode.com) — vivent dans les résultats de recherche amont, pas dans les 24 claims confirmés.*

## Sources (citées dans les claims confirmés)

Primaires : temporal.io/blog + docs.temporal.io (event-history, workflow-definition, handling-messages, ai-cookbook/human-in-the-loop) · docs.langchain.com (persistence, use-time-travel, interrupts) · docs.restate.dev (human-in-the-loop, external-events).
Analyses : xgrid.co (failure-patterns) · journal.resonatehq.io · zylos.ai · restate.dev/vs/temporal · langchain.com/blog/deep-agents-prompt-caching *(source du claim réfuté)* · digitalapplied.com (prompt-caching) · diagrid.io (checkpoints-are-not-durable-execution) · blog.raed.dev (issue #6208).
Cadrage (hors 24 vérifiés) : quellixlabs.com · augmentcode.com.

## Caveats
- Champ à évolution rapide (LangGraph 1.x live, chiffres prompt caching model-conditional côté OpenAI) — re-vérifier au-delà de quelques mois.
- Deux corrections de vérificateur : [C14] erreur bloquante **retryable** (pas terminale) ; [C20] fragilité **conditionnelle à l'architecture re-exécutive**, neutralisée en record-then-substitute.
- Plusieurs primaires = blogs vendeurs (temporal/restate/langchain), systématiquement corroborés par docs neutres avant confirmation.
