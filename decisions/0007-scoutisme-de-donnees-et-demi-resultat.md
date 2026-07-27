# ADR-0007 — Scoutisme de données et demi-résultat comme livrable

- **Status:** Proposed
- **Date:** 2026-07-27
- **Decision-makers:** Alexandre Pillonel, Claude (co-conception)

## Context

Le pipeline de la vision suppose des données déjà ingérées par FME en
amont. Le scénario « départ à froid » — un utilisateur non expert arrive
avec une question métier floue et **aucune donnée dans le socle** (exemple
étalon : « je cherche un terrain à bâtir dont la situation laisse présager
une forte progression de valeur ») — expose deux vides : aucune capacité à
découvrir des sources de données en cours de session, et aucun statut pour
le résultat partiel qu'on peut atteindre faute de données complètes.

## Decision

1. **Le mandat du curateur est étendu au scoutisme de données** (« en
   amont de l'amont ») : quand une question métier arrive sans données
   correspondantes, il mobilise les connaissances universelles du LLM pour
   identifier les sources existantes (opendata.swiss, geo.admin.ch, OFS,
   portails cantonaux…), évalue leur pertinence (couverture, granularité,
   fraîcheur, conditions d'accès) et propose un **plan d'acquisition**. Le
   catalogue peut porter des fiches *pressenties* (statut « non ingéré »,
   limites anticipées) avant l'arrivée des données. L'ingestion effective
   reste du ressort de FME et de la validation humaine (P3, P8).
2. **Le « départ à froid » devient scénario de référence** de la boucle de
   découverte, en trois approximations successives : structurer l'espace
   des facteurs (zéro donnée nécessaire) → trier le faisable (scoutisme) →
   livrer le demi-résultat honnête.
3. **Le demi-résultat est un livrable de première classe**, pas un échec
   faute de données : grille de scoring multicritère spatialisée,
   shortlist, incertitude affichée, carte des angles morts, plan
   d'acquisition des données manquantes. Jamais présenté comme une
   prédiction (P6) — transposition directe du cadrage du cas accidents
   (« carte pour prioriser », ADR-0006).

## Consequences

### Positive

- De la valeur démontrable **avant toute donnée ingérée** — le meilleur
  cas de démonstration pour des utilisateurs non experts.
- Le catalogue s'enrichit dès l'expression du besoin (fiches pressenties).
- Le critique a un piège domaine identifié à couvrir : confondre « les
  prix ont monté » avec « les prix vont monter » (régression vers la
  moyenne).

### Negative / costs accepted

- Le scoutisme **outillé** (recherche effective de sources en session)
  exige des accès externes à cadrer — reporté en v2 (Q-0011). Dès la v1,
  seul le scoutisme « de tête » (connaissances universelles du LLM)
  fonctionne, sans garantie de fraîcheur sur l'état réel des portails.
- Une fiche pressentie erronée (source surestimée) coûte du temps ; d'où
  l'obligation d'honnêteté du curateur sur l'accessibilité réelle.

## Alternatives considered

- **Statu quo (« dataset introuvable »)** — Rejeté : casse le scénario
  non-expert et ampute la boucle de découverte de sa phase la plus
  démonstrative.
- **Agent « scout » dédié** — Rejeté : le curateur a déjà le profil
  (évaluation de sources, interview, catalogue) ; un rôle de plus dilue la
  charte et nourrit le risque cathédrale.

## Supersedes

None.

## References

- Journal : [`../journal/2026-07-27-plus-value-et-depart-a-froid.md`](../journal/2026-07-27-plus-value-et-depart-a-froid.md)
- Vision : `<IMPL:src>/docs/architecture/overview.md` §4.3, §5, §6, §12, §13 (cible v0.3, à porter après validation)
- Question ouverte : Q-0011 ([`../OPEN-QUESTIONS.md`](../OPEN-QUESTIONS.md))
- ADR liée : [`0006-couche-ml-deterministe.md`](0006-couche-ml-deterministe.md) (même cadrage anti-survente)
