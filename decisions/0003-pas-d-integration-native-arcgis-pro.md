# ADR-0003 — Pas d'intégration native ArcGIS Pro en v1

- **Status:** Proposed
- **Date:** 2026-07-26
- **Decision-makers:** Alexandre Pillonel, Claude (co-conception)

## Context

Question posée : héberger le workspace dans ArcGIS Pro (SDK .NET, dockpane WebView2) pour rester au plus près de l'atelier cartographique des spécialistes ?

## Decision

**Non pour la v1.** Le workspace est une application web (Vue.js) qui consomme ArcGIS Enterprise Portal (couches, géotraitements, authentification — pattern PUMA). Chaque insight spatial est exportable vers Pro (couche Portal ou GeoParquet). Pro reste l'atelier de **production cartographique** ; le workspace est l'atelier de **découverte**.

## Consequences

### Positive

- Stack alignée sur les compétences de l'équipe (Python / Vue), pas de C#/.NET.
- Chat traité comme citoyen de première classe, pas contraint par un hôte lourd.
- Compatible multi-participants (pas d'adhérence licence/poste).

### Negative / costs accepted

- Pas d'intégration « in-app » dans Pro : le pont se fait par export, pas par co-résidence.

## Alternatives considered

- **Hébergement dans ArcGIS Pro (add-in .NET / WebView2)** — Rejeté : stack hors périmètre de l'équipe ; UI contrainte où le chat serait un citoyen de seconde zone ; adhérence licence/poste incompatible avec le multi-participants.

## Supersedes

None.

## References

- Journal : [`../journal/2026-07-26-session-fondation.md`](../journal/2026-07-26-session-fondation.md) §9
- Vision : `<IMPL:src>/docs/architecture/overview.md` §11
- Porte ouverte : add-in léger « ouvrir cette emprise dans le workspace » envisageable en v2+ si la demande est forte.
