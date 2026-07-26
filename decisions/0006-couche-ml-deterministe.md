# ADR-0006 — Couche modélisation ML déterministe, LLM orchestrateur

- **Status:** Proposed
- **Date:** 2026-07-26
- **Decision-makers:** Alexandre Pillonel, Claude (co-conception)

## Context

Cas d'usage soumis : produire une vision prospective du risque d'accidents à partir de l'historique. Un LLM ne sait pas faire d'optimisation statistique sur des millions de lignes ; un modèle ML ne « comprend » rien au métier. Il faut répartir le travail sans faire du LLM une boîte noire prédictive.

## Decision

Division du travail : le **LLM est le stratège** (génère l'espace d'hypothèses de facteurs, identifie les données manquantes, interprète les importances, critique — biais de déclaration, régression vers la moyenne, trafic vs dangerosité). Un **modèle ML classique, déterministe et versionné** (GLM Poisson / gradient boosting spatio-temporel, scikit-learn ou XGBoost) est le **calculateur**, invoqué comme outils MCP (`train_model` / `predict` / `explain`). Validation croisée strictement **temporelle**.

**Cadrage (fait partie de la décision)** : on ne « prédit pas les accidents ». On produit une **carte de probabilité de risque par tronçon / maille H3** pour prioriser des aménagements. La formulation protège contre la survente prédictive.

## Consequences

### Positive

- Prédiction déterministe, versionnée et reproductible — jamais une boîte noire dans le chat.
- Le LLM apporte le regard métier et la critique méthodologique sans usurper le calcul.
- Le pilote accidents peut démarrer en v1 sur sa partie exploratoire (facteurs, profils, densités normalisées).

### Negative / costs accepted

- Deux artefacts à maintenir (modèle ML versionné + orchestration LLM).
- La couche ML complète est reportée en v2 ; seule l'exploration démarre en v1.

## Alternatives considered

- **LLM prédicteur direct** — Rejeté : un LLM ne fait pas d'optimisation statistique fiable sur des volumes ; opacité et non-reproductibilité inacceptables en contexte décisionnel.
- **Modèle ML seul, sans LLM** — Rejeté : perd l'apport métier (hypothèses de facteurs, critique des biais, interprétation).

## Supersedes

None.

## References

- Journal : [`../journal/2026-07-26-session-fondation.md`](../journal/2026-07-26-session-fondation.md) §13
- Vision : `<IMPL:src>/docs/architecture/overview.md` §7, §12 (périmètre v2), §13 (risque de survente prédictive)
- Dataset pilote à confirmer : Q-0002 ([`../OPEN-QUESTIONS.md`](../OPEN-QUESTIONS.md))
