# Journal — Revue de conformité et cadrage v1

- Date : 2026-07-26 (2e session du jour ; la 1re = fondation)
- Participants : Alex ; Claude (revue critique explicitement mandatée)
- Nature : revue + cadrage + approfondissements fondateurs. **Aucun code.**
- Produits : topologie corrigée (commité) ; OPEN-QUESTIONS enrichi (Q-0004/0008/0009/0010) ; ce journal.

---

## 1. Revue de conformité `src` / `spec` vs `standards`

Revue déclenchée par deux questions d'Alex : `src`/`spec` respectent-ils les
standards, et pourquoi `spec` n'a pas de README.

- **Structure** : `src` = template impl au caractère près (zéro placeholder
  résiduel, git initialisé) ; `spec` = template spec (6 ADRs `Proposed`,
  journal, OPEN-QUESTIONS, slices). Conforme.
- **README spec** : son absence est **conforme et voulue** — le template
  `templates/spec/` n'en contient pas, `RULES.md:12` ne l'exige pas (contraste
  avec l'impl, `RULES.md:13`), et la logique « consommateur externe » le
  justifie (le spec a un seul consommateur : la session Claude ; sa porte
  d'entrée est `CLAUDE.md`).
- **Écart de date** relevé : `overview.md` date la fondation du 2026-07-25,
  le reste du 2026-07-26 (à aligner, non corrigé cette session).
- **Deux trous doctrinaux dans `standards/`** (candidats bin h, différés à une
  session `methods/spec` dédiée — inscrits ici pour mémoire) :
  1. `RULES.md:13` exige `LICENSE` comme fichier racine impl, mais
     `templates/impl/` n'en fournit aucun (et `src` n'en a pas).
  2. `RULES.md:12` liste `BACKLOG` parmi les artefacts spec, absent de
     `templates/spec/`.

## 2. Triage de deux reviews externes

- **Grille NotebookLM** (« Reality Check v0.2 ») : #1 (fusionner les repos)
  écarté — mauvaise variable, contredit ADR-0002 ; #2 (critique peut halluciner
  → coupler au déterministe) déjà dans le design, à rendre explicite ;
  #3 (illusion du coût zéro du greffier) meilleur point, bon diagnostic (Q-0003)
  mais remède « JSON strict » à jeter. Méta : la grille pousse à re-concevoir
  avant d'implémenter — mini-piège cathédrale.
- **Review LLM externe** : moitié technique excellente (découpage walking
  skeleton MCP sans UI ; durcissement MCP read-only ; type `untrusted_data` ;
  empreinte de reproductibilité ; invariants géospatiaux ; stats spatiales),
  distillée dans Q-0004/0008/0009. Moitié gouvernance = **contresens de
  catégorie** : elle lit le `spec` comme un repo produit public contributeur-
  facing ; sous ADR-0002 c'est un process artifact à consommateur unique. Le
  correctif de fond `LICENSE` (dépôt public) corrobore le trou n°1.

## 3. Repos privés + drift topologie

Les deux reviews présupposaient des repos publics : vérifié, les deux **sont**
sur GitHub (`inserap/intreepid-spec`, `intreepid-src`). Or
`repository-topology.md` disait « no remote — local only » → drift réel.
Décision d'Alex : **repos privés par défaut** ; la publication n'était qu'une
fenêtre temporaire pour donner accès à des LLM externes (d'où les reviews).
Topologie corrigée + note privée, commit dédié `chore(topology): record private
github remotes` (`5d91ff5`).

## 4. Auth des agents et compte enterprise (recherche sourcée)

Question d'Alex : les agents d'intreepid peuvent-ils consommer son quota
d'abonnement enterprise au lieu d'une API facturée au token ? Recherche sur doc
officielle (déblocage : la session était en **Plan Mode**, qui bloquait
WebFetch — pas un réglage persistant). Constat cité :

> « Unless previously approved, Anthropic does not allow third party developers
> to offer claude.ai login or rate limits for their products, including agents
> built on the Claude Agent SDK. Please use the API key authentication methods… »

- **Agent SDK** : s'authentifie par `ANTHROPIC_API_KEY` (ou cloud provider),
  pas par abonnement. Techniquement le binaire embarqué *peut* prendre un
  `CLAUDE_CODE_OAUTH_TOKEN`, mais **interdit pour un produit tiers sauf accord**.
- **Produit déployé** = Commercial Terms of Service.
- **Dev / prototypage local par l'auteur = usage interactif permis** → la phase
  squelette peut tourner sur le compte perso.
- **Ouvert** (Q-0010) : négocier l'exception « previously approved » + tarif
  API produit avec l'account team enterprise.

## 5. Cadrage v1 (sprints de 3 semaines)

Principe : **risk-first = anti-cathédrale** — ordonner par risque décroissant,
chaque sprint = 1 démo montrable = 1 hypothèse validée/tuée. Prérequis dur :
fermer Q-0002 (dataset pilote **et** destinataire métier réel). Séquence
esquissée : (1) test du signal (`profile_stats` + 1 agent, sans UI) ;
(2) boucle de preuve (query_sql borné + repro + Quarto) ; (3) rigueur (critique +
modèles nuls) ; (4) capitalisation (greffier, calibrage Q-0003 sur session
réelle). v1 « réussie » = passage des trois lentilles (problème aigu, fiabilité,
capitalisation) sur données réelles. Stratégie de test à **deux étages** :
déterministe (golden en CI) + comportement LLM (évals), pivot = **fixture à
vérités plantées**. Non promu en working-pattern (rien d'exécuté).

## 6. Approfondissements fondateurs (clarifications importantes)

- **Couche ML ≠ moteur d'apprentissage.** Confusion levée : le ML (C3bis) est un
  **calculateur déterministe versionné**, il n'apprend pas « par l'usage » ; il
  ne s'améliore que par ré-entraînement explicite. Le vrai moteur
  d'amélioration par l'usage est **P9 / la couche connaissance** (catalogue,
  graphe, biographie, playbook). Lien : la connaissance améliore les *entrées*
  du ML à chaque ré-entraînement. ML reste **v2**.
- **Profiling ≠ ML ≠ curation.** `profile_stats` = statistiques **descriptives**
  (SQL DuckDB), pas du ML. La curation est le travail du **curateur (LLM)** +
  humain (MR), pas du ML. Trois moteurs distincts à ne pas confondre.
- **Requêtes inventées par le LLM** = `query_sql` (borné) + primitives spatiales
  + mode croisé de `profile_stats`. « Connaître sans lire les lignes » =
  maîtriser la **forme statistique** via agrégations (DuckDB scanne les
  milliards, le LLM lit le résumé). `sample` pour valeurs rares (borné,
  `untrusted_data`). Recettes ad hoc éprouvées → capitalisées au **playbook**.
- **Biographie = confluent cross-analyse** (raffinement Q-0004). Distinction
  clé : *fait intrinsèque à la donnée* (vrai quelle que soit la question → fiche,
  partagé entre analyses sans lien) vs *insight sur le monde* (par-analyse →
  graphe). Promotion filtrée curateur→MR, provenance obligatoire (P4), garde
  anti-gonflement (cousin Q-0003). Sérendipité : ouvre une branche ; reste
  hypothèse jusqu'à survie au critique/modèle nul avant promotion.

## 7. État en fin de session

- Aucune implémentation (cohérent avec la règle dure : pas de v0.3 d'archi avant
  session réelle sur données réelles).
- OPEN-QUESTIONS : Q-0009 et Q-0010 ajoutées ; Q-0004 et Q-0008 raffinées.
- Q-0004 devient dense (5 raffinements) — candidate à éclatement quand on
  l'attaquera, pas maintenant (structure prématurée).
- Prochaine étape de plus fort rendement : **fermer Q-0002** (pilote +
  destinataire), condition du walking skeleton.

## Parking de session

- `De-Algiz-a-intreepid.pptx` non suivi à la racine — à committer ou sortir.
- LICENSE / BACKLOG : trous doctrine `standards/` à traiter en session
  `methods/spec`.
- Écart de date `overview.md` (2026-07-25 vs 26) à aligner.
