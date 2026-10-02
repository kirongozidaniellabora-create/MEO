# Parties prenantes & cartographie pouvoir / intérêt

> Diapositives 15 et 17 du support MEO.

## 1. Définition

> **Partie prenante** = toute personne ou organisation **qui influence** le projet **ou qui est
> affectée** par lui.

Deux conséquences pratiques :

* une partie prenante peut être **interne** (collègue, sponsor) ou **externe** (client, fournisseur) ;
* l'oubli de parties prenantes figure parmi les **causes d'échec fréquentes** : le projet échoue
  parce qu'une personne refusait le résultat, alors qu'on ne l'avait jamais consultée.

## 2. Les acteurs, rôle par rôle

| Acteur | Ce qu'il fait concrètement | Ici : qui ? |
|---|---|---|
| **Sponsor** | Porte le projet dans l'organisation, finance, **arbitre** | Responsable pédagogique MEO |
| **Client (MOA)** | Exprime le besoin, **reçoit et valide** le résultat | L'utilisateur diabétique destinataire |
| **Chef de projet** | Pilote au quotidien, responsable des résultats | Le développeur (étudiant B1) |
| **Équipe projet** | Réalise les tâches, produit les livrables | Le développeur (même personne) |
| **Utilisateurs finaux** | Utiliseront le résultat au quotidien | Le patient + son entourage |
| **Fournisseurs** | Matériel, services, sous-traitance | Flutter SDK, Dart, `pub.dev`, Android SDK |
| **Autres** | Comité de pilotage, direction, services support, autorités, riverains, syndicats | Équipe pédagogique, service informatique |

> **MOA ≠ MOE** (diapositive 16) — deux rôles souvent confondus :
>
> | | **MOA** — Maîtrise d'Ouvrage | **MOE** — Maîtrise d'Œuvre |
> |---|---|---|
> | Sens | Owner / Client | Contractor / Supplier |
> | Définit | le **QUOI** et le **POURQUOI** | le **COMMENT** |
> | Actions | exprime le besoin, fixe budget et délais, **valide (recette)** | conçoit, réalise, garantit la conformité |
> | Ici | l'utilisateur diabétique : veut suivre sa glycémie au quotidien | le développeur : choisit Flutter, le stockage local, l'ergonomie |
>
> *Analogie de la diapositive : une commune fait construire une école → la commune est MOA,
> le cabinet d'architectes et les entreprises de BTP sont MOE.*

## 3. Matrice pouvoir / intérêt

```
                        POUVOIR
              Faible                          Élevé
        ┌─────────────────────────┬─────────────────────────┐
  Élevé │  IMPLIQUER              │  GÉRER ÉTROITEMENT      │
        │  Dans les décisions     │  Communication régulière│
  INTÉ- │  Partager les           │  Partager les décisions │
   RÊT  │  informations          │  Solliciter les avis    │
        ├─────────────────────────┼─────────────────────────┤
  Faible │  SURVEILLER            │  SATISFAIRE             │
        │  Effort minimal         │  Consulter, éviter les  │
        │  Ne pas déranger        │  surprises              │
        └─────────────────────────┴─────────────────────────┘
```

**Règle de décision** : le quadrant détermine le **niveau d'attention** et le **type de
communication**, pas l'importance morale de la personne.

| Partie prenante | Pouvoir | Intérêt | Quadrant | Stratégie appliquée dans le projet | Preuve |
|---|:---:|:---:|---|---|---|
| Responsable pédagogique MEO (sponsor) | 🔴 Élevé | 🔴 Élevé | **Gérer étroitement** | Message d'avancement à chaque jalon, décision d'arbitrage lui est soumise | § Jalons de la charte |
| Utilisateur diabétique (client / MOA) | 🟡 Moyen | 🔴 Élevé | **Impliquer** | Test de parcours de saisie à J7 et recette à J8 | Recette utilisateur |
| Soignant de référence (diabétologue) | 🟡 Moyen | 🟡 Moyen | **Consulter** | Conseils sourcés (HAS / SFD), avertissement médical visible, aucune prescription | Écran « Conseils » |
| Étudiants de la promotion | 🟢 Faible | 🟡 Moyen | **Consulter** | Test d'ergonomie informel avant J8 | Retours notés |
| Fournisseurs (Flutter, `pub.dev`, Android SDK) | 🟢 Faible | 🟢 Faible | **Surveiller** | Version du SDK notée dans le README, dépendances minimales, `pubspec.lock` versionné | `README.md` |
| Plateforme Android / Google Play | 🟡 Moyen | 🟢 Faible | **Surveiller** | `minSdk 24`, aucune permission inutile, pas de réseau | `AndroidManifest.xml` |
| Service informatique / hébergement | 🟢 Faible | 🟢 Faible | **Surveiller** | Aucun serveur : rien à héberger | § Non-objectifs |

## 4. Exemple de la diapositive transposé au projet

Pour le gala de l'école (exemple du support) :
gérer étroitement = direction + BDE ; satisfaire = mairie (autorisations) ; tenir informé =
étudiants invités ; surveiller = riverains.

**Transposition à DiabTrack :**

| Quadrant | Acteurs |
|---|---|
| **Gérer étroitement** | Sponsor MEO ; client diabétique (a un droit de veto sur l'ergonomie) |
| **Impliquer** | Utilisateurs finaux (entourage, aidants qui font les injections le soir) |
| **Consulter** | Diabétologue (contenu médical), promotion (tests d'ergonomie) |
| **Surveiller** | Fournisseurs techniques, plateforme Android |

## 5. Plan d'engagement (qui, quoi, quand)

| Partie prenante | Engagement attendu | Moment | Support |
|---|---|---|---|
| Sponsor | Autorisation, arbitrage, validation des jalons | J1, puis chaque jalon | Charte + points courts |
| Client | Expression du besoin, recette, validation finale | J1, J7, J8, J9 | Entretien + test sur appareil |
| Diabétologue | Lecture critique des conseils | J7 | Revue du contenu |
| Étudiants | Retour d'ergonomie | Avant J8 | Questionnaire à 5 questions |
| Équipe (moi) | Tenue du journal de bord, mise à jour du suivi | Quotidien | Fichier de suivi |

## 6. Règle d'or

> Une partie prenante **non cartographiée est un risque non anticipé**.
> Le gel du périmètre à J2 s'accompagne donc d'une **relecture de la matrice** : toute nouvelle
> demande devient soit un **risque** (si elle vient d'un acteur influent), soit une **demande de
> changement** à arbitrer par le sponsor.
