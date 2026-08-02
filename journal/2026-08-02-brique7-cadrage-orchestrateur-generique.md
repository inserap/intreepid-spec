# Journal — Brique #7 (curateur d'ingestion) : cadrage qui a fait émerger l'architecture d'exécution des agents

- Date : 2026-08-02
- Participants : Alex ; Claude
- Nature : session de **conception** (brainstorming + design + plan + 3 passes advisor + ADR + 2 veilles). **Zéro code shippé.**
- Produits durables : **ADR-0009** (Proposed), note de veille `research/2026-08-02-orchestration-agents-sans-etat.md`, Q-0021, ce journal. Design v2 + plan **conservés en vol** (slice #7 non terminée).
- Temps engagé : ≈ **1h31** (bloc `2026-08-02 08:19`) ; span ≈ 5h34 (gonflé par les agents en arrière-plan : claude-code-guide, 2 advisors, deep-research, récupération de transcript).

---

## 1. Le point de départ : « allons pour le curateur »

Après l'inventaire du reste-à-faire v1 (3 items sur 7 : curateur, interface, attribution), Alex a choisi le **curateur** (item #2). Brainstorming : périmètre **amont seul** (ingestion), + une idée d'Alex qui a tenu tout du long — l'humain peut verser une **doc** décrivant la donnée, versée *avant* l'interview (3 sources : profiling MCP + doc + interview, l'interview réduite au reliquat). Caractère **maïeutique** retenu (proposer des hypothèses + demander), et surtout la bascule d'Alex vers une **vraie conversation multi-tours** plutôt que « 2 passes » — la curation *est* conversationnelle par nature.

## 2. Trois découvertes d'exploration ont fait dérailler (utilement) le design

En cartographiant le code réel avant le plan, trois écarts avec le design supposé :
1. `profile_stats` **présuppose une fiche** (allowlist + types) → un dataset à curer n'en a pas → besoin d'un **profil brut sans fiche** (inférence de type, Q-0015a).
2. Le **serveur MCP est mono-fiche** (`INTREEPID_FICHE` au boot) → ne sert pas un dataset non-fiché.
3. Le **`Scribe` est mono-run** (crée+scelle en un CM) → une conversation async multi-invocations a besoin d'open/append/seal.

J'ai d'abord proposé la voie *rapide* (curateur en-process, hors MCP). Alex a eu un **« bad feeling »** et demandé une carte mentale des composants. Elle a révélé le fond : le curateur ne casse pas « un 2ᵉ agent », il **casse deux uniformités** que l'archi mono-agent masquait — l'**accès donnée** (Fork A) et l'**orchestration** (Fork B).

## 3. Les deux forks, tranchés

- **Fork A → A1** : Alex tranche « pas de bricolage » — le MCP reste la **porte unique** (P2/P3), on le rend **multi-dataset** (profil brut sans fiche). La porte latérale en-process (A2) = dette rejetée.
- **Fork B → orchestrateur générique** : Alex voit que `run_analysis` (one-shot) est un driver taillé pour l'analyste, et que l'analyse *aussi* est conversationnelle (il corrige mon « analyste = 1 tour », résidu de l'implémentation actuelle). Conclusion : **une seule boucle générique + un profil de rôle** ; l'analyste devient un profil one-shot, le curateur un profil multi-tours ; l'analyse conversationnelle = même boucle, différée (Q-0002). *La différence curation/analyse n'est pas le mécanisme (identique) mais le profil* (charte + contrat de sortie + prérequis + terminaison).

Sa question technique — « comment le contexte et l'historique arrivent au LLM ? » — a été le pivot. Vérifiée sur le vrai `claude_agent_sdk` (agent claude-code-guide) : contexte = **string only** (pas de slot structuré) ; historique = soit **SDK-owned** (resume, mais #109 : illisible à la reprise, couplé au `cwd`, double-store), soit **application-owned** (rejeu depuis notre trace). Alex a validé **(B) application-owned**.

## 4. Deux veilles avant de graver (« construire solide »)

Alex a demandé une recherche « pour ne pas tomber dans un piège futur » sur un principe *au cœur* du système.
- **Corpus interne** (agent Explore sur `research/`+journaux) : valide append-only immuable (Trrack/LangGraph vs forky), « distiller à la clôture », MCP read-only+fiche, le paradigme « tuer les hypothèses, pas les pondre » (anti PNAS 2026). Apport neuf : **modèle de nœud** à repenser sur 3 axes (grain **Action**, **acteur**, **artefact**).
- **Deep-research web** (24 claims vérifiés 3-0) : **verdict — pour du read-only, le rejeu-store-maison suffit ; un moteur durable serait de la sur-ingénierie** ; 6 garde-fous à emprunter. Confirme aussi que « resume » n'est jamais magique (même LangGraph ré-exécute) et corrige le mécanisme du prompt caching (mémoïsation de préfixe **exact**, pas snapshot d'état → préfixe **byte-stable** requis). Consignée en `research/2026-08-02-…`.

## 5. ADR-0009, design v2, plan advisor-SHIP

- **ADR-0009** grave : orchestrateur générique + profil de rôle · historique **application-owned** / record-then-substitute · MCP multi-dataset · 4 garde-fous · modèle de nœud enrichi. Alternatives (moteur durable, resume SDK, porte latérale, drivers dupliqués) documentées et rejetées. Statut **Proposed** — Alex validera `Accepted` à l'implémentation *complète* de la brique #7.
- **Design v2** en **4 couches séparables** (S orchestrateur / T trace cycle-ouvert / M MCP multi-dataset / C profil curateur) avec **points de coupe** explicites. Découpage acté : **#7a = Phase A (socle)** d'abord.
- **Plan** : Phase A détaillée TDD, B/C/D en feuille de route (choix anti-cathédrale assumé). Porté à **SHIP en 3 passes advisor** : passe 1 (4 MUSTs — dont un vrai gate-breaker : le monkeypatch de `query` dans `test_scribe_runner.py` que le refactor casse ; + `Profile.parse` dimensionné `list[str]` pour la Phase D) ; passe 2 (2 gate-breakers ruff) ; passe 3 → SHIP. Corrections **matérialisées inline** dans les tâches.

## 6. Terminologie & un incident d'outillage

- « nous-owned » (néologisme maladroit) → **application-owned** sur remarque d'Alex.
- **Incident** : un advisor « actif » (general-purpose) a **écrit les fichiers du plan dans le repo impl** pour tester ruff en réel — pollution non désirée, **nettoyée** (`git restore` + `rm`, repo re-vérifié propre). Les passes suivantes ont été instruites de **tester hors-repo**. Leçon d'outillage → candidat de raffinement `workflow/04-advisor-passes.md`.

## 7. Leçons

- **Écouter le « bad feeling »** de l'humain : il pointait une fracture d'invariant (accès donnée) que la voie rapide cachait. Le recul (carte mentale) a converti un 2ᵉ agent en une **refonte propre de l'archi d'exécution**.
- **Recadrer par la recherche, pas par principe** (écho brique #6) : la deep-research a *confirmé* la coupe (store-maison suffit) et fourni des garde-fous concrets — investissement justifié pour un principe au cœur.
- **L'advisor actif paie mais peut salir** : il a trouvé le gate-breaker `test_scribe_runner.py` que la lecture ratait ; il faut l'encadrer (hors-repo).
- **Anti-cathédrale tenu** : B/C/D en feuille de route, code détaillé à l'exécution ; walking skeleton = #7a socle d'abord.

## 8. État en vol & reprise

Slice #7 **non terminée** → design v2 + plan **conservés** (gitignorés). Reprise en **session fraîche** : session-start (relit ADR-0009, OPEN-QUESTIONS, journaux) → rouvrir design+plan en vol → **exécuter #7a (Phase A)** en subagent-driven, puis détailler B/C/D. Pré-requis : aucun (Phase A = refactor pur, fixtures existantes).

## 9. Pointeurs

- ADR : `decisions/0009-architecture-execution-agents.md` (Proposed)
- Veille : `research/2026-08-02-orchestration-agents-sans-etat.md`
- Design/plan (éphémères, en vol) : `docs/superpowers/specs/2026-08-02-brique-7-curateur-ingestion-design.md` ; `docs/superpowers/plans/2026-08-02-brique-7-curateur-ingestion.md`
- OPEN-QUESTIONS : **Q-0021** (ajout) ; Q-0004 / Q-0019 / Q-0013 (raffinées)
- Amont : `journal/2026-08-02-contrat-interrogation-mission.md` ; overview §3/§4 (à porter après acceptation de l'ADR)
