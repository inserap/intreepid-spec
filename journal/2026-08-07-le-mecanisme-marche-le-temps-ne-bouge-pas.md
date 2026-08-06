# Journal — Le mécanisme marche, le temps ne bouge pas

- Date : 2026-08-06 → 2026-08-07
- Participants : Alex ; Claude
- Nature : cycle complet **brainstorming → design → plan → 4 passes advisor → exécution
  subagent-driven (6 tâches) → revue finale → gate humain ÉCHOUÉ → merge sur décision d'Alex**.
  Release **v0.13.0** (merge `fe091aa`, release `2d46473`, tag en attente). Puis un **recadrage
  d'objectif** par Alex qui a invalidé le cadrage de trois sessions.
- Temps engagé ≈ **2h31** ; span session ≈ **15h22** ; span git de la slice ≈ **11h15**.

---

## 1. La slice a fait exactement ce qu'on lui demandait

Le brouillon de fiche pesait 79 % de ce que le curateur écrit. La brique #10 le fait n'émettre que
ses deltas : le brouillon émis passe de 55 604 à 35 837 caractères, **−36 %**. Le mécanisme est
propre — deux fonctions pures, zéro ligne d'orchestrateur, la fiche reste opaque pour Python — et il
a traversé quatre passes d'advisor, six revues de tâche et une revue finale.

Le gate a échoué, et le coût a **monté** de 14,5 %.

## 2. Ce que le gate a coûté et ce qu'il a acheté

Deux dollars et douze minutes de présence, pour un verdict que rien d'autre n'aurait pu produire.
Tests verts, revues approuvées, quatre passes d'advisor : aucun de ces organes n'a vu que la slice
manquerait son objectif. C'est la troisième fois de suite que le gate trouve ce que le reste rate.

Il a aussi produit un fait plus utile que son verdict. En décomposant le temps sur les deux traces —
celle du matin, celle du soir — le compte tombe **à la seconde près** :

| ce que l'agent écrit | matin | soir | |
|---|---|---|---|
| la fiche | 322 s · 70 % | 257 s · 56 % | −65 s |
| la prose | 81 s · 18 % | 107 s · 23 % | +26 s |
| le raisonnement | 57 s · 12 % | 98 s · 21 % | +41 s |
| **total** | **460 s** | **462 s** | **+2 s** |

Les 65 secondes gagnées sur la fiche ont été **intégralement reprises** par le raisonnement et la
prose. Il n'y a plus de mystère : le mécanisme est neutre.

## 3. Trois fois, on a déplacé la charge sans la réduire

C'est le pattern de la brique, et il a un historique :

- **#8** : on retire le brouillon intermédiaire → la mémoire passe dans la prose. C'est le mur de
  texte qui avait fait échouer ce gate-là.
- **#8 corrigée** : on remet le brouillon → il pèse 79 % de la sortie.
- **#10** : on le rend incrémental → le raisonnement croît de 39 %, l'agent re-profile deux fois de
  plus, et la fiche devient 3,5 fois plus verbeuse par colonne.

L'agent a un travail à faire. Lui retirer un moyen ne retire pas le besoin ; il en prend un autre.
**Seule une borne sur le total ne se compense pas** — c'est la leçon, et elle change la façon de
concevoir toute slice future sur le comportement d'un agent.

## 4. Le recadrage d'Alex, qui a invalidé trois sessions de travail

Après le gate, Alex a écrit ceci :

> « L'objectif en soi n'est pas de faire des économies ou diminuer le prix, mais de comprendre et
> optimiser le contenu et surtout le **temps**. Tu t'imagines faire ce travail sur plusieurs
> **centaines** de couches ? C'est tout simplement impossible. […] C'est ça que je recherche :
> **maîtriser les appels et leur contenu**. »

J'optimisais des dollars. Le modèle de temps que j'ai construit ensuite dit que les deux sujets que
je poussais — le cache, la primitive du SDK — ne font gagner **aucune seconde** : le hors-API pèse
**3,4 secondes sur 961**. Le temps est intégralement de la génération, `temps ≈ tokens générés ÷ 72`.

Et la chaîne de raisonnement qui m'y avait mené était fausse à un endroit précis : « 79 % de ce que
l'agent **écrit** est le brouillon » n'est pas « 79 % du **coût** », encore moins « 79 % du
**temps** ». J'ai optimisé un proxy pendant trois sessions sans jamais vérifier qu'il corrélait avec
la cible — et il ne corrélait pas.

## 5. Ce qu'Alex a vu que je n'avais pas vu

**La fiche avait perdu sa connaissance transversale.** Il a remarqué que le dernier JSON ne portait
que trois clés là où les précédents étaient plus riches. C'est pire que ça : douze clés racine en
#7c, dix en #8, **trois** en #10 — grain, périmètre, référentiels, points non tranchés, tout a
disparu. La cause est une phrase que j'avais écrite, qui se lit comme une liste fermée. C'est aussi
ce qui explique la colonne fantôme `_indicateurs_usagers` : l'agent avait une note transversale et
aucun endroit où la mettre.

**Et il a proposé l'architecture.** Partant d'une observation du transcript de référence — le tour 1
y dit déjà « Draft initial rédigé avec hypothèses. 3 questions prioritaires » — il a vu que l'agent
prépare tout **avant** la première réponse, et qu'il suffirait de servir les questions depuis
l'application. Deux appels LLM au lieu de cinq ; la phase de questions ne coûte **aucune génération**
et donc **aucune attente**. Les chiffres valident son intuition d'un facteur deux à trois : 961 s →
~400 s, et à 300 couches 80 h → ~33 h.

C'est le premier changement depuis #7c qui touche la **cause** — le nombre d'allers-retours — au lieu
de comprimer ce qui transite dans chacun. Et il donne rétrospectivement son sens à la brique #10 :
sans le mécanisme de delta, la révision finale de cette structure ré-émettrait la fiche entière. Elle
n'était pas fausse, elle était incomplète.

**Enfin il a corrigé une bêtise de ma part.** J'avais écrit « 4 questions par jeu, 1 200 décisions
pour 300 couches », comme si 4 était une constante. C'est ce qui est arrivé deux fois, pas une
propriété — et j'avais moi-même écrit au design que *le nombre de questions est une conséquence,
jamais un réglage*. Pire : la charte porte un **plafond déguisé** (« quelques questions structurantes
suffisent »). Il n'y a pas de nombre correct ; cent questions sont légitimes si cent jugements
exigent une autorité que le profil n'a pas.

## 6. Ce que je dois consigner sur moi

**Trois erreurs dans la même journée, toutes de la même famille : présenter comme acquis ce qui ne
l'est pas.**

1. **Le critère 1 « passé décisivement, 3,3 → 1,2 »** est flatté par son dénominateur : la fiche a
   grossi de 72 %. À taille constante, le ratio vaut **2,1** — un échec. Le seul chiffre honnête est
   le brouillon émis, −36 %. J'aurais dû le voir en écrivant le critère.
2. **« Une trouvaille neuve : `at0` contre `at00` »** — elle figure mot pour mot dans la fiche du
   matin. Aucune trouvaille neuve.
3. **« La cause, ce sont les deux re-profilages »** — mesuré après coup : ils expliquent **au plus un
   quart** de la hausse de cache. C'est la question d'Alex, *« comment va-t-on corriger ? »*, qui m'a
   forcé à mesurer et à me déjuger.

Le point commun : à chaque fois le support narratif était bon et l'attribution fausse. Et à chaque
fois c'est **une question d'Alex sur les chiffres** qui l'a exposé — comme *« qu'est-ce que ça
résout ? »* avait retourné une décision la semaine précédente.

## 7. Deux bloquants que la revue finale a trouvés, et qu'aucun test ne pouvait voir

**La garde de prose supprimait une prescription centrale.** « Ne redocumente jamais une colonne déjà
transmise » n'exemptait que le verrou — or la charte impose aussi de résumer les pièges les plus
coûteux au tour de validation, qui portent sur des colonnes transmises. Un modèle obéissant aurait
supprimé la dernière protection avant qu'Alex valide 36 colonnes. Alex a choisi d'énoncer la **règle**
plutôt que d'ajouter une seconde exception — « une liste d'exceptions serait un château de cartes ».

**Un critère de gate était arithmétiquement impossible.** Il exigeait `delta ≤ prose`, ce que le
mécanisme rend inatteignable — et **l'illustration du runbook le démontrait six lignes plus haut**.
Quatre passes d'advisor, six revues, personne. Une séance réussie aurait déclenché le garde-fou D5.

## 8. Leçons

- **On déplace la charge d'un agent, on ne la réduit pas.** Contraindre un canal isolé le fait
  compenser par un autre. Trois fois de suite. Seule une borne globale ne se compense pas.
- **Un proxy se vérifie avant de s'optimiser.** Établir le modèle qui relie la grandeur à l'objectif,
  sinon on optimise à côté pendant trois sessions.
- **Un critère de gate doit être prouvé atteignable**, et reposer sur un mécanisme mesuré et non sur
  un diagnostic de recap. Faire l'arithmétique au moment de l'arrêter.
- **Le gate reste le seul organe qui dise la vérité** — mais il ne suffit pas : c'est la lecture
  humaine de ses chiffres qui a exposé trois erreurs qu'il n'avait pas signalées.
- **Merger une slice dont le gate a échoué se justifie**, à condition de dire pourquoi et de ne pas
  maquiller le verdict. Le CHANGELOG et le catalogue de démo portent « gate échoué — mergée comme
  prérequis », pas « à jour ».

## 9. Alternatives écartées (reportées ici avant suppression des éphémères)

- **Découpage** : « Q-0024 d'abord » écarté car on aurait optimisé le transport d'une charge qu'on
  s'apprêtait à réduire ; « une seule slice pour les quatre leviers » écarté car on n'aurait pas pu
  attribuer un gain à un levier.
- **Mémoire** : « deltas en historique sans rien renvoyer » écarté (un oubli de colonne au tour de
  validation ne se verrait qu'au gate) ; « historique nettoyé + brouillon canonique ré-injecté »
  écarté (même ordre de grandeur en tokens, plus de mécanique, et Python devient rédacteur du prompt).
- **Longueur des questions** : sortie du périmètre en cours de brainstorming, sur la mesure — la prose
  entière pèse 20 % des caractères et ~0,17 $, la raccourcir de moitié économise neuf centimes.
- **Garde de prose** : « ajouter une seconde incise » et « ne rien changer » écartés au profit de la
  règle générique.
- **Critère de gate impossible** : « règle de désambiguïsation dans le runbook » et « garder tel
  quel » écartés au profit du retrait — un gate qu'on ajuste pour qu'il s'ouvre a cessé d'en être un.
- **Densité de la fiche** : « regroupement seul, prose conservée » et « dense partout sans
  regroupement » écartés ; le bloc transversal est de toute façon nécessaire pour réparer la
  régression.
- **Sort de la branche** : « la garder ouverte et y greffer la slice suivante » écarté par Alex au
  profit du merge comme prérequis.

## 10. Pointeurs

- Recap : `slices/2026-08-07-01-brique-10-brouillon-incremental-execution.md`
- Matériel : `research/2026-08-06-brique10-gate-materiel.md` — verdict, mesures, transcript, et
  **§ 8 : le plan de reprise** (structure en deux appels, charte, fiche dense, `thinking=False`) ;
  `research/2026-08-06-RoadTrafficAccidentLocations.fiche.v3.yaml`
- Amont : `journal/2026-08-06-brique8-correction-et-mesure-arbitrable.md`
- ADR : `decisions/0009-architecture-execution-agents.md` (`Proposed`) — sa boucle est questionnée par
  la structure en deux appels, mais **aucune ADR n'est écrite** : elle n'est ni conçue ni
  implémentée, et l'écrire maintenant serait le pattern Henry/Algiz.
- Livraison : `<IMPL:src>` merge `fe091aa`, release `2d46473`, `v0.13.0` — **tags `v0.12.0` et
  `v0.13.0` en attente** (I-3)
- OPEN-QUESTIONS : **Q-0025** (ajout), **Q-0023** (résolue) ; Q-0019 / Q-0024 / Q-0013 / Q-0004 /
  Q-0015 (raffinées)
- Doctrine : trois candidats de promotion écrits dans `CLAUDE.md` avec le token
  `[promotion-candidate]`, **non promus** — à arbitrer par une revue d'usage depuis `methods/spec`.
