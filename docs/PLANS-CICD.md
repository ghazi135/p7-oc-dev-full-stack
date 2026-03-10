# Étape 2 – Plans d’automatisation (testing, sécurité, conteneurisation)

Ce document formalise les règles et objectifs de l’automatisation **avant** la mise en œuvre du pipeline. Les choix techniques (GitHub Actions, SonarQube Cloud, Docker) en dépendent.

---

## 1. Plan de testing périodique

### Types de tests exécutés

| Zone | Type | Outil | Objectif |
|------|------|--------|-----------|
| Backend | Tests unitaires / intégration | JUnit 5, Spring Boot Test, DataJpaTest | Vérifier le contexte Spring et les repositories (non-régression, validation fonctionnelle). |
| Frontend | Tests unitaires (composants, services) | Karma + Jasmine | Vérifier le comportement des composants et services (non-régression, qualité). |

Aucun test E2E (Playwright/Cypress) n’est défini pour l’instant ; le plan peut être étendu plus tard.

### Moments d’exécution

| Événement | Tests exécutés | Objectif |
|-----------|----------------|----------|
| **Push** sur toute branche | Build back + front, tests back, tests front | Détecter rapidement les régressions et les erreurs de build. |
| **Pull Request** vers `main` | Idem + analyse SonarQube (si configurée) | Valider que la PR ne dégrade pas la qualité ni la sécurité. |
| **Merge / tag** (optionnel) | Idem + étape CD (build et push d’images) | Préparer des artefacts déployables. |

### Objectifs associés

- **Validation fonctionnelle** : les tests back (repository, contexte) et front (composants, services) confirment que le comportement attendu est respecté.
- **Non-régression** : à chaque modification, l’ensemble des tests doit rester vert.
- **Qualité** : le build et les tests sont un préalable à toute analyse SonarQube ; les échecs de tests bloquent la suite du pipeline.

---

## 2. Plan de sécurité

### Rôle de SonarQube Cloud

- **Analyse statique** du code back (Java) et front (TypeScript/JavaScript) à chaque pipeline CI (push/PR).
- **Types de problèmes surveillés** :
  - **Bugs** : erreurs probables ou avérées.
  - **Vulnérabilités** : failles de sécurité (OWASP Top 10, etc.).
  - **Code smells** : dette technique, maintenabilité.
  - **Couverture** : utilisation des rapports de couverture (Gradle, Karma) pour suivre l’évolution.

Références : [SonarSource Rules](https://rules.sonarsource.com/), [OWASP Top 10:2021](https://owasp.org/Top10/).

### Bonnes pratiques dans la CI

- **Secrets** : aucun mot de passe, token ou clé en clair dans le code ou les workflows. Utiliser les **secrets GitHub** (ex. `SONAR_TOKEN`) et les **variables d’environnement** du dépôt.
- **Dépendances** :  
  - Back : Gradle peut être étendu avec des plugins d’audit (ex. OWASP Dependency Check) en option.  
  - Front : `npm audit` peut être exécuté en étape du workflow pour signaler les vulnérabilités connues.
- **Images Docker** : utilisation d’images de base officielles et à jour ; pas de données sensibles dans les images (cf. section 3).

---

## 3. Principes de conteneurisation et de déploiement

### Rôle des Dockerfiles existants

- **Dockerfile** à la racine : build multi-cibles.
  - **front** : build Angular (node) → image Alpine + Caddy pour servir les fichiers statiques (ports 80/443).
  - **back** : build Gradle (gradle:jdk17) → image Alpine + JRE pour exécuter le JAR (port 8080).
  - **standalone** : combine front + back dans une seule image avec Supervisord (dev/démo).
- Les stages de build (`front-build`, `back-build`) produisent les artefacts ; les stages finaux ne contiennent que le strict nécessaire pour l’exécution (léger, surface d’attaque réduite).

### Rôle de docker-compose

- **Orchestration locale** : lancer front, back et éventuellement d’autres services (ex. base de données si on sort d’HSQLDB embarqué) avec une seule commande (`docker-compose up`).
- **Cohérence** : mêmes images (ou builds locaux) que celles utilisées en CI/CD, pour reproduire le comportement en production.
- **Documentation** : le fichier `docker-compose.yml` décrit les services, ports et variables d’environnement ; il sert de référence pour le déploiement.

### Stratégie de déploiement

- **CI** : à chaque push/PR → build + tests + SonarQube. Aucune publication d’image à ce stade.
- **CD** : sur branche `main` (ou sur création de tag) → build des images Docker (front, back, éventuellement standalone) et **publication vers un registre** (ex. GitHub Container Registry – GHCR).
- **Tags d’images** : `latest` pour la dernière version sur `main`, et optionnellement le SHA du commit ou un numéro de version pour la traçabilité.
- **Environnements** : pas d’hébergement cible (Heroku, K8s, etc.) décrit dans ce plan ; le CD se limite à la publication d’images prêtes à être déployées ailleurs.

Ces principes sont appliqués dans le pipeline (étapes 3 à 5) et dans la documentation des commandes (README et ce document).
