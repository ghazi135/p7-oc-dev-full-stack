<p align="center">
   <img src="./front/src/favicon.png" width="192px" />
</p>

# MicroCRM (P7 - Développeur Full-Stack - Java et Angular - Mettez en œuvre l'intégration et le déploiement continu d'une application Full-Stack)

MicroCRM est une application de démonstration basique ayant pour objectif de servir de socle pour le module "P7 - Développeur Full-Stack".

L'application MicroCRM est une implémentation simplifiée d'un ["CRM" (Customer Relationship Management)](https://fr.wikipedia.org/wiki/Gestion_de_la_relation_client). Les fonctionnalités sont limitées à la création, édition et la visualisations des individus liés à des organisations.

![Page d'accueil](./misc/screenshots/screenshot_1.png)
![Édition de la fiche d'un individu](./misc/screenshots/screenshot_2.png)

## Code source

### Organisation

Ce [monorepo](https://en.wikipedia.org/wiki/Monorepo) contient les 2 composantes du projet "MicroCRM":

- La partie serveur (ou "backend"), en Java SpringBoot 3;
- La partie cliente (ou "frontend"), en Angular 17.

### Démarrer avec les sources

#### Serveur

##### Dépendances

- [OpenJDK >= 17](https://openjdk.org/)

##### Procédure

1. Se positionner dans le répertoire `back` avec une invite de commande:

   ```shell
   cd back
   ```

2. Construire le JAR:

   ```shell
   # Sur Linux
   ./gradlew build

   # Sur Windows
   gradlew.bat build
   ```

3. Démarrer le service:

   ```shell
   java -jar build/libs/microcrm-0.0.1-SNAPSHOT.jar
   ```

Puis ouvrir l'URL http://localhost:8080 dans votre navigateur.

#### Client

##### Dépendances

- [NPM >= 10.2.4](https://www.npmjs.com/)

##### Procédure

1. Se positionner dans le répertoire `front` avec une invite de commande:

   ```shell
   cd front
   ```

2. (La première fois seulement) Installer les dépendances NodeJS:

   ```shell
   npm install
   ```

3. Démarrer le service de développement:

   ```shell
   npx @angular/cli serve
   ```

Puis ouvrir l'URL http://localhost:4200 dans votre navigateur.

### Exécution des tests

#### Client

**Dépendances**

- Google Chrome ou Chromium

Dans votre terminal:

```shell
cd front
CHROME_BIN=</path/to/google/chrome> npm test
```

#### Serveur

Dans votre terminal:

```shell
cd back
./gradlew test
```

### Images Docker

#### Client

##### Construire l'image

```shell
docker build --target front -t orion-microcrm-front:latest .
```

##### Exécuter l'image

```shell
docker run -it --rm -p 80:80 -p 443:443 orion-microcrm-front:latest
```

L'application sera disponible sur https://localhost.

#### Serveur

##### Construire l'image

```shell
docker build --target back -t orion-microcrm-back:latest .
```

##### Exécuter l'image

```shell
docker run -it --rm -p 8080:8080 orion-microcrm-back:latest
```

L'API sera disponible sur http://localhost:8080.

#### Tout en un

```shell
docker build --target standalone -t orion-microcrm-standalone:latest .
```

##### Exécuter l'image

```shell
docker run -it --rm -p 8080:8080 -p 80:80 -p 443:443 orion-microcrm-standalone:latest
```

L'application sera disponible sur https://localhost et l'API sur http://localhost:8080.

---

## Documentation (mission P7)

- **[Étape 1 – Analyse du dépôt et veille](docs/ETAPE1-ANALYSE.md)** : structure du projet, commandes de build/tests, contraintes CI/CD.
- **[Plans CI/CD (étape 2)](docs/PLANS-CICD.md)** : plan de testing, plan de sécurité, principes de conteneurisation et déploiement.
- **[Docker Compose](docs/DOCKER-COMPOSE.md)** : orchestration des services, lancement avec `docker-compose up`.
- **[Référence des commandes CI/CD](docs/COMMANDES-CICD.md)** : tableau des commandes (objectif, où définies, quand exécutées).
- **[Stack ELK](docs/ELK.md)** : centralisation des logs (Elasticsearch, Logstash, Kibana), dashboards.
- **[Métriques DORA et KPI](docs/METRIQUES-DORA-KPI.md)** : indicateurs de performance du pipeline et analyse.
- **[Plan de sécurité (finalisé)](docs/PLAN-SECURITE-FINAL.md)** : vulnérabilités, SonarQube, recommandations.
- **[Plans déploiement, sauvegarde, mise à jour](docs/PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md)** : procédures et bonnes pratiques.
- **[Documentation technique finale](docs/DOCUMENTATION-TECHNIQUE-FINALE.md)** : synthèse métriques, KPI, recommandations.
- **[Vérification auto-évaluation P7](docs/VERIFICATION-AUTO-EVALUATION-P7.md)** : grille de vérification par rapport au livrable attendu.

---

## CI/CD (GitHub Actions)

Le pipeline est défini dans [.github/workflows/ci.yml](.github/workflows/ci.yml) :

- **CI** : à chaque push et pull request → build back + front, exécution des tests (JUnit, Karma).
- **SonarQube Cloud** : activé si la variable de dépôt `ACTIVATE_SONAR` est définie à `true`. À configurer :
  - **Secrets** : `SONAR_TOKEN` (jeton SonarCloud).
  - **Variables de dépôt** : `SONAR_PROJECT_KEY`, `SONAR_ORGANIZATION` (nom d’organisation SonarCloud).
- **CD** : sur push vers `main` / `master` → build et publication des images Docker (front, back, standalone) vers GitHub Container Registry (GHCR).

Aucun secret ne doit être stocké en clair ; utiliser les [secrets et variables GitHub](https://docs.github.com/en/actions/security-guides/encrypted-secrets).

---

## Docker Compose

Lancer l’application avec les services orchestrés :

```shell
docker-compose up --build
```

- **Front** : http://localhost (80) ou https://localhost (443).
- **Back** : http://localhost:8080.

Image tout-en-un (front + back dans un seul conteneur) :

```shell
docker-compose --profile full up standalone --build
```

Voir [docs/DOCKER-COMPOSE.md](docs/DOCKER-COMPOSE.md) pour les détails.

---

## Stack ELK (monitoring des logs)

Pour centraliser les logs du back-end et les visualiser dans Kibana (tableaux de bord, erreurs, tendances) :

```shell
docker-compose -f docker-compose-elk.yml up
```

- **Kibana** : http://localhost:5601  
- **Elasticsearch** : http://localhost:9200  
- Prévoir environ **4 Go RAM**. Les logs du back sont envoyés à Logstash lorsque le profil Spring `elk` est actif.

Voir [docs/ELK.md](docs/ELK.md) pour l’installation, la configuration et l’envoi des logs applicatifs.
