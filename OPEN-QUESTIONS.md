# Questions ouvertes — spec

> Liste vivante des items non résolus ou différés pour le projet `intreepid`. Les questions touchant la doctrine partagée (`standards/`) sont résolues ici, même si elles produisent un commit doctrinal côté standards.
> Mise à jour pendant les rituels session-end (bins c. additions, d. résolutions).
> Les IDs `Q-NNNN` sont **immuables** : ne jamais réutiliser un Q-NNNN même après résolution.

## Comment utiliser ce fichier

- **Ajouter** un item quand une session fait émerger une vraie ambiguïté non résolvable en séance.
- **Résoudre** un item quand une session livre une réponse (ADR, entrée journal, slice execution).
- **Raffiner** un item quand sa formulation évolue.

## Ouvertes

| ID | Question | Apparue | Catégorie | Notes |
|---|---|---|---|---|
| Q-0001 | Nom définitif du projet ? | 2026-07-26 | Produit / naming | Nom de code actuel : `intreepid`. Candidats pressentis : *Semantree*, *Semantrek*. Anciens candidats (Ramure, Sylva, Dendrite, Arolle) abandonnés. Critère : raconter l'arbre *et* l'enracinement territorial/sémantique. |
| Q-0002 | Dataset pilote et question métier réelle pour la v1 ? | 2026-07-26 | Produit / périmètre | Cas accidents (OFROU, open data, couches geo.admin.ch) pressenti mais non confirmé ; aucun destinataire métier identifié à ce jour. |
| Q-0003 | Granularité des nœuds de l'arbre : quels critères pour que le greffier décide ce qui mérite un nœud ? | 2026-07-26 | Technique | Pari technique central du projet. À calibrer sur sessions réelles, pas sur le papier. |
| Q-0004 | Schéma du catalogue sémantique et modèle de données de l'arbre/trace (avec attribution et empreintes spatiales) ? | 2026-07-26 | Architecture | Prochaine étape n°3 de l'architecture — conditionne tout le reste. |
| Q-0005 | Réutilisation concrète du substrat Henry : les Plans/Traits sont-ils repris tels quels, adaptés, ou seulement comme inspiration de format ? | 2026-07-26 | Architecture | ADR-0005 pose l'absorption dans le principe ; le degré reste à trancher au moment du squelette. |
| Q-0006 | Empreintes spatiales floues : seuils de la représentation dégradée (emprise exacte → communes → canton) ? | 2026-07-26 | Technique | À trancher lors de l'implémentation du couplage arbre-carte (v2). |
| Q-0007 | Observabilité technique : le logging DuckDB maison suffit-il, ou Langfuse (auto-hébergé) en v2 ? | 2026-07-26 | Technique | Décision différée — une ligne de risque, pas une couche. |
| Q-0008 | Injection de prompt via colonnes textuelles des données : quelles données du périmètre contiennent du texte tiers, et quel traitement ? | 2026-07-26 | Sécurité | Risque identifié lors de la revue écosystème ; à qualifier avec le dataset pilote. |

## Résolues

| ID | Question | Résolue | Pointeur de résolution |
|---|---|---|---|
| _aucune pour l'instant_ | | | |

## Différées

| ID | Question | Apparue | Raison / cible |
|---|---|---|---|
| _aucune pour l'instant_ | | | |
