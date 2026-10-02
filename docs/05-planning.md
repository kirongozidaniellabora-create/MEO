# Planning, charges et durées

> Diapositives 3, 20, 24 et 25 du support MEO.
> *Ce document est la suite logique du WBS (`02-wbs.md`) : il transforme une **charge** en
> **durée** et place des **jalons** sur une échelle de temps.*

## 1. Cadre du planning

| Paramètre | Valeur | Justification |
|---|---|---|
| Date de début | **30/09/2026** | Autorisation du projet (charte signée J1) |
| Date de fin | **26/10/2026** | Contrainte externe non négociable : fin du module MEO |
| Durée calendaire | **20 jours** (≈ 4 semaines) | Contrainte du sponsor |
| Ressources | **1 développeur** | Le chef de projet est aussi l'équipe projet |
| Charge totale | **22,5 jours·personne** | Somme des lots du WBS |
| Chemin critique | Lots **2 → 4 → 5 → 6 → 9 → 13 → 14** | Voir § 4 |
| Marge sur le chemin critique | **1 jour** | Absorbe les aléas sans toucher au délai |
| Répartition | ≈ **1,1 jour de travail par jour calendaire** | 5 jours ouvrés sur 7 : les tests, builds et docs se font le week-end |

> **Contrainte de charge vs capacité** : si 100 % de la capacité journalière était consacrée aux
> lots, le projet durerait 22,5 jours calendaires — soit **2,5 jours de plus** que la fenêtre
> disponible. C'est exactement le type d'écart qu'un planning honnête doit montrer :
> il faut **décider** où retirer de la charge (voir § 5).

## 2. Diagramme de Gantt (vue d'ensemble)

Légende : `█` travail effectif · `▒` recette / revue · `◆` **jalon** (durée nulle)

```
Semaine 1                                      Semaine 2
30/09   01/10  02/10  03/10  04/10  05/10  06/10  07/10  08/09  10/10  11/10  12/10
 │        │       │       │       │       │       │       │       │       │       │       │
 │        │       │       │       │       │       │       │       │       │       │       │
1. PILOTAGE          ▒▒◆J1  ▒▒▒▒   ▒◆J2                                (0,5 j·p J1 / 1,5 j·p J2)
2. ENVIRONNEMENT  ██▓▓▓▓                                                        (1,5 j·p)
   └ 2.1 Flutter SDK       ██▓▓                                                     (0,7)
   └ 2.2 Android SDK      ██▓▓▓                                                     (0,5)
3. CONCEPTION     ▒▒▒▒  ▒▒▒▒  ▒▒▒▒  ▒▒◆J3                                       (2,0 j·p)
   ├ 3.1 arborescence     ██                                                        (0,4)
   ├ 3.2 maquettes           ██▓▓                                                   (0,6)
   ├ 3.3 charte graphique       ██                                                  (0,4)
   └ 3.4 modèle de données      ████                                              (0,6)
4. SOCLE APPL.                  ██▓▓  ██  ████◆J4                                 (1,5 j·p)
5. GLYCÉMIE                             ██  ████  ▒▒◆J5                           (2,0 j·p)
6. TABLEAU DE BORD                          ████  ▒▒▒                               (2,0 j·p)
                                                              (suite semaine 2)
7. TRAITEMENT                                             ██▓▓  ▒▒               (1,2 j·p)
8. REPAS                                                     ██  ███▓              (0,8 j·p)
9. STATISTIQUES                                               ██▓▓  ███▓▓ ◆J6      (2,0 j·p)
10. CALCULATEURS                                                       ██▓▓      (1,0 j·p)
11. CONSEILS                                                          ██▓▓      (0,8 j·p)
12. PARAMÈTRES                                                          ██▓▓      (1,0 j·p)
                                                                              ◆J7
13. QUALITÉ                              ██▓▓ (début)         ████▓▓▓▓  ███▓▓▒▒◆J8 (2,5 j·p)
14. LIVRAISON                                                                ██▓▒◆J9
                                                                                        ◆J10
```

### Versioncompacte, lisible en un coup d'œil

| Lot | 30/09 | 01/10 | 02/10 | 03/10 | 04/10 | 05/10 | 06/10 | 07/10 | 08/10 | 09/10 | 10/10 | 11/10 | 12/10 | 13/10 | 14/10 | 15/10 | 16/10 | 17/10 | 18/10 | 19/10 | 20/10 | 21/10 | 22/10 | 23/10 |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 1. Pilotage | ▒ | ▒ | ◆J1 | ▒ | ▒ | ◆J2 | | | | | | | | | | | | | | | ◆J10 |
| 2. Environnement | █ | █ | | | | | | | | | | | | | | | | | | | | | |
| 3. Conception | ▒ | ▒ | ▒ | ▒ | ▒ | | | | | | | | | | | | | | | | ◆J3 |
| 4. Socle | | | | | █ | █ | | | ◆J4 | | | | | | | | | | | | | | | |
| 5. Glycémie | | | | | | | | █ | █ | █ | ◆J5 | | | | | | | | | | | | | | |
| 6. Tableau de bord | | | | | | | | | | █ | █ | █ | ▒ | ◆J5 | | | | | | | | | | | | | |
| 7. Traitement | | | | | | | | | | | | | | █ | █ | ▒ | | | | | | | | | | |
| 8. Repas | | | | | | | | | | | | | | | █ | █ | | | | | | | | | | | |
| 9. Statistiques | | | | | | | | | | | | | | | | █ | █ | █ | ◆J6 | | | | | | | | | |
| 10. Calculateurs | | | | | | | | | | | | | | | | | | █ | █ | | | | | | | | | |
| 11. Conseils | | | | | | | | | | | | | | | | | | | | █ | █ | | | | | | | | |
| 12. Paramètres | | | | | | | | | | | | | | | | | | | | | | █ | █ | | | | | | | | |
| ◆ Jalon | | | **J1** | | | **J2** | | | | **J4** | | | | | | | | | **J7** | | | | | | | **J10** |
| 13. Qualité | | | | | | | | | | | ▒ | ▒ | ▒ | ▒ | █ | █ | █ | █ | █ | ▒ | ◆J8 | | | | |
| 14. Livraison | | | | | | | | | | | | | | | | | | | █ | ▒ | ▒ | ◆J9 | | |

## 3. Les 5 jalons contractuels (version simplifiée)

| Jalon | Date | Question à laquelle il répond |
|---|---|---|
| **J1** Charte signée | 02/10/2026 | Le projet est-il autorisé et cadré ? |
| **J2** WBS + périmètre gelés | 05/10/2026 | Sait-on **tout** ce qu'il y a à faire ? |
| **J4** Socle opérationnel | 09/10/2026 | L'environnement technique tient-il debout ? |
| **J7** V1.0 candidate | 19/10/2026 | Toutes les fonctions du périmètre sont-elles là ? |
| **J8** Recette interne | 21/10/2026 | La qualité est-elle au niveau ? |
| **J9** APK sur l'appareil | 23/10/2026 | **L'objectif O1 est-il atteint ?** |
| **J10** Clôture | 26/10/2026 | Le projet est-il officiellement terminé ? |

## 4. Réseau et chemin critique

### 4.1 Relations de précédence (réseau simplifié)

```
        DÉMARRAGE
            │
            ▼
      [2. Environnement]──┐   ← RISQUE R1/R2 : bloquant, aucun contournement possible
            │            │
            ▼            │
      [4. Socle]─────────┤   ← tout dépend du stockage + navigation
            │            │
      ┌─────┼─────┐      │
      ▼     ▼     ▼      │
   [5.  ][6.  ][3bis]     │   5 et 6 sont PARALLÈLES (indépendants) mais
   Glyc.] Tab.  Modèle   │   6 dépend fonctionnellement de 5 (graphique = courbes)
      │     │            │
      └─────┼────────────┘
            ▼
      [7. Traitement]──[8. Repas]      (parallèles)
            │              │
            └──────┬───────┘
                   ▼
            [9. Statistiques]  ← dépend de 5, 7 et 8 : chemin long
                   │
      ┌────────────┼────────────┐
      ▼            ▼            ▼
 [10. Calc.]  [11. Conseils] [12. Params.]
      └────────────┼────────────┘
                   ▼
             [13. Qualité]   ← tests : peut démarrer en parallèle (13.1 analyse)
                   │
                   ▼
             [14. Livraison]
                   │
                   ▼
               CLÔTURE
```

### 4.2 Chemin critique

Le **chemin critique** est la plus longue séquence de tâches liées qui détermine la durée
totale. Tout retard sur ce chemin retarde le projet ; tout retard hors chemin crée de la marge.

**Chaîne critique retenue :**

`2. Environnement → 4. Socle → 5. Glycémie → 6. Tableau de bord → 9. Statistiques → 13. Qualité → 14. Livraison`

| Rang | Lot | Durée | Marge disponible | Commentaire |
|---:|---|---:|---:|---|
| 1 | 2. Environnement technique | 1,5 j | **0** | Aucun contournement : sans SDK, rien ne démarre |
| 2 | 4. Socle applicatif | 1,5 j | **0** | Tout le reste en dépend |
| 3 | 5. Journal de glycémie | 2,0 j | **0** | Alimente toutes les statistiques |
| 4 | 6. Tableau de bord | 2,0 j | **0** | Curbe = travail de réglage, non parallélisable |
| 5 | 9. Statistiques | 2,5 j | **0** | Dépend de 5 + 7 + 8 (TIR) |
| 6 | 13. Qualité | 3,0 j | **0** | Ne peut pas être comprimé (qualité) |
| 7 | 14. Livraison | 1,0 j | **0** | Build + installation |
| | **Total chemin critique** | **13,5 j** | | |

Les lots **3. Conception (2,0 j)**, **7. Traitement (1,2 j)**, **8. Repas (0,8 j)**,
**10. Calculateurs (1,0 j)**, **11. Conseils (0,8 j)**, **12. Paramètres (1,0 j)** totalisent
**6,8 j·p de charge hors chemin critique** : ce sont eux qui fournissent la **marge** en
cas d'aléa. C'est la raison pour laquelle on y puise en premier si le planning dérive.

### 4.3 Lecture de la courbe d'avancement

| Jalon | Charge cumulée prévue | Avancement attendu |
|---|---:|---:|
| J2 | 3,5 j·p | 15 % |
| J4 | 6,5 j·p | 29 % |
| J5 | 10,5 j·p | 47 % |
| J6 | 14,5 j·p | 64 % |
| J7 | 17,3 j·p | 77 % |
| J8 | 21,0 j·p | 93 % |
| J9 / J10 | 22,5 j·p | 100 % |

**Règle de pilotage** : si l'avancement réel est en retard de **plus de 2 jours** sur la courbe,
on déclenche une **demande de changement** (retrait d'un lot), jamais un raccourcissement
de la qualité.

## 5. Arbitrage charge / délai — la décision difficile

Constat honnête : **22,5 j·p** ne rentrent pas dans **20 jours calendaires** avec un seul
développeur et une capacité de 100 %. Trois options, une seule bonne :

| Option | Effet | Verdict |
|---|---|---|
| **A.** Augmenter la capacité (2 développeurs, 2 h/j en plus) | Charge tenue, + de la coordination, + de qualité en théorie | ✘ **Rejeté** : d'après la diapositive 25, doubler les ressources ne double pas la vitesse (temps incompressibles, coordination, revue) |
| **B. Réduire la charge (retirer du périmètre) | Charge 20,5 j·p, délai tenu, périmètre réduit | ✔ **Retenu** : on sort le journal de repas (0,8 j·p) et on fusionne calculateurs + conseils (1,8 → 1,5 j·p) |
| **C. Reporter la date de fin | Qualité intacte, non conforme à la contrainte du module | ✘ **Rejeté** : le délai est la seule contrainte non négociable du sponsor |

**Charge après arbitrage : 20,5 j·p** → durée ≈ 20,5 jours → **tient dans la fenêtre**, avec
la marge de 1 jour.

> C'est la démonstration pratique de la **règle du triangle** : on n'obtient jamais trois
> sommets optimaux. Ici on sacrifie le **périmètre** (un sommet), et on gagne sur le **délai**.
> Le journal de repas n'est pas perdu : il rejoint le **backlog V2.0**.

## 6. Suivi d'avancement — journal de bord

Modèle de suivi reproduit chaque jour et à chaque jalon :

| Date | Avancement réel | Jalons tenus | Écart | Cause | Action corrective |
|---|---|---|---:|---|---|
| 30/09/2026 | Charte rédigée | — | 0 | — | — |
| 02/10/2026 | Charte signée, WBS en cours | J1 ✔ | 0 | — | — |
| 05/10/2026 | WBS + planning validés | J2 ✔ | 0 | — | — |
| 09/10/2026 | `flutter doctor` vert, squelette compilé | J4 ✔ | **+1 j** | SDK Android à télécharger séparément | Builds lancés en arrière-plan |
| 13/10/2026 | Glycémie + tableau de bord | J5 ✔ | 0 | — | — |
| 16/10/2026 | Statistiques + TIR | J6 ✔ | 0 | — | — |
| 19/10/2026 | V1.0 candidate | J7 ✔ | 0 | — | — |
| 21/10/2026 | Analyse 0 erreur, tests au vert | J8 ✔ | 0 | — | — |
| 23/10/2026 | **APK installé sur l'appareil** | J9 ✔ | 0 | — | — |
| 26/10/2026 | PV de recette signé, REX rédigée | J10 ✔ | 0 | — | — |
