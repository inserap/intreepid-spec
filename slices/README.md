# Slices — intreepid

Une slice = une unité de travail livrable. Chaque slice produit 3 artefacts.

| Phase | Fichier | Location | Persistant ? |
|---|---|---|---|
| Design | `YYYY-MM-DD-<slug>-design.md` | `docs/superpowers/specs/` | **Éphémère** — jamais commité |
| Plan | `YYYY-MM-DD-<slug>-implementation.md` | `docs/superpowers/plans/` | **Éphémère** — jamais commité |
| Execution | `<YYYY-MM-DD-NN-slug>-execution.md` | `slices/` | **Persistant** — commité |

Nommage execution : `YYYY-MM-DD-NN-<slug>-execution.md` (NN à 2 chiffres, démarrage `01`).

## Règle de discipline

**Delete, don't rely on gitignore.**

Le `.gitignore` projet filtre `docs/superpowers/specs/*-design.md` et `docs/superpowers/plans/*-implementation.md` comme filet de sécurité, mais la règle absolue est : supprimer du disque avant commit (bin "i" du rituel session-end). La discipline supprime ; gitignore est juste un filet.

Template execution : [`TEMPLATE-execution.md`](TEMPLATE-execution.md).

Détails complets : `<STANDARDS>/conventions/slices.md`.

## Index

| Date | Slug | Execution pointer |
|---|---|---|
| _aucune pour l'instant_ | | |
