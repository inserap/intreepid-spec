# Journal — Brique #2 : `profile_stats` aux 4 types (temporel + spatial) + démo

- Date : 2026-07-30
- Participants : Alex ; Claude
- Nature : session d'**implémentation** (brique #2) + rédaction de la **démo** + Q&A de conception
- Produits : brique #2 shippée dans `<IMPL:src>` (mergée `main`, tag `v0.3.0`) ; runbook de démo ; raffinements OPEN-QUESTIONS (Q-0004 recentrée, Q-0008, **Q-0015** nouvelle) ; convention workflow projet dans `CLAUDE.md` ; ce journal ; execution recap.

---

## 1. Ce qui a été livré

`profile_stats` couvre désormais les **4 types** de l'overview §4.2 : ajout de `_temporal` (bornes, trous de série, saisonnalité, volume/an) et `_spatial` (types de géométrie, SRID déclaré, emprise, taux hors-emprise, invalides/vides/nulls, dim Z, longueur/aire ; NN + densité **différés** « prévu / non implémenté » → H3 anti-MAUP). Deux dettes de la brique #1 soldées : `skewness` dans `_numeric` ; `bounds.open_readonly` en **context manager** (`TemporaryDirectory` auto-nettoyé, extension `spatial` chargée sur connexion read-only P3, fermeture avant nettoyage — garde Windows). Fixture OFROU étendue (`date`/`geom` GeoParquet WKB LV95/`canton`) avec anomalies plantées (trou 2018-2019 = 24 mois ; null-island + points hors-CH). Oracle agent étendu : faits temporel/spatial authentiques ≥4/5 **et** refus de **deux** faux patterns causaux (gravité×mois ; « baisse de volume ⇒ routes plus sûres »).

Exécution disciplinée : `brainstorming` → `writing-plans` → **2 passes advisor** (NEEDS_CHANGES → SHIP) → `subagent-driven-development` (6 tâches, implémenteur + double revue spec/qualité par tâche) → revue finale de branche (**Ready to merge: Yes**). Gate qualité (ruff / pyright `standard` / pytest) vert à chaque commit.

## 2. La démo comme gate de validation humaine

Le runbook `src/demo/brique-2-temps-et-espace.md` a été rédigé **avec des sorties réelles capturées** (`demo.py` aligné sur la question de l'oracle). La démo raconte : les 4 types visibles → le trou de collecte 2018-2019 → 1,67 % de points hors Suisse → **double refus** causal → preuve testée → bonus « l'agent flaire que le jeu est synthétique » (distribution de vitesse trop uniforme).

**Leçon centrale** : c'est la **démo**, pas seulement les tests verts, qui porte la validation humaine — et elle a révélé des défauts que les tests n'attrapaient pas (voir §3). Or cette session l'a faite **dans le mauvais ordre** : merge + tag *puis* démo *puis* corrections. D'où deux conséquences (un retag, des commits post-tag). Corrigé en **convention workflow projet** (`CLAUDE.md`) : scénario de démo produit **pendant** l'implémentation, démo lancée **avant** le merge, **CHANGELOG + tag en dernier commit après merge**.

## 3. Corrections issues du Q&A post-démo

- **Régression Q-0004 (spoiler de fiche)** : le fix M-1 de la Task 3 avait restauré une intention de fixture (`note: "…révèle 999…"`) en **champ de fiche**. Mais `describe` renvoie la fiche **verbatim** → l'agent lisait le spoiler, ce qui **défait l'oracle** (il doit *découvrir* `999`, pas se le faire souffler). Retiré de la fiche, remis en **commentaire dev** de `build_fixture.py` avec garde-fou. Oracle **re-lancé sans le spoiler → vert** (l'agent découvre `999` seul). C'est du surajustement Q-0004 attrapé de justesse.
- **Frontière LLM ≠ affichage humain** : l'argument métier « les positions ne quittent pas votre système » est **fragile** (la carte arbre↔carte *montrera* les positions à l'humain). Reformulé sur l'invariant **durable** : les positions n'entrent jamais *dans le modèle* (agrégats only) ; elles restent dans l'infra, montrées *à l'utilisateur*, jamais transmises au LLM/à un tiers.
- **Échantillon-drill-down** : P2 autorise les *échantillons* → sur anomalie, tirer un échantillon borné/pseudonymisé/`untrusted_data` pour comprendre l'origine est légitime et renforce le curateur (Q-0008).

## 4. Insights de curation → Q-0015

Le Q&A a fait converger trois responsabilités du **curateur** au moment de rédiger la fiche, regroupées en **Q-0015** (extraite de Q-0004 devenue fourre-tout) : (a) **inférence de type** (numérique continu vs code déguisé) ; (b) **sensibilité des sorties agrégées** (un agrégat n'est pas anodin : `max(salaire)`, k-anonymat sur `top_k`/cellules rares, CA) ; (c) **hygiène anti-spoiler** (rien de méta-test dans la fiche agent-visible).

## 5. Gouvernance : revue d'usage de standards (à porter dans `methods/spec`)

En traitant le bin « h », on a jugé **prématuré** de muter la doctrine *partagée* (`standards/`) pour une convention validée sur **un seul** projet. La convention (démo-gate, CHANGELOG/tag post-merge) reste donc **projet-local** (`CLAUDE.md`), **marquée candidat de promotion**. Idée émergée, supérieure au seul bin « h » *push* : une **revue périodique d'usage de standards, conduite depuis `methods/spec`** (mécanisme *pull*, vue cross-projets), qui arbitre quels candidats **graduent** vers `standards/` (applique le seuil « validé à l'usage / ≥2 projets »). **À instruire dans une session `methods/spec`** — hors périmètre d'intreepid.

## 6. Leçons

- La **démo avant le merge** est un gate de validation humaine à part entière ; elle attrape ce que les tests verts ne voient pas (spoiler, argument fragile). Ordre : démo → merge → CHANGELOG/tag.
- `describe` renvoyant la fiche **verbatim**, toute méta-donnée de fixture y **fuit** : l'intention design reste **dev-side**.
- Distinguer **frontière LLM** (durable) et **affichage humain** (fonctionnalité) dans tout argument de confidentialité.
- Une question ouverte qui **accrète** (Q-0004) perd sa valeur de suivi : **extraire** en questions focalisées. *Follow-up* : groomer Q-0004 (sortir « biographie/fait-vs-insight » et « frontière charte↔fiche »).

## 7. Pointeurs

- Execution recap : `slices/2026-07-30-01-brique2-profile-stats-temporel-spatial-execution.md`
- Livraison : `<IMPL:src>` `main` (merge `e1297ac`), tag `v0.3.0`, démo `src/demo/brique-2-temps-et-espace.md`
- Amont : `journal/2026-07-29-etat-de-lart-et-revue-brique1.md` (cadrage brique #2)
- OPEN-QUESTIONS : Q-0015 (nouvelle), Q-0004 (recentrée), Q-0008 (raffinée)
- Convention workflow : `CLAUDE.md` § « Project workflow conventions »
