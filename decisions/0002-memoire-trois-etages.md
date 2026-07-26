# ADR-0002 — Persistance de la mémoire en trois étages

- **Status:** Proposed
- **Date:** 2026-07-26
- **Decision-makers:** Alexandre Pillonel, Claude (co-conception)

## Context

L'arbre de session ne peut pas être « la mémoire » tout court : relire tous les arbres passés est illisible et dépasse le contexte du LLM après quelques sessions. Il faut distinguer ce qui s'est passé, ce qu'on a appris, et comment on travaille — et charger la bonne mémoire au bon moment.

## Decision

Trois étages distincts :

1. **Épisodique** — arbres de session (JSON/SQLite ou DuckDB dédié), **immuables** une fois la session close ; notebooks Quarto comme projection lisible (GitLab/GitHub).
2. **Sémantique** — graphe de connaissances + catalogue/biographie (YAML, évolution par merge request, traçable jusqu'au nœud source).
3. **Procédurale** — playbook + charte des agents (Markdown/YAML).

**Chargement paresseux** : au démarrage, l'agent reçoit le catalogue concerné, les insights actifs liés au sujet et l'état de la dernière session ; le reste est accessible à la demande via `search_knowledge` / `search_sessions`.

## Consequences

### Positive

- Le contexte LLM reste léger et pertinent ; la mémoire complète reste interrogeable sans être chargée.
- L'attribution (qui a dit / validé quoi) est dans le schéma dès la v1.
- Traçabilité de chaque insight jusqu'au nœud source qui le prouve.

### Negative / costs accepted

- Le greffier porte une étape de **distillation** à la clôture de session (coût de conception non trivial).
- Trois stockages à maintenir cohérents plutôt qu'un seul.

## Alternatives considered

- **Composants mémoire génériques (Mem0, Zep, Letta)** — Rejetés : conçus pour la personnalisation de chatbots ; notre mémoire est domaine-spécifique par conception. Les adopter serait une cathédrale déguisée en raccourci.

## Supersedes

None.

## References

- Journal : [`../journal/2026-07-26-session-fondation.md`](../journal/2026-07-26-session-fondation.md) §13
- Vision : `<IMPL:src>/docs/architecture/overview.md` §10
