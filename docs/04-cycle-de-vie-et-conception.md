# Cycle de vie, approche et conception

> Diapositives 19, 20, 21 et 22 du support MEO.

## 1. Projet, programme, portefeuille

| Niveau | Définition | Exemple du support | Chez DiabTrack |
|---|---|---|---|
| **Projet** | Crée un résultat **unique** dans une **durée limitée** | Installer un logiciel de suivi de production | **DiabTrack V1.0** (1 application, 20 jours) |
| **Programme** | Groupe de projets liés pilotés **ensemble** pour des bénéfices impossibles à atteindre séparément | « Usine 4.0 » (logiciel + robotisation + formation) | Feut une **V2.0** (Bluetooth lecteur, CGM, notifications) |
| **Portefeuille** | Ensemble des projets, programmes et opérations d'une organisation, sélectionnés selon la stratégie | « Transformation industrielle 2030 » | Le **parcours MEO de l'étudiant** (MEO, EEE, MIA, MME, HUM) |

**Lien projet / opérations** : à la fin du projet, le résultat est **remis aux opérations** qui
l'exploitent. Ici, à la clôture (J10), l'application passe en **usage quotidien** par le patient ;
le développement, lui, s'arrête. C'est le critère décisif de la diapositive 5.

## 2. Les cinq groupes de processus (cycle de vie)

> *« Groupes de processus » dans le PMBOK 6, « Focus Areas » dans le PMBOK 8 (2025).
> Les phases concrètes varient selon le secteur.*

| Groupe | Ce qu'on y fait | **Sortie clé** (livrable) | Application DiabTrack | Dates |
|---|---|---|---|---|
| **1. Démarrage** | Autoriser le projet | **Charte de projet** | Charte signée, chef de projet nommé | 30/09 → 02/10 |
| **2. Planification** | Définir **comment** atteindre l'objectif | Plan de management, **WBS**, planning | WBS, planning, matrice des parties prenantes, risques | 02/10 → 09/10 |
| **3. Exécution** | Réaliser le travail | **Livrables** | Code des 12 lots applicatifs | 09/10 → 21/10 |
| **4. Clôture** | Faire valider, transférer, capitaliser | **PV de recette**, retour d'expérience | APK installé, PV signé, REX, backlog V2 | 21/10 → 26/10 |

**+ Surveillance et maîtrise — en continu** : mesurer l'avancement, comparer au plan, corriger,
gérer les changements. Concrètement chez moi : un **journal de bord** quotidien et un
**tableau de bord d'avancement** mis à jour à chaque jalon.

## 3. « Décider tôt coûte moins cher »

```
     Coût d'un changement
     ▲
     │                                          ╱
     │                                       ╱
     │                                    ╱
     │                                 ╱
     │                        ╱········╱
     │          ╱············╱
     │  ╱·····╱
     └──┴──────┴────────┴────────┴────────┴──────▶
      Démarrage  Planification  Exécution  Clôture

     Capacité d'influence sur le résultat : maximale au DÉBUT, quasi nulle à la fin
```

*(Courbes illustratives de tendance, conformément à la mention du support « sans valeurs mesurées ».)*

**À retenir** : au début, les décisions **coûtent peu** et **pèsent lourd** sur le résultat. En fin
de projet, chaque modification coûte cher.

**Conséquence pratique — c'est la justification de tout le cadrage preceding** :
investir du temps dans la charte, le WBS et le planning. *Une heure de réflexion au démarrage évite
des semaines de reprise.*

| Décision prise | Coût si prise à J1 | Coût si prise à J18 | Gain |
|---|---:|---:|---:|
| Choisir Flutter + stockage local | 0,2 j·p | 4 j·p (réécriture) | **×20** |
| Geler le périmètre | 0,2 j·p | 3 j·p (reprise de 6 lots) | **×15** |
| Valider les 6 maquettes | 0,3 j·p | 2 j·p (refonte d'ergonomie) | **×7** |
| Nommer un interlocuteur unique | 0,1 j·p | 1,5 j·p (allers-retours) | **×15** |

## 4. Trois approches possibles

| Approche | Principe | Adaptée si | Exemples du support |
|---|---|---|---|
| **Prédictive** (« en cascade ») | Périmètre, délai et coût fixés au départ ; les phases se suivent | Besoin **stable et bien connu** | Construction, installation industrielle |
| **Adaptative** (agile) | Livraisons courtes et fréquentes ; le périmètre évolue selon les retours | Besoin **incertain ou évolutif** | Logiciel, innovation produit |
| **Hybride** (mixte) | Cadre prédictif global, parties menées en itérations | Projets mêlant **matériel et logiciel** | Machine connectée, usine 4.0 |

### Choix retenu : **HYBRIDE**

| Élément | Traitement | Justification |
|---|---|---|
| Cadrage (charte, budget, jalons, périmètre) | **Prédictif** | Le besoin est connu, l'échéance scolaire est fixe |
| Développement du code | **Adaptatif** | Le framework Flutter est exploratoire : itérations courtes |
| Livraison | **Hybride** | Jalons fixes, mais contenu ajusté à chaque itération |

**Itérations de 7 jours** à l'intérieur de la phase d'exécution, chacune se terminant par une
**revue + démonstration** :

| Itération | Contenu | Jalon de sortie | Charge |
|---|---|---|---:|
| S1 | Socle : thème, navigation, persistance, modèles | J4 | 4,5 j·p |
| S2 | Journal de glycémie + tableau de bord | J5 | 4,0 j·p |
| S3 | Insuline, repas, statistiques | J6 | 4,0 j·p |
| S4 | Conseils, calculateurs, paramètres | J7 | 4,3 j·p |
| S5 | Qualité (tests, analyse), corrections, livraison | J8–J9 | 3,5 j·p |
| Clôture | PV + REX | J10 | 0,3 j·p |

**Définition de « terminé » (DoD)** pour une tâche :
`code écrit + analyse statique sans erreur + test unitaire si calcul + écran atteignable et lisible
sur un écran de 5,5 pouces`.

## 5. Conception fonctionnelle (maquettes)

### 5.1 Arborescence des écrans

```
DiabTrack
├── 1. Onboarding (une seule fois)
│   ├── 1.1 Accueil / présentation
│   ├── 1.2 Type de diabète (type 1 / type 2 / autre)
│   ├── 1.3 Objectifs cibles (à jeun, post-prandial, HbA1c)
│   └── 1.4 Consentement + avertissement médical
│
├── 2. Accueil (Tableau de bord)          ← onglet 1
│   ├── 2.1 Carte « dernière mesure » + badge de statut coloré
│   ├── 2.2 Graphique du jour (courbe + zones de statut)
│   ├── 2.3 Indicateurs : mesures, moyenne, % dans la cible
│   ├── 2.4 Insuline du jour, glucides du jour
│   └── 2.5 Actions rapides (3 boutons ronds)
│
├── 3. Mesures (Journal de glycémie)      ← onglet 2
│   ├── 3.1 Liste groupée par jour, filtres (7 j / 30 j / tout)
│   ├── 3.2 Formulaire de saisie rapide
│   ├── 3.3 Détail / édition / suppression / duplication
│   └── 3.4 Contexte : moment, repas lié, sport, sommeil, stress, notes
│
├── 4. Traitement (Insuline)              ← onglet 3
│   ├── 4.1 Journal des doses du jour
│   ├── 4.2 Basal / bolus, type d'analogue, lot de stylo
│   ├── 4.3 Cumul quotidien vs dose prescrite
│   └── 4.4 Saisie rapide
│
├── 5. Plus (Statistiques, Repas, Conseils, Paramètres)  ← onglet 4
│   ├── 5.1 Statistiques : moyennes, TIR 14 j, variabilité, HbA1c
│   ├── 5.2 Repas & glucides
│   ├── 5.3 Conseils & éducation diabétologique
│   ├── 5.4 Calculateurs (correction, glucides, hypoglycémie)
│   └── 5.5 Paramètres (profil, objectifs, export/import, réinitialisation)
```

### 5.2 Maquettes (schéma des 6 écrans principaux)

**1 — Onboarding** : logo + titre *DiabTrack* → 3 questions (type, objectifs) → bouton
« Commencer », mention « Cette application ne remplace pas un avis médical ».

**2 — Accueil** : barre de titre « Bonjour » + date ; carte centrale (goutte + valeur `128`
+ badge « dans la cible ») ; graphique 24 h ; rangée de 3 indicateurs ; insuline/glucides ;
3 boutons d'action rapide en bas.

**3 — Mesures** : champ de saisie chiffré en grand + sélecteur de moment + validation
`Enregistrer` ; liste par jour avec icône de statut, valeur, heure, contexte.

**4 — Traitement** : dose du jour en gros, jauge dose prescrite, liste des injections,
bouton `+ Injecter`.

**5 — Statistiques** : TIR en pourcentage + barre segmentée (bas / cible / haut), moyenne,
écart-type, courbe d'évolution HbA1c, sélecteur de période.

**6 — Conseils** : liste de fiches thématiques, chacune avec titre, « en cas d'urgence »
mis en évidence, et sources.

### 5.3 Charte graphique — le code couleur du statut glycémique

Le statut est calculé à partir des **objectifs personnalisés** (pas de valeurs en dur) :

| Statut | Condition par défaut | Couleur | Usage |
|---|---|---|---|
| **Hypoglycémie** | < 0,70 g/L | 🔴 Rouge `#D32F2F` | Alerte, badge urgent |
| **Bas** | 0,70 – 0,90 g/L | 🟠 Orange `#F57C00` | Attention |
| **Dans la cible** | 0,90 – 1,80 g/L | 🟢 Vert `#2E7D32` | Nominal |
| **Haut** | 1,80 – 2,50 g/L | 🟠 Orange `#F57C00` | Attention |
| **Hyperglycémie** | > 2,50 g/L | 🔴 Rouge `#D32F2F` | Alerte, contrôle cétonique |
| **Non mesuré** | — | ⚪ Gris `#9E9E9E` | Pas de donnée |

Couleurs d'accent de l'application : **teal / indigo** (couleurs de soin, non alarmantes).
Aucune couleur n'est utilisée seule : chaque statut est **accompagné d'un libellé texte** et
d'une **icône** (accessibilité aux daltoniens).

### 5.4 Modèle de données

```
Profile (1)
  ├─ diabetesType : enum(type1, type2, autre)
  ├─ age, birthYear
  ├─ targets : targetFasting, targetPostMeal, targetHbA1c
  ├─ insulinSettings : dailyPrescribedUnits, carbRatio(g/U), sensitivity(g/L per U)
  └─ uiSettings : nom affiché, unités

GlucoseReading (N) ──┐
  ├─ id, dateTime                    │
  ├─ valueMgDl  (stockage en mg/dL,  │
  │              affichage en g/L)   │
  ├─ context : enum(àJeun, avantRepas,│
  │            aprèsRepas, coucher,  │
  │            avantSport, aprèsSport)│
  ├─ mealId (optionnel) ─────────────┤
  ├─ exercise, stressLevel, sleepHours│
  ├─ note (texte libre)               │
  └─ tags : List<String>              │
                                          │
Meal (N) ────────────────────────────────┘
  ├─ id, dateTime, type: enum(ptitDej, dej, diner, collation, diner2, cena)
  ├─ carbsG, description, note

InsulinEntry (N)
  ├─ id, dateTime
  ├─ kind: enum(basal, bolus)
  ├─ productName (analogue court/long)
  ├─ units, mealId (si bolus), correction (booléen)
  └─ penLot, note

HbA1cRecord (N)
  ├─ id, date, valuePercent, labName, note

ActivityLog (N)   ← REX, clôture
  ├─ id, date, content

Preferences (1)
  └─ version, onBoardingDone, seededDemo, lastExportDate
```

**Règle de conversion retenue pour éviter les erreurs** :
la glycémie est **stockée en mg/dL** (unité internationale, entier) et **affichée en g/L** avec
une décimale — `1 g/L = 100 mg/dL`. Tous les seuils, cibles et calculs utilisent la même unité
via des fonctions de conversion testées.

**Contraintes de stockage (R5)** : tout est **local** (`shared_preferences`, un seul document JSON
versionné). Aucune permission réseau, aucun envoi de données de santé.
