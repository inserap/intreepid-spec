# Journal — Brique #5 (le produit de session) : implémentation, ship v0.6.0, et une validation réussie sur du réel

- Date : 2026-08-01
- Participants : Alex ; Claude
- Nature : session d'**implémentation** (exécution subagent-driven du plan SHIP du cadrage 2026-08-01)
- Produits : brique #5 shippée dans `<IMPL:src>` (merge `a272884`, release `v0.6.0`) ; execution recap ;
  raffinement Q-0016 ; ce journal.
- Temps engagé : bloc `21:34` (≈ 2h12 cumulé session-end-cadrage + implémentation).

---

## 1. Ce qui a été livré

Le **produit de session** : l'analyste tourne sur la **vraie donnée OFROU** (267 761 lignes),
capturé par le greffier, et un **notebook Quarto** est généré depuis la trace — narratif +
appels d'outils + résultats agrégés, observations en callouts colorés (fait/hypothèse/refusé),
rejouable et partageable en un fichier HTML autonome. La fiche devient **auto-descriptive**
(porte le chemin de sa donnée + son exposition, relatifs à elle-même) et le serveur se pointe
sur **une** fiche via `INTREEPID_FICHE` — bascule fixture ↔ réel en une variable d'env. Zéro
nouvel outil MCP : la valeur vient de la **capitalisation** (le notebook), pas d'un organe neuf.

Exécution disciplinée : 4 tâches (implémenteur frais + revue de tâche sur diff **stagé** +
commit contrôleur après *Approved*), revue finale whole-branch sur `opus` → **Ready to merge** →
merge → release `v0.6.0` en commit final post-merge (tag annoté, sur instruction explicite d'Alex).

## 2. La validation sur du réel a réussi — et c'était le but du recadrage

Le run réel (gate humain, `opus`, **$0,19, 6 tours**) a produit exactement ce qu'Alex voulait
en recadrant cette petite brique en **banc de validation** : un analyste **surdoué et honnête**.
Sur la fixture, les anomalies étaient *plantées* — l'agent « découvrait » ce qu'on savait déjà.
Sur le vrai OFROU, **on ne connaissait pas la réponse** :

- **Donnée propre → il le dit** : aucune sentinelle, série continue, `geom` valide → l'analyste
  conclut honnêtement « aucune anomalie », **sans en halluciner une**. C'est le test le plus dur
  (un LLM sur-zélé invente des patterns) — la **posture P6 validée sur un 2ᵉ dataset réel**.
- **Volume ≠ excès, sur du réel** : **BE** sur-concentré vs sa population (std_excess 32,76) ;
  **ZH** plus gros comptage brut (49 397) mais **expliqué par l'exposition** (+1279 seulement).
  « Sans le test, le classement par comptage brut aurait trompé » — le différenciateur en action.
- **Refus causal motivé** : « BE plus dangereux » → **refusé**, avec le mécanisme (proxy
  population ≠ trafic ; réseau de transit A1/A6 ; dénominateur véhicules-km absent).

La donnée était propre, mais la **démonstration**, elle, ne l'était pas d'avance : elle a émergé
du réel. C'est la différence entre une validation et du théâtre.

## 3. Deux corrections d'Alex qui ont porté

- **La source raw** : Alex a rappelé que la conversion CSV→Parquet est un **job ETL/FME amont**,
  hors de notre solution — on consomme le Parquet raw sous `data/raw/`, on ne le fabrique pas.
  J'ai repointé `prepare/` **et** `build_fixture.py` sur `data/raw/`, supprimé le parquet racine
  bâtard, sans toucher au monde fixture committé (mêmes bytes relocalisés → zéro dérive, golden verts).
- **Le modèle nul par défaut** (Q-0016) : Alex a mis en doute « à défaut → uniforme ». Il a
  raison — pour des unités inégales, l'uniforme suppose l'équiprobabilité (presque toujours faux)
  et **ré-introduit la confusion volume↔excès** que l'outil combat. Nouvelle orientation
  (slice dédiée) : exposition = **choix conscient** ; sans déclaration → **abstention**, pas un
  verdict trompeur. Consigné en Q-0016.

## 4. Le run réel a révélé un bug que la fixture cachait

`demo_notebook.py` a **planté à l'impression console** : Windows cp1252 ne code pas les `≈`/`±`
que l'analyste emploie naturellement (`UnicodeEncodeError`). Le crash était *après* la capture
(la session était dans le store) mais *avant* la génération du notebook. Correctif :
`sys.stdout.reconfigure(encoding="utf-8", errors="replace")`. **La fixture ne produisait pas ces
caractères** — seul le run réel pouvait l'exposer. Écho de la leçon brique #4 : la vraie donnée
voit ce que les tests ne voient pas.

## 5. Une glissade de scénario, attrapée par Alex

J'avais évoqué un « raffinement v2 : rendre `std_excess` proéminent quand la p-value sature ».
Alex a demandé : *ne câble-t-on pas un scénario qui n'a de sens qu'en test ?* Il a raison, et
j'ai retiré l'idée. L'outil renvoie **déjà** pseudo-p **et** std_excess ; l'analyste a lu l'effet
tout seul (le partage « calcul = faits, LLM = regard » a fonctionné). Encoder une réaction à la
saturation qu'on a vue dans *nos* données = surajustement (Q-0004) et usine à gaz (P7). La seule
chose durable serait une littératie **générique** (plancher `1/(R+1)`, classer par effet quand p
sature) — et encore, le modèle l'a fait sans qu'on lui souffle rien. On n'ajoute rien.

## 6. Leçons

- **Recadrer une petite brique en banc de validation** est un excellent substitut *contrôlable*
  à Q-0002 — à condition que l'inattendu **émerge du réel**. Ici, il a émergé.
- **Le gate humain doit valider une démo qui MARCHE** : un crash console (même trivial) n'est pas
  une démo validée — d'où le re-run propre après correctif.
- **La revue finale whole-branch sur `opus`** confirme les seams cross-tâches qu'aucune revue de
  tâche ne voit (défaut=fixture prouvé par la sentinelle 999, cohérence dataset≠vue).
- **Écouter l'objection méthodo de l'humain** (modèle nul par défaut, source raw, glissade
  std_excess) a redressé trois fois la trajectoire — le jugement métier reste en amont.

## 7. Pointeurs

- Execution recap : `slices/2026-08-01-01-brique5-notebook-session-reelle-execution.md`
- Livraison : `<IMPL:src>` `main` merge `a272884`, release `16e2c2f`, tag `v0.6.0`
- Démo : `<IMPL:src>/demo/brique-5-notebook.md` (sorties réelles) ; notebook rendu HTML via Quarto 1.10.18
- Amont : `journal/2026-08-01-brique5-notebook-cadrage.md` ; `research/2026-08-01-donnees-suisses-et-quarto.md`
- OPEN-QUESTIONS : Q-0016 (raffinée — abstention par défaut) ; Q-0004/Q-0002 (touchées)
