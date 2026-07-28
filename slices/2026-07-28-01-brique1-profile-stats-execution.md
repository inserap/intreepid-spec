# 2026-07-28-01-brique1-profile-stats — Execution recap

## Scope

Première brique livrable d'`intreepid` (walking skeleton, sans UI) : un agent LLM
(Claude Agent SDK, isolé aux seuls outils MCP) qui, via un serveur FastMCP read-only
exposant `profile_stats` (statistiques mono-colonne) sur un sous-ensemble réel des
accidents OFROU **avec anomalies plantées**, rend un verdict structuré — remonte un
fait authentique (sentinelle `999`), refuse un faux pattern (gravité×mois) sans lire
de lignes brutes (P2/P3). Vérifié par des tests à deux étages (golden déterministe +
éval agent N=5). Shippé dans `<IMPL:src>`, mergé sur `main` (`fb86047`).

## Shipped artifacts

Dans `<IMPL:src>` (package `intreepid`) :
- `mcp_server/` : `server.py` (FastMCP, 3 outils), `profile_stats.py` (numérique +
  catégoriel, typage piloté par la fiche), `catalog.py` (`describe`/`list_datasets`),
  `bounds.py` (connexion DuckDB fichier `read_only=True`).
- `agent/` : `runner.py` (`run_analysis`, isolation P2/P3 via `disallowed_tools` +
  `strict_mcp_config`/`setting_sources`/`skills`), `charter.md` (charte d'honnêteté,
  profilage systématique), `verdict.py` (schéma pydantic + parseur tolérant).
- `fixtures/` : `build_fixture.py`, `accidents_seed.parquet` (~9 KB, committé),
  `ground_truth.yaml`, `accidents.fiche.yaml`.
- `tests/` : golden `profile_stats`/`bounds`/`server`/`fixture`/`verdict`, garde-test
  P2/P3 `test_runner_options.py`, éval `test_agent_eval.py` (`@pytest.mark.agent`).
- `demo.py` (montrable CLI), `pyproject.toml` (gate qualité), `data/` (source OFROU,
  gitignorée).

## Deviations from plan (if any)

- **Read-only (MUST advisor)** : `disabled_filesystems` ne bloquait pas les écritures
  → base fichier `.duckdb` rouverte `read_only=True`, vue créée avant réouverture.
- **Isolation des outils** : `tools=[]` (adopté sur lecture de source) vide aussi les
  outils MCP (constaté par smoke) → `disallowed_tools` + `strict_mcp_config=True` +
  `setting_sources=[]` + `skills=[]`, vérifié empiriquement.
- **Charte** : profilage systématique de *toutes* les colonnes ajouté (concentration
  `type_route` remontait 2/5 → ≥4/5).
- **Gate qualité** : adopté en cours de finalisation ; déviation `pyright standard`
  (ADR-0008) au lieu de `strict`.

## Validation

- **Tests :** 18 déterministes verts (`uv run pytest -m "not agent"`) ; éval agent
  `1 passed in ~229s` — sentinelle 999 ≥4/5 `fait`, concentration ≥4/5 `hypothèse`,
  faux pattern **0/5** `fait`.
- **Gate qualité :** `ruff format` + `ruff check` verts ; `pyright standard` 0 erreur.
- **Reviews :** revue par tâche (spec + qualité) sur chaque tâche ; 2 passes advisor
  sur le plan (NEEDS_CHANGES → SHIP) ; revue finale de branche « With fixes » →
  Important P2/P3 corrigé (isolation réelle des outils) + guard-test ajouté.

## Follow-ups

- **Q-0012** (nouvelle) : ratchet vers `pyright strict` via wrappers typés autour de
  la stack maison, puis ADR qui `Supersedes` ADR-0008.
- **Q-0002** (inchangée, LE verrou) : brique construite en mode répétition (persona
  métier simulé) → valide la mécanique, pas la valeur ; à montrer tôt à une vraie
  personne métier.
- **Minors différés** (triage revue finale) : `mkdtemp` non nettoyés (`bounds.py`) ;
  `FIXTURES` via `parent.parent.parent` (`server.py`) ; regex `parse_verdict` fragile
  sur accolades échappées ; `disallowed_tools` = denylist (fragile si nouveaux
  built-ins SDK) ; clé `n` hors contrat dans `profile_stats`.
- **`src/CHANGELOG.md`** : à alimenter (entrée `[0.1.0]` : brique #1 + gate qualité).

## Pointers

- Journal : `journal/2026-07-28-brique1-walking-skeleton.md`
- ADR touchée : `decisions/0008-code-quality-deviation-pyright-standard.md` (Proposed)
- Merge de livraison : `<IMPL:src>` commit `fb86047` (main)
- CHANGELOG : `<IMPL:src>/CHANGELOG.md` section `[0.1.0]` (à écrire)
