# ADR-0005 — Absorption du substrat d'exécution de Henry

- **Status:** Proposed
- **Date:** 2026-07-26
- **Decision-makers:** Alexandre Pillonel, Claude (co-conception)

## Context

Henry (successeur d'Algiz) : géoportail AI-native, NL → Plans typés (DAG) → Runtime déterministe, Adapters, Registry, système de types à Traits. Spec de grande qualité (Tier 1 complet), implémentation jamais démarrée. Analyse aux trois lentilles : **fiabilité** excellente ; **impossible-avant** faible (le résultat égale trois clics dans un géoportail — couche linguistique sur des capacités existantes) ; **capitalisation** absente (agent stateless, rien n'apprend).

## Decision

**Absorber, pas enterrer.** Le workspace fournit la raison d'être et la couche de connaissance qui manquaient à Henry ; Henry fournit le substrat d'exécution rigoureux le moins spécifié chez nous :

- **Plan** (DAG typé, auditable, persistable) = format pressenti de nos « requêtes visibles et rejouables ».
- **Adapters** = pattern d'intégration Portal / swisstopo / FME.
- **Registry** = mécanique d'inventaire, à enrichir de la dimension sémantique du catalogue.

Le degré exact de réutilisation (repris tels quels, adaptés, ou simple inspiration de format) reste à trancher au moment du squelette (cf. Q-0005).

## Consequences

### Positive

- On récupère une conception d'exécution éprouvée sans repartir de zéro.
- La lignée Algiz → Henry → workspace se lit comme une convergence : le *comment* construit avant d'avoir trouvé le bon *pourquoi*.

### Negative / costs accepted

- Risque de sur-importer un substrat conçu pour un autre but ; à contenir par la règle anti-cathédrale.
- Leçon gravée dans le `CLAUDE.md` du projet : **spec sans implémentation = signal d'alarme.**

## Alternatives considered

- **Enterrer Henry et repartir de zéro** — Rejeté : gaspille un travail de conception de qualité directement réutilisable.
- **Reprendre Henry tel quel comme base** — Rejeté : Henry manque du pourquoi (impossible-avant faible) et de la capitalisation ; le reprendre entier reconduirait ses angles morts.

## Supersedes

None.

## References

- Journal : [`../journal/2026-07-26-session-fondation.md`](../journal/2026-07-26-session-fondation.md) §10, §11
- `henry-spec` : https://github.com/alexpillonel/henry-spec
- Question ouverte associée : Q-0005 ([`../OPEN-QUESTIONS.md`](../OPEN-QUESTIONS.md))
