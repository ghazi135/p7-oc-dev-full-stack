# =============================================================================
# Dockerfile multi-stages — MicroCRM (P7)
# =============================================================================
# Objectif : produire jusqu’à 3 images finales à partir d’un seul fichier :
#   - front   : fichiers Angular statiques servis par Caddy (ports 80/443)
#   - back    : API Spring Boot en JAR + JRE 17 (port 8080)
#   - standalone : front + back dans un seul conteneur (Supervisord)
#
# Construction ciblée (exemples) :
#   docker build --target front -t microcrm-front .
#   docker build --target back  -t microcrm-back  .
#   docker build --target standalone -t microcrm-all .
# =============================================================================

# -----------------------------------------------------------------------------
# Étape 1 — Build du frontend (Angular)
# -----------------------------------------------------------------------------
# Image de base : Node 20 sur Alpine (léger, adapté au build npm).
FROM node:20-alpine AS front-build

# Copie du code source du front dans le conteneur (contexte = racine du dépôt).
COPY ./front /src

WORKDIR /src

# Installation reproductible des dépendances (package-lock.json) puis build prod.
# --optimization active les optimisations Angular (taille bundle, tree-shaking, etc.).
RUN npm ci \
    && npx @angular/cli build --optimization

# -----------------------------------------------------------------------------
# Étape 2 — Build du backend (Gradle / Spring Boot)
# -----------------------------------------------------------------------------
# Image officielle Gradle avec JDK 17 : pas besoin d’installer Java à la main.
FROM gradle:jdk17 AS back-build

COPY ./back /src

WORKDIR /src

# gradlew doit être exécutable sur Linux ; build produit le JAR dans build/libs/.
RUN chmod +x gradlew && ./gradlew build

# -----------------------------------------------------------------------------
# Étape 3 — Image runtime « front » seule
# -----------------------------------------------------------------------------
# Alpine minimal : on ne garde que Caddy + les fichiers statiques générés.
FROM alpine:3.19 AS front

# Artefacts du build Angular (chemin typique Angular 17+ : dist/<projet>/browser).
COPY --from=front-build /src/dist/microcrm/browser /app/front

# Configuration Caddy (reverse proxy / HTTPS selon ton fichier).
COPY misc/docker/Caddyfile /app/Caddyfile

RUN apk add caddy

WORKDIR /app

EXPOSE 80
EXPOSE 443

# Démarre Caddy en premier plan (processus PID 1 du conteneur).
CMD ["/usr/sbin/caddy", "run"]

# -----------------------------------------------------------------------------
# Étape 4 — Image runtime « back » seule
# -----------------------------------------------------------------------------
FROM alpine:3.19 AS back

# Récupère uniquement le JAR compilé (pas les sources ni Gradle).
COPY --from=back-build /src/build/libs/microcrm-0.0.1-SNAPSHOT.jar /app/back/microcrm-0.0.1-SNAPSHOT.jar

# JRE headless suffisant pour exécuter le JAR (pas besoin du JDK complet).
RUN apk add --no-cache openjdk17-jre-headless

WORKDIR /app

EXPOSE 8080

CMD ["java", "-jar", "/app/back/microcrm-0.0.1-SNAPSHOT.jar"]

# -----------------------------------------------------------------------------
# Étape 5 — Image « standalone » (front + back)
# -----------------------------------------------------------------------------
# Réutilise les couches des images front et back : un seul conteneur expose
# les deux services, orchestrés par Supervisord (voir misc/docker/supervisor.ini).

FROM alpine:3.19 AS standalone

# Import du système de fichiers des étapes précédentes (binaires, /app, Caddy, etc.).
COPY --from=front / /
COPY --from=back / /

COPY misc/docker/supervisor.ini /app/supervisor.ini

RUN apk add supervisor

WORKDIR /app

# Supervisord lance Caddy + l’API Java selon la configuration.
CMD ["/usr/bin/supervisord", "-c", "/app/supervisor.ini"]

