# 2026-08-04-01-brique-7c-curateur-conversationnel — Execution recap

## Scope

Brique #7c — **curateur conversationnel d'ingestion** : le **2ᵉ profil réel** de
l'orchestrateur générique (ADR-0009, matérialise Q-0021). En conversation REPL
human-in-the-loop, il transforme un dataset **non fiché** en une **fiche
`columns`-complète validée**. Walking-skeleton **en-process** (pas de résilience
crash inter-runs, assumé). Découpage tranché au cadrage (5 décisions) : (1)
en-process ; (2) surface REPL ; (3) charte maïeutique sobre ; (4) bloc `columns`
seul, `exposures` = découverte (hors-scope) ; (5) `fiche_draft` LLM-owned (Python
= transporteur opaque, agnosticité).

Shippé dans `<IMPL:src>` : merge `f834e3c`, release **v0.10.0** (`4f9088a`, tag
`v0.10.0` posé + poussé sur demande explicite d'Alex).

## Shipped artifacts

Dans `<IMPL:src>` (v0.10.0) :
- `agent/orchestrator.py` + `agent/profile.py` (MODIF) — **boucle multi-tours
  en-process** : `Profile` gagne 2 champs **optionnels** (`next_input`,
  `build_prompt`) → défaut one-shot = **non-régression stricte** de l'analyste.
  `run_agent` boucle tant que non-terminal (historique **application-owned**
  ré-injecté ; charte = `system_prompt` byte-stable) ; **un seul `Scribe`** sur
  toute la conversation ; `on_result` à la validation **avant** scellement.
- `agent/curator/` (NEW, package) : `turn.py` (`CuratorTurn` + `parse_curator_turn`,
  dernier bloc JSON fencé gagne, repli tolérant — Q-0014) ; `fiche_writer.py`
  (`write_fiche` YAML + hash SHA-256 idempotent) ; `surface.py` (REPL, I/O
  injectés) ; `charter.md` (charte maïeutique agnostique) ; `profile.py`
  (isolation P2/P3, terminaison = validation humaine, `on_result` écrit la fiche +
  grave `curation_validated` avec le hash, garde anti-traversée du nom).
- `demo_curator.py` (NEW) + `demo/brique-7c-curateur.md` (runbook) — conversation
  réelle sur OFROU brut, **preuve greffier in-process** avant fermeture du tmp.
- Tests : `test_orchestrator.py` (multi-tours) + `test_curator_{turn,fiche_writer,
  surface,profile}.py`. **113 déterministes verts**.

## Deviations from plan (if any)

- **2 affinements de signature** (esprit inchangé) : `Profile` gagne **2** champs
  (pas 3 — terminaison = « `next_input` retourne `None` ») ; charte = `system_prompt`
  (byte-stable). Décidés au plan.
- **Advisor passe 1** : re-fetch `profile_raw` assumé (transcript texte-seul, pas de
  tool_results ré-injectés) — design §4.1 aligné ; ligne de test obfusquée
  corrigée ; parsing durci (try/except).
- **Advisor passe 2** : `reportOptionalCall` (narrowing des callables optionnels),
  E501, I001 — corrigés inline.
- **T4 (choix A d'Alex)** : `999` génériciser en « code sentinelle » (agnosticité
  + validité démo) + assertion `strict_mcp_config`.
- **T5 (Important)** : trace éphémère vs critère de gate → preuve greffier
  in-process (façon `demo_greffier`).
- **Refactor de regroupement** (`ee2129e`) : `curator_profile.py`/`curator_charter.md`
  → `curator/{profile,charter}.md` (préfixe supprimé) — décision Alex (package par
  rôle ; l'analyste suivra en session future).

## Validation

- **Gate déterministe** : 113 passed, ruff + pyright standard 0 erreur — par tâche
  (diff stagé) et sur `main` post-merge.
- **Revues** : par tâche (spec + qualité, Approved) ; **revue finale whole-branch
  (opus) : Ready to merge** — non-régression one-shot, isolation P2/P3, garde
  anti-path-traversal du nom de fiche, `on_result` avant scellement, idempotence,
  tous vérifiés ; aucun MUST.
- **Démo (gate humain)** : curation réelle de l'OFROU **brut** (267 761 lignes, 36
  colonnes). **Fond spectaculaire** — le curateur trouve les vrais pièges seul
  (EPSG:2056, périmètre corporel-seul, `at0`/`at00` disjoints + trap `LIKE`,
  millésime communal **qu'Alex n'avait pas identifié**, booléen piéton sur-ensemble
  d'at8, périmètres vélo/moto larges, sentinelle horaire), fiche validée
  (`curation_validated`, 8 tours humains). **Révélé** : la **naturalité
  conversationnelle** n'est pas active *par défaut* (questions robotiques ; excellent
  seulement après une précision live de l'humain) → décision Alex : merger le
  skeleton prouvé, qualité conversationnelle en **slice dédiée** (Q-0022, matériel
  capturé). Deux tentatives de charte (naturelle) **abandonnées** avant merge — non
  shippées.

## Follow-ups

- **Q-0022** — slice conversationnelle dédiée (fine-tune sur le transcript +
  fiche réels : `research/2026-08-04-curateur-gate-humain-materiel.md`).
- Résilience crash inter-runs (couche B2 `open/append/seal`) — ADR-0009 §4a.
- Bloc `exposures` = **brique découverte dédiée** — Q-0016/Q-0004, mode découverte
  §4.3.
- Rendu agnostique des renderers (`render.py`/`notebook.py` dispatchent sur
  `kind=="observation"`).
- `Profile.__post_init__` valider co-présence `next_input`+`build_prompt` (au 3ᵉ
  profil).
- Promotion de l'analyste en `agent/analyst/` (symétrie du package par rôle).
- ADR-0009 `Proposed` → `Accepted` (à froid, quand Q-0017 se règle).

## Temps

- **Engagé** : ≈ **3h+** sur les sessions du 03-04/08 (activity.log : 2h14 + 1h04,
  hors tour de session-end) — brainstorm + design + plan + 2 passes advisor + exec
  subagent-driven (5 tâches + refactor) + gate humain.
- **Span git #7c** : `86640d7` (03/08 22:21) → `4f9088a` (04/08 07:28) ≈ **9h**,
  gonflé par les advisors en arrière-plan (dont l'opus final) + la nuit.

## Pointers

- Journal : `journal/2026-08-04-brique7c-curateur-conversationnel.md`
- Matériel slice : `research/2026-08-04-curateur-gate-humain-materiel.md` +
  `research/RoadTrafficAccidentLocations.fiche.example.yaml`
- ADR : `decisions/0009-architecture-execution-agents.md` (Proposed)
- Livraison : `<IMPL:src>` merge `f834e3c`, release `4f9088a`, tag `v0.10.0`,
  `src/CHANGELOG.md [0.10.0]`
- OPEN-QUESTIONS : Q-0022 (ajout) ; Q-0021 / Q-0004 / Q-0016 / Q-0015 / Q-0019 /
  Q-0017 / Q-0013 (raffinées)
