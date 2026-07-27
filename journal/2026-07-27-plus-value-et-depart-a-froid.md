# 2026-07-27 — plus-value-et-depart-a-froid

## Context

Session Claude Code. Deux questions d'Alex : (1) la solution apporte-t-elle
une **vraie plus-value**, ou n'est-ce qu'un pilotage par LLM de
fonctionnalités connues ? (2) le LLM peut-il, par ses connaissances
universelles et par approximations successives, amener un utilisateur non
expert d'une question floue **sans aucune donnée** (« un terrain à bâtir
dont la situation laisse présager une forte progression de valeur »)
jusqu'à un résultat qu'il n'aurait jamais atteint seul — ou au moins un
demi-résultat qui l'oriente ?

## What was decided / shipped

- **Analyse plus-value** : frontière nette posée entre la partie
  commoditisée (la boucle chat → SQL → viz — Databricks Genie, Snowflake
  Cortex, ou un simple client LLM générique + serveur MCP DuckDB la
  fournissent) et les capacités propres au projet : greffier/trace
  (hypothèses abandonnées *et leurs raisons*), capitalisation P5/P9,
  `profile_stats` + regard des connaissances universelles, structure
  adversariale (critique, candide, modèles nuls). La plus-value est réelle
  mais elle vit dans la trace, la mémoire et la rigueur — pas dans la
  boucle de requêtage.
- **Test de visibilité de la plus-value (v1)** adopté comme règle de
  périmètre (pendant de la règle d'admission) : chaque livrable v1 doit
  répondre à *« qu'est-ce qu'un client LLM générique branché sur un MCP
  DuckDB n'obtiendrait pas ? »*. Risque associé ajouté : « plus-value
  invisible en v1 » (perçu comme un chatbot de plus).
- **ADR-0007 (Proposed)** : scoutisme de données (extension du mandat du
  curateur) + « départ à froid » comme scénario de référence de la boucle
  de découverte + le **demi-résultat honnête** (grille de scoring
  multicritère spatialisée, incertitude affichée, carte des angles morts,
  plan d'acquisition) comme livrable de première classe — jamais une
  prédiction (P6).
- **Modifications v0.3 de la vision** (`<IMPL:src>/docs/architecture/overview.md`)
  rédigées en session, **à porter dans src après validation** (voir note
  process ci-dessous) :
  - §4.3 : le curateur opère à *trois* moments — nouveau volet « en amont
    de l'amont » (scoutisme, fiches *pressenties* au catalogue, ingestion
    restant FME + validation humaine, P3/P8) ;
  - §5 : scénario de référence « départ à froid », trois approximations
    successives (structurer l'espace des facteurs par connaissances
    universelles → trier le faisable par scoutisme → livrer le
    demi-résultat honnête) ;
  - §6 : charte du curateur étendue (mandat, interdits, honnêteté sur
    l'accessibilité réelle des sources pressenties) ;
  - §12 : test de visibilité de la plus-value + « scoutisme outillé » en
    v2 (item 7) ;
  - §13 : risque « plus-value invisible en v1 » + mitigation ;
  - glossaire src : *scoutisme de données*, *départ à froid*,
    *demi-résultat*.

**Note process** : ces modifications avaient d'abord été commitées
directement dans src (branche `claude/llm-value-capabilities-4r4ch1`) —
erreur de cible. Le commit a été retiré (branche remise sur `main`) ; le
spec pilote, src reçoit par promotion.

## Open questions evolved

- **Ajout Q-0011** : outillage du scoutisme de données — quel accès aux
  portails externes depuis une session, sous quelles contraintes, et quel
  format pour les fiches « pressenties » ?

## Lessons learned (validated patterns)

- **Vérifier le repo cible en début de session** : une session lancée sur
  src a commité de la conception directement dans le livrable. Le travail
  de conception se fait ici, dans le spec.
- Le scénario « départ à froid » est probablement le **meilleur cas de
  démonstration** de la valeur LLM face à un non-expert : il produit de la
  valeur avant toute donnée ingérée. À articuler avec le choix du pilote
  (Q-0002).
- La règle dure de la fondation (« pas de v0.4 avant une première session
  réelle ») est respectée : la cible est une v0.3, additive et bornée.

## Pointers

- ADR : [`../decisions/0007-scoutisme-de-donnees-et-demi-resultat.md`](../decisions/0007-scoutisme-de-donnees-et-demi-resultat.md)
- Journal lié : [`2026-07-26-session-fondation.md`](2026-07-26-session-fondation.md) (§3 exigence anti-WOW, §11 règle « pas de v0.4 »)
