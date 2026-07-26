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

<-- list of N project-specific invariants, or "None yet — see decisions/ as they emerge" -->

## Project-specific anti-patterns

<-- list of project-specific anti-patterns, or "None yet" -->

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
