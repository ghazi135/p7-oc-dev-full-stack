# Présentation soutenance P7 – Option B (Orion)

**Mission :** Mettre en œuvre l'intégration et le déploiement continu d'une application Full-Stack.

**Durée :** 15 min présentation + 10 min questions + 5 min débrief.

---

## Slide 1 – Titre et contexte

**MicroCRM – Chaîne CI/CD Full-Stack (Java / Angular)**

- **Option B** : scénario fictif Orion
- **Objectif** : industrialiser l’application (build, tests, qualité, déploiement)
- **Livrables** : repo GitHub (workflow + Dockerfiles + README) + documentation CI/CD complète

*À dire :* « J’ai réalisé la mission en option B pour Orion. Je vais vous présenter le repo et la documentation, en montrant comment chaque compétence est couverte. »

---

## Slide 2 – Vue d’ensemble des livrables

| Compétence | Repo GitHub | Documentation |
|------------|-------------|----------------|
| Concevoir et préparer les environnements | **Workflow** `.github/workflows/ci-cd.yml` | Étapes de mise en œuvre du pipeline CI/CD |
| Automatiser les pipelines | **Dockerfiles** (front, back, standalone) | Plan de conteneurisation et déploiement |
| Renforcer la sécurité avec des plans de test | **Tests** dans le pipeline | Plan de testing périodique + Plan de sécurité |
| Améliorer les pipelines | — | KPI proposés et métriques |
| Planifier la mise en production | — | Plan de testing, sauvegarde, mises à jour |
| Optimiser (dette technique) | — | Analyse des métriques |

*À dire :* « Chaque ligne correspond à une compétence. Le repo contient le workflow et les Dockerfiles ; le reste est dans la documentation. »

---

## Slide 3 – Compétence 1 : Workflow et environnements de test

**CE1–CE2–CE4 : Workflow complet et justifié**

- **Où :** `.github/workflows/ci-cd.yml`
- **Étapes :** Checkout → Build back (Gradle, JUnit, JaCoCo) → Build front (npm, Karma, LCOV) → SonarQube Cloud → CD (build & push images Docker Hub)
- **Déclencheurs :** push et PR sur `main`/`master` ; CD uniquement sur push
- **Secrets :** aucun en clair ; `SONAR_TOKEN`, `DOCKERHUB_TOKEN` via GitHub Secrets

**Environnement de tests :** exécution automatique des tests et récupération des résultats (rapports JaCoCo + LCOV pour SonarQube).

*À dire :* « Le workflow couvre build, tests automatisés, analyse qualité/sécurité et déploiement. Les actions et outils sont justifiés dans la doc. Un membre de l’équipe Orion peut reproduire le pipeline avec la documentation. »

---

## Slide 4 – Compétence 2 : Dockerfiles et conteneurisation

**CE1–CE2–CE3 : Outils adaptés, automatisation complète, plan clair**

- **Où :** `Dockerfile` à la racine (multi-étapes, 3 cibles)
- **Cibles :** `front` (Angular + Caddy, 80/443), `back` (JAR + JRE 17, 8080), `standalone` (front+back, Supervisord)
- **Choix :** images Alpine, build séparé des artefacts, pas de données sensibles dans les images
- **Orchestration :** `docker-compose up --build` pour back + front

*À dire :* « Le Dockerfile est adapté au projet Java/Angular. Chaque instruction sert soit au build soit à l’exécution minimale. Le plan de conteneurisation dans la doc permet de comprendre, exécuter et maintenir le pipeline. »

---

## Slide 5 – Compétence 3 : Tests et sécurité

**CE1–CE5 : Plan de testing + plan de sécurité cohérents**

- **Tests dans le pipeline :** exécution automatique, dépendances installées (`npm ci`, Gradle), tests au bon moment (avant SonarQube et CD)
- **Quand :** push et PR (plan de testing périodique détaillé dans la doc)
- **Comportement attendu :** JUnit (Spring, repositories), Karma/Jasmine (composants, services)
- **Plan de sécurité :** vulnérabilités, duplications, complexité, règles critiques, couverture (SonarQube) ; bonnes pratiques (secrets, images)

*À dire :* « Les tests sont déclenchés selon le plan de testing et permettent de vérifier le comportement de l’application. Le plan de sécurité s’appuie sur les analyses SonarQube et est aligné avec le code et le workflow. »

---

## Slide 6 – Compétence 4 : KPI et métriques (monitoring)

**CE1–CE5 : Monitoring méthodique, DORA, KPI, recommandations**

- **Monitoring :** stack ELK (installation, configuration, sources de logs) ; dashboards Kibana (erreurs, volumétrie, tendances)
- **Métriques DORA :** lead time, deployment frequency, MTTR, change failure rate (méthodes de calcul dans la doc)
- **KPI :** temps de build back/front, taux de succès des tests, qualité SonarQube, fréquence des erreurs (logs)
- **Anomalies :** identification à partir des logs, métriques et visualisations ; pistes d’amélioration

*À dire :* « La mise en place du monitoring est décrite étape par étape. Les métriques DORA et les KPI sont calculés et interprétés ; l’analyse sert à proposer des pistes d’amélioration concrètes. »

---

## Slide 7 – Compétence 5 : Plans mise en production

**CE1–CE4 : Risques, reprise, automatisation, mise à jour**

- **Risques :** indisponibilité, échec de déploiement, configuration (ex. variables d’environnement) — décrits dans le plan de déploiement
- **Procédure de reprise :** redémarrage/recréation des conteneurs ; restauration à partir du dépôt et du pipeline
- **Action automatisée :** reconstruction et republication des images via le pipeline CI/CD à partir du dépôt (build reproductible)
- **Plan de mise à jour :** code, dépendances (Gradle, npm), images Docker ; nécessité d’ajuster les processus avec l’évolution de l’application et des outils

*À dire :* « Les plans décrivent les risques, une procédure de reprise détaillée et au moins une action automatisée pour la restauration. Le plan de mise à jour prévoit d’ajuster régulièrement les processus. »

---

## Slide 8 – Compétence 6 : Analyse des métriques et dette technique

**CE1–CE5 : SonarQube, DORA, KPI, points critiques, préconisations**

- **Sources :** résultats SonarQube (bugs, vulnérabilités, code smells, couverture), métriques DORA, KPI, logs/dashboards ELK
- **Points critiques identifiés :** ex. fiabilité (issues), couverture à augmenter, security hotspots à revoir
- **Processus :** analyse → priorisation → actions possibles (corriger les issues, renforcer les tests, serrer le Quality Gate)
- **Documentation finale :** métriques DORA, KPI, résultats SonarQube, observations logs/dashboards, recommandations (DOCUMENTATION-TECHNIQUE-FINALE.md + DOCUMENTATION-CICD-LIVRABLE.md)

*À dire :* « Je m’appuie sur SonarQube, les métriques DORA et les KPI pour identifier la dette technique et les risques. Les préconisations sont adaptées au contexte et la documentation finale intègre tous ces éléments. »

---

## Slide 9 – Synthèse et démo

**Récapitulatif**

- **Repo :** workflow complet, Dockerfiles adaptés, tests intégrés, secrets protégés
- **Documentation :** étapes CI/CD, plan de conteneurisation, plans de testing et sécurité, KPI/métriques, plans sauvegarde et mise à jour, analyse des métriques
- **Option B :** choix techniques justifiés (bonnes pratiques, veille), pipeline reproductible pour Orion

**Démo possible (si temps)** : ouvrir le repo (workflow, Dockerfile), montrer un run GitHub Actions ou le dashboard SonarCloud.

*À dire :* « J’ai présenté les six compétences et les livrables associés. Je peux vous montrer le workflow ou le Dockerfile en direct, ou répondre à vos questions. »

---

## Annexe – Questions possibles (préparation)

1. **Fréquence et positionnement des tests** : Les tests sont exécutés à chaque push et à chaque PR ; cela permet de détecter les régressions tôt et de bloquer le merge si la qualité ou les tests se dégradent.
2. **Stratégie de mise à jour** : Mise à jour du code via Git ; dépendances (Gradle, npm) et images de base documentées dans le plan de mise à jour ; toute évolution passe par le pipeline (build, tests, qualité) pour garantir la stabilité.
3. **Risques si plans incomplets** : Indisponibilité, perte de données, déploiements non reproductibles, difficulté à reprendre après incident ; la documentation permet à l’équipe de reproduire et de maintenir le pipeline.

---

*Document de présentation – P7 Option B – À utiliser comme support de slides (1 slide = 1 section ##).*
