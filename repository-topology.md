# Topologie — spec

> Spec repo pour le projet `intreepid`. Pilote 1 impl(s).
> Mis à jour le 2026-07-26 par Alexandre Pillonel. À mettre à jour **AVANT** tout autre travail si un repo référencé est renommé ou déplacé.

## Paths

| Symbol | Filesystem path | Role | Read mode |
|---|---|---|---|
| `<SPEC>` | `C:\Projects\INSER\AI\intreepid\spec` (this repo) | Spec : pilote le projet `intreepid` | self |
| `<STANDARDS>` | `../../methods/standards` | Doctrine live (méthodologie INSER AI) | live-read |
| `<IMPL:src>` | `../src` | Livrable autonome | reference |

## Remote git (optional)

- Spec : `origin` → `https://github.com/inserap/intreepid-spec.git` (**privé**)
- Standards : `n/a — local clone`
- Impl(s) : `src` → `origin` → `https://github.com/inserap/intreepid-src.git` (**privé**)

> Repos **privés** par défaut. Aucune publication publique n'est prévue ; une éventuelle exposition n'est que temporaire (p. ex. donner accès à un LLM externe pour revue) et ne change ni le rôle du `spec` (process artifact à consommateur unique, cf. ADR-0002) ni l'absence de README côté `spec`.

## Conventions de référencement

- **Liens markdown vers la doctrine** : `<STANDARDS>/conventions/<file>.md` (relatif depuis ce spec).
- **Liens vers les impl** : `<IMPL:src>/...` ou explicit relative `../src/...` selon préférence locale.
- **Pas de path absolu codé en dur** dans les artefacts shippés (sauf ce fichier, qui est le single source of truth).

## Drift detection

- **Trigger** : un fichier de ce spec mentionne un path qui ne résout pas → corriger **ce fichier en premier**, avant tout autre travail.
- **Procédure** :
  1. Mettre à jour la ligne concernée dans la table Paths.
  2. `grep -r "<ancien-chemin>" .` dans le spec pour repérer toutes les références.
  3. Propager les corrections dans les artefacts touchés (CLAUDE.md wrapper, repository-topology.md, journal, slices, OPEN-QUESTIONS, decisions en cours).
  4. Commit dédié : `chore(topology): rename <X> → <Y>`.
  5. Si un impl repo est concerné côté livrable, vérifier que son `architecture/` ne référence pas un path externe obsolète.
