# Vérification – Auto-évaluation P7 (FAE)

Ce document permet de **vérifier le travail** par rapport à la grille d’auto-évaluation (PDF FAE P7 FDSJA). Chaque indicateur de réussite est repris avec la référence au livrable correspondant.

---

## Compétences et livrables

### 1. Concevoir et préparer les environnements de développement et de tests

| Indicateur | Référence dans le projet |
|------------|---------------------------|
| L’environnement de tests permet d’exécuter les tests automatisés et d’en récupérer les résultats. | Pipeline CI (`.github/workflows/ci.yml`) : jobs `back-build-test` et `front-build-test` ; exécution locale : `./gradlew test` (back), `npm test` (front). Voir [ETAPE1-ANALYSE.md](ETAPE1-ANALYSE.md) et [COMMANDES-CICD.md](COMMANDES-CICD.md). |
| Le workflow CI/CD du repo GitHub comprend bien toutes les étapes attendues. | Build back + front, tests back + front, SonarQube Cloud (si activé), build & push des images Docker (CD). Voir [.github/workflows/ci.yml](../.github/workflows/ci.yml) et [COMMANDES-CICD.md](COMMANDES-CICD.md). |
| Les actions, outils ou scripts utilisés pour chaque étape du workflow sont justifiés. | [PLANS-CICD.md](PLANS-CICD.md), [COMMANDES-CICD.md](COMMANDES-CICD.md), [ETAPE1-ANALYSE.md](ETAPE1-ANALYSE.md). |
| Clarté et organisation des étapes de mise en œuvre dans la documentation. | Structure dans [docs/](.), [README.md](../README.md), [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md). |

### 2. Automatiser les pipelines CI/CD

| Indicateur | Référence dans le projet |
|------------|---------------------------|
| Outils et actions du pipeline adaptés au projet full-stack Java/Angular. | Gradle (back), npm/Angular CLI (front), SonarQube, Docker (cibles front, back, standalone). [ETAPE1-ANALYSE.md](ETAPE1-ANALYSE.md), [PLANS-CICD.md](PLANS-CICD.md). |
| La configuration CI/CD assure l’automatisation complète des tâches demandées. | Build, tests, analyse qualité (SonarQube si activé), publication des images Docker. [.github/workflows/ci.yml](../.github/workflows/ci.yml). |
| Pas d’étapes inutiles ou manquantes par rapport aux attentes. | Workflow ciblé : build, test, qualité, CD ; pas d’ELK dans la CI (trop lourd). [COMMANDES-CICD.md](COMMANDES-CICD.md). |
| Clarté du plan de conteneurisation : comprendre, exécuter et maintenir le pipeline. | [PLANS-CICD.md](PLANS-CICD.md), [DOCKER-COMPOSE.md](DOCKER-COMPOSE.md), [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md). |
| Méthodologie et choix techniques décrits fidèlement. | [PLANS-CICD.md](PLANS-CICD.md), [ETAPE1-ANALYSE.md](ETAPE1-ANALYSE.md). |

### 3. Renforcer la sécurité avec des plans de test

| Indicateur | Référence dans le projet |
|------------|---------------------------|
| Exécution des tests automatique ; dépendances installées ; tests au bon moment dans le workflow. | Jobs CI dédiés back et front ; `npm ci` / Gradle ; tests avant SonarQube et CD. [.github/workflows/ci.yml](../.github/workflows/ci.yml). |
| Tests déclenchés selon les règles prévues, en cohérence avec le plan de testing périodique. | Push et PR sur `main`/`master` ; voir [PLANS-CICD.md](PLANS-CICD.md) (plan de testing). |
| Les tests automatisés permettent de vérifier le comportement attendu de l’application. | JUnit (contexte Spring, repositories), Karma/Jasmine (composants, services). [ETAPE1-ANALYSE.md](ETAPE1-ANALYSE.md). |
| Plan de testing périodique : quand les tests sont exécutés. | [PLANS-CICD.md](PLANS-CICD.md) – tableau « Moments d’exécution ». |
| Plan de testing périodique complet. | Types de tests, moments, objectifs. [PLANS-CICD.md](PLANS-CICD.md). |
| Plan de sécurité et description de l’intégration des tests cohérents avec le code et le workflow. | [PLANS-CICD.md](PLANS-CICD.md), [PLAN-SECURITE-FINAL.md](PLAN-SECURITE-FINAL.md). |

### 4. Améliorer les pipelines CI/CD (monitoring, KPI)

| Indicateur | Référence dans le projet |
|------------|---------------------------|
| Mise en place du monitoring méthodique : installation, configuration minimale, sources de logs pertinentes. | Stack ELK (docker-compose-elk.yml), Logstash pipeline, logs JSON Spring Boot. [ELK.md](ELK.md). |
| Les dashboards permettent de visualiser les éléments demandés. | Kibana : index `microcrm-logs-*`, visualisations (erreurs, volume, fréquence). [ELK.md](ELK.md) ; à illustrer par des captures. |
| Calcul et interprétation des métriques DORA dans la documentation. | [METRIQUES-DORA-KPI.md](METRIQUES-DORA-KPI.md). |
| Choix des KPI et analyse permettant d’identifier des pistes d’amélioration. | [METRIQUES-DORA-KPI.md](METRIQUES-DORA-KPI.md), [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md). |
| Identification détaillée des anomalies ou risques depuis les logs, métriques ou visualisations. | [PLAN-SECURITE-FINAL.md](PLAN-SECURITE-FINAL.md) (croisement SonarQube / ELK), [METRIQUES-DORA-KPI.md](METRIQUES-DORA-KPI.md). |
| Documentation complète, de la mise en place du monitoring aux recommandations. | [ELK.md](ELK.md), [METRIQUES-DORA-KPI.md](METRIQUES-DORA-KPI.md), [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md). |

### 5. Planifier et documenter la mise en production

| Indicateur | Référence dans le projet |
|------------|---------------------------|
| Plans présentant les risques pouvant survenir lors de la mise en production. | [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md) – risques et reprise. |
| Procédure de reprise détaillée. | Plan de déploiement (redémarrage, recréation des conteneurs) ; plan de sauvegarde (restauration à partir du dépôt et du pipeline). [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md). |
| Au moins une action automatisée facilitant la restauration dans le plan de sauvegarde. | Reconstruction et republication des images via le pipeline CI/CD à partir du dépôt. [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md). |
| Nécessité d’ajuster régulièrement les processus en fonction de l’évolution de l’application ou des outils. | Plan de mise à jour et bonnes pratiques. [PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md](PLANS-DEPLOIEMENT-SAUVEGARDE-MISE-A-JOUR.md), [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md). |

### 6. Optimiser la solution en réduisant la dette technique

| Indicateur | Référence dans le projet |
|------------|---------------------------|
| Identification des éléments contribuant à la dette technique à partir de SonarQube, métriques DORA et KPI. | [PLAN-SECURITE-FINAL.md](PLAN-SECURITE-FINAL.md), [METRIQUES-DORA-KPI.md](METRIQUES-DORA-KPI.md). |
| Processus d’amélioration proposé cohérent. | [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md) – recommandations argumentées. |
| Outils et sources analysées adaptés au contexte. | SonarQube (Java/TS), GitHub Actions, ELK, Gradle, npm. [ETAPE1-ANALYSE.md](ETAPE1-ANALYSE.md), [PLAN-SECURITE-FINAL.md](PLAN-SECURITE-FINAL.md). |
| Au moins un point critique mis en évidence. | Vulnérabilités et règles critiques SonarQube ; erreurs fréquentes (ELK). [PLAN-SECURITE-FINAL.md](PLAN-SECURITE-FINAL.md). |
| Conclusions satisfaisantes. | Synthèse et recommandations dans [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md). |
| Préconisations réalistes, adaptées au contexte et techniquement cohérentes. | [PLAN-SECURITE-FINAL.md](PLAN-SECURITE-FINAL.md), [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md). |
| Documentation finale complète : métriques DORA, KPI, résultats SonarQube, observations logs/dashboards, recommandations. | [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md) et liens vers tous les documents listés. |

---

## À faire de votre côté

1. **Cocher les cases** du PDF d’auto-évaluation en vous appuyant sur les références ci-dessus.
2. **Renseigner la colonne « Notes »** du PDF avec les chemins des fichiers ou des commentaires utiles pour la soutenance.
3. **Ajouter des captures d’écran** des dashboards Kibana (et éventuellement SonarQube / GitHub Actions) dans `docs/screenshots/` et les citer dans [DOCUMENTATION-TECHNIQUE-FINALE.md](DOCUMENTATION-TECHNIQUE-FINALE.md) pour illustrer les visualisations et les tendances.
