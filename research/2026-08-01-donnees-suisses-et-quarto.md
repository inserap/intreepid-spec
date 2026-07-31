# Veille — Enrichissement données suisses (accidents) + génération programmatique de Quarto

- Date : 2026-08-01
- Contexte : cadrage brique #5 (analyste sur OFROU réel + notebook). Deux questions confiées à des
  agents de recherche web : (1) quelles données publiques suisses enrichiraient l'analyse
  accidents, à quel **coût d'intégration** ? (2) comment générer programmatiquement un `.qmd`
  Quarto depuis une **trace de session figée** ?
- Statut : référence durable (dépasse la brique #5 — utile pour paliers B/C et enrichissements futurs).

---

## 1. Faisabilité — enrichissement du dataset OFROU accidents (LV95 / EPSG:2056)

Constat transversal : le dénominateur d'exposition idéal (**trafic TJM national**) n'est **pas**
une couche continue par tronçon en open data — c'est de la donnée par station (~500 points +
XLSX). C'est le maillon faible.

| # | Source | Portail / accès | SRID | Difficulté jointure | Valeur |
|---|--------|-----------------|------|---------------------|--------|
| 1 | Trafic TJM/DTV (ASTRA `ch.astra.strassenverkehrszaehlung-uebergeordnet`) | opendata.swiss · WMS + XLSX + REST ; ~500 stations | 2056 | **Élevée** | Élevée en principe mais **couverture partielle** |
| 2 | Réseau routier swissTLM3D (`ch.swisstopo.swisstlm3d-strassen`) | opendata.swiss · GeoPackage/Shapefile | 2056 | Moyenne | Élevée (rattachement accident↔tronçon) |
| 3a | Vitesses signalisées **national** | Fragmenté ; couche continue nationale **inexistante** (seul Zürich-Ville complet) | 2056 | Élevée | Moyenne, non couvrant |
| 3b | **SITG Genève** — vitesses/signalisation (`OTC_LIMITATIONS_VITESSE`, `otc-sv-signal`, zones modération) | sitg.ge.ch · WFS/WMS ArcGIS natif LV95 | 2056 | Faible→Moyenne | **Élevée sur GE** |
| 4 | Écoles (`ch.bfs.schulstandorte` OFS ; SITG pour GE) | geo.admin.ch REST + download | 2056 | Faible (points→points, buffer) | Moyenne |
| 5a | **Population hectare STATPOP/GEOSTAT** (national) | opendata.swiss · **CSV grille hectare** ; licence OPEN-BY-ASK | 2056 | **Faible** (grille régulière) | **Élevée** (normalisation densité) |
| 5b | Population OCSTAT Genève (`OCS_POPULATION_SSECTEUR`) | sitg.ge.ch · WFS/WMS, 394 sous-secteurs | 2056 | Faible (point-in-polygon) | Moyenne→Élevée sur GE |
| 6 | Agrégation **H3** | lib `h3` — **reprojection 2056→4326 requise** | 4326 | Faible | Élevée (maille anti-MAUP) |

### Recommandation (coût/valeur pour une session de découverte, pas un pipeline de prod)
1. **Quick-wins quasi gratuits** : **STATPOP hectare** (jointure directe LV95, CSV) pour
   normaliser par densité, et **maille H3** (reprojection triviale) pour l'agrégation.
2. **Second cercle si focale Genève** : le **SITG** (vitesses, écoles, population sous-secteurs),
   natif LV95, WFS/WMS, faible coût de jointure, forte valeur locale.
3. **À écarter d'une découverte** : le **TJM national** comme dénominateur « propre » (couverture
   ~500 stations) et la **vitesse nationale** (inexistante en couche continue) ; **swissTLM3D**
   utile mais un cran au-dessus (rattachement tronçon).

> **Décision brique #5** (palier A) : exposition = **population par canton** (BFS, petit CSV),
> proxy grossier **assumé et gravé dans la fiche** (≠ trafic). Le trafic réel comme dénominateur
> = travail futur (Q-0016). H3/STATPOP/SITG = paliers B/C.

---

## 2. Génération programmatique de Quarto depuis une trace figée

Un `.qmd` = Pandoc Markdown + front-matter YAML. **Aucune API Python native `quarto.render()`**
(manque reconnu, discussion quarto-cli #7814) → on shell la CLI via `subprocess`.

### Les 4 voies (résultats DÉJÀ connus dans notre cas)
| Voie | Mécanique | Quand |
|------|-----------|-------|
| **(a) Templating texte (jinja2/f-strings → .qmd)** | On écrit md+YAML, résultats figés, puis `quarto render` | **Notre cas** — robuste, zéro dépendance exotique |
| (b) CLI `quarto render` sur cellules exécutables | Quarto **exécute** les cellules | Si (re)calcul au render (engine requis) |
| (c) `nbformat` → `.ipynb` + `quarto convert` | Traduit sans exécuter | Si notebook `.ipynb` livrable en plus |
| (d) `papermill` + quarto | Template paramétré rendu N fois | Rapports paramétrés (pas notre besoin) |

### Cellules SQL/DuckDB
- **Exécutable** `{sql}` + `#| connection:` = **engine knitr (R) uniquement** (issue #4227). Piège :
  quoter le nom de connexion (« No method for S4 class:duckdb_connection »).
- **Notre voie (sans engine)** : bloc **display-only** ` ```{.sql} ` / ` ```{.json} ` (coloration
  Pandoc, **aucune exécution**) + **table markdown** du résultat agrégé figé → 100 % déterministe.
- `execute: freeze: true` cache les résultats dans `_freeze/` mais reste document-level/incrémental
  fragile → le bloc statique est plus simple et sans faille.

### Fonctionnalités utiles
- **Callouts** (fait → `.callout-note`/`important` · hypothèse → `.callout-warning` · refusé →
  `.callout-caution`), avec ID préfixé (`#nte-`, `#wrn-`, `#cau-`) + titre pour cross-ref.
- Front-matter HTML : `toc`, `code-fold`, `embed-resources: true` (HTML autonome partageable),
  `theme`.

### Repos prior art (vérifiés)
- **`NousResearch/hermes-agent`** — `sessions export` écrit Markdown/**Quarto**/HTML depuis les
  traces de session (+ `--redact`). Pattern trace→Quarto exact.
- **`luoyuctl/agenttrace`** — TUI + rapports depuis l'historique de sessions d'agents (Claude Code,
  Codex, JSONL). Les deux **sérialisent une trace figée**, ne recalculent pas.
- Contexte : Pimentel MSR 2019 / Rule CHI 2018 — **4 % des notebooks reproductibles, 27,6 % sans
  texte** → la discipline de capture (greffier) EST la valeur.

### Verdict (appliqué au design brique #5)
**Templating texte Python → `.qmd` markdown pur → `quarto render` HTML, résultats FIGÉS, aucun
engine.** Réintroduire un engine pour recalculer ce qu'on connaît déjà = anti-pattern (test de
plus-value : n'apporte rien que la trace ne contienne). La « rejouabilité » est portée par le fait
que l'**appel d'outil + son résultat** sont montrés — nos outils MCP n'exposent pas leur SQL brut
(rejouabilité-SQL vraie = v2). `render_html` best-effort (dégrade si CLI `quarto` absent).

---

## Sources principales
- opendata.swiss (ASTRA trafic, swissTLM3D, STATPOP « Bevölkerungsstatistik: Einwohner ») ·
  sitg.ge.ch (OTC vitesses/signalisation, OCS population) · geo.admin.ch (`ch.bfs.schulstandorte`) ·
  h3geo.org.
- quarto.org (computations/python, output-formats/html-code, authoring/callouts, cross-references,
  computations/caching) · quarto-cli issues #4227, #7814 · github.com/NousResearch/hermes-agent ·
  github.com/luoyuctl/agenttrace.
