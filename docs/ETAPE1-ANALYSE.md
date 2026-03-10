# Étape 1 – Analyse du dépôt et veille technologique

## 1. Structure du dépôt

Le projet **MicroCRM** est un **monorepo** contenant :

| Répertoire | Rôle |
|------------|------|
| `back/` | Backend Java **Spring Boot 3.2** (Gradle), API REST (Spring Data REST), JPA, HSQLDB |
| `front/` | Frontend **Angular 17** (CLI, standalone components) |
| `misc/docker/` | Fichiers pour la conteneurisation (Caddyfile, supervisor.ini) |
| Racine | `Dockerfile` multi-cibles (front, back, standalone) |

### Organisation du code

- **Backend** : `back/src/main/java/com/openclassroom/devops/orion/microcrm/`  
  Entités (`Person`, `Organization`), repositories Spring Data, configuration REST, fixture de données.
- **Frontend** : `front/src/app/`  
  Composants (main-dashboard, person-details, organization-details), services (person, organization), routing Angular.
- **Tests** :  
  - Back : `back/src/test/java/...` (JUnit 5, Spring Boot Test, DataJpaTest).  
  - Front : Karma + Jasmine, config dans `karma.conf.js`, specs à côté des composants/services.

---

## 2. Commandes de build et de tests

### Backend (Gradle)

| Action | Commande | Où |
|--------|----------|-----|
| Build (compile + tests) | `./gradlew build` (Linux/macOS) ou `gradlew.bat build` (Windows) | Depuis `back/` |
| Tests seuls | `./gradlew test` | Depuis `back/` |
| JAR produit | `back/build/libs/microcrm-0.0.1-SNAPSHOT.jar` | Après `build` |

**Dépendances** : OpenJDK ≥ 17.

### Frontend (npm / Angular CLI)

| Action | Commande | Où |
|--------|----------|-----|
| Installer les dépendances | `npm ci` ou `npm install` | Depuis `front/` |
| Build production | `npx @angular/cli build --optimization` ou `npm run build` | Depuis `front/` |
| Build sortie | `front/dist/microcrm/browser/` | Après build |
| Tests unitaires | `npm test` (équivalent à `ng test`) | Depuis `front/` |

**Dépendances** : Node.js / npm (Angular 17 requiert Node 18.19+ ou 20.11+).  
**Tests** : Karma + Jasmine, navigateur headless (Chrome) avec launcher `ChromeHeadlessNoSandbox` pour la CI.

### Récapitulatif – Lancement local

```bash
# Backend
cd back
./gradlew build
java -jar build/libs/microcrm-0.0.1-SNAPSHOT.jar
# API : http://localhost:8080

# Frontend (autre terminal)
cd front
npm ci
npx @angular/cli serve
# App : http://localhost:4200
```

L’API est utilisée via `front/src/app/config.ts` : `API_BASE_URL = "http://localhost:8080"`.

---

## 3. Tests existants

### Backend

- **MicroCRMApplicationTests** : `@SpringBootTest`, vérifie le chargement du contexte.
- **PersonRepositoryIntegrationTest** : `@DataJpaTest`, test du repository (findByEmail).

Exécution : `./gradlew test` depuis `back/`.  
Framework : JUnit 5, Spring Boot Test, test-logger (plugin Gradle).

### Frontend

- Specs Jasmine pour les composants et services (ex. `app.component.spec.ts`, `person.service.spec.ts`, etc.).
- Config Karma : `karma.conf.js` avec `ChromeHeadlessNoSandbox` (flags `--no-sandbox`) pour la CI, et coverage (HTML + text-summary).

Exécution : `npm test` depuis `front/` (nécessite Chrome/Chromium pour les tests).

---

## 4. Outils et dépendances déjà en place

- **Back** : Gradle (wrapper), Spring Boot 3.2.5, Java 17, HSQLDB, Spring Data JPA/REST, plugin test-logger.
- **Front** : Angular 17, TypeScript 5.4, Karma 6.4, Jasmine 5.1, karma-coverage.
- **Docker** : Dockerfile multi-stage (front-build, back-build, front, back, standalone), Caddy (front), Supervisord (standalone), images Alpine.

---

## 5. Contraintes techniques pour la CI/CD

- **Backend** : JDK 17 obligatoire pour le build et les tests.
- **Frontend** : Node 18+ recommandé ; tests avec Chrome headless (à installer ou utiliser une action avec Chrome).
- **Pas de Maven** : le backend utilise **Gradle** ; les workflows doivent appeler `./gradlew` et non `mvn`.
- **Secrets** : aucun secret en dur ; utiliser les variables d’environnement / secrets GitHub (ex. `SONAR_TOKEN` pour SonarQube Cloud).
- **Artefacts** : JAR dans `back/build/libs/`, build Angular dans `front/dist/microcrm/browser/` ; les cibles Docker s’appuient sur ces chemins.

---

## 6. Veille technologique – Versions et bonnes pratiques

### Versions pertinentes

- **Java** : 17 LTS (aligné avec le projet) ; 21 LTS possible pour les images d’exécution.
- **Node** : 18 LTS ou 20 LTS pour Angular 17.
- **Angular** : 17.x (project actuel) ; Angular 18 disponible, migration optionnelle.
- **Spring Boot** : 3.2.x (project actuel) ; 3.3.x en évolution.
- **Docker** : images de base légères et officielles (ex. `eclipse-temurin:17-jre-alpine`, `node:20-alpine`) pour sécurité et taille.

### Bonnes pratiques pipelines CI/CD Full-Stack Java / Angular

- **Monorepo** : un workflow unique avec jobs/steps pour back et front (parallélisation quand c’est possible).
- **Cache** : cache Gradle (`~/.gradle/caches`, `~/.gradle/wrapper`), cache npm (`node_modules` ou `npm cache`) pour accélérer les builds.
- **Tests** : exécuter les tests back et front à chaque push/PR ; échouer le pipeline si les tests échouent.
- **Qualité / sécurité** : intégrer SonarQube (ou SonarQube Cloud) pour analyse statique ; pas de secrets en clair ; vérifier les dépendances (ex. OWASP, audit npm).
- **Conteneurisation** : images multi-stage, utilisateur non-root en production, bases minimales (Alpine/slim), pas de données sensibles dans les images.
- **CD** : build d’images uniquement sur branche main ou tags ; pousser vers un registre (ex. GitHub Container Registry) avec des tags explicites (commit SHA, version).

Ces éléments sont pris en compte dans les plans (étape 2) et dans la configuration du pipeline (étapes 3 à 5).
