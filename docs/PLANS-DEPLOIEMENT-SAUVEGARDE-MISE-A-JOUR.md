# Plans : Déploiement, Sauvegarde, Mise à jour

Ce document décrit le **plan de déploiement**, le **plan de sauvegarde** et le **plan de mise à jour** de l’application MicroCRM (étape 4). Il complète le plan de conteneurisation et déploiement déjà initié dans [PLANS-CICD.md](PLANS-CICD.md).

---

## 1. Plan de déploiement

### 1.1 Objectif

Décrire **comment** l’application est déployée, **dans quel ordre** et avec **quels prérequis**, en cohérence avec le pipeline CI/CD et la conteneurisation.

### 1.2 Prérequis techniques

- **Environnement** : hôte ou orchestrateur (ex. serveur, VM, cloud) avec Docker et Docker Compose (ou capacité à exécuter des conteneurs).
- **Réseau** : accès au registre d’images (ex. GHCR) si les images sont tirées depuis le pipeline.
- **Ressources** : au minimum 2 Go RAM pour back + front ; davantage si la stack ELK est déployée à côté.

### 1.3 Ordre et procédure

1. **Récupération des artefacts**
   - Images Docker : `microcrm-back`, `microcrm-front` (et éventuellement `microcrm-standalone`) depuis le registre (ex. GHCR après passage du pipeline CD).
   - Ou : build local à partir des sources (`docker build`, cibles `back`, `front`, `standalone`).

2. **Déploiement des services**
   - **Option A (recommandée pour cohérence)** : utiliser le fichier `docker-compose.yml` du projet.
     - `docker-compose pull` (si images depuis un registre), puis `docker-compose up -d`.
     - Ordre implicite : `back` puis `front` (grâce à `depends_on`).
   - **Option B** : déployer uniquement l’image **standalone** pour un déploiement tout-en-un (back + front dans un seul conteneur).
     - `docker run -d -p 8080:8080 -p 80:80 -p 443:443 <image-standalone>`.

3. **Vérification**
   - Back : `curl http://localhost:8080` (ou URL de l’API).
   - Front : accès à l’interface (http/https selon les ports exposés).

4. **Variables d’environnement**
   - Aucune donnée sensible ne doit être en dur dans les images.
   - En production, fournir les configurations (ex. URL d’API pour le front, paramètres de base de données si évolution future) via variables d’environnement ou secrets.

### 1.4 Risques et reprise

- **Risque** : indisponibilité en cas d’échec du déploiement ou de panne du conteneur.
- **Reprise** : redémarrage des conteneurs (`docker-compose restart` ou recréation avec `docker-compose up -d`). En cas de base de données externe (non présente dans ce projet), une procédure de restauration des sauvegardes s’applique (voir plan de sauvegarde).

---

## 2. Plan de sauvegarde

### 2.1 Données et configurations à sauvegarder

| Élément | Description | Fréquence suggérée |
|---------|-------------|-------------------|
| **Code source et historique** | Dépôt Git (GitHub). | Continue (push / merge). |
| **Configurations** | Fichiers de configuration du projet (docker-compose, pipeline, Logstash, etc.) versionnés dans le dépôt. | À chaque changement significatif (commit). |
| **Données applicatives** | Dans le projet actuel : HSQLDB en mémoire (backend) — **aucune persistance** des données. | N/A tant qu’il n’y a pas de base persistante. |
| **Secrets / variables** | Les secrets (tokens, mots de passe) ne doivent **pas** être dans le dépôt ; ils sont gérés par la plateforme (ex. GitHub Secrets). | Sauvegarder la liste des clés utilisées et leur emplacement (documentation interne), sans stocker les valeurs. |

### 2.2 Méthode et environnement

- **Code et config** : sauvegarde assurée par Git (remote GitHub). Une copie locale ou un miroir peut être utilisé comme secours.
- **Restoration** : cloner le dépôt ou faire un `git pull` ; rejouer le pipeline pour reconstruire les images si besoin.
- **Action automatisée facilitant la restauration** : le **pipeline CI/CD** permet de reconstruire et republier les images à partir du code à tout moment ; en cas de perte d’un environnement, on peut redéployer à partir du dépôt et du registre d’images.

Pour une future base de données persistante : définir des sauvegardes régulières (dumps) et une procédure de restauration (répertoire, fréquence, rétention), hors scope du livrable actuel.

---

## 3. Plan de mise à jour

### 3.1 Objectif

Expliquer **comment** l’application et ses dépendances sont mises à jour et **comment** maintenir la solution à jour (dépendances, bibliothèques, images de base).

### 3.2 Application

- **Mise à jour du code** : via le dépôt Git (branches, PR, merge sur `main`). Le pipeline CI/CD build et teste ; le CD publie les nouvelles images sur push sur `main`.
- **Déploiement des mises à jour** : tirer les nouvelles images depuis le registre et redémarrer les conteneurs (`docker-compose pull && docker-compose up -d`) ou déclencher un déploiement automatisé si l’environnement le permet.

### 3.3 Dépendances et packages

- **Backend (Gradle)** : mettre à jour les dépendances dans `back/build.gradle` (versions des plugins et des librairies). Lancer `./gradlew dependencyUpdates` (avec un plugin dédié si besoin) pour repérer les mises à jour disponibles. Valider par les tests et la CI.
- **Frontend (npm)** : `npm outdated`, puis mise à jour ciblée dans `front/package.json` et `npm install` ; lancer les tests (Karma) et la CI avant merge.
- **Images Docker** : mettre à jour les tags des images de base dans le `Dockerfile` (ex. `node:20-alpine`, `eclipse-temurin`, `alpine:3.19`) et les versions dans `docker-compose-elk.yml` (Elasticsearch, Logstash, Kibana 8.x). Rebuild et tests après chaque changement.

### 3.4 Bonnes pratiques

- **Évolution régulière** : ajuster les processus (tests, qualité SonarQube, KPI) en fonction de l’évolution de l’application et des outils (voir [METRIQUES-DORA-KPI.md](METRIQUES-DORA-KPI.md) et [PLAN-SECURITE-FINAL.md](PLAN-SECURITE-FINAL.md)).
- **Non-régression** : toute mise à jour (code, dépendances, images) doit passer par le pipeline (build, tests, analyse qualité) avant déploiement.
- **Traçabilité** : versions et changements documentés dans le dépôt (commits, tags, release notes si applicable).

Ces plans sont volontairement simples et applicables par un développeur ou un opérateur ; ils ne contiennent aucune donnée sensible (identifiants, tokens, secrets).
