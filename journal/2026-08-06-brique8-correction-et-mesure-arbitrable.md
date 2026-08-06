# Journal — La décision qu'on avait prise, et les deux faits qui l'ont retournée

- Date : 2026-08-05 → 2026-08-06
- Participants : Alex ; Claude
- Nature : cycle complet **brainstorming → design → plan → 4 passes advisor → exécution
  subagent-driven (9 tâches) → revue finale → gate humain PASSÉ → ship**. Release **v0.12.0**
  (merge `931e010`, release `671f25d`, tag en attente). Plus un **audit de `v0.11.0`** demandé par
  Alex en cours de cadrage.
- Temps engagé ≈ **0h45** (instrument, cf. §8) ; span session ≈ **17h40** ; span git de la slice
  ≈ **11h**.

---

## 1. La reprise devait appliquer une décision. Elle l'a retournée.

Le pointeur de reprise du journal de la veille était net : brouillon incrémental invisible, Python
accumule, quatre rustines de charte qui tombent. J'ai commencé le brainstorming en cadrant
l'implémentation de cette décision — où fusionner, comment signaler un delta — et Alex a arbitré cinq
questions dans ce cadre.

Puis il a posé la question qui a tout déplacé : **« par rapport à v0.10.0, qu'est-ce qui va être mis
en place, et qu'est-ce que ça résout ? »** Question de comptable, posée à un projet qui a un
anti-pattern nommé pour l'inflation. En relisant le transcript de référence ligne à ligne pour y
répondre, deux faits sont apparus qui n'étaient pas dans le pointeur.

**Premier fait : le transcript de référence est plus sobre que la charte écrite pour l'imiter.** Il
pose **une** question par tour, et n'en a demandé que **sept pour trente-six colonnes**. La réserve
inscrite dans le matériel — « une à la fois sur 36 colonnes = beaucoup de tours » — est réfutée par
le transcript lui-même. Or la charte de #8 prescrivait **1 à 3** questions, arbitrage que j'avais
construit contre une peur de latence que la donnée contredisait déjà. Le mur de texte était la
**somme de deux écarts** au transcript : le batch *et* « Tranché seul ». Le pointeur n'en visait
qu'un.

**Second fait, plus gênant : la mesure qui avait tranché la décision portait sur un objet qu'elle
altérait.** `orchestrator.py` fait `thinking=trace_to is not None`. Le raisonnement étendu n'était
activé **que parce qu'on traçait**. Les 141 s et 0,42 $ qui avaient servi à trancher incluaient donc
un coût qu'une exécution non tracée ne paie pas. Et le couplage ne venait pas de la slice de mesure
qu'on venait de livrer — il datait de la brique #4, deux slices plus tôt.

D'où la révision : **v0.10.0 n'avait pas le mur** (son brouillon complet était ré-émis à chaque tour,
invisible, cumulatif par construction). Le seul défaut que v0.10.0 ratait vraiment, c'est la qualité
du premier tour sans redirection live. Le reste était du coût, et le coût n'était pas chiffrable.
**Le brouillon incrémental a donc été différé**, et la slice a livré à la place ce qui permettrait de
l'arbitrer.

## 2. L'audit qu'Alex a demandé, et ce qu'il a réellement dit

Au milieu du cadrage, Alex a exprimé un doute : « le code généré n'a pas été efficace et une
complexité s'est installée avec une impression de château de cartes (v0.11.0) ». Question légitime,
et la bonne réponse n'était pas mon impression de lecture — je n'avais pas audité ce code, je
l'avais lu.

Un reviewer frais sur le diff : **DÉFAUTS MINEURS**, architecture saine, ratio tests/code de 1:1,
aucune abstraction prématurée, branche `degraded` justifiée par des traces réelles sur disque. Mais
un constat qui compte : **tous** les défauts se concentrent dans une seule couche — l'agrégation et
le rendu des totaux — et c'est **la seule sans aucun test**. Ce n'est pas un hasard si les deux
défauts déjà connus sont passés par là ; il en a trouvé un troisième de la même famille.

Deux corrections d'aiguillage sont sorties de cet échange. D'abord, le « château de cartes » qu'Alex
avait nommé au journal visait la **charte** — 158 lignes, quatre rustines en `if` de langage naturel
— et c'est précisément ce que la slice démonte ; un revert de `v0.11.0` n'y aurait rien changé, tout
en détruisant l'instrument de mesure dont le design dépendait. Ensuite, j'avais écrit dans le design
que stocker de l'UTC « rendrait les traces existantes incomparables » : **exagéré**, recopié du
suivi de la veille sans vérification. Rien n'affiche d'horodatage absolu.

## 3. Les corrections qui se corrigent : quatre passes, et la leçon est arithmétique

Quatre passes d'advisor frais, 9 MUSTs, 21 SHOULDs. La progression vaut plus que les chiffres :

- passe 2 : trois MUSTs, dont **deux créés par les corrections de la passe 1** ;
- passe 3 : trois MUSTs, dont **un créé par la passe 2** ;
- passe 4 : SHIP — mais un SHOULD qui était une **contradiction créée par la passe 3** (une section
  du plan interdisait ce qu'une étape ajoutée par cette même passe demandait ; un sous-agent
  obéissant aurait sauté l'étape).

Le mécanisme récurrent a un nom : **les numéros de ligne dans un plan multi-tâches sont périmés par
les tâches antérieures du même plan.** La tâche 1 retire trois lignes d'un docstring, la tâche 4 en
ajoute trente ; toute référence numérique écrite avant l'exécution est fausse au moment où elle est
lue — y compris celles que j'avais **ajoutées** pour corriger un SHOULD de la passe précédente. Le
plan repère désormais par **ancres verbatim**, vérifiées présentes et uniques.

Trois défauts valaient à eux seuls les quatre passes : un test de charte qui aurait échoué **après**
le correctif, parce que son interdiction (`"tranche seul"`) matchait le texte de remplacement que le
plan écrivait lui-même ; un `NameError` qui aurait empêché `metrics.py` de s'importer ; et la cascade
de numéros de ligne.

## 4. Deux fois, le diagnostic était juste et le correctif faux

C'est la leçon la plus transférable de la session.

Un reviewer a trouvé que la durée totale des appels d'outil était **sommée** alors que des appels
parallèles sont concurrents — juste, et mesurable (quatre appels sur deux secondes donnaient huit
secondes). Mais son correctif — « regrouper les appels partageant le même `ts` » — était **faux** :
`_insert` appelle `_now()` **par nœud**, les horodatages diffèrent de quelques microsecondes et ne
sont jamais égaux. Le regroupement n'aurait rien matché. Seule l'union d'intervalles corrige.

Le second est passé en production. Un reviewer a signalé qu'un appel dont on ignore l'issue
s'affichait comme réussi, en posant que `is_error=None` signifie « non apparié ». J'ai accepté sans
confronter la prémisse à une trace réelle. Or le SDK ne pose `is_error` **que sur erreur** : `None`
sur un appel apparié signifie **succès**. Résultat, dans le rapport du gate d'Alex, les six appels
d'outil — tous réussis — s'affichaient `[sans résultat]`. **C'est le gate humain qui a exposé le
défaut**, dans le module même dont la mission est de ne jamais mentir. Corrigé, avec le test qui
manquait — celui qui l'aurait attrapé.

## 5. Le gate est passé, et il a produit plus que son verdict

Sur l'OFROU brut : **premier tour au niveau attendu, sans aucune consigne de style**. Les réponses
d'Alex tiennent en `1a`, `2a`, `3b`, `4a`, `o`. Une question par tour tenue, quatre questions, fiche
36 colonnes validée. Et deux trouvailles absentes de v0.10.0 : la sévérité **ordinale à l'envers**
(`as1` = le plus grave, un `max` numérique inverse la gravité) et l'**absence totale de comptage de
victimes** — on ne peut jamais sommer des victimes. Alex a **contredit le penchant** de l'agent en
question 3 ; celui-ci a verrouillé « contre mon penchant » et rangé son observation en **piège non
résolu** plutôt que de l'abandonner. C'est exactement le comportement que la puce PENCHANT visait.

Puis les chiffres, qui sont la vraie sortie de la slice :

```
734.4s · 1.8033 USD · 5 tours · API 460.6s
Sortie écrite : tour d'agent 69 628 car. · thinking 9 829 car.
```

**79 % de ce que l'agent écrit est le brouillon de fiche.** Le levier de coût n'est ni la charte, ni
le raisonnement : c'est le brouillon ré-émis entier à chaque tour. La décision qu'on avait différée
faute de chiffre l'a maintenant.

**Deux prédictions réfutées.** « Une question à la fois allonge la séance » : quatre questions et
cinq tours, contre sept et huit à la référence — c'est plus **court**. « La latence par tour va
croître au fil de la séance » : 90,0 / 97,4 / 88,5 / 101,7 / 90,3 secondes, quasi plate. Cette
seconde prédiction était **la mienne**, et je l'avais fait écrire au runbook comme un avertissement.

**Un fait nouveau, non anticipé** : le cache d'entrée **ne tient pas en multi-tours**. Les lectures
plafonnent à 14 137 dès le tour 3 tandis que les créations croissent — l'historique est **re-créé** à
chaque tour au lieu d'être étendu, parce que `build_prompt` le sérialise en **un seul** message et
que le préfixe cacheable s'arrête donc à la charte. La docstring du SDK dit la chose sans détour :
`query()` est *stateless*, et `ClaudeSDKClient` est ce qu'il recommande pour les « REPL-like
interfaces ». Nous avons construit un REPL sur la primitive one-shot. Cela touche la boucle
d'ADR-0009 — d'où **Q-0024** plutôt qu'un correctif de fin de slice.

## 6. Ce que je dois consigner sur moi

**Deux fois dans la même session, j'ai présenté à Alex une illustration comme une mesure.** Au
checkpoint de la tâche 6, j'ai annoncé « le raisonnement pèse environ sept fois la prose » — calculé
sur une valeur de prose de 1 200 caractères que j'avais **inventée**, puisque la vieille trace ne
contenait aucun nœud de tour d'agent. Le run réel dit l'inverse : la sortie de l'agent domine d'un
facteur sept. J'ai corrigé de moi-même, mais après avoir laissé le chiffre circuler deux fois.

Et la revue finale a attrapé la conséquence de la même négligence : l'étiquette « prose » de la ligne
d'attribution était **fausse** — le nœud contient la prose *et* le bloc JSON. Une fiche réelle
extrapolée à 36 colonnes fait ~6 700 caractères ; le chiffre aurait été dominé par le brouillon, et
le runbook demandait à Alex de le lire comme « le texte que je lis ». Il aurait conclu l'inverse de
la vérité, **au gate même que cette mesure sert**.

## 7. Leçons

- **Une question de comptable posée au bon moment vaut une passe d'advisor.** « Qu'est-ce que ça
  résout par rapport à la version précédente ? » a retourné une décision déjà écrite au journal.
- **Vérifier le correctif d'un reviewer, pas seulement son diagnostic.** Deux fois le diagnostic
  était juste et la solution fausse ; la seconde est passée en production.
- **Un instrument ne doit pas altérer l'objet mesuré.** Brancher la mesure activait le raisonnement,
  donc changeait le coût mesuré. Le couplage dormait depuis deux slices.
- **Les numéros de ligne d'un plan multi-tâches sont périmés par ses propres tâches antérieures.**
  Ancres verbatim.
- **Un chiffre inventé pour illustrer finit par être cité comme mesure.** Étiqueter l'illustration,
  ou ne pas la produire.
- **Corriger par retrait est plus sûr que corriger par mécanisme** — et ici c'était aussi moins cher :
  138 lignes de charte, zéro ligne de logique côté curateur, gate passé.

## 8. Note d'instrumentation

Le compteur de temps engagé donne **0h45** pour un span de 17h40. Le chiffre est honnête mais
trompeur pris seul : il approxime la **présence humaine**, et cette session a été dominée par de
longues exécutions autonomes — douze sous-agents, dont un advisor à 21 minutes. Alex n'était
effectivement pas au clavier. La mesure fait ce qu'elle promet ; c'est la lecture « temps de travail »
qui serait fausse. À garder en tête quand ces chiffres s'accumuleront.

## 9. Pointeurs

- Recap : `slices/2026-08-06-01-brique-8-correction-charte-execution.md`
- Matériel : `research/2026-08-06-curateur-gate-materiel.md` (transcript complet de la séance +
  mesures, pendant de la note de #7c), `research/2026-08-06-RoadTrafficAccidentLocations.fiche.v2.yaml`
  (fiche du gate), `research/2026-08-04-curateur-gate-humain-materiel.md` (la cible, référence de
  concision)
- Amont : `journal/2026-08-05-brique8-gate-rate-et-mesure.md` §8 — le pointeur de reprise dont la
  décision a été révisée
- ADR : `decisions/0009-architecture-execution-agents.md` (`Proposed`) — sa boucle est questionnée
  par la preuve (Q-0024)
- Livraison : `<IMPL:src>` merge `931e010`, release `671f25d`, `v0.12.0` — **tag user-driven en
  attente**
- OPEN-QUESTIONS : **Q-0024** (ajout), **Q-0022** (résolue) ; Q-0023 / Q-0013 / Q-0019 / Q-0010 /
  Q-0004 (raffinées)
- Doctrine : trois candidats de promotion proposés, **non appliqués** (ancres verbatim dans les plans,
  vérifier le correctif d'un reviewer, un instrument n'altère pas l'objet mesuré) — à arbitrer par une
  revue d'usage depuis `methods/spec`
