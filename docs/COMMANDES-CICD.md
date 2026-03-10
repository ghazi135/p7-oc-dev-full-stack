# Référence des commandes – CI/CD et exécution

Documentation des commandes importantes : **objectif**, **où elles sont définies**, **à quel moment elles sont exécutées** (local, CI, CD, release).

---

## Build et tests (local)

| Commande | Objectif | Où définie | Quand exécutée |
|----------|----------|------------|----------------|
| `cd back && ./gradlew build` | Compiler le back, lancer les tests JUnit, produire le JAR | `back/build.gradle` | Local, CI (job Backend – Build & Tests) |
| `cd back && ./gradlew test` | Exécuter uniquement les tests back | `back/build.gradle` | Local |
| `cd front && npm ci` | Installer les dépendances front (lockfile) | `front/package.json` | Local, CI (job Frontend) |
| `cd front && npm run build` | Build Angular production (optimisation) | `front/package.json`, `front/angular.json` | Local, CI (job Frontend) |
| `cd front && npm test -- --no-watch --browsers=ChromeHeadlessNoSandbox` | Lancer les tests unitaires front (Karma/Jasmine) en headless | `front/package.json`, `front/karma.conf.js` | Local, CI (job Frontend) |

---

## Docker (local)

| Commande | Objectif | Où définie | Quand exécutée |
|----------|----------|------------|----------------|
| `docker build --target front -t orion-microcrm-front:latest .` | Construire l’image du front (Caddy + fichiers statiques) | `Dockerfile` | Local |
| `docker build --target back -t orion-microcrm-back:latest .` | Construire l’image du back (JRE + JAR) | `Dockerfile` | Local |
| `docker build --target standalone -t orion-microcrm-standalone:latest .` | Construire l’image tout-en-un (Supervisord) | `Dockerfile` | Local |
| `docker-compose up` | Démarrer les services back + front (ou standalone avec `--profile full`) | `docker-compose.yml` | Local |

---

## Pipeline GitHub Actions (CI)

| Job / step | Objectif | Où défini | Quand exécuté |
|------------|----------|-----------|----------------|
| **Backend – Build & Tests** | Build Gradle + tests back, upload du JAR en artifact | `.github/workflows/ci.yml` | À chaque push et pull request sur `main` / `master` |
| **Frontend – Build & Tests** | npm ci, build Angular, tests Karma (Chrome headless) | `.github/workflows/ci.yml` | À chaque push et pull request sur `main` / `master` |
| **SonarQube Cloud** | Analyse statique qualité / sécurité (bugs, vulnérabilités, code smells) | `.github/workflows/ci.yml` | Si la variable de dépôt `ACTIVATE_SONAR` = `true` (après succès des jobs back et front) |

---

## Pipeline GitHub Actions (CD)

| Job / step | Objectif | Où défini | Quand exécuté |
|------------|----------|-----------|----------------|
| **Build & Push Docker images** | Construire les images front, back, standalone et les pousser vers GitHub Container Registry (GHCR) | `.github/workflows/ci.yml` | Uniquement sur **push** vers `main` ou `master` (pas sur pull request) |

Les images sont publiées avec les tags `latest` et le SHA du commit.

---

## Résumé des moments d’exécution

- **Local** : build, tests, Docker, docker-compose à la demande.
- **CI** : à chaque push et PR → build back + front, tests back + front, (optionnel) SonarQube.
- **CD** : à chaque push sur `main` / `master` → build et push des images Docker vers GHCR.
