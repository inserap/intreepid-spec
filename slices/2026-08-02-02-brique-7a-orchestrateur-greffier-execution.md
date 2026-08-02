# 2026-08-02-02-brique-7a-orchestrateur-greffier — Execution recap

## Scope

Première sous-brique de #7 (curateur d'ingestion), **Phase A d'ADR-0009** : installer le **socle
d'exécution générique** des agents avant d'empiler le curateur. Trois mouvements, tous à
**iso-comportement** (non-régression stricte de l'analyste) :

1. **A1** — extraire de `run_analysis` un orchestrateur générique `run_agent(profile, …)` one-shot
   + une dataclass `Profile` (ce qui change d'un rôle à l'autre : options SDK, parsing, hook de
   capture `on_result`).
2. **A2** — exprimer l'analyste comme un `Profile` (`analyst_profile.py`) et réduire `runner.py` à
   un **wrapper mince** (signature publique `run_analysis` inchangée).
3. **A3** — rendre le **greffier agnostique du rôle** : la primitive générique `record_nodes`/
   `TraceBuilder.custom` remplace `record_verdict`/`verdict` ; le schéma « observation » de
   l'analyste descend dans le profil. Émergé d'une objection d'Alex en séance (« le scribe connaît
   l'analyste »).

Exécution subagent-driven (implémenteur frais + revue par tâche sur diff stagé + revue finale
whole-branch). Shippé dans `<IMPL:src>`, mergé `main` (`2933ef6`), release **v0.8.0** (`642b80e`,
tag user-driven).

## Shipped artifacts

Dans `<IMPL:src>` (v0.8.0) :
- `intreepid/agent/orchestrator.py` (NEW) : `run_agent(profile, prompt, *, model, trace_to)` —
  boucle one-shot commune (garde OAuth Q-0010, capture greffier **best-effort** via `_safe`, parsing
  délégué au profil).
- `intreepid/agent/profile.py` (NEW) : `Profile` (dataclass frozen) — `role, build_options, parse,
  on_result`. **Minimal** (one-shot) ; les champs multi-tours (`is_terminal`/`next_input`) viendront
  en #7c/D.
- `intreepid/agent/analyst_profile.py` (NEW) : l'analyste comme profil (charte, allowlist MCP,
  isolation P2/P3, projection du verdict). Note défensive « pourquoi `tools=[]` retiré (smoke) »
  restaurée (`5e3c8bc`).
- `intreepid/agent/runner.py` (réécrit) : wrapper mince délégant à `run_agent(analyst_profile())` ;
  re-exporte `_build_options`/`_MCP_TOOLS` (garde-tests d'isolation).
- `intreepid/scribe/trace.py` + `store.py` (MODIF) : `record_verdict`/`verdict` → `record_nodes`/
  `custom` (primitive générique `(kind, content, meta)`). Socle de capture **agnostique** :
  `grep -iE 'verdict|observation|analyste'` sur `store.py`+`trace.py` = **vide**.
- Tests : `test_orchestrator.py`, `test_analyst_profile.py` (NEW) + adaptations `test_scribe_*`.
  **89 déterministes verts**.

## Deviations from plan (if any)

- **A3 non prévu au plan initial** : l'agnostisation du greffier a été **insérée** en séance (Task
  A3) suite à l'objection d'Alex, avant de clore #7a. Nom de la primitive (`record_nodes`/`custom`)
  tranché avec Alex (vs `record_result`/`result`, écarté car trop étroit pour les kinds de curation
  futurs).
- **Renderers hors-scope A3** : `render.py`/`notebook.py` dispatchent encore sur `kind=="observation"`
  (couplage de *lecture*) — délibérément différé (décision d'Alex), follow-up « rendu agnostique ».
- Fix I-1 de revue A3 : `nature: None` ajouté à la fixture `test_scribe_store` (fidélité à la
  projection réelle).

## Validation

- **Gate déterministe** : `89 passed`, ruff format/check + pyright standard 0 erreur — après chaque
  tâche et sur `main` post-merge.
- **Revues** : par tâche (spec + qualité) sur diff **stagé**, toutes Approved ; **revue finale
  whole-branch (opus) : Ready to merge** — isolation P2/P3 identique (ré-export = identité de
  fonction → `test_runner_options.py` intact), non-régression stricte, socle agnostique confirmés.
- **Démo (gate humain)** : `demo_greffier` (run analyste réel `opus` sur fixture `accidents_seed`) —
  arbre capturé/rejoué **structurellement identique** à l'historique, via `run_agent` : `session_root`
  → thinking/tool_call/tool_result → observations, statut `closed`. **Non-régression prouvée.**

## Follow-ups

- **Rendu agnostique des renderers** (`render.py`/`notebook.py`) : registre de rendu par `kind` fourni
  par le profil — tâche dédiée (couplage de lecture, cf. Q-0004).
- `Protocol` pour `record_nodes` (retirer un `# type: ignore` de test) — au prochain profil.
- Q-0021 : le curateur (#7c) sera le 2ᵉ profil réel = test décisif de « agent = profil ».

## Temps

- **Engagé** : la session (14:12) totalise ≈ **1h32** engagé (couvre #7a **et** #7b) ; part #7a ~
  span git 14:22→16:04 (≈ 1h40). Voir journal pour le détail.

## Pointers

- Journal : `journal/2026-08-02-brique7ab-socle-et-profil-brut.md`
- ADR : `decisions/0009-architecture-execution-agents.md` (Proposed)
- Livraison : `<IMPL:src>` merge `2933ef6`, release `642b80e`, tag `v0.8.0`, `src/CHANGELOG.md [0.8.0]`
- Démo : `<IMPL:src>/demo/brique-4-greffier.md` (réutilisée comme smoke de non-régression)
- OPEN-QUESTIONS : Q-0021 / Q-0004 (raffinées)
