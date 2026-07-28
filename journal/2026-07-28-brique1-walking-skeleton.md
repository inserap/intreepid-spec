# Journal — Brique #1 : walking skeleton + adoption du gate qualité

- Date : 2026-07-28 (session longue, démarrée en soirée du 2026-07-27)
- Participants : Alex ; Claude (exécution subagent-driven explicitement mandatée)
- Nature : **première implémentation réelle** du projet + adoption de la doctrine qualité
- Produits : brique #1 shippée et mergée dans `src` (commit de merge `fb86047`) ;
  ADR-0008 ; gate qualité `standards@0.7.0` adopté ; ce journal + execution recap.

---

## 1. Nettoyage git préalable

Deux erreurs d'une session mobile corrigées : (a) `src` avait reçu par erreur une
vision v0.3 (mergée mais non revertée sur `origin/main`) — `origin/main` réécrit
sur l'état propre `9ac2a9e`, branche de PR supprimée ; (b) `spec` avait divergé
(origine portait la propagation ADR-0007 du mobile, local portait topology +
revue-cadrage non pushés) — réconcilié par cherry-pick, avec **résolution d'une
collision d'ID** : deux Q-0009 distincts créés en parallèle → le scoutisme
renuméroté **Q-0011**, la rigueur statistique gardant Q-0009.

## 2. Cadrage de la brique #1 (brainstorming)

Choix de la brique la plus haute-valeur **et** générique : *un agent qui, via
`profile_stats` borné (MCP read-only) sur du vrai OFROU + anomalies plantées,
remonte un fait et refuse un faux pattern, sans lire de lignes brutes, sans UI*.
Décisions verrouillées une à une : substrat = réel + planté ; surface = `profile_stats`
mono-colonne seul ; « refuser » = honnêteté disciplinée (P6), pas de modèle-nul ;
oracle = verdict structuré + assertions ; archi = stack vision minimale (FastMCP +
Claude Agent SDK) ; mono-repo `src` ; pas de FME. Le **croisé à la demande** est
reconnu nécessaire mais différé (roadmap : arrive avec/juste avant le modèle-nul,
jamais seul). Invariant « test de visibilité de la plus-value » gravé dans CLAUDE.md.

## 3. Plan + advisor passes

Plan TDD en 9 tâches (0→8). **Faute de process reconnue** : j'avais d'abord sauté
les passes advisor (la doctrine les rend obligatoires). Corrigé : 2 passes fraîches
→ 1re NEEDS_CHANGES (le read-only par `disabled_filesystems` était bidon — testé
empiriquement par l'advisor sur DuckDB 1.5.5 ; fix = base fichier `read_only=True`,
vue créée avant réouverture) → 2e SHIP. Données OFROU réelles téléchargées et
converties en Parquet (`data/`, gitignoré) pour dé-risquer le schéma du plan.

## 4. Exécution subagent-driven + ship

Un sous-agent implémenteur frais par tâche + revue (spec + qualité) après chacune +
revue finale de branche. Points marquants : commits parfois refusés côté sous-agent
(permissions) → finalisés par le coordinateur ; décision de committer la fixture
Parquet (~9 KB, open data anonymisé, fixture de test hermétique) après challenge
d'Alex. Oracle N=5 : **sentinelle 999 en `fait` ≥4/5**, **concentration `type_route`
≥4/5**, **faux pattern gravité×mois 0/5 en `fait`** (tolérance zéro tenue). La
concentration échouait d'abord (2/5) → **itération de la charte** (profilage
systématique de toutes les colonnes), pas des seuils. Brique mergée dans `main`.

## 5. La saga de l'isolation des outils (P2/P3)

Le différenciateur central — l'agent n'atteint la donnée QUE par MCP — a demandé
trois tours : (a) `allowed_tools` n'exclut pas les built-ins ; (b) `tools=[]` a été
adopté sur lecture de source du SDK… puis mon **smoke a montré qu'il vide AUSSI les
outils MCP** (agent sans outil) ; (c) retour à `disallowed_tools` (+ `Skill`) +
`strict_mcp_config=True` + `setting_sources=[]` + `skills=[]`, vérifié par smoke.
Leçon nette : **l'empirique prime sur la lecture de source** pour le comportement
d'API d'une lib.

## 6. Gate qualité + ADR-0008

Adoption de `standards@0.7.0` (`code-quality.md`) : ruff (format + lint E,F,I,UP,B,D
avec en-têtes de module) + pyright + pytest. `pyright strict` = 148 erreurs, ~126 de
**frontière** (libs maison sans stubs). Sur la bonne intuition d'Alex (« mets le mode
en *standard*, pas *basic* »), passage à `typeCheckingMode="standard"` : il ne restait
que **17 vraies erreurs** (`.fetchone()` non gardés, un `dict[str, any]` builtin au
lieu de `Any`), toutes corrigées — `basic` les aurait ratées. Déviation d'un cran,
tracée par **ADR-0008** + override déclaré dans CLAUDE.md, avec ratchet vers `strict`.
En-têtes de module rédigés en français (choix d'Alex).

## 7. Leçons

- **Advisor passes = non négociable** ; je les avais oubliées.
- **Empirique > lecture de source** pour le comportement des libs.
- **`standard` avant `basic`** : la déviation minimale qui garde du mordant.
- **uv, jamais pip** (enregistré en mémoire ; candidat promotion doctrine).
- Le walking skeleton est **montrable** (`uv run python -m intreepid.demo`) — pile la
  règle anti-cathédrale : imparfait et montré plutôt que complet et jamais fini.

## 8. État en fin de session

- `src` : brique #1 mergée sur `main` (`fb86047`), gate vert, version à passer 0.1.0.
- `spec` : ADR-0008 + override commités ; ce journal + execution recap.
- **Q-0002 reste LE verrou** : la brique a été construite en *mode répétition*
  (données réelles + persona métier simulé) ; elle valide la *mécanique*, pas encore
  la *valeur* — à mettre tôt devant une vraie personne métier.
- Prochaine étape de plus fort rendement : montrer la brique + fermer Q-0002.
