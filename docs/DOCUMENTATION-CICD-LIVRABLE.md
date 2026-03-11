# Documentation CI/CD complète – MicroCRM (P7)

**Mission :** Mettre en œuvre l'intégration et le déploiement continu d'une application Full-Stack.

**Contexte :** Projet réalisé dans le cadre de **l’option B (scénario fictif Orion)** : chaîne CI/CD conçue et documentée pour l’application MicroCRM, avec justification des choix techniques et respect des livrables attendus.

Ce document constitue le **livrable documentation** pour la soutenance. Il regroupe la Partie 1 (mise en œuvre CI/CD, conteneurisation, testing) et la Partie 2 (KPI, métriques, sécurité, sauvegarde, mises à jour).

### Correspondance avec la mission : « Une documentation de CI/CD complète contenant »

| Partie | Élément demandé | Où dans ce document |
|--------|-----------------|----------------------|
| **Partie 1** | Les étapes de mise en œuvre CI/CD | **§ 1** – Les étapes de mise en œuvre CI/CD |
| **Partie 1** | Le plan de conteneurisation et déploiement | **§ 2** – Le plan de conteneurisation et déploiement |
| **Partie 1** | Le plan de testing périodique | **§ 3** – Le plan de testing périodique |
| **Partie 2** | Les KPI proposés et les métriques | **§ 4** – Les KPI proposés et les métriques |
| **Partie 2** | L'analyse des métriques | **§ 5** – L'analyse des métriques |
| **Partie 2** | Le plan de sécurité | **§ 6** – Le plan de sécurité |
| **Partie 2** | Le plan de sauvegarde des données | **§ 7** – Le plan de sauvegarde des données |
| **Partie 2** | Le plan des mises à jour | **§ 8** – Le plan des mises à jour |

**Un seul document** : [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) (ce fichier) constitue à lui seul la **documentation de CI/CD complète** demandée (Partie 1 + Partie 2). Documents complémentaires : [PRESENTATION-SOUTENANCE-P7.md](PRESENTATION-SOUTENANCE-P7.md), [VERIFICATION-AUTO-EVALUATION-P7.md](VERIFICATION-AUTO-EVALUATION-P7.md). Détails par thème : [PLANS-CICD.md](PLANS-CICD.md), [PLAN-SECURITE-FINAL.md](PLAN-SECURITE-FINAL.md), [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md), [METRIQUES-DORA-KPI.md](METRIQUES-DORA-KPI.md), [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md), [DOCKER-COMPOSE.md](DOCKER-COMPOSE.md), [ELK.md](ELK.md).

---

# Partie 1 – Mise en œuvre CI/CD

## 1. Les étapes de mise en œuvre CI/CD

Le pipeline est défini dans **`.github/workflows/ci-cd.yml`** et s’exécute sur chaque **push** et **pull request** vers les branches `main` et `master`.

### Étapes réalisées

| Étape | Description | Outils |
|-------|-------------|--------|
| **1. Checkout** | Récupération du code source depuis le dépôt GitHub. | `actions/checkout@v4` |
| **2. Backend – Build & Tests** | Build Gradle (Java 17), exécution des tests JUnit, génération du JAR et du rapport JaCoCo. | JDK 17 (Temurin), Gradle, JUnit 5 |
| **3. Frontend – Build & Tests** | `npm ci`, build Angular (production), tests unitaires Karma/Jasmine, génération du rapport LCOV. | Node.js 20, npm, Karma, Chrome Headless |
| **4. SonarQube Cloud** | Analyse statique du code (back + front), qualité, sécurité, couverture (si `ACTIVATE_SONAR=true`). | SonarScanner, SonarCloud |
| **5. CD – Build & Push Docker** | Sur `main`/`master` uniquement : build des images Docker (front, back, standalone) et publication vers Docker Hub. | Docker Buildx, Docker Hub |

### Déclencheurs

- **CI** : à chaque push et à chaque pull request vers `main` ou `master`.
- **CD** : uniquement sur push vers `main` ou `master` (pas sur les PR).

### Secrets et variables à configurer (GitHub)

| Type | Nom | Usage |
|------|-----|--------|
| Secret | `DOCKERHUB_TOKEN` | Authentification pour le push des images vers Docker Hub. |
| Secret | `SONAR_TOKEN` | Jeton SonarCloud pour l’analyse qualité/sécurité. |
| Variable | `DOCKERHUB_USERNAME` | Nom d’utilisateur Docker Hub (optionnel si dérivé du repo). |
| Variable | `SONAR_PROJECT_KEY` | Clé du projet SonarCloud (ex. `ghazi135_p7-oc-dev-full-stack`). |
| Variable | `SONAR_ORGANIZATION` | Organisation SonarCloud (ex. `ghazi135`). |
| Variable | `ACTIVATE_SONAR` | `true` pour activer le job SonarQube dans le pipeline. |

### Référence des commandes (build, tests, pipeline)

| Contexte | Commandes / jobs | Quand |
|----------|------------------|--------|
| **Local back** | `cd back && ./gradlew build` (ou `test`) | À la demande |
| **Local front** | `cd front && npm ci && npm run build` ; `npm test -- --no-watch --browsers=ChromeHeadlessNoSandbox` | À la demande |
| **CI** | Jobs Backend – Build & Tests, Frontend – Build & Tests (`.github/workflows/ci-cd.yml`) | Chaque push et PR sur `main`/`master` |
| **SonarQube** | Job SonarQube Cloud (même workflow) | Si `ACTIVATE_SONAR=true` |
| **CD** | Job Build & Push Docker images (front, back, standalone → Docker Hub) | Uniquement push sur `main`/`master` |

---

## 2. Le plan de conteneurisation et déploiement

### 2.1 Dockerfile et cibles

Le **Dockerfile** unique à la racine du projet est un **build multi-étapes** avec plusieurs cibles :

| Cible | Description | Ports | Usage |
|-------|-------------|-------|--------|
| **front** | Build Angular → image Alpine + Caddy pour servir les fichiers statiques (HTTP/HTTPS). | 80, 443 | Service front seul. |
| **back** | Build Gradle → JAR → image Alpine + JRE 17. | 8080 | Service API seul. |
| **standalone** | Combine front + back dans une seule image (Supervisord). | 80, 443, 8080 | Démo ou déploiement simplifié. |

**Choix techniques :**

- **Images de base** : Alpine pour réduire la taille et la surface d’attaque.
- **Build séparé** : les étapes `front-build` et `back-build` produisent les artefacts ; les étapes finales ne contiennent que le strict nécessaire pour l’exécution.
- **Pas de données sensibles** dans les images (config via variables d’environnement en déploiement).

### 2.2 Orchestration avec Docker Compose

Le fichier **`docker-compose.yml`** à la racine permet de lancer l’application (services `back` et `front`) avec une seule commande :

```bash
docker-compose up --build
```

- **back** : API sur http://localhost:8080  
- **front** : Interface sur http://localhost (80) ou https://localhost (443)

Pour l’image tout-en-un :

```bash
docker-compose --profile full up standalone --build
```

### 2.3 Stratégie de déploiement

- **CI** : à chaque push/PR → build + tests + SonarQube (si activé). Aucune publication d’image.
- **CD** : sur branche `main`/`master` → build des images (front, back, standalone) et **publication vers Docker Hub**.
- **Tags d’images** : `latest` pour la dernière version sur `main` ; possibilité d’ajouter le SHA du commit ou un numéro de version pour la traçabilité.

Le détail des procédures (ordre de déploiement, vérifications, variables d’environnement) est dans [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md#1-plan-de-déploiement).

---

## 3. Le plan de testing périodique

### 3.1 Types de tests

| Zone | Type | Outil | Objectif |
|------|------|--------|-----------|
| **Backend** | Tests unitaires / intégration | JUnit 5, Spring Boot Test, DataJpaTest | Vérifier le contexte Spring, les repositories et la non-régression. |
| **Frontend** | Tests unitaires (composants, services) | Karma + Jasmine | Vérifier le comportement des composants et services. |

Les rapports de couverture sont utilisés par SonarQube :

- **Backend** : JaCoCo → `back/build/reports/jacoco/test/jacocoTestReport.xml`
- **Frontend** : LCOV → `front/coverage/microcrm/lcov.info`

### 3.2 Moments d’exécution

| Événement | Tests exécutés | Objectif |
|-----------|----------------|----------|
| **Push** sur toute branche | Build back + front, tests back, tests front | Détecter rapidement les régressions et les erreurs de build. |
| **Pull Request** vers `main` | Idem + analyse SonarQube (si activée) | S’assurer que la PR ne dégrade pas la qualité ni la sécurité. |
| **Merge sur main** | Idem + CD (build et push des images) | Produire des artefacts déployables. |

### 3.3 Objectifs

- **Validation fonctionnelle** : les tests back et front confirment le comportement attendu.
- **Non-régression** : à chaque modification, l’ensemble des tests doit rester vert ; un échec bloque la suite du pipeline.
- **Qualité** : le build et les tests sont un préalable à l’analyse SonarQube.

Le plan détaillé est décrit dans [PLANS-CICD.md](PLANS-CICD.md#1-plan-de-testing-périodique).

---

# Partie 2 – KPI, métriques, sécurité, sauvegarde, mises à jour

## 4. Les KPI proposés et les métriques

### 4.1 Métriques DORA

| Métrique | Définition | Objectif |
|----------|-------------|----------|
| **Lead Time for Changes** | Délai entre un commit et la mise en production effective. | Réduire ce délai (ex. durée du pipeline). |
| **Deployment Frequency** | Nombre de déploiements en production sur une période. | Augmenter la fréquence grâce à un pipeline fiable. |
| **MTTR (Mean Time to Restore)** | Temps moyen pour rétablir le service après un incident. | Réduire le MTTR. |
| **Change Failure Rate** | Pourcentage de déploiements ayant provoqué un problème (bug, rollback). | Réduire ce taux par la qualité et les tests. |

### 4.2 KPI opérationnels du projet

| KPI | Description | Méthode de calcul | Objectif |
|-----|-------------|--------------------|----------|
| **Temps de build back** | Durée du job « Backend – Build & Tests ». | Moyenne sur les derniers runs (GitHub Actions). | Réduire (cache Gradle). |
| **Temps de build front** | Durée du job « Frontend – Build & Tests ». | Moyenne sur les runs. | Réduire (cache npm). |
| **Taux de succès des tests** | % de runs CI où tous les tests passent. | (Runs avec tests verts) / (Runs totaux) × 100. | Viser 100 %. |
| **Qualité SonarQube** | Statut du Quality Gate et nombre d’issues. | Résultats SonarCloud sur les PR/push. | Maintenir le gate vert. |
| **Fréquence des erreurs (logs)** | Nombre d’événements ERROR dans les logs. | Comptage dans ELK/Kibana (index `microcrm-logs-*`). | Détecter les pics et corriger. |

Le tableau détaillé et les formules sont dans [METRIQUES-DORA-KPI.md](METRIQUES-DORA-KPI.md).

---

## 5. L’analyse des métriques

- **Pipeline** : le CI (build + tests) et le CD (build & push des images) fournissent les données pour le Lead Time et la Deployment Frequency. Relever les durées des jobs sur plusieurs exécutions permet d’identifier les lenteurs (cache Gradle/npm, parallélisation).
- **Qualité** : les métriques SonarQube (bugs, vulnérabilités, code smells) et le taux de succès des tests sont des indicateurs de la **Change Failure Rate** potentielle : moins d’anomalies et des tests systématiques limitent les déploiements défaillants.
- **Monitoring** : les indicateurs ELK (volume de logs, erreurs, tendances) permettent de relier les incidents au comportement de l’application et d’alimenter une estimation du **MTTR**.

Cette analyse est à mettre à jour après chaque période d’observation (sprint, lot de déploiements). La synthèse et les recommandations sont dans [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md).

---

## 6. Le plan de sécurité

### 6.1 Rôle de SonarQube Cloud

- **Analyse statique** du code back (Java) et front (TypeScript/JavaScript) à chaque run CI (push/PR).
- **Types de problèmes surveillés** : bugs, vulnérabilités (OWASP Top 10, etc.), code smells, couverture de tests.

Références : [SonarSource Rules](https://rules.sonarsource.com/), [OWASP Top 10](https://owasp.org/Top10/).

### 6.2 Éléments à suivre (résultats SonarQube)

| Catégorie | Description | Où les trouver |
|-----------|-------------|----------------|
| **Vulnérabilités** | Failles de sécurité (injection, exposition de données). | SonarCloud, onglet Security / Vulnerabilities. |
| **Duplications** | Code dupliqué. | Métrique « Duplications ». |
| **Zones à forte complexité** | Complexité cyclomatique/cognitive élevée. | SonarCloud, Complexity / Cognitive Complexity. |
| **Règles critiques violées** | Violations Blocker ou Critical. | SonarCloud, Issues, filtre par sévérité. |
| **Couverture de tests** | % de lignes/branches couvertes. | Rapports JaCoCo (back) et LCOV (front). |

### 6.3 Bonnes pratiques en place

- **Secrets** : aucun mot de passe, token ou clé en clair ; utilisation des secrets et variables GitHub.
- **Images Docker** : bases officielles (Alpine, Temurin), images légères, pas de données sensibles dans les images.
- **Pipeline** : tests automatiques et analyse SonarQube (si activée) avant merge.

### 6.4 Pistes d’amélioration

1. Corriger toutes les **vulnérabilités** et **issues critiques** remontées par SonarQube.  
2. Augmenter la **couverture de tests** sur les parties critiques.  
3. Réduire les **duplications** et la **complexité** (refactoring ciblé).  
4. Exécuter **npm audit** (front) et un audit des dépendances back (ex. OWASP Dependency Check) en CI.

Le plan détaillé est dans [PLAN-SECURITE-FINAL.md](PLAN-SECURITE-FINAL.md).

---

## 7. Le plan de sauvegarde des données

### 7.1 Éléments à sauvegarder

| Élément | Description | Fréquence |
|---------|-------------|-----------|
| **Code source et historique** | Dépôt Git (GitHub). | Continue (push/merge). |
| **Configurations** | Fichiers de configuration (docker-compose, pipeline, Logstash, etc.) versionnés dans le dépôt. | À chaque changement significatif. |
| **Données applicatives** | Projet actuel : HSQLDB en mémoire (backend) — **aucune persistance**. | N/A tant qu’il n’y a pas de base persistante. |
| **Secrets / variables** | Gérés par la plateforme (GitHub Secrets). Ne pas les stocker dans le dépôt ; documenter la liste des clés et leur emplacement. | Documentation interne à jour. |

### 7.2 Méthode et restauration

- **Code et config** : sauvegarde assurée par Git (remote GitHub). Cloner le dépôt ou `git pull` pour restaurer.
- **Reconstruction** : le pipeline CI/CD permet de reconstruire et republier les images à partir du code à tout moment ; en cas de perte d’un environnement, redéployer à partir du dépôt et du registre d’images.

Pour une future base de données persistante : définir des sauvegardes régulières (dumps) et une procédure de restauration (répertoire, fréquence, rétention).

Le détail est dans [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md#2-plan-de-sauvegarde).

---

## 8. Le plan des mises à jour

### 8.1 Application

- **Mise à jour du code** : via le dépôt Git (branches, PR, merge sur `main`). Le pipeline CI build et teste ; le CD publie les nouvelles images sur push sur `main`.
- **Déploiement des mises à jour** : tirer les nouvelles images depuis le registre et redémarrer les conteneurs (`docker-compose pull && docker-compose up -d`) ou déclencher un déploiement automatisé si l’environnement le permet.

### 8.2 Dépendances et packages

- **Backend (Gradle)** : mettre à jour les dépendances dans `back/build.gradle` ; valider par les tests et la CI.
- **Frontend (npm)** : `npm outdated`, puis mise à jour ciblée dans `front/package.json` et `npm install` ; lancer les tests (Karma) et la CI avant merge.
- **Images Docker** : mettre à jour les tags des images de base dans le `Dockerfile` (node, gradle, alpine) et dans `docker-compose-elk.yml` (Elasticsearch, Logstash, Kibana) ; rebuild et tests après chaque changement.

### 8.3 Bonnes pratiques

- **Évolution régulière** : ajuster les processus (tests, qualité SonarQube, KPI) en fonction de l’évolution de l’application et des outils.
- **Non-régression** : toute mise à jour (code, dépendances, images) doit passer par le pipeline (build, tests, analyse qualité) avant déploiement.
- **Traçabilité** : versions et changements documentés dans le dépôt (commits, tags, release notes si applicable).

Le détail est dans [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md#3-plan-de-mise-à-jour).

---

## Récapitulatif des livrables

| Livrable | Emplacement |
|----------|--------------|
| **Workflow CI/CD** | [.github/workflows/ci-cd.yml](../.github/workflows/ci-cd.yml) |
| **Dockerfiles** | [Dockerfile](../Dockerfile) (multi-cibles : front, back, standalone) |
| **README (choix techniques et instructions)** | [README.md](../README.md) |
| **Documentation CI/CD complète** | Ce document + références ci-dessus |
