# Journal — Le gate qui échoue par excès inverse, et la mesure qui tranche

- Date : 2026-08-04 → 2026-08-05
- Participants : Alex ; Claude
- Nature : **deux slices**. Brique #8 (qualité conversationnelle du curateur) — cycle complet
  brainstorming → design → plan → **3 passes advisor** → exécution subagent-driven (3 tâches) →
  revue finale → **gate humain ÉCHOUÉ**, branche laissée ouverte, **non mergée**. Brique #9
  (mesure du coût et du temps) — cadrée en réaction, **shippée v0.11.0** (merge `e86c817`,
  release `120fc16`, tag en attente).
- Temps engagé ≈ **4h11** (sessions du 04/08) ; span git #8+#9 : 04/08 16:01 → 05/08 01:06 ≈ **9h**.

---

## 1. Le pari de #8, et pourquoi il était raisonnable

Le gate humain de #7c avait établi une hiérarchie nette : charte terse = robotique ; charte
« naturelle » = mieux mais insuffisant ; **charte + précision live d'Alex = excellent**. Q-0022
demandait de rendre ce niveau 3 actif par défaut.

Le diagnostic posé au brainstorming : ce n'est pas un « ton », c'est une **forme de tour**
prescriptible, lisible telle quelle dans le transcript gold-standard — verrou du point acquis
formulé par sa conséquence, question ancrée sur les chiffres du profil, enjeu rendu tangible par
un mécanisme, options fermées, « je ne sais pas » légitime. Alex a confirmé : **structure +
registre**, pas le rythme. Et il a apporté la précision décisive : avec ~2 min de latence par
tour, « une question à la fois » est contre-productif — **la contrainte porte sur la question,
pas sur le tour**.

Trois décisions ont suivi : forme prescrite + **gabarit** qui la montre (les adjectifs avaient
déjà échoué en v0.10.1) ; **prose hors du bloc JSON** ; et **D3 — la fiche complète n'est émise
qu'au tour final**, les brouillons intermédiaires n'étant pas consommés et coûtant des milliers
de tokens de génération par tour.

## 2. Trois passes d'advisor, dont une qui corrige la précédente

Passe 1 (6 MUSTs) : un vrai bug de parsing (tour **muet** si le modèle ouvre par son bloc), la
charte qui se contredisait, la **suppression des quatre amorces type-level** dont le gold dépend,
et des commandes de gate invérifiables.

Passe 2 (2 MUSTs) : **elle corrige la passe 1**. La garde que la passe 1 avait fait ajouter
relançait le LLM *sans humain dans la boucle* — donc sans borne, la boucle `run_agent` n'ayant
aucun compteur — et son message aurait été gravé par l'orchestrateur en `human_turn` /
`actor: "human"` : **un tour humain qui n'a pas eu lieu dans une trace probante**. Second MUST :
la charte demandait à l'agent de « garder en mémoire » des arbitrages, instruction impossible —
il est sans état entre les tours.

Passe 3 (1 MUST) : les deux ajouts de la passe 2 étaient écrits dans les *prescriptions* mais
jamais propagés au **gabarit** — or c'est l'exemple qui porte, pas la consigne.

**Leçon de méthode** : la passe fraîche par advisor n'est pas une formalité. Deux fois sur trois,
la passe N a trouvé un défaut **créé** par la correction de la passe N−1.

## 3. Le gate : le mur de texte

Sur l'OFROU brut, **les questions sont bonnes** — objet, chiffres, enjeu, options, penchant
assumé avec son indice contraire. C'est la ligne « **Tranché seul :** » qui rend le tour
illisible : une vingtaine de colonnes documentées d'affilée, verdicts longs, en une seule coulée.

Le mode d'échec est l'**inverse** de celui qu'on corrigeait : plus télégraphique, mais saturé.
Et il était **annoncé** : la revue finale de #8 l'avait classé risque n°1 (« le tour devient un
mur »), signalé à Alex, et **non traité** — la décision du batch étant la sienne, motivée par la
latence vécue. Le risque s'est réalisé.

**Diagnostic causal** : en supprimant le `fiche_draft` intermédiaire (D3), on a privé l'agent de
sa mémoire structurée et on l'a forcé à la porter **en prose** — c'est-à-dire dans le seul canal
que l'humain lit. Le brouillon JSON faisait ce travail mieux : structuré, cumulatif, et **jamais
affiché** (`_next_input` ne montre que `message`). *On a déplacé la mémoire de la soute vers le
salon.* Alex l'avait pressenti mot pour mot : « avec la fiche, la charte me paraissait plus
concise ».

Son inquiétude — « ces petits ajustements ressemblent à des `if` de langage naturel pour tenir un
château de cartes » — était fondée et je l'ai reconnue : la charte est passée de 45 à 145 lignes,
dont **quatre rustines qui découlent toutes de D3**.

## 4. La brique #9 : mesurer avant d'arbitrer

D3 existait pour une raison (≈ 2 min/tour). Sans mesure, on troquait un défaut contre un autre à
l'aveugle. Alex a demandé une instrumentation **pérenne** : « pouvoir mesurer les coûts autant
financier que temps de toutes les actions pertinentes ».

Principe retenu : **la mesure n'est pas un organe, c'est une lecture de la trace.** Le greffier
capturait déjà tout — sauf qu'on ne le relisait pas. Deux découvertes ont cadré la slice :

- le SDK expose `duration_ms`, `duration_api_ms`, `total_cost_usd`, `usage` ; leur différence
  donne le temps hors appel LLM ;
- **le greffier les jetait** : `result_meta` est **écrasée à chaque tour** (décision cohérente au
  temps du seul analyste mono-tour). Choix d'Alex : la fin de tour devient **un nœud horodaté**.

Découverte à l'écriture du plan, qui a corrigé le design : le `ts` était **écrit** en base mais
jamais **relu** — la durée d'un appel d'outil était littéralement incalculable. Correction
asymétrique à dessein : `TraceBuilder` reste **pur** (aucune horloge), le store est l'unique
autorité du temps.

La revue finale a trouvé le défaut qui comptait : les **totaux** affichaient `0` là où la valeur
est **inconnue** — une session interrompue avant le premier retour du SDK annonçait « 0,0000 USD »
à côté de 200 s de temps réel. Et surtout : `duration_ms − duration_api_ms` **n'est pas** le coût
des outils (l'orchestrateur relance une requête neuve à chaque tour : démarrage du CLI et
amorçage du serveur MCP y tombent). Renommé `non_api_ms`, avec la décomposition qui tranche
vraiment — outils réellement mesurés vs reste.

## 5. Le chiffre

Run interrompu après un tour, sur la branche #8 instrumentée :

```
Session … [aborted]
  bout en bout : 145.1s · coût total : 0.4194 USD · 1 tour(s)
  dont API : 138.8s · hors API : 2.4s
    dont outils mesurés : 3.1s
  #1 141.2s · in 6 / out 9939 tokens
  ToolSearch 0.9s · ToolSearch 0.0s · mcp__intreepid__profile_raw 2.2s
```

Et l'`usage` complet : `cache_read_input_tokens: 43781`, `cache_creation: 14900`,
`input_tokens: 6`, `output_tokens: 9939`.

**Lecture** :
- **98 % du temps est de la génération** (138,8 s d'API sur 141,2). Le re-profilage de 267 761
  lignes coûte **2,2 s**. Le démarrage de processus est négligeable. Toutes les hypothèses sur les
  outils tombent.
- **Le cache d'entrée fonctionne déjà pleinement** : 43 781 tokens relus, 6 facturés au plein
  tarif. L'idée d'Alex d'« appender pour profiter du cache » est **déjà réalisée de facto** —
  `build_prompt` re-sérialise un préfixe byte-stable. Rien à optimiser de ce côté.
- **Le seul levier est la sortie** : 9 939 tokens pour un tour, 0,42 $.

**Conclusion qui n'était pas visible avant la mesure** : ni le brouillon ni « Tranché seul » ne
sont le problème en soi — le problème est que l'agent **régénère l'intégralité de sa mémoire à
chaque tour**, quelle qu'en soit la forme. On avait remplacé un pavé invisible par un pavé
visible : même coût, lisibilité en moins. Or **l'historique lui est déjà ré-injecté et mis en
cache** : le faire réécrire est un pur gaspillage.

## 6. Une hypothèse réfutée, à ne pas raconter faussement

Le levier « sortir la prose du JSON » reposait sur l'idée qu'une chaîne JSON échappée pousse à la
compression. **C'est faux** : le gold-standard a été produit *avec* la prose dans le JSON, et il
est excellent. Le format n'était pas le frein.

On garde néanmoins le format prose + bloc de métadonnées, mais pour une **autre raison** : à
10 000 tokens de sortie, un JSON malformé fait perdre **tout le message** ; en prose libre, le
repli conserve le texte et seules les métadonnées sont perdues. **Robustesse, pas compression.**
Écrit ici pour que la prochaine session n'hérite pas d'une justification fausse.

## 7. Leçons

- **Le risque signalé et non traité se réalise.** La revue finale avait nommé « le tour devient un
  mur » comme risque n°1. Le signaler ne suffit pas ; il aurait fallu soit le traiter, soit
  décider explicitement de le laisser courir en sachant que le gate n'a qu'une itération.
- **Mesurer avant d'arbitrer.** Trois décisions de charte reposaient sur une intuition de latence.
  Une seule mesure les a toutes réorientées — et elle a coûté moins cher qu'un run de démo.
- **Écouter l'inquiétude de l'humain sur la forme du système**, pas seulement sur son résultat.
  « Château de cartes » était un diagnostic juste, formulé avant que la mesure ne le confirme.
- **Une hypothèse invoquée pour justifier un changement doit être vérifiée ou requalifiée.**
  Sinon elle se fossilise en fausse évidence.
- **La passe advisor fraîche gagne son coût** : elle corrige aussi les corrections.

## 8. POINTEUR DE REPRISE — correction de #8 (à cadrer en session fraîche)

> État : branche `brique-8-curateur-naturel` **ouverte, non mergée**, à jour avec `main`
> (merge `38f5046`), gate vert (140 tests). Sa charte est **celle qui a produit le mur**.

**Décision prise avec Alex (2026-08-05), à implémenter** : **brouillon incrémental invisible.**

- Le curateur n'émet plus que les colonnes **nouvellement** tranchées ; **Python accumule** au fil
  des tours (fusion par clé sous `columns`) et garantit la fiche complète au tour final.
- La ligne « **Tranché seul :** » **disparaît**, et avec elle les **quatre rustines** de charte
  qu'elle avait entraînées : le rappel dans § Forme, l'avertissement « ta seule mémoire est le
  texte », le « rappelle `profile_raw` avant la fiche finale », et l'illustration au gabarit. La
  charte redescend autour de **120 lignes**.
- **Concession à tracer** : la fiche cesse d'être un objet totalement opaque pour Python. La
  fusion reste **générique** (accumulation par clé, aucune sémantique métier), mais c'est un recul
  assumé sur la décision #5 de #7c (« Python = transporteur opaque »). Recoupe **Q-0023**.
- Deux corrections à embarquer dans `scribe/metrics.py` : afficher les **tokens de cache**
  (le rapport affiche « in 6 » et tait 58 000 tokens) ; supprimer le **résidu négatif**
  (« démarrage : −0,7 s ») — les durées d'outil (horodatages côté orchestrateur) et le temps
  hors-API (SDK) ne sont pas commensurables et ne doivent pas se soustraire.
- **Ne pas re-tuner la charte au gate** : garde-fou D5 déjà écrit au runbook — une seule itération,
  sinon on arrête et on cadre l'approche C (contrat de tour structuré, rendu composé par la
  surface).

**Reste ouvert après ça** : la latence par tour restera de l'ordre de la minute tant que la sortie
est longue — la question « combien de tokens un tour doit-il coûter » est la vraie inconnue de
l'UX conversationnelle.

## 9. Pointeurs

- Recap : `slices/2026-08-05-01-brique-9-mesure-cout-et-temps-execution.md`
- Matériel : `research/2026-08-04-curateur-gate-humain-materiel.md` (gold-standard),
  `research/RoadTrafficAccidentLocations.fiche.example.yaml`
- Amont : `journal/2026-08-04-brique7c-curateur-conversationnel.md` (origine de Q-0022)
- ADR : `decisions/0009-architecture-execution-agents.md` (`Proposed`)
- Livraison #9 : `<IMPL:src>` merge `e86c817`, release `120fc16`, `v0.11.0` — **tag user-driven en attente**
- OPEN-QUESTIONS : **Q-0023** (ajout), **Q-0007** (résolue) ; Q-0022 / Q-0014 / Q-0013 / Q-0004 (raffinées)
