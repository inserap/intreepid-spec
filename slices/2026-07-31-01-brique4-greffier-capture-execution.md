# 2026-07-31-01-brique4-greffier-capture — Execution recap

## Scope

Quatrième brique livrable d'`intreepid` (walking skeleton v0.2) : **le greffier** — première
traversée de la couche mémoire (§10). Une couche d'**observation passive** capture le flux
complet d'une session de l'analyste (thinking résumé, appels MCP, agrégats, verdict avec refus
motivés) et le persiste en **arbre de session immuable** dans un store DuckDB épisodique dédié,
rejouable (P4) et rendable en ASCII. Capture **opt-in** (`trace_to`) : sans elle, le runner est
strictement inchangé. Exécution depuis le plan SHIP du cadrage du 2026-07-30 (design + plan
approuvés par 2 advisors, **non refaits**). Shippé dans `<IMPL:src>`, mergé sur `main`
(merge `c594e64`), release `v0.5.0` (commit `db3f36c` ; **tag user-driven**).

## Shipped artifacts

Dans `<IMPL:src>` (package `intreepid`) :
- `scribe/trace.py` (NEW) : contrat de données Q-0004 — `TraceNode`/`SessionTrace` +
  `TraceBuilder`, mapping **pur** (sans I/O ni LLM) du flux Agent SDK ; ids déterministes
  `{sid}#{seq}` ; `tool_result` apparié à son `tool_call` via `tool_use_id`.
- `scribe/store.py` (NEW) : `Scribe` context manager DuckDB — **écriture incrémentale**
  (chaque nœud durable dès sa capture), scellement `closed`/`aborted`+raison en `__exit__`,
  **append-only** (session scellée ou crashée-`open` jamais rouverte), `__enter__` gardé
  contre la fuite de connexion ; `load()` réhydrate en read-only.
- `scribe/render.py` (NEW) : arbre ASCII (💭 thinking, 🔧 appels+agrégats indentés,
  observations avec statuts — `refusé`/`hypothèse` = branches mortes documentées).
- `agent/runner.py` : `run_analysis(…, trace_to=None)` — tee opt-in via `_safe`
  (**non-intrusion** : panne du greffier loggée/avalée, verdict toujours rendu ; exception de
  l'analyste enregistrée puis re-propagée) ; thinking summarized activé seulement en mode
  enregistré ; docstring `model="opus"` (Q-0013) restaurée.
- `tests/` : `test_scribe_mapping` (6+), `test_scribe_store` (immuabilité sur les 3 états),
  `test_scribe_render`, `test_scribe_runner` (non-régression + **3 tests non-intrusion/abort**
  à travers le runner), `test_scribe_agent` (agent réel, marqué `agent`). 51 → 59 déterministes.
- `demo/brique-4-greffier.md` (NEW, sorties réelles du 2026-07-31) + `demo_greffier.py` +
  ligne `demo/README.md`. `CHANGELOG.md [0.5.0]`, `pyproject`/`uv.lock` 0.5.0.

Côté spec : `CLAUDE.md` — **2 nouvelles conventions workflow** (feedback Alex en séance) :
**commit = dernière étape d'une tâche** (après gate qualité ET revue ; l'implémenteur stage,
le commit tombe après Approved) ; **récap plain-language = checkpoint turn-final par tâche**.

## Deviations from plan (if any)

- **Flux d'exécution refondu en cours de route** (feedback Alex, tâche 3+) : le plan/skill
  faisait committer l'implémenteur avant la revue ; passage à *stage → revue → fix →
  re-revue → commit*. Les tâches 1-2 ont suivi l'ancien ordre (leurs revues sont venues
  après commit) — pas de réécriture d'historique.
- **Récaps par tâche jamais parvenus à l'humain** : rédigés entre appels d'outils au milieu
  de longs tours autonomes → non affichés. Diagnostiqué (pas un problème de subagents — les
  reports sur disque avaient leur section récap), corrigé en convention checkpoint.
- **Fixes plan-mandatés** : plusieurs findings de revue provenaient du code du plan lui-même
  (import local, connexions DuckDB non fermées — classe de bug Windows de brique #2, docstring
  opus perdue). Corrigés sans contradiction avec l'intention du plan ; erratum consigné.
- Runbook démo intégré au commit de la vague de fixes par `--amend` (choix Alex) plutôt qu'en
  commit dédié.

## Validation

- **Golden déterministes** : `59 passed` (`uv run pytest -m "not agent"`), gate complet vert
  (ruff format/check, pyright standard 0 erreur) — vérifié indépendamment par le contrôleur
  avant le commit de la vague de fixes.
- **Test agent** : `1 passed` (78 s) — session réelle capturée, scellée `closed`, ≥1 `tool_call`,
  ≥1 `observation` ; le thinking summarized **est** capturé (2 nœuds 💭 dans la démo).
- **Non-régression** : `test_runner_options.py` (7 tests) passés **sans modification** ;
  `trace_to=None` → aucun store, thinking off.
- **Reviews** : revue par tâche (spec + qualité + scan de domaine) sur les 6 tâches ; revue
  finale de branche « With fixes » → vague de fixes unique → re-revue **Ready to merge: Yes**.
  Le finding majeur de la revue finale : l'**invariant-titre (non-intrusion) n'avait aucune
  couverture** — 3 tests ajoutés.
- **Démo (gate humain)** : validée par Alex après Q&A (session≠analyse ; troncature = vue,
  le store garde l'agrégat complet).
- **Scan de domaine** : `grep -rin "accident|canton|vitesse|ofrou" intreepid/scribe/` vide.
- **Temps engagé** : ≈ 0h45 (31.07 matin) ; span git src 07:55 → 09:53 (10 commits, dont
  merge + release).

## Follow-ups

- **Dette code (triage revue finale, différée post-merge)** : monkeypatch au lieu
  d'assignation brute dans 2 tests runner ; DDL dupliquée à la main dans
  `test_open_crashed_session` ; imports locaux redondants dans 2 tests.
- **V2-list (revue finale)** : nœud `verdict_raw` quand `parse_verdict` échoue (forensique —
  aujourd'hui le texte brut non parsé est perdu hors `aborted_reason`) ; `render()` n'affiche
  pas `SessionTrace.meta` (num_turns, coûts).
- **Q-0004** : contrat livré ; restent schéma catalogue/fiche, liens inter-sessions
  (`wasInformedBy` — reprise d'analyse par référence), DAG, distillation, rappel MCP.
- **Q-0003** : capture grain événement en production ; calibration « Action sémantique » sur
  vraie session multi-tours (attend Q-0002).
- **Promotion** : 3 conventions workflow projet-local candidates (démo-gate ; commit-dernier ;
  récap-checkpoint) — arbitrage par la revue d'usage de standards depuis `methods/spec`.
- **Q-0002** (inchangée, LE verrou) : vraie question métier / destinataire réel.

## Pointers

- Journal : `journal/2026-07-31-brique4-greffier-implementation.md`
- Cadrage amont : `journal/2026-07-30-brique4-greffier-cadrage.md` ;
  veille `research/2026-07-30-greffier-provenance.md`
- Livraison : `<IMPL:src>` `main` merge `c594e64`, release `db3f36c`, tag `v0.5.0`
  (user-driven), `src/CHANGELOG.md [0.5.0]`
- Démo : `<IMPL:src>/demo/brique-4-greffier.md`
- OPEN-QUESTIONS : Q-0004 (raffinée — contrat livré, session≠analyse), Q-0003 (raffinée)
