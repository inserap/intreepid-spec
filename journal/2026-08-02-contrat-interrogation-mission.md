# Journal — Le contrat d'interrogation : affûtage de la mission (discussion, zéro code)

- Date : 2026-08-02
- Participants : Alex ; Claude
- Nature : session de **discussion doctrinale/produit** — aucune implémentation, aucun slice.
  Produit durable : mission gravée en overview v0.3, une nouvelle question ouverte, ce journal.
- Amont : brique #5 (validation réelle, v0.6.0) ; brique #6 (cadrage, en vol).

---

## 1. La question de départ : plus-value + « peut-on interroger simplement ? »

Alex a rouvert deux fils sans vouloir implémenter : (a) *sommes-nous toujours dans une
solution à vraie plus-value* — vs un LLM générique + DuckDB MCP ? ; (b) au-delà de l'insight
inattendu après analyse profonde, *le système peut-il aussi répondre à des questions simples*
(« plus d'accidents la nuit ? », « accidents moto 11h-13h en hiver ? », « accidents par canton
à moins de 200 m d'une école ? », « nombre total ? ») pour amorcer ou illustrer une analyse.
Son intuition : **qui peut le plus peut le moins**.

## 2. Trois recadrages qui ont fait converger la discussion

- **La plus-value n'est ni l'insight ni la réponse — c'est la rigueur.** Auto-générer des
  insights est commoditisé et même toxique (Q-0018, PNAS 2026) ; le text-to-SQL aussi. Ce qui
  reste défendable : honnêteté fait/hypothèse/refusé, volume≠excès, abstention plutôt que
  verdict trompeur, provenance, refus causal motivé — la brique #5 l'a **prouvé sur du réel**
  (refus de « BE plus dangereux »). Étroit mais réel. Le différenciateur n'est pas ce que le
  système *dit*, c'est ce qu'il *refuse de dire* — et **comment** il le refuse.
- **Les questions « simples » ne sont pas d'une seule famille.** Le *fait brut* (total, filtre)
  est descriptif et commoditisé ; mais « plus la nuit ? » et « près des écoles ? » sont des
  **questions de risque déguisées en comptage** — le terrain-maison (exposition, MAUP,
  confondeur). Un dashboard naïf répondrait « oui, 60 % la nuit » = précisément le mensonge que
  le projet existe pour ne pas commettre.
- **Le « moins » n'est pas trivial chez nous — grâce à la fiche.** Un DuckDB MCP générique
  répond « vitesse max = 999 » ; nous savons que `999` est une sentinelle. Une cellule à 2 =
  violation de k-anonymat (Q-0015). Donc interroger *à travers la fiche* ≠ interroger DuckDB
  nu : le comptage bête reste correct (sentinelles, unités, SRID, k-anonymat). Le « moins »,
  passé par notre couche, est **meilleur** — et ça passe le test de plus-value v1.

## 3. Le retournement d'Alex : pas de limite à la question

Mon vocabulaire (« garde-fous », « refus », « abstention ») sonnait comme des limites *à
l'entrée*. Alex a corrigé, et c'est le cœur : **le but n'est pas de brider l'interrogation,
mais de répondre et d'expliquer le mieux possible ce qu'est ou n'est pas la réponse, avec tous
les doutes et/ou certitudes.** Reformulation propre du contrat :

> **Entrée sans limite. Sortie maximalement honnête.**

L'abstention devient une réponse *plus riche*, pas un mur : « la donnée ne tranche pas, et voici
pourquoi » est de l'information en plus. Ça **dissout** la tension du §1 : « interroger
simplement » n'est plus un problème, c'est le cas trivial où la qualification est légère ; le
même mécanisme couvre le continuum du comptage bête à l'insight factualisé.

## 4. La distinction que j'ai maintenue : deux natures de « ce que la réponse n'est pas »

- **Épistémique** (le sujet d'Alex) — « je peux répondre au comptage, pas au risque » : on dit
  *toujours tout*, jamais une limite (= P6, « jusqu'au bout de ce qu'on peut savoir »).
- **Protection** — k-anonymat, PII, confidentialité org (I-5, P8) : « je ne descends pas sous
  *k* » n'est pas un doute mais une **règle de non-divulgation**, orthogonale à la vérité. Elle
  limite réellement la *sortie*, pour une raison sans rapport avec ce qu'on sait.

Ne pas confondre les deux : « la donnée ne permet pas de conclure » (on le dit) vs « je ne dois
pas révéler ce décompte » (on le protège, en le disant aussi).

## 5. Le différenciateur le plus fort de la conversation : la maïeutique

Le dernier pas a fait le saut de nature : **accompagner l'utilisateur vers la bonne question**,
même quand elle paraît simple. « Qualifier la réponse » est *défensif* (ne pas mentir) ;
« révéler la question qu'il fallait poser » est *génératif* (créer de la valeur d'analyse). La
formule : **intreepid répond à la question posée, et révèle la question qu'il fallait poser.**
C'est là qu'il cesse d'être un DuckDB honnête pour devenir un **compagnon d'analyse**.

Déjà en germe (brique #5 : refus causal en nommant le dénominateur manquant) — mais arrêté à
« je ne peux pas ». La vision prolonge vers « … mais voici comment on pourrait » (niveau 2 =
proposer le chemin → rejoint le **scoutisme de données**, Q-0011).

**Trois garde-fous non négociables** (sinon ça se retourne en prof condescendant / LLM
moralisateur) : (1) **répondre d'abord, reformuler ensuite** — le fait brut est dû
immédiatement, la reformulation est une offre posée après ; (2) **proposer sans imposer** —
l'humain reste pilote ; (3) **émerger de la fiche, pas d'un script** — l'écart se déduit de
l'exposition déclarée/manquante, jamais une liste de reformulations câblées (violation de
`no-hard-coded-scenarios`, dette Q-0004 `999`/`concentration→hypothèse`).

## 6. Ce qu'on grave, ce qu'on ne construit pas

**Posture, pas moteur.** On ne construit rien aujourd'hui — c'est une manière d'être de
l'analyste, et ça ne se valide qu'avec un vrai utilisateur (Q-0002, LE verrou). La charte des
agents (§6, opérationnelle) reste **intouchée** ; les 3 garde-fous y descendront le jour où une
brique maïeutique sera cadrée. Ce qu'on grave maintenant : la **mission** en overview §1 (v0.3,
« Contrat d'interrogation »), et la direction produit en **Q-0020**.

## 7. Leçons

- **Écouter le recadrage de l'humain** : « pas de limite à la question » a corrigé mon propre
  vocabulaire — la valeur est dans la qualification de la *sortie*, pas dans un péage à
  l'*entrée*. Le jugement reste en amont.
- **Nommer précisément la mission vaut mieux que l'élargir** : on a *rétréci* la revendication
  (pas « trouver des insights » — commoditisé) pour la rendre *défendable* (qualifier +
  reformuler). Anti-cathédrale appliqué à la vision elle-même.
- **Graver ≠ raconter** : une mission se grave dans l'overview (canonique, versionné), pas
  seulement dans un journal (narratif).

## 8. Pointeurs

- Mission gravée : `<IMPL:src>/docs/architecture/overview.md` §1 « Contrat d'interrogation » (v0.3)
- OPEN-QUESTIONS : **Q-0020** (ajoutée) ; Q-0004 (pointeur ajouté). NB : Q-0019 (dérive
  d'isolation P3) déjà pris par la session brique #6 (v0.7.0) shippée entre-temps.
- Amont : `journal/2026-08-01-brique5-notebook-implementation.md` (refus causal en germe) ;
  Q-0018 (insights auto-générés = commoditisés/toxiques) ; Q-0002 (le verrou)
- Recoupe : Q-0002, Q-0004, Q-0008 (elicitation), Q-0011 (scoutisme), Q-0015 (protection)
