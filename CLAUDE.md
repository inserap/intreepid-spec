# CLAUDE.md — spec

Spec repo for the project `intreepid`. Drives sessions on the impl repo(s).

**Conversational language: français.**

## Session rituals

The session-start ritual is **mandatory at the very beginning of every conversation**, before any other interaction (answer, question, exploration, edit). No exceptions: no "quick question", no "minor fix", no "just a look".

Generic procedures live in `standards/`:

- Session-start: see `<STANDARDS>/workflow/session-start.md`.
- Session-end: see `<STANDARDS>/workflow/session-end.md`.

Explicit triggers (FR / EN equivalents accepted):

- `Initie la session selon CLAUDE.md` / `start session`
- `Termine la session selon CLAUDE.md` / `end session`

## Paths to other repos

This spec's path resolution lives in [`repository-topology.md`](repository-topology.md). At session-start, after reading this file, read `repository-topology.md` to resolve `<STANDARDS>` and `<IMPL:*>`.

## Project-specific invariants

- **Architecture reference** lives in `<IMPL:src>/docs/architecture/overview.md`. Any change to it is a new version with a changelog line — never a silent edit.
- **Component admission rule**: a component must either speed up iteration or solidify knowledge. Otherwise it stays out.
- **Plus-value visibility test** (v1 scope rule, companion to the admission rule): every v1 deliverable must answer *"what would a generic LLM client wired to a DuckDB MCP not provide?"* If the answer is "nothing", it is WOW theatre, not value — it stays out. Source: journal 2026-07-27, ADR-0007 context.
- **Read-only on source data** (P2/P3): agents never ingest raw rows and never mutate sources; access is through MCP tools (profiles, aggregates, samples). Sensitive data is pseudonymised upstream (FME) — see also I-5.
- **Hard rule**: no next architecture version before a first real discovery session on real data. Spec must precede a walking skeleton, not replace it.

## Project-specific anti-patterns

- **The Henry/Algiz pattern**: fully specifying an architecture without ever implementing it (Tier 1 complete, Tier 2 never started). A spec with no implementation is an alarm, not an achievement — cross the whole system minimally first. See ADR-0005.

## Project overrides — language (if any)

<-- If the project overrides the standards language tier-list, declare it here with a justifying ADR pointer -->

## Project overrides — code quality

- **`src` : pyright `typeCheckingMode = "standard"`** au lieu du défaut `strict` de `standards@0.7.0`. Déviation d'un cran, justifiée par [ADR-0008](decisions/0008-code-quality-deviation-pyright-standard.md) : la stack maison (DuckDB/FastMCP/Agent SDK/PyYAML) est sans stubs → `strict` = bruit de propagation d'`Unknown` en frontière. `ruff` + `pytest` restent pleins. Ratchet vers `strict` planifié (wrappers typés).

## Project workflow conventions (raffinent le workflow `<STANDARDS>/workflow/` — ship, exec, reviews)

> Conventions **projet-local**, validées à l'usage sur intreepid. **Candidats de promotion** vers `standards/` — à arbitrer par une *revue d'usage de standards* conduite depuis `methods/spec` (mécanisme pull, cf. journal 2026-07-30), pas par une mutation de standards depuis une session projet.

- **Démo = gate de validation humaine AVANT le merge final.** Quand la slice produit un livrable démontrable, son **scénario de démo** (runbook `src/demo/brique-N-*.md` + driver `demo.py`) est produit **pendant l'implémentation**, et la démo est **lancée avant le merge** : c'est la démo, pas seulement les tests verts, que l'humain valide. (Leçon brique #2 : la démo a révélé un spoiler de fiche et un argument métier fragile — mieux vaut avant le merge.)
- **CHANGELOG + tag en DERNIER commit, APRÈS le merge.** Le bump de version + l'entrée CHANGELOG + le tag SemVer ne vivent pas sur la branche avant merge : ils forment un **commit final distinct sur `main` après le merge**, pour que le commit de merge reflète le code revu et que les métadonnées de release soient un pas auditable séparé. (`git tag` reste user-driven — I-3.)
- Ordre de la phase ship : revue finale SHIP → **scénario de démo** → **démo (gate humain)** → **merge** → **CHANGELOG + tag (commit final post-merge)** → execution recap + journal.
- **Commit = DERNIÈRE étape d'une tâche, après gate qualité ET revue (raffine `<STANDARDS>/workflow/05-subagent-exec.md` / `06-per-task-reviews.md`).** Ordre par tâche : implémentation TDD → gate qualité vert → `git add` (stage seul) → revue de tâche sur le diff stagé → fixes éventuels (re-gate, re-revue) → **commit seulement après verdict Approved**. Aucun commit — même trivial (reformatage, reliquat) — sans gate vert et revue préalables. `git add`/`git commit` restent deux étapes distinctes (I-4). Candidat de promotion.
- **Récap plain-language de fin de tâche = CHECKPOINT (raffine `<STANDARDS>/workflow/05-subagent-exec.md` / `06-per-task-reviews.md`).** À la fin de **chaque tâche d'implémentation** (subagent-driven ou manuelle) : fournir un **résumé concis, fichier par fichier, en langage clair** des modifications — « ce que fait ce changement et pourquoi », 1-2 lignes par fichier, orienté intention/effet, jamais un dump de diff. **Mécanique de livraison obligatoire : le récap est le message FINAL du tour — terminer le tour après chaque tâche (checkpoint), la tâche suivante n'est dispatchée qu'après le « continue » (ou correction) de l'humain.** Raison : le texte émis entre appels d'outils au milieu d'un long tour n'est pas affiché de manière fiable — un récap non remis n'existe pas (leçon brique #4, 2026-07-31). But : compréhension et validation humaine au fil de l'eau. Candidat de promotion.
- **Mesure du temps engagé (instrumentation locale).** Des hooks Claude Code (`SessionStart`/`UserPromptSubmit`/`Stop`, dans `.claude/settings.local.json` — per-user, gitignoré) horodatent l'activité dans `.claude/activity.log` (gitignoré). Le script versionné [`bin/engaged-time.sh`](bin/engaged-time.sh) calcule le **temps engagé** par session (somme des intervalles sous un seuil d'idle, défaut 600 s) + le span. Au session-end, consigner *temps engagé + span git* dans l'execution recap. Approxime la présence active, **pas** le temps de cerveau pur ; forward-only (démarre à l'installation). Candidat de promotion.

## Universal reminders

The full universal anti-pattern list lives in `<STANDARDS>/anti-patterns/`. Recurring reminders :

- Editing a file under `<STANDARDS>/` directly without going through the session-end ritual's bin "b".
- Copying doctrine files back into this spec (defeats live-linking).
- Treating this CLAUDE.md as the source of session ritual logic — it is a wrapper. The source lives in `<STANDARDS>/workflow/session-*.md`.
- Bypassing the session-start ritual under the pretense of "a quick question".
- Committing ephemeral slice working files.
- Chaining `git add` and `git commit`.
- Running `git tag` or `git push` autonomously.
