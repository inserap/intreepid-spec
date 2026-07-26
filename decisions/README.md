# spec — decisions (drafts)

Cet espace héberge les **ADRs en cours de rédaction** (statut `Proposed`) du projet `intreepid`. Une fois `Accepted`, une ADR est promue vers le `decisions/` du impl repo associé (procédure de promotion : voir doctrine méthodologie).

Les ADRs `Accepted` historiques vivent dans le impl repo (cf. `<IMPL:<name>>/decisions/`).

## Convention

- Format Nygard + Alternatives + Supersedes (voir `<STANDARDS>/conventions/ADR.md`).
- Une ADR `Accepted` est **immutable**. Toute évolution passe par un nouvel ADR avec `Supersedes`.
- Numérotation continue à partir de la dernière ADR `Accepted` dans le impl associé.

## Drafts en cours (Proposed)

| ID | Titre | Statut |
|---|---|---|
| ADR-0001 | Socle de données : DuckDB + GeoParquet | Proposed |
| ADR-0002 | Persistance de la mémoire en trois étages | Proposed |
| ADR-0003 | Pas d'intégration native ArcGIS Pro en v1 | Proposed |
| ADR-0004 | Collaboration multi-utilisateurs sérialisée par l'agent | Proposed |
| ADR-0005 | Absorption du substrat d'exécution de Henry | Proposed |
| ADR-0006 | Couche modélisation ML déterministe, LLM orchestrateur | Proposed |

Issus de la session de fondation du 2026-07-26. À promouvoir vers `<IMPL:src>/docs/decisions/` une fois `Accepted`.
