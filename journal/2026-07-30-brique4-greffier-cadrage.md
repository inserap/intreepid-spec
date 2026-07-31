# Journal — Brique #4 (le greffier) : recherche + cadrage complet, implémentation à reprendre

- Date : 2026-07-30 (clôturée le 2026-07-31 au matin)
- Participants : Alex ; Claude
- Nature : session de **cadrage** (recherche + design + plan, **aucune implémentation shippée**)
- Produits : `research/2026-07-30-greffier-provenance.md` ; raffinements Q-0003/Q-0004 ; design + plan
  éphémères **conservés** (slice en vol) ; branche `feat/greffier-capture` créée dans `<IMPL:src>` ; ce journal.
- Temps engagé : ≈ 1h10 (30.07 soir : 0h18 + 0h49 ; reprise 31.07 matin : ~0h03). Span git spec : aucun
  commit pendant la session (tout committe au session-end).

---

## 1. Choix de la brique #4 : le greffier

Inventaire vérifié du `src` face au périmètre v1 (overview §12) : trois briques ont creusé **un seul axe**
(le MCP « profil + preuve ») ; greffier/mémoire, interface et notebook n'ont jamais été traversés. Préconisation
retenue : **le greffier + le modèle de trace** — c'est l'étape n°3/5 du plan (§14), le membre le plus
différenciant (la veille du 2026-07-29 a montré que la couche MCP read-only est reproductible par n'importe
qui ; le « vrai plus » n°1 et n°2 — documentation à coût zéro, capitalisation — vit au-dessus), et il prépare
la séance métier Q-0002. Alternative écartée : approfondir la rigueur Q-0009 (re-polir la couche déjà creusée,
axe le moins différenciant).

## 2. Recherche ciblée (5 agents parallèles) → `research/2026-07-30-greffier-provenance.md`

Cinq volets, tous vérifiés `gh api` / sources : code réel de `forky` ; modèles de données de provenance
(Trrack, Verdant, langgraph, OpenLineage) ; littérature *analytic provenance* (granularité Q-0003) ;
W3C PROV ; capture mécanique Agent SDK + distillation (graphiti, letta, kektordb).

**Le fil** : la littérature valide le pari mais l'inverse — le *quoi* se logge automatiquement, le
***pourquoi*** (insight/rationale/abandons) ne se capture PAS automatiquement (reconstruction depuis les
logs : 60–79 %, Dou 2009) et meurt de son coût quand il est manuel (40 ans de design rationale). **Notre
carte** : l'agent verbalise déjà son raisonnement → le greffier le récolte en NL non-bloquant et le structure
à la distillation (formalisation incrémentale). Convergences fortes : indexer **par artefact** pas par
chronologie ; **immuabilité append-only** + branches mortes conservées (forky = contre-exemple : mutable) ;
**facets** pour l'extension ; distiller **à la clôture** en 2 temps. Découverte d'implémentabilité : le
**Claude Agent SDK fournit le seam** (`SessionStore` non-bloquant par contrat ; ici, plus simple encore :
tee du flux `query()` one-shot). Verdict PROV : **vocabulaire allégé oui, stack RDF non**. Deux corrections
factuelles à la veille du 29 consignées (PROV-AGENT/flowcept ; OTel GenAI migré).

## 3. Design (brainstorming, 3 décisions + robustesse)

Décisions validées une à une : **(1) périmètre = capture seule** (pas de distillation — walking skeleton sans
non-déterminisme LLM) ; **(2) flux complet + raisonnement** (`thinking` summarized via option SDK — sans toucher
charte ni contrat JSON, Q-0014 non rouverte) ; **(3) modèle A mono-table typée** (`sessions` + `nodes`, B
composite = YAGNI, C transcript brut = repousse le contrat Q-0004). Cadrage honnête gravé : la trace du banc
one-shot est **quasi-linéaire** — la démo = « documentation fidèle à coût zéro, rejouable », pas un arbre
branchu ; l'arborescence attend une vraie session multi-tours (Q-0002).

**Apport décisif d'Alex** : le flush final unique perdait la trace en cas d'échec → `Scribe` refondu en
**context manager + écriture incrémentale** (chaque nœud durable dès sa capture ; `__exit__` scelle `closed`
ou `aborted`+raison ; double filet : même un SIGKILL ne perd que l'événement en vol). Une session interrompue
devient elle-même une donnée. Distinction gravée : exception de *l'analyste* = enregistrée puis re-propagée ;
panne du *scribe* = avalée (non-intrusion).

## 4. Plan + 2 passes advisor SHIP

Plan writing-plans (6 tâches TDD : trace.py mapping pur → store.py Scribe/load → render.py ASCII → runner
tee opt-in → démo → test agent), chaque API **vérifiée contre le code réel** (types SDK lus dans le venv :
`thinking={"type":"adaptive","display":"summarized"}`, champs requis de `ResultMessage`…). **Advisor #1 :
SHIP, 0 MUST, 6 SHOULDs** (3 appliqués : commentaire blocs serveur, capture de `nature`, version README) ;
**advisor #2** (le même agent repris via SendMessage, passe ciblée sur les 3 changements) : **SHIP, 0 MUST**.

## 5. État d'interruption + reprise

L'exécution subagent-driven a été lancée : branche **`feat/greffier-capture`** créée dans `<IMPL:src>`
(base `155a63f` = v0.4.0, working tree clean), puis session interrompue **avant la Task 1 — zéro commit**.
Design + plan éphémères **conservés sur disque** (gitignorés, slice en vol) :
`docs/superpowers/specs/2026-07-30-greffier-design.md` et `docs/superpowers/plans/2026-07-30-greffier.md`.

### Prompt de démarrage de la session d'implémentation (à coller dans une nouvelle session)

```text
Brique #4 — implémenter le greffier (capture épisodique) depuis le plan SHIP existant.

1) Initie la session selon CLAUDE.md (rituel complet) AVANT toute autre chose.

2) Contexte : le cadrage est FAIT (journal/2026-07-30-brique4-greffier-cadrage.md). Design
   validé + plan approuvé par 2 passes advisor (SHIP, 0 MUST) — NE PAS refaire brainstorming
   ni advisor. Lire :
   - design : docs/superpowers/specs/2026-07-30-greffier-design.md
   - plan   : docs/superpowers/plans/2026-07-30-greffier.md (6 tâches TDD, code complet)
   - veille : research/2026-07-30-greffier-provenance.md (référence, pas requis pour coder)

3) État git : <IMPL:src> a déjà la branche feat/greffier-capture (base 155a63f = v0.4.0,
   zéro commit). S'y placer et exécuter le plan en superpowers:subagent-driven-development :
   un sous-agent frais par tâche + double revue (spec + qualité) par tâche, dans l'ordre
   Task 1 → 6. BASE de la Task 1 = 155a63f.

4) Discipline NON négociable : gate qualité (ruff / pyright standard / pytest -m "not agent")
   vert avant CHAQUE commit ; git add et git commit en DEUX étapes ; jamais tag/push autonome ;
   scan de domaine sur intreepid/scribe/ (grep accident|canton|vitesse|ofrou → vide) ;
   non-régression : trace_to=None → runner strictement inchangé (l'oracle existant doit rester
   vert) ; les tests de test_runner_options.py doivent passer inchangés.

5) Ordre ship (convention projet) : revue finale de branche → démo brique-4 (runbook avec
   sorties réelles, GATE HUMAIN) → merge → CHANGELOG [0.5.0] + bump + tag en commit final
   post-merge (tag user-driven) → execution recap + journal → SUPPRIMER les éphémères
   design/plan (slice alors complète).

6) Hors périmètre (rappel design §10) : distillation, rappel MCP search_sessions, arbre
   visuel, DAG/merge/fork, empreinte spatiale peuplée, attribution multi-acteurs, toute
   modif de charte/contrat JSON (Q-0014).
```

## 6. Leçons

- **L'objection humaine au design a porté exactement là où la revue automatique ne regardait pas** (durabilité
  en cas d'échec) : le gate humain par section de design vaut son coût — même leçon que la démo-gate, plus tôt
  dans le cycle.
- **Vérifier les API dans le venv avant d'écrire le plan** (types SDK lus dans `site-packages`) : l'advisor n'a
  trouvé 0 MUST — le coût de vérification amont s'est remboursé en une passe.
- **Reprendre le même advisor via SendMessage** pour une re-passe ciblée coûte une fraction d'un advisor frais
  et suffit pour valider des changements localisés (déjà pratiqué brique #3 avec un advisor frais ; variante
  économe).
- Un session-end peut clore une session de cadrage **sans forcer de slice** : la slice reste en vol, ses
  éphémères survivent, le journal porte le fil.

## 7. Pointeurs

- Veille greffier : `research/2026-07-30-greffier-provenance.md`
- Design/plan (éphémères, en vol) : `docs/superpowers/specs/2026-07-30-greffier-design.md`,
  `docs/superpowers/plans/2026-07-30-greffier.md`
- OPEN-QUESTIONS : Q-0003 et Q-0004 raffinées
- Amont : `journal/2026-07-30-brique3-concentration-modele-nul.md` ; veille `research/2026-07-29-etat-de-lart-github.md` §6/§7
- Impl : `<IMPL:src>` branche `feat/greffier-capture` (base `155a63f`, 0 commit)
