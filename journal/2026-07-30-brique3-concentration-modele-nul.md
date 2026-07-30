# Journal — Brique #3 : premier organe de preuve (modèle nul de concentration)

- Date : 2026-07-30
- Participants : Alex ; Claude
- Nature : session d'**implémentation** (brique #3), cycle complet brainstorming → design → plan → 2 advisors → subagent-driven → ship
- Produits : brique #3 shippée dans `<IMPL:src>` (merge `bd0499a`, release `v0.4.0`) ; execution recap ; Q-0016 (nouvelle) + Q-0009 raffinée ; ce journal.

---

## 1. Ce qui a été livré

`concentration_test` : le **premier organe de preuve** d'intreepid. Jusqu'ici l'agent
refusait un faux motif par *flair honnête* (P6) ; il le **réfute** désormais par une
**preuve reproductible** — un modèle nul par permutation. On lui donne, par unité, un
comptage observé et une **exposition attendue** ; il rejoue le hasard 999 fois
(redistribution multinomiale pondérée par l'exposition, seed fixé) et rend un pseudo-p +
l'écart de Poisson standardisé. Deux volets : `most_concentrated` (la vraie concentration)
et `highest_raw_count` (le plus gros volume brut) — leur contraste **est** la démonstration
« volume ≠ excès ». Sur la fixture : BE prouvé point noir (z=+34,2, p=0,001) ; ZH, plus gros
volume (781), **réfuté** (z=−3,28, p=1,0). Le LLM ne voit que des agrégats (P2), read-only
(P3), rejouable (P4).

Cycle complet et discipliné : brainstorming → design → plan → **2 passes advisor** (SHIP, 0
MUST, 6 SHOULD tous appliqués) → subagent-driven (6 tâches, implémenteur + double revue +
scan de domaine par tâche) → revue finale **Ready to merge** → démo (gate humain) → merge →
release `v0.4.0`.

## 2. La généricité rappelée à l'ordre (leçon centrale)

En cours de design, j'avais logé l'exposition de façon **spécifique-accidents** (table
`canton_exposure` câblée, `unit_col="canton"` par défaut). Alex a repris : *tout ce qu'on
construit doit fonctionner sur n'importe quelles données ; le jeu accidents n'est qu'un banc
de test.* Le **concept** (conditionner le nul sur une exposition) était juste ; c'est le
**couplage** qui était faux. Corrigé par la convention de fiche **`exposures`** : l'exposition
est une **connaissance métier déclarée dans la fiche**, pas un hardcode — comme `profile_stats`
est piloté par le `type` de la fiche. Le code (`nullmodel.py`, `concentration.py`, `charter.md`)
ne contient **aucun** terme de domaine, vérifié par un *scan de domaine* (grep) à chaque tâche.
Règle gravée en mémoire persistante : **l'agnosticité est un défaut par défaut à vérifier
moi-même, pas une préférence à me rappeler** (cf. Q-0004, frontière charte↔fiche).

## 3. L'oracle qui valide l'agent (bonne surprise)

Le premier run de l'oracle échouait (`false_as_fait == 6`). Réflexe systematic-debugging :
**diagnostiquer avant de corriger** — dump des verdicts réels. Verdict : l'agent est
**exemplaire** (il dit « ZH n'est PAS un excès, pseudo-p = 1, sous-représenté » en citant la
preuve). C'était le **matcher** qui comptait cette *réfutation correcte* comme une
hallucination (il matchait « ZH » + « excès » + `fait` sans distinguer affirmation de
négation). Root cause = test, pas comportement. Fix négation-aware + word-boundary. **Leçon** :
face à un oracle rouge, distinguer *le matcher* du *comportement* avant de toucher la charte
ou les seuils — j'ai failli itérer la charte pour un agent qui n'avait rien à se reprocher.

## 4. Le choix de l'exposition → Q-0016

Le Q&A d'Alex a fait émerger une question méthodologique centrale : *comment sait-on quelle
exposition utiliser ?* Réponse : c'est une **question métier** (« qu'est-ce qui gonfle
mécaniquement le comptage, indépendamment du phénomène ? » = le dénominateur qui fait un
taux), **déclarée en fiche**, élicitée par le curateur ; sans exposition évidente → nul
uniforme (affirmation plus faible, signalée) ; plusieurs candidates → test de robustesse
(futur). Extraite en **Q-0016** (dédiée, plutôt que gonfler Q-0009 — cousin de la leçon
anti-accrétion de Q-0004). Recoupe Q-0015 (curation) et Q-0008 (élicitation).

## 5. Incidents de process

- **API 529** répétés au moment de lancer le 1ᵉʳ advisor (incident serveur, 0 token) — patienté
  puis relancé, verdict SHIP obtenu.
- **Fix subagent déraillé** : au lieu d'appliquer le fix, il a disserté sur le multilinguisme et
  laissé le repo à moitié modifié + une modif parasite de `settings.json`. Repris à la main
  (le contrôleur détenait le code exact). Rappel : un sous-agent de fix doit *exécuter*, pas
  *commenter* — brief à resserrer.
- **`.claude/settings.json`** : modifié par Alex (`git`→`gitro`) ; retiré du suivi + gitignoré
  dans un `chore` séparé (per-user, déjà poussé → propagation au prochain push).
- **Ordre ship respecté** cette fois : démo (gate) **avant** merge, CHANGELOG/tag en dernier
  commit après merge — la convention projet de la brique #2 a tenu.

## 6. Leçons

- **Agnosticité = défaut par défaut**, pas préférence : le domaine vit dans la fiche/fixture,
  jamais dans le code/charte ; scan de domaine à chaque revue.
- **Oracle rouge → diagnostiquer matcher vs comportement** avant de toucher charte/seuils.
- **Narrer les vrais chiffres** dans la démo (z négatif, pas « ≈ 0 ») — la démo est un gate,
  elle ne doit pas mentir sur le mécanisme (advisor S1).
- **Une dépendance se justifie au premier appel réel** : `esda` écarté tant qu'il n'est pas
  utilisé (règle d'admission de composant) — pas de dépendance morte « pour plus tard ».
- La **2ᵉ passe advisor ciblée** (demandée par Alex) a attrapé une divergence spec↔code que
  j'avais laissée (contrat `w_u ≥ 0` vs garde `> 0`) : un 2ᵉ regard sur les diffs vaut le coût.

## 7. Pointeurs

- Execution recap : `slices/2026-07-30-02-brique3-concentration-modele-nul-execution.md`
- Livraison : `<IMPL:src>` `main` merge `bd0499a`, release `155a63f`, tag `v0.4.0` (user-driven)
- Démo : `<IMPL:src>/demo/brique-3-concentration-et-preuve.md`
- OPEN-QUESTIONS : Q-0016 (nouvelle), Q-0009 (raffinée)
- Amont : `journal/2026-07-29-etat-de-lart-et-revue-brique1.md` (veille §5), brique #2 (2026-07-30-01)
