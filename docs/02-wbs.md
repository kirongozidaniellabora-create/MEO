# WBS — Organigramme des tâches

> *Work Breakdown Structure* (diapositive 27 du support MEO).
> **Règle des 100 %** : le WBS contient **tout le travail du projet, et rien d'autre**.

## Principes appliqués

1. **Règle des 100 %** — chaque lot couvre 100 % du travail, aucune tâche n'apparaît à deux endroits.
2. **Orienté livrables** — on découpe en **« quoi livrer »** avant « quoi faire ».
3. **Lot de travail (work package)** — le dernier niveau est **estimable** et **confiable** à un
   responsable unique, ce qui permet la charge, la durée et le coût.
4. **Règle 8/80** respectée : aucun lot de travail ne dépasse 80 jours·personne.

---

## Arborescence

```
0.  DIABTRACK — Suivi du diabète (Android)
│
├── 1. Pilotage du projet ................................ 2,0 j·p
│   ├── 1.1 Charte de projet (objectifs SMART, périmètre, jalons)     0,5
│   ├── 1.2 WBS + planning (charge → durée) ........................... 0,5
│   ├── 1.3 Identification et cartographie des parties prenantes .... 0,3
│   ├── 1.4 Registre des risques + plan d'arbitrage (triangle) ........ 0,4
│   └── 1.5 Recette, PV de clôture et retour d'expérience ............ 0,3
│
├── 2. Environnement technique ............................ 1,5 j·p
│   ├── 2.1 Installation du Flutter SDK (stable) ........................ 0,7
│   ├── 2.2 Installation du SDK Android + acceptation des licences ..... 0,5
│   ├── 2.3 Création du squelette du projet + configuration release .... 0,3
│
├── 3. Conception ......................................... 2,0 j·p
│   ├── 3.1 Arborescence fonctionnelle (écrans, navigation) ............. 0,4
│   ├── 3.2 Maquettes des 6 écrans principaux ........................... 0,6
│   ├── 3.3 Charte graphique (couleurs de statut glycémique, thème) ... 0,4
│   └── 3.4 Modèle de données (entités, champs, relations) ............. 0,6
│
├── 4. Socle applicatif ................................... 1,5 j·p
│   ├── 4.1 Thème Material 3 + composants réutilisables ................. 0,4
│   ├── 4.2 Navigation (bottom navigation + onglets) ................... 0,3
│   ├── 4.3 Persistance locale (sérialisation JSON) .................... 0,5
│   └── 4.4 Gestion d'état (ChangeNotifier + ListenableBuilder) ......... 0,3
│
├── 5. LIVRABLE — Journal de glycémie ..................... 2,0 j·p
│   ├── 5.1 Entité GlucoseReading (modèle + conversions) ................ 0,4
│   ├── 5.2 Écran de saisie rapide (objectif : < 20 s) ................. 0,6
│   ├── 5.3 Historique : liste, filtres, regroupement par jour .......... 0,5
│   └── 5.4 Édition, suppression, duplication d'une mesure .............. 0,5
│
├── 6. LIVRABLE — Tableau de bord ........................ 2,0 j·p
│   ├── 6.1 Carte « dernière mesure » + badge de statut ................ 0,4
│   ├── 6.2 Graphique du jour (CustomPainter, sans dépendance) ......... 0,9
│   ├── 6.3 Indicateurs du jour (mesures, moyenne, dans la cible) ...... 0,4
│   └── 6.4 Actions rapides (+1 mesure, + insuline, + repas) ........... 0,3
│
├── 7. LIVRABLE — Traitement & insuline ................... 1,2 j·p
│   ├── 7.1 Entité InsulinEntry (type, dose, basal/bolus) .............. 0,3
│   ├── 7.2 Journal des doses (liste du jour + cumul) .................. 0,5
│   └── 7.3 Rappel du total quotidien vs dose prescrite ................. 0,4
│
├── 8. LIVRABLE — Repas & glucides ....................... 0,8 j·p
│   ├── 8.1 Entité Meal (type, glucides, heure) ....................... 0,3
│   └── 8.2 Journal des repas + répartition des glucides du jour ....... 0,5
│
├── 9. LIVRABLE — Statistiques ........................... 2,0 j·p
│   ├── 9.1 Moyennes, moyenne mobile, amplitude ........................ 0,4
│   ├── 9.2 Temps dans la cible (TIR) à 14 jours ...................... 0,6
│   ├── 9.3 Indicateur de variabilité (écart-type, coefficient) ....... 0,5
│   └── 9.4 Suivi de l'HbA1c et de sa cible ............................ 0,5
│
├── 10. LIVRABLE — Calculateurs .......................... 1,0 j·p
│   ├── 10.1 Dose de correction (glycémie − cible) ÷ sensibilité ........ 0,3
│   ├── 10.2 Insuline pour glucides (glucides ÷ ratio) .................. 0,3
│   └── 10.3 Protocole de correction d'hypoglycémie .................... 0,4
│
├── 11. LIVRABLE — Conseils & éducation ................... 0,8 j·p
│   ├── 11.1 Hypoglycémie / hyperglycémie (urgence + correction) ........ 0,3
│   ├── 11.2 Insulinothérapie, nutrition, activité physique ............. 0.3
│   └── 11.3 Santé du pied, voyages, données personnelles .............. 0,2
│
├── 12. LIVRABLE — Paramètres & données ................... 1,0 j·p
│   ├── 12.1 Profil, objectifs cibles, unité d'insuline ................. 0.3
│   ├── 12.2 Export / import JSON (portabilité des données) ............ 0.4
│   └── 12.3 Réinitialisation et jeu de démonstration .................... 0.3
│
├── 13. Qualité ........................................... 2,5 j·p
│   ├── 13.1 Analyse statique (`flutter analyze` à 0 erreur) ........... 0.5
│   ├── 13.2 Tests unitaires (TIR, dose de correction, sérialisation) .. 1.0
│   ├── 13.3 Revue de code (nommage, documentation, doublons) .......... 0.5
│   └── 13.4 Traitement des défauts bloquants (correction) .............. 0.5
│
└── 14. Livraison ........................................ 1,0 j·p
    ├── 14.1 Documentation utilisateur (README + aide integrated) ....... 0.4
    ├── 14.2 Build de l'APK release ..................................... 0.3
    ├── 14.3 Installation sur l'appareil + vérification de persistance ... 0.3
```

---

## Charge, durée, ressource

Trois notions **différentes** (diapositive 24-25) — à ne jamais confondre :

| Notion | Définition | Unité | Où sert-elle ? |
|---|---|---|---|
| **Livrable** | Résultat vérifiable produit par le projet | — | Recette, PV de validation |
| **Jalon** | Événement clé à une date donnée, **durée nulle** | date | Suivi de l'avancement |
| **Tâche (activité)** | Travail à réaliser, avec début, fin, ressources | — | Affectation |
| **Ressource** | Personne, machine, matériel ou budget mobilisé | U | Coût |
| **Charge (effort)** | **Quantité de travail** | **jours·personne** | **le budget** |
| **Durée** | Temps calendaire entre début et fin | jours | **le planning** |

`Durée = Charge ÷ Nombre de ressources` — **jusqu'à une certaine limite** seulement.

### Exemple appliqué au lot 6 « Tableau de bord »

Charge = 2,0 j·p.

| Ressources | Durée théorique | Validité |
|---|---|---|
| 1 développeur | 2 jours | ✔ réaliste |
| 2 développeurs | 1 jour | ⚠ trop optimiste : la revue et les corrections s'ajoutent |
| 4 développeurs | 0,5 jour | ✘ **impossible** : 4 personnes ne font pas 4× plus vite un travail de création (le dessin du graphique, la mise au point du `CustomPainter` est séquentiel) |

> C'est exactement la démonstration de la diapositive 25 (8 peintres dans 4 salles) : la
> coordination et les temps incompressibles (compilation, revue, séchage) limitent le gain.
> **On raisonne donc en charge (j·p) et on convertit prudemment en durée.**

### Tableau de charge par lot (récapitulatif)

| Lot | Charge (j·p) | Durée retenue | Ressources | Raison |
|---|---:|---:|---|---|
| 1. Pilotage | 2,0 | 2 j | 1 | Documentaire, séquentiel |
| 2. Environnement technique | 1,5 | 1,5 j | 1 | Installation + téléchargements en arrière-plan |
| 3. Conception | 2,0 | 2 j | 1 | Créatif, non parallélisable |
| 4. Socle applicatif | 1,5 | 1,5 j | 1 | Technique |
| 5. Journal de glycémie | 2,0 | 2 j | 1 | Technique |
| 6. Tableau de bord | 2,0 | 2 j | 1 | Graphique = travail de réglage |
| 7. Traitement | 1,2 | 1,5 j | 1 | +0,3 j de marge (données physiologiques) |
| 8. Repas | 0,8 | 1 j | 1 | +0,2 j de marge |
| 9. Statistiques | 2,0 | 2,5 j | 1 | +0,5 j de marge (formules à vérifier) |
| 10. Calculateurs | 1,0 | 1 j | 1 | Formules simples |
| 11. Conseils | 0,8 | 1 j | 1 | Rédaction de contenu |
| 12. Paramètres | 1,0 | 1 j | 1 | Technique |
| 13. Qualité | 2,5 | 3 j | 1 | Les tests révèlent des défauts : il faut du temps pour les corriger |
| 14. Livraison | 1,0 | 1 j | 1 | Build + installation |
| **TOTAL** | **22,5** | **≈ 23,5 j calendaires** | **1** | + marge ≈ 1 j (≈ 4 %) |

La marge de 1 jour correspond au **plan de repli** : elle absorbe les aléas sans toucher au délai,
puisque le délai est la contrainte que l'on ne peut pas négocier.
