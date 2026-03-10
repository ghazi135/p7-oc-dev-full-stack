# Stack ELK – Centralisation des logs (MicroCRM)

## Objectif

Centraliser les logs du **back-end (Spring Boot)** et permettre la visualisation dans **Kibana** : erreurs, tendances, volume et fréquence des événements.

## Prérequis

- Docker et Docker Compose installés.
- Application déjà exécutée via Docker Compose (voir [DOCKER-COMPOSE.md](DOCKER-COMPOSE.md)).
- Environ **4 Go de RAM** disponibles pour la stack ELK.

## Qu’est-ce qu’un docker-compose spécifique à ELK ?

C’est un fichier **séparé** (`docker-compose-elk.yml`) qui :

- Définit les 3 services : **Elasticsearch**, **Logstash**, **Kibana**.
- Expose les ports : **9200** (Elasticsearch), **5601** (Kibana), **5044** (Logstash, réception des logs).
- Utilise une configuration minimale adaptée à un poste de développeur (single-node, sécurité xpack désactivée pour le dev).
- S’exécute avec :  
  `docker-compose -f docker-compose-elk.yml up`

ELK **n’est pas intégré au pipeline CI/CD** (trop lourd pour les runners).

## Démarrer la stack ELK

```bash
docker-compose -f docker-compose-elk.yml up --build
```

- **Elasticsearch** : http://localhost:9200  
- **Kibana** : http://localhost:5601  
- **Logstash** : écoute en TCP sur le port **5044** (logs au format JSON).

## Envoyer les logs du back-end vers ELK

Le back-end Spring Boot est configuré pour envoyer les logs à Logstash **uniquement** lorsque le profil **`elk`** est actif (voir `back/src/main/resources/logback-spring.xml`).

### Option 1 : Lancer l’application + ELK ensemble

1. Démarrer ELK :  
   `docker-compose -f docker-compose-elk.yml up -d`
2. Lancer l’application en indiquant le profil `elk` et l’hôte Logstash :
   - **Depuis l’hôte** (JAR) :  
     `LOGSTASH_HOST=localhost java -Dspring.profiles.active=elk -jar back/build/libs/microcrm-0.0.1-SNAPSHOT.jar`
   - **Avec Docker Compose** (app + ELK sur le même réseau) : créer un fichier `docker-compose.override.yml` (à ne pas versionner si vous y mettez des paramètres locaux) :

```yaml
services:
  back:
    environment:
      SPRING_PROFILES_ACTIVE: elk
      LOGSTASH_HOST: logstash
```

Puis :  
`docker-compose -f docker-compose.yml -f docker-compose-elk.yml -f docker-compose.override.yml up`

Ainsi, le conteneur `back` peut joindre le service `logstash` sur le réseau Docker.

### Option 2 : ELK seul (sans application)

Pour tester Kibana sans logs applicatifs, vous pouvez envoyer des logs de test via TCP (ex. avec `nc` ou un script) sur le port 5044 au format JSON.

## Structure des logs (back-end)

- **Format** : JSON (encoder Logstash dans Logback).
- **Champs utiles** : `@timestamp`, `level`, `logger_name`, `message`, `stack_trace` (en cas d’erreur).
- **Index Elasticsearch** : `microcrm-logs-YYYY.MM.dd` (défini dans `elk/logstash/pipeline/logstash.conf`).

## Tableaux de bord Kibana

1. Ouvrir Kibana : http://localhost:5601  
2. **Créer un index pattern** : `microcrm-logs-*` (champ temporel : `@timestamp`).  
3. **Discover** : explorer les logs, filtrer par `level`, `logger_name`, `message`.  
4. **Visualisations** :
   - Volume de logs par heure / jour.
   - Répartition par niveau (ERROR, WARN, INFO).
   - Filtre sur les erreurs (`level: ERROR`).
   - Fréquence des événements par `logger_name`.

Les captures d’écran des dashboards peuvent être ajoutées à la documentation technique (voir [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md)).

## Points de vigilance

- **Mémoire** : adapter `ES_JAVA_OPTS` dans `docker-compose-elk.yml` si besoin (ex. `-Xms1g -Xmx1g` sur une machine plus puissante).
- **Versions** : stack en **8.x** (ex. 8.11.0), stable et récente.
- **CI/CD** : ne pas lancer ELK dans le pipeline GitHub Actions (trop lourd).
