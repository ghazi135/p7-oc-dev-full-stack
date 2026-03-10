# Docker Compose – MicroCRM

## Objectif

Orchestrer les services **front** et **back** (et optionnellement **standalone**) pour lancer l’application en un seul ordre : `docker-compose up`.

## Choix techniques

- **Images** : construites à partir du `Dockerfile` multi-cibles (front, back, standalone). Images de base Alpine pour réduire la taille et la surface d’attaque.
- **Réseau** : les services sont sur le réseau par défaut ; le front est compilé avec `API_BASE_URL = http://localhost:8080`, le navigateur accédant au back via le port exposé sur l’hôte.
- **Pas de données sensibles** dans les images ; HSQLDB est en mémoire (backend).

## Utilisation

```bash
# Lancer back + front (ports 8080, 80, 443)
docker-compose up --build

# En arrière-plan
docker-compose up -d --build

# Lancer l’image tout-en-un (front + back dans un seul conteneur)
docker-compose --profile full up standalone --build
```

## Vérification des images

- Utiliser des images de base officielles/maintenues (Alpine, Temurin/Eclipse Adoptium pour le JRE).
- Ne pas stocker de secrets dans les images ; utiliser des variables d’environnement ou des secrets au runtime si besoin.
