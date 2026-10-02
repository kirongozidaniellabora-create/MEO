# DiabTrack — Charte de projet

> Document de référence issu de la Séance 1 « Gestion de Projet » (ICAM — B1).
> Ce document **autorise officiellement** le projet et nomme le chef de projet.

| Champ | Valeur |
|---|---|
| **Nom du projet** | DiabTrack — Application mobile de suivi du diabète |
| **Sponsor** | Responsable pédagogique MEO — ICAM |
| **Chef de projet** | Étudiant développeur (B1) |
| **MOA (Owner / Client)** | L'utilisateur diabétique destinataire de l'application |
| **MOE (Contractor)** | L'équipe de développement Flutter (= le chef de projet) |
| **Date d'autorisation** | 30/09/2026 |
| **Date de fin prévue** | 26/10/2026 |
| **Version visée** | V1.0 — Android (API 24 / Android 7.0 et +) |
| **Budget monétaire** | 0 € (Flutter SDK, Dart et les paquets utilisés sont gratuits et open source) |
| **Budget humain** | ≈ 22,5 jours·personne |

---

## 1. Besoin à l'origine du projet (Pourquoi ?)

Besoin réel et non technique, conformément aux déclencheurs vus en séance :

1. **Problème à résoudre** — un patient diabétique_note ses glycémies sur un carnet papier ou
   n'y pense pas du tout ; il ne voit jamais son évolution ni son *temps dans la cible*.
2. **Enjeu de santé** — les hypoglycémies ne sont pas détectées à temps, l'*HbA1c* est découvert
   seulement à la prochaine analyse sanguine (tous les 3 mois).
3. **Demande d'usage** — l'utilisateur veut un outil **disponible hors connexion**, dans la poche,
   utilisable en 2 gestes, et qui ne stocke **aucune donnée de santé chez un tiers**.

**Critère de la demande** (slide « Projet ou pas projet ? ») : début et fin fixés, résultat
**unique et nouveau**. C'est bien un **projet**, pas une activité opérationnelle : à la livraison,
l'application passe « aux opérations » (usage quotidien), le développement s'arrête.

---

## 2. Objectifs SMART

| # | Objectif | Sp. | M. | A. | R. | T. |
|---|---|---|---|---|---|---|
| O1 | Livrer une application Flutter **installable sur un téléphone Android** | ✔ | ✔ | ✔ | ✔ | **23/10/2026** |
| O2 | Enregistrer une glycémie en **moins de 20 secondes** (≤ 4 gestes) | ✔ | ✔ | ✔ | ✔ | **13/10/2026** |
| O3 | Afficher le **temps dans la cible (TIR)** sur 14 jours conforme à la formule de référence, écart ≤ 1 % | ✔ | ✔ | ✔ | ✔ | **16/10/2026** |
| O4 | **100 %** des données de santé stockées **localement** (aucun appel réseau applicatif) | ✔ | ✔ | ✔ | ✔ | **16/10/2026** |
| O5 | Fournir la documentation de gestion de projet complète (charte, WBS, planning, matrice des parties prenantes, risques, recette) | ✔ | ✔ | ✔ | ✔ | **26/10/2026** |
| O6 | Atteindre **0 erreur** `flutter analyze` et **≥ 80 %** de tests unitaires au vert | ✔ | ✔ | ✔ | ✔ | **21/10/2026** |
| O7 | Ajouter un **avertissement médical** visible et des sources vérifiables pour les conseils | ✔ | ✔ | ✔ | ✔ | **19/10/2026** |

**Non-objectif explicite** : l'application ne pose pas de diagnostic et ne modifie aucune
prescription. Elle ne remplace ni le médecin, ni le carnet de suivi.

---

## 3. Périmètre

### 3.1 Inclus (à la livraison V1.0)

| # | Lot | Contenu |
|---|---|---|
| I1 | Profil & objectifs | Type de diabète, âge, objectifs cibles (à jeun, post-prandial, HbA1c), unité d'insuline |
| I2 | Journal de glycémie | Saisie, édition, suppression, liste, contexte (repas, sport, sommeil, stress), notes, étiquettes |
| I3 | Journal de traitement | Insuline rapide / lente, basal ou bolus, dose, heure, lot de stylo |
| I4 | Journal de repas | Glucides par repas, répartition quotidienne |
| I5 | Tableau de bord | Dernière mesure + statut coloré, graphique du jour, indicateurs, actions rapides |
| I6 | Statistiques | Moyennes, amplitude, TIR (14 j), variabilité, évolution *HbA1c* |
| I7 | Calculateurs | Dose de correction, insuline pour glucides, protocole d'hypoglycémie |
| I8 | Conseils | Hypo/hyper, insulinothérapie, nutrition, activité physique, santé du pied, voyages |
| I9 | Paramètres & données | Modification des objectifs, export/import JSON, réinitialisation, mode démo |
| I10 | Qualité & livraison | Analyse statique, tests unitaires, APK, installation sur l'appareil |

### 3.2 Exclus (hors V1.0 — « non-objectifs »)

* Synchronisation **cloud** et création de compte (serveur inexistant, coût et conformité).
* Lecture **Bluetooth** d'un lecteur de glycémie ou d'un capteur **CGM temps réel**.
* Intégration **Health Connect / Apple Health**.
* **Notifications push** et rappels système (le module d'alertes système est dépriorisé).
* Versions **iOS**, **Web**, **tablette** (V1 = Android uniquement).
* Prescription médicale, modification du traitement, interprétation clinique des courbes.
* Interface dans d'autres langues que le français (V1).

> **Gel du périmètre** : cette liste est figée au jalon J2. Toute demande nouvelle après J2 est
> traitée comme une **demande de changement** (cf. § 8 — arbitrage), ce qui évite le *scope creep*
> listé comme cause n° 2 d'échec de projet.

---

## 4. Livrables

| ID | Livrable | Vérifiable par |
|---|---|---|
| **L1** | Charte de projet signée | Ce document, signature du sponsor |
| **L2** | WBS + planning (charge / durée) | `docs/02-wbs.md`, `docs/05-planning.md` |
| **L3** | Conception : arborescence fonctionnelle, maquettes, modèle de données | `docs/03-conception.md` + code |
| **L4** | Code source complet de l'application Flutter | Dossier `lib/` de l'APK |
| **L5** | APK installable (`build/app/outputs/flutter-apk/app-release.apk`) | Installation réussie sur l'appareil |
| **L6** | Documentation utilisateur | `README.md` + écran « Aide » de l'app |
| **L7** | Recette : PV de recette + retour d'expérience | `docs/06-recette-rex.md` |

---

## 5. Jalons clés

Durée totale : **20 jours calendaires** (30/09 → 26/10/2026).

| Jalon | Date | Événement (durée nulle) | Critère de passage |
|---|---|---|---|
| **J1** | 02/10/2026 | Charte de projet signée | Ce document validé par le sponsor |
| **J2** | 05/10/2026 | WBS + planning validés, périmètre gelé | Arborescence à 100 % du travail, jalons datés |
| **J3** | 07/10/2026 | Maquettes des écrans validées | 6 écrans principaux maquettés |
| **J4** | 09/10/2026 | Socle technique opérationnel | `flutter doctor` vert, projet compilé, persistance OK |
| **J5** | 13/10/2026 | V0.1 — Glycémie + tableau de bord | O2 atteint : saisie en < 20 s |
| **J6** | 16/10/2026 | V0.2 — Insuline, repas, statistiques | O3 et O4 atteints |
| **J7** | 19/10/2026 | V1.0 — Candidature : conseils, calculateurs, paramètres | O7 atteint, toutes les fonctions du périmètre présentes |
| **J8** | 21/10/2026 | Recette interne réussie | O6 atteint, aucun défaut bloquant ouvert |
| **J9** | 23/10/2026 | APK installé sur le téléphone | Application lancée sur l'appareil, données persistantes vérifiées |
| **J10** | 26/10/2026 | Clôture du projet | PV de recette signé + REX rédigée |

---

## 6. Parties prenantes

Synthèse ; la matrice **pouvoir / intérêt** complète est dans
[`docs/04-parties-prenantes.md`](04-parties-prenantes.md).

| Acteur | Rôle | Pouvoir | Intérêt | Quadrant | Stratégie |
|---|---|:---:|:---:|---|---|
| Responsable pédagogique (sponsor) | Finance, arbitre, valide la recette | 🔴 Élevé | 🔴 Élevé | Gérer étroitement | Point d'avancement à chaque jalon |
| Utilisateur diabétique (client / MOA) | Exprime le besoin, valide le résultat | 🟡 Moyen | 🔴 Élevé | Impliquer | Recette utilisateur, retours formalisés |
| Soignant de référence (diabétologue) | Valide le contenu médical | 🟡 Moyen | 🟡 Moyen | Consulter | Sources citées, aucun avis prescriptif |
| Étudiants de la promotion | Utilisateurs précoces | 🟢 Faible | 🟡 Moyen | Consulter | Test utilisateur avant J8 |
| Fournisseurs (Flutter, pub.dev) | SDK et paquets | 🟢 Faible | 🟢 Faible | Surveiller | Version SDK notée, dépendances minimales |
| Google Play / Android | Plateforme cible, signature | 🟡 Moyen | 🟢 Faible | Surveiller | minSdk 24, pas de permission inutile |

---

## 7. Budget

| Poste | Détail | Charge (j·p) |
|---|---|---|
| Cadrage & gestion de projet | Charte, WBS, planning, parties prenantes, risques | 2,0 |
| Environnement technique | Installation Flutter + Android SDK, licences, configuration | 1,5 |
| Conception | Arborescence, maquettes, modèle de données, thème | 2,0 |
| Socle applicatif | Thème, navigation, persistance locale, gestion d'état | 1,5 |
| Module glycémie | Modèle, saisie, historique, édition | 2,0 |
| Tableau de bord | Carte de mesure, graphique, indicateurs, raccourcis | 2,0 |
| Traitement & repas | Insuline, glucides, distribution | 2,0 |
| Statistiques | Moyennes, TIR, variabilité, HbA1c | 2,0 |
| Calculateurs & conseils | 3 calculateurs, bibliothèque de conseils | 2,0 |
| Paramètres & données | Objectifs, export/import, réinitialisation | 1,0 |
| Qualité & recette | Analyse, tests, revue, corrections | 2,5 |
| Livraison & documentation | APK, installation, doc utilisateur, REX | 1,0 |
| **TOTAL** | | **22,5** |

Coût monétaire = **0 €** : Flutter, Dart et l'unique dépendance externe sont libres de droits.
La seule « monnaie » du projet est le **temps** (22,5 jours·personne) — c'est la variable à arbitrer.

---

## 8. Risques majeurs

| ID | Risque | P | I | Critère | Plan de mitigation | Plan de repli |
|---|---|:---:|:---:|:---:|---|---|
| R1 | Flutter SDK absent de la machine (constaté) | 🔴 | 🔴 | Critique | Installer **dès J1**, en arrière-plan pendant la rédaction | Repli sur une PWA (hors périmètre) |
| R2 | SDK Android absent / licences non acceptées | 🔴 | 🔴 | Critique | `sdkmanager` + `licenses` automatisés | Utiliser Android Studio pour valider les licences |
| R3 | Réseau vers `pub.dev` indisponible | 🟡 | 🔴 | Élevé | **Dépendances minimales** (1 seule) ; pas de graphique tiers (dessin maison) | Remplacer `shared_preferences` par un fichier JSON brut |
| R4 | Téléphone non connecté / débogage USB désactivé | 🟡 | 🴣 | Élevé | Prévoir un **APK partageable** dès J7 ; guide d'installation écrit | Livrer l'APK + la procédure d'installation manuelle |
| R5 | Fuite de données de santé | 🟢 | 🔴 | Élevé | Stockage **local chiffré en base**, export **explicite** | Aucun transfert réseau n'est implémenté → rien à couper |
| R6 | Dérive du périmètre (*scope creep*) | 🟡 | 🟡 | Moyen | Gel du périmètre à J2, backlog de V2 explicitement listé | Renvoi en « V2.0 » au sponsor |
| R7 | Estimation trop optimiste (cause d'échec n° 3) | 🟡 | 🟡 | Moyen | Estimation par **charge (j·p)** puis conversion en durée | Réduction du périmètre, jamais de la durée |
| R8 | Contenu médical inexact | 🟡 | 🔴 | Élevé | Avertissement visible, sources (HAS, SFD) citées, avis de diabétologue | Neutralisation des conseils litigieux |
| R9 | Build Android long / échecs Gradle | 🟡 | 🟡 | Moyen | Lancer les builds **en arrière-plan**, corriger au fil de l'eau | Debug APK (build plus léger) |

---

## 9. Triangle des contraintes — règles d'arbitrage

Un projet ne peut pas optimiser simultanément **coût**, **délai** et **périmètre** :
modifier un sommet impose d'ajuster au moins un autre.

| Contrainte reçue | Options retenues | Décision |
|---|---|---|
| « Je veux la V1.0 avant le 23/10 » | (a) +ressources, (b) –périmètre, (c) –qualité | **(b) –périmètre** : on sort le journal de repas s'il le faut ; on ne livre pas un code non testé |
| « Je veux ajouter des notifications / le Bluetooth » | (a) +délai, (b) +coût, (c) hors périmètre | **(c)** : backlog V2.0, sinon *scope creep* |
| « Je veux.zero € » | (a) payer un service, (b) plus de temps de dev | **(b)** : budget = 22,5 j·p, 0 € |
| Un défaut bloquant est trouvé à J8 | (a) livrer quand même, (b) retarder | **(b)** : le délai s'ajuste, la qualité est non négociable |

**Règle de priorité appliquée dans ce projet** :
`Qualité > Sécurité des données > Délai > Périmètre > Coût`

---

## 10. Approche de conduite

Cadre **hybride** (cf. `04-cycle-de-vie.md`) :
squelette **prédictif** (les 5 groupes de processus du PMBOK) + **itérations courtes de 7 jours**
à l'intérieur de la phase d'exécution, avec revue et démonstration à chaque jalon.

Raison : le périmètre est connu et figé (construction type), mais la solution technique
 Flutter est exploratoire (approche agile) → c'est le cas d'école du **hybride**.

## 11. Stratégie de communication

| Destinataire | Support | Fréquence | Contenu |
|---|---|---|---|
| Sponsor | Message court d'avancement | À chaque jalon (J1→J10) | Avancement, écarts, risques |
| Utilisateur final | Test en situation réelle | J7 et J8 | Parcours de saisie, lisibilité |
| Équipe de développement (moi-même) | Journal de bord fichier | Quotidien | Heures, blocages, décisions |

## 12. Signatures

| Rôle | Nom | Date | Signature |
|---|---|---|---|
| Sponsor — responsable pédagogique MEO | | | |
| Chef de projet — étudiant développeur B1 | | | |
| Client (MOA) — utilisateur diabétique | | | |

> La signature du sponsor **autorise officiellement** le projet et officialise la nomination du
> chef de projet (cf. diapositive 26 du support).
