# ADR-0004 — Collaboration multi-utilisateurs sérialisée par l'agent

- **Status:** Proposed
- **Date:** 2026-07-26
- **Decision-makers:** Alexandre Pillonel, Claude (co-conception)

## Context

Plusieurs personnes doivent pouvoir interagir sur la même session (créer des branches, repartir de celle d'un collègue, critiquer/clore une branche) depuis leurs propres appareils, sans complexité de synchronisation d'état.

## Decision

Pas de co-édition temps réel (pas de CRDT ni de websockets de synchronisation d'état). Toutes les contributions passent par la conversation avec l'agent, qui les ordonne naturellement — **l'agent est le point de sérialisation**. L'attribution native (pastilles/couleurs par auteur) est dans le schéma de données dès la v1, même en mono-utilisateur.

## Consequences

### Positive

- Simplicité par l'agentique plutôt que par de la plomberie collaborative.
- Pas de conflits d'édition possibles par construction.
- Le notebook de sortie documente qui a validé quoi (traçabilité de gouvernance).
- Deux modes servis : synchrone léger (salle + écran partagé, zéro dev) et asynchrone (annotations sur notebook → graphe).

### Negative / costs accepted

- Pas d'édition concurrente fluide façon Google Docs ; l'interaction reste médiée par l'agent.
- L'attribution structurée en v1 a un coût de conception, mais son rétrofit ultérieur serait bien plus cher (décision structurante assumée tôt).

## Alternatives considered

- **Co-édition temps réel (CRDT / websockets)** — Rejeté : complexité de synchronisation d'état disproportionnée ; l'agent comme sérialiseur suffit et supprime les conflits par construction.

## Supersedes

None.

## References

- Journal : [`../journal/2026-07-26-session-fondation.md`](../journal/2026-07-26-session-fondation.md) §5, §10
- Vision : `<IMPL:src>/docs/architecture/overview.md` §9
