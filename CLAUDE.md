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

## Universal reminders

The full universal anti-pattern list lives in `<STANDARDS>/anti-patterns/`. Recurring reminders :

- Editing a file under `<STANDARDS>/` directly without going through the session-end ritual's bin "b".
- Copying doctrine files back into this spec (defeats live-linking).
- Treating this CLAUDE.md as the source of session ritual logic — it is a wrapper. The source lives in `<STANDARDS>/workflow/session-*.md`.
- Bypassing the session-start ritual under the pretense of "a quick question".
- Committing ephemeral slice working files.
- Chaining `git add` and `git commit`.
- Running `git tag` or `git push` autonomously.
