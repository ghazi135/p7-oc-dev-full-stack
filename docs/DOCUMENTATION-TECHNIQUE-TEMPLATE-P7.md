# Documentation technique – MicroCRM (P7)

**Ce document suit la structure du template ODT fourni (Template documentation P7-FS).**  
Remplir les champs [entre crochets] et s’appuyer sur les liens vers la doc existante pour compléter l’ODT.

---

## Page de titre

- **Titre du document** : Documentation technique – MicroCRM
- **Auteur** : [à renseigner]
- **Option choisie** : Option B (Scénario Orion)
- **Date** : [à renseigner]

---

## 1. Introduction

- **Contexte du projet** : Application MicroCRM (CRM simplifié), monorepo Java Spring Boot 3 (back) + Angular 17 (front). Mission P7 : industrialisation CI/CD, conteneurisation, qualité, monitoring.
- **Objectifs de l’industrialisation** : Automatiser build, tests, analyse qualité (SonarQube), déploiement (images Docker), création de releases ; garantir reproductibilité et traçabilité.
- **Technologies principales** : Java 17, Spring Boot 3, Gradle ; Angular 17, npm ; GitHub Actions ; Docker / Docker Compose ; SonarCloud ; ELK (monitoring).
- **Présentation rapide du pipeline CI/CD** : Workflow unique `.github/workflows/ci-cd.yml` : CI (build back + front, tests JUnit et Karma) à chaque push/PR ; SonarQube si activé ; CD (build & push images Docker Hub) sur push main/master ; création automatique d’une release (tag vX.Y.Z + JAR + build front) après CD. → Détail : [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 1.

---

## 2. Étapes de mise en œuvre du pipeline CI/CD

### 2.1 Structure du pipeline

- **Étapes principales** : Checkout → Build back (Gradle, JUnit, JaCoCo) → Build front (npm, Karma, LCOV) → [optionnel] SonarQube Cloud → Build & push images Docker (front, back, standalone) → Create release (tag + JAR + front zip). → [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 1.
- **Ordre d’exécution** : Jobs parallèles back et front ; puis SonarQube (si activé) et CD en aval ; release après CD.
- **Justification du choix des actions GitHub** : actions officielles (checkout, setup-java, setup-node), SonarSource/sonarqube-scan-action, docker/build-push-action, softprops/action-gh-release ; cache Gradle/npm pour la rapidité ; secrets via GitHub (aucun en clair).

### 2.2 Scripts d’automatisation

- **Scripts utilisés** : `back/gradlew` (build, test), `front` (npm ci, npm run build, npm test), Dockerfile (cibles front, back, standalone), docker-compose.yml.
- **Leur rôle dans le pipeline** : Gradle et npm pour build/tests ; Dockerfile pour images ; docker-compose pour orchestration locale.
- **Comment les exécuter ou les adapter** : Voir README et [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 1 (référence des commandes).

### 2.3 Reproductibilité

- **Comment relancer le pipeline** : Push ou PR sur main/master ; ou création manuelle d’un workflow_dispatch si ajouté.
- **Gestion des secrets** : SONAR_TOKEN, DOCKERHUB_TOKEN dans GitHub Secrets ; variables (SONAR_PROJECT_KEY, SONAR_ORGANIZATION, DOCKERHUB_USERNAME, ACTIVATE_SONAR) en variables de dépôt ; jamais en clair dans le code ni les workflows.

---

## 3. Plan de conteneurisation et de déploiement

### 3.1 Dockerfiles

- **Principaux choix techniques** : Images de base Alpine ; multi-stage (front-build, back-build puis étapes d’exécution) ; Caddy pour le front, JRE 17 pour le back ; pas de données sensibles dans les images. → [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 2.
- **Explication du multi-stage build** : Stages `front-build` et `back-build` produisent les artefacts ; stages finaux ne contiennent que le strict nécessaire (fichiers statiques + Caddy, ou JAR + JRE) ; cible `standalone` combine front + back avec Supervisord.

### 3.2 docker-compose.yml

- **Services définis** : back (API 8080), front (80/443) ; option standalone (profil full).
- **Instructions pour lancer l’application localement** : `docker-compose up --build` ; ou `docker-compose --profile full up standalone --build`. → [DOCKER-COMPOSE.md](DOCKER-COMPOSE.md), README.

---

## 4. Plan de testing périodique

### 4.1 Types de tests automatisés

- **Tests unitaires, d’intégration, sécurité** : JUnit 5 (back), Karma/Jasmine (front) ; SonarQube pour qualité/sécurité.
- **Quand les tests doivent être exécutés** : À chaque push et à chaque pull request ; avant SonarQube et CD.
- **Quels tests à quelle étape** : Jobs dédiés back et front ; rapports JaCoCo et LCOV pour SonarQube.
- **Critères de réussite ou d’alerte** : Build et tests doivent passer ; Quality Gate SonarQube si activé. → [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 3, [PLANS-CICD.md](PLANS-CICD.md).

### 4.2 Fréquence d’exécution

- **Sur push** : build back + front, tests back + front.
- **Sur pull request** : idem + SonarQube si ACTIVATE_SONAR=true.
- **Avant release** : après CD, job Create release (tag + artefacts).

### 4.3 Objectifs des tests

- **Qualité** : détection des régressions et des code smells.
- **Non-régression** : tous les tests doivent rester verts.
- **Vérification du bon fonctionnement avant déploiement** : aucun déploiement d’image si les tests échouent.

---

## 5. Plan de sécurité

### 5.1 Résultats SonarQube

- **Vulnérabilités identifiées** : Suivre l’onglet Security / Vulnerabilities dans SonarCloud ; actuellement 0 vulnérabilité (note A) selon les captures.
- **Code Smells critiques** : Fiabilité (note C, 11 issues) ; Maintenabilité (43 issues).
- **Zones de complexité** : À consulter dans SonarCloud (Complexity, Cognitive Complexity).
- **Couverture des tests** : Agrégée back + front (ex. 37,4 %) ; rapports JaCoCo (back) et LCOV (front). → [PLAN-SECURITE-FINAL.md](PLAN-SECURITE-FINAL.md), [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 6.

### 5.2 Analyse des risques

- **Vulnérabilités** : Suivi via SonarQube et Security Hotspots (revue manuelle).
- **Risques liés au pipeline** : Secrets (gérés via GitHub) ; dépendances (Gradle, npm) ; images de base Docker à maintenir à jour.

### 5.3 Plan d’action / Remédiation

- **Actions immédiates** : Corriger les 11 issues de fiabilité ; revoir le Security Hotspot.
- **Actions à court terme** : Augmenter la couverture de tests ; traiter les code smells prioritaires.
- **Actions à long terme** : npm audit / OWASP Dependency Check en CI ; serrer le Quality Gate. → [PLAN-SECURITE-FINAL.md](PLAN-SECURITE-FINAL.md).

---

## 6. Monitoring, métriques & KPI

### 6.1 Métriques DORA

- **Lead Time, Deployment Frequency, MTTR, Change Failure Rate** : Définitions et méthode de calcul dans [METRIQUES-DORA-KPI.md](METRIQUES-DORA-KPI.md) ; valeurs à renseigner à partir des runs GitHub Actions et du suivi des incidents. → [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 4–5.

### 6.2 KPI personnalisés

- **Temps de build** (back, front), **temps des tests**, **taux d’erreurs dans les logs** (ELK), **qualité SonarQube**. → [METRIQUES-DORA-KPI.md](METRIQUES-DORA-KPI.md).

### 6.3 Analyse synthétique du monitoring

- **Tendances, points forts, points à améliorer, dashboards, alertes** : Synthèse dans [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md) ; stack ELK décrite dans [ELK.md](ELK.md).

---

## 7. Plan de sauvegarde des données

### 7.1 Ce qui doit être sauvegardé

- **Données** : HSQLDB en mémoire (pas de persistance actuelle).
- **Fichiers de configuration** : Versionnés dans le dépôt (docker-compose, workflows, Logstash, etc.).
- **Artefacts de build** : Reconstructibles via le pipeline ; releases GitHub (JAR + front zip). → [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 7, [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md).

### 7.2 Procédure de sauvegarde

- **Format, fréquence, outils** : Git (code et config) ; pipeline pour reconstruire les images et les releases.

### 7.3 Procédure de restauration

- **Scénario d’incident, étapes pour revenir à une version stable, limitations** : Redémarrage/recréation des conteneurs ; restauration à partir du dépôt et du registre d’images ; reconstruction via le pipeline. → [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md).

---

## 8. Plan de mise à jour

### 8.1 Mise à jour de l’application

- **Dépendances Maven / npm** : Mise à jour dans `back/build.gradle` et `front/package.json` ; validation par tests et CI.
- **Mises à jour Angular / Spring Boot** : Suivre les releases ; tester et documenter.
- **Mises à jour Docker (images)** : Mise à jour des tags des images de base dans le Dockerfile et docker-compose-elk. → [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 8, [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md).

### 8.2 Mise à jour du pipeline CI/CD

- **Versions des actions GitHub** : Vérifier les versions (actions/checkout@v4, etc.) et les release notes.
- **Versions des scripts, maintenance du workflow** : Documenter les changements dans le dépôt ; relecture du workflow après mise à jour majeure.

### 8.3 Fréquence & bonnes pratiques

- Ajuster régulièrement les processus (sauvegarde, restauration, mise à jour) en fonction de l’évolution de l’application et des outils ; toute mise à jour doit passer par le pipeline (build, tests, qualité) avant déploiement.

---

## 9. Conclusion

- **Résumé des améliorations apportées** : Pipeline CI/CD complet (build, tests, SonarQube, CD, release) ; conteneurisation multi-cibles ; documentation structurée (livrable Partie 1 et 2).
- **Gains observés** : Fiabilité (tests automatiques), traçabilité (releases, Quality Gate), reproductibilité (Docker, secrets gérés).
- **Recommandations pour les itérations suivantes** : Voir [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md) (recommandations).

---

## Annexes (optionnelles)

- **Captures SonarQube** : À déposer dans `docs/screenshots/` et référencer. → [docs/screenshots/README.md](screenshots/README.md)
- **Captures de logs (monitoring Option B)** : Kibana (index `microcrm-logs-*`). → [ELK.md](ELK.md)
- **Extraits de workflows** : `.github/workflows/ci-cd.yml` (commenté).
- **Commandes utiles** : README, [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 1 (référence des commandes).
