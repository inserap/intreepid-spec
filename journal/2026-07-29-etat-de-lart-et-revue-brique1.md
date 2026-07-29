# Journal — État de l'art GitHub (réanalyse multi-agent) + revue spec↔code brique #1

- Date : 2026-07-29
- Participants : Alex ; Claude
- Nature : session de **veille + revue croisée** (aucune implémentation)
- Produits : `research/2026-07-29-etat-de-lart-github.md` (déplacé depuis `src`, réécrit) ;
  raffinements OPEN-QUESTIONS (Q-0004, Q-0008, Q-0009, Q-0011) + **Q-0014** (nouvelle) ; ce journal.

---

## 1. État de l'art GitHub — déplacement + réanalyse ancrée sur la vision

- Le document de veille avait été créé **à tort dans `src/docs/research/`** (le livrable) — même
  erreur de cible que le 2026-07-27. Déplacé en **`spec/research/`** (process artifact ; consommateur =
  la session). La copie de `src` est retirée du working tree.
- Deux défauts de la 1re version : (a) mauvais emplacement ; (b) **mauvais référentiel** — l'analyse
  semblait ancrée sur l'état de la brique #1 (un seul outil MCP + un agent), ce qui sous-pondère
  mécaniquement les briques futures (arbre/carte, mémoire, critique/candide, modèles nuls, scoutisme).
- Réanalyse : **8 agents de recherche parallèles**, un par capacité de la vision (overview v0.2), avec
  pour référentiel la **vision complète**. Chaque repo **vérifié existant via `gh api`** (aucune
  hallucination) ; jugement **sur les idées et l'implémentation, pas les étoiles**.
- **Corrections factuelles** : H3-en-MCP existe (`overnin/h3-mcp`, `iamvibhorsingh/bbox-mcp-server`,
  `geo-perception`, `openassistant`) ; le MAUP est déjà outillé (`pysal/esda` → `smaup.py`) ; le
  read-only DuckDB spatial en MCP est déjà formalisé par un tiers (`afterrealism/duckdb-spatial-docsbox-mcp`
  = littéralement la brique #1). Corollaire test de plus-value : cette couche est reproductible par
  n'importe qui → le « vrai plus » vit **au-dessus** (greffier, capitalisation, critique/candide).
- **Trous blancs confirmés (= plus-value défendable)** : `profile_stats` comme proxy exclusif ; couplage
  arbre↔carte + zones blanches ; ML classique générique en outils MCP ; multi-user sérialisé par
  l'agent ; test anti-MAUP multi-résolution H3 automatisé.
- **Nouveaux repos-clés** : `Canner/WrenAI` (catalogue gouverné, dry-plan), `sanonone/kektordb`
  (invalidation sans perte — miroir mémoire), `ishandhanani/forky` (DAG SQLite + merge 3-voies),
  `modelcontextprotocol/ext-apps` (MCP Apps, spec officielle 01.2026), `LGDiMaggio/predictive-maintenance-mcp`
  (seul patron concret de ML-as-MCP), le trio rigueur `dowhy`/`esda`/`spacv`, `kevics1/geo-perception`
  (split Skills÷MCP), `malkreide/swisstopo-mcp` (clé BFS = jointure sémantique).

## 2. Revue spec↔code de la brique #1 (analyse externe **vérifiée contre le code**)

Une analyse externe (autre LLM) a été fournie. Discipline « vérifier, ne pas inventer » appliquée :
chaque affirmation a été **contrôlée contre les fichiers réels** avant d'être retenue.

**Forces confirmées** : P2/P3 en défense-en-profondeur (`bounds.py` `read_only=True` + allowlist de la
fiche dans `profile_stats` + `disallowed_tools` dans `runner.py`) ; P6 **testé** (`Literal["fait",
"hypothèse", "refusé"]` pydantic dans `verdict.py`) ; traçabilité spec→code (commentaires `P2/P3`,
`Q-0010`, `Q-0013`).

**Gaps vérifiés** :
- **Gap 1 — types 2/4** : `_DISPATCH = {categorical, numeric}` ; temporel + spatial absents alors que
  l'overview §4.2 en liste 4. Différé brique #2 (connu).
- **Gap 5 (NEUF) — skewness manquant** : `_numeric` calcule min/max/moyenne/médiane/quantiles/écart-type/
  zéros/outliers mais **pas la skewness**, que §4.2 liste explicitement. DuckDB expose `skewness()`
  (une ligne). Non tracé auparavant → à corriger.
- **Gap 2 — catalog mono-dataset** : `list_datasets → [fiche["dataset"]]` ; verrou multi-dataset (lié à
  la progression brique #2 et à Q-0002).
- **Gap 3 — fuite de fichiers temporaires** : `bounds.py` `tempfile.mkdtemp()` sans cleanup. **Déjà
  tracé** (execution recap, « Minors différés »).
- **Gap 4 — parsing verdict fragile** : `parse_verdict` prend le **premier** tableau JSON (regex
  non-greedy) → mauvais si l'agent émet un tableau d'exemples *puis* le verdict. **Déjà tracé**.
- **Gap 6 — surajustement charte** : exemples `999` / concentration→hypothèse tunés OFROU. **Déjà Q-0004.**

**Nuance / correction à l'analyse externe** : les types temporel/spatial ne « disparaissent » pas
totalement en silence — un `type` hors `_DISPATCH` lève `ValueError("type de colonne non supporté dans
la brique #1: …")`. Le message signale bien le périmètre brique #1 ; ce qu'il ne distingue pas, c'est
« prévu mais pas encore là » de « jamais ». La décision challengée #3 reste pertinente, mais
« silencieusement » est à nuancer.

**Décisions techniques challengées** (retenues comme dette/décision) :
1. **Verdict** : remplacer la regex par une sortie structurée (JSON mode forcé côté Claude, ou balise
   délimitante) avant que la charte ne gagne en complexité → **Q-0014**.
2. **`bounds.py`** : `TemporaryDirectory` (context manager) + nettoyage, même serveur long-lived.
3. **`profile_stats`** : rendre le différé temporel/spatial **explicite** (NotImplementedError nommé +
   roadmap) plutôt que via un message générique.

## 3. Répercussions OPEN-QUESTIONS

- **Q-0004** : + pointeurs (split Skills÷MCP `geo-perception` = frontière charte↔fiche ; fiche YAML
  `pg-mcp-server` ; clé BFS `swisstopo-mcp`) ; charte overfitting re-confirmée par la revue.
- **Q-0008** : + `SecuringGISAgent` (durcissement de prompts) et `geodados` (MCP Elicitation = parade au
  mode d'échec « résolution silencieuse de l'ambiguïté » mesuré par `geoagenteval`).
- **Q-0009** : + `esda` (`smaup`/permutation), `spacv` (spatial leakage), `statsmodels` (multi-tests,
  BSD vs Pingouin GPL), `dowhy` (refuters → outil MCP `refute_insight`).
- **Q-0011** : + `geodata-atlas` (catalogue curé par agents) + standards Frictionless/Croissant.
- **Q-0014 (NOUVELLE)** : stratégie de sortie structurée de l'agent (verdict).

## 4. Leçons

- Répéter l'erreur de cible (doc dans `src`) confirme le réflexe **« vérifier le repo cible »** : la
  veille/conception vit dans `spec`.
- **Vérifier une analyse externe contre le code avant de la graver** : 4 gaps sur 6 étaient déjà connus,
  1 (skewness) était neuf, 1 affirmation (« silencieusement ») nuancée.
- Le **fan-out multi-agent ancré sur la vision** (pas l'implémentation courante) a produit des
  recoupements que la 1re passe avait ratés (H3-en-MCP, MAUP outillé, forky/kektordb).

## 5. Pointeurs

- Veille : `research/2026-07-29-etat-de-lart-github.md`
- Brique #1 : `slices/2026-07-28-01-brique1-profile-stats-execution.md`
- Vision : `<IMPL:src>/docs/architecture/overview.md` (§4.2 `profile_stats`)
- Journaux liés : `2026-07-28-brique1-walking-skeleton.md`, `2026-07-27-plus-value-et-depart-a-froid.md`

---

## 6. Suite de session — cadrage de la brique #2

- **Décision : enchaîner la brique #2 sans attendre la clôture de Q-0002.** La séance métier
  est à ~10 jours ; on continue d'implémenter pour progresser. **Clarification de la règle dure** :
  elle porte sur les *versions d'architecture* (« pas de v0.3 de l'`overview` avant une session de
  découverte réelle »), **pas** sur l'implémentation de briques de l'architecture v0.2 existante.
  Compléter `profile_stats` reste du walking skeleton v0.2 → légitime. Q-0002 demeure le verrou de
  la **valeur**, pas du **code**. (Correction assumée : j'avais sur-appliqué la règle dure.)
- **Pas de backlog** (choix explicite). Le mécanisme « ne rien perdre » = le prompt de démarrage
  ci-dessous, qui porte lui-même les 3 items + tous les pointeurs.
- **Périmètre pressenti de la brique #2** (le brainstorming tranchera l'ampleur exacte —
  temporel+spatial ensemble ou spatial en brique #3) :
  1. Type **temporel** `_temporal` (bornes, trous de série, saisonnalité, ruptures de volume).
  2. Type **spatial** `_spatial` (emprise, densité/région, plus proche voisin, géométries invalides).
  3. Passagers de dette brique #1 : **skewness** manquant dans `_numeric` ; `bounds.py`
     `mkdtemp` → `TemporaryDirectory`. Les types non couverts → message explicite (pas générique).

### Prompt de démarrage de la brique #2 (à coller dans une nouvelle session)

```text
Brique #2 — compléter `profile_stats` aux 4 types de colonnes (temporel + spatial)
+ solder 2 dettes de la brique #1.

Cadre : je pilote intreepid depuis le spec. On enchaîne sur la brique #2 SANS attendre
Q-0002 (séance métier dans ~10 jours) — c'est légitime : la « règle dure » du projet porte
sur les VERSIONS d'architecture (pas de v0.3 de l'overview avant données réelles), pas sur
l'implémentation de briques de l'architecture v0.2 existante. On reste dans le walking
skeleton v0.2.

1) Initie la session selon CLAUDE.md (rituel de session-start complet) AVANT toute autre chose.

2) Objectif — le profileur ne couvre aujourd'hui que 2/4 des types de l'overview §4.2
   (`categorical`, `numeric`). Cette brique ajoute les 2 manquants et solde 2 dettes :
   - TYPE temporel `_temporal` : bornes, trous de série, saisonnalité grossière, ruptures de
     volume (les changements de collecte doivent se voir).
   - TYPE spatial `_spatial` : emprise (ST_Extent), densité par région, distance au plus proche
     voisin, taux de géométries invalides — via l'extension DuckDB spatial.
   - PASSAGER 1 (dette brique #1) : `skewness` absent dans `_numeric` alors que §4.2 le liste
     (DuckDB expose `skewness()` — une ligne).
   - PASSAGER 2 (dette brique #1) : `mcp_server/bounds.py` — remplacer `tempfile.mkdtemp()` sans
     nettoyage par un `TemporaryDirectory` (context manager), même en serveur long-lived.
   - Corollaire : le `ValueError("… non supporté dans la brique #1")` de `profile_stats.py`
     disparaît pour ces types ; pour tout type restant non couvert, message explicite
     « prévu / non implémenté » (pas un message générique qui masque l'intention).

3) À VÉRIFIER en phase design (ne rien présumer) : `fixtures/accidents_seed.parquet` +
   `accidents.fiche.yaml` contiennent-ils des colonnes de date et de géométrie exploitables ?
   Sinon, étendre la fixture (open data OFROU anonymisé) + la fiche, et planter des anomalies
   temporelles/spatiales pour l'oracle (ex. trou de série, géométrie invalide, code sentinelle).

4) Discipline NON négociable (leçons de la brique #1) :
   - superpowers:brainstorming AVANT tout code — le design tranche le périmètre exact : temporel
     ET spatial ensemble, ou spatial reporté en brique #3 si trop large (walking skeleton : croiser
     minimalement d'abord).
   - writing-plans → au moins une passe advisor jusqu'au verdict SHIP (NE PAS sauter les passes
     advisor — faute commise en brique #1).
   - TDD + subagent-driven-development ; gate qualité vert (ruff / pyright `standard` / pytest)
     avant chaque commit ; `git add` et `git commit` en DEUX étapes ; jamais de tag/push autonome.
   - Étendre l'oracle `tests/test_agent_eval.py` : l'agent doit remonter un fait temporel/spatial
     authentique ET refuser un faux pattern, sans lire de lignes brutes (P2).

5) Contexte durable à relire (pour ne rien perdre) :
   - Revue + décisions actées : journal/2026-07-29-etat-de-lart-et-revue-brique1.md
   - Dette/minors brique #1 : slices/2026-07-28-01-brique1-profile-stats-execution.md
     (sections « Minors différés » + « Follow-ups »)
   - Spec cible : <IMPL:src>/docs/architecture/overview.md §4.2 (tableau des 4 types)
   - Rigueur (Q-0009) + briques réutilisables de la veille research/2026-07-29-etat-de-lart-github.md :
     pysal/esda (emprise/autocorrélation spatiale), overnin/h3-mcp (H3), whylogs / ing-bank/popmon
     (dérive temporelle) — INSPIRATION de sortie seulement ; `profile_stats` reste écrit en SQL
     DuckDB pushdown, pas de dépendance embarquée.
   - Q-0014 (sortie structurée du verdict) : NE PAS traiter ici, SAUF si on touche verdict.py /
     charter.md ; sinon la laisser ouverte.

6) Hors périmètre explicite (briques ultérieures) : multi-dataset (catalog reste mono-dataset),
   croisé à la demande, modèle nul, couche ML, UI.
```
