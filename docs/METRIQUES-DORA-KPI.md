# Métriques DORA et KPI opérationnels

Ce document alimente l’**étape 2** de la mission (analyse de la performance du pipeline) et sert de base pour la documentation technique finale.

---

## 1. Rappel : les 4 métriques DORA

| Métrique | Définition | Objectif |
|----------|------------|----------|
| **Lead Time for Changes** | Délai entre un commit (changement dans le code) et la mise en production effective. | Réduire ce délai pour livrer plus vite. |
| **Deployment Frequency** | Nombre de déploiements en production sur une période (jour / semaine / mois). | Augmenter la fréquence avec un pipeline fiable. |
| **Mean Time to Restore (MTTR)** | Temps moyen pour rétablir le service après un incident. | Réduire le MTTR pour limiter l’impact des pannes. |
| **Change Failure Rate** | Pourcentage de déploiements qui provoquent un problème (bug, panne, rollback). | Réduire ce taux par la qualité et les tests. |

---

## 2. Tableau des métriques et KPI (projet MicroCRM)

*Valeurs à remplir à partir de l’historique GitHub Actions et des observations ELK (après plusieurs exécutions du pipeline).*

### 2.1 Métriques DORA (estimation sur 3 exécutions minimum)

| Métrique | Méthode de calcul | Exemple de valeur (à adapter) | Source |
|----------|-------------------|--------------------------------|--------|
| **Lead Time for Changes** | (Heure de fin du workflow CD – Heure du dernier commit du push) pour un déploiement réussi. | Ex. ~5–15 min (temps du pipeline) | GitHub Actions, onglet « Actions » |
| **Deployment Frequency** | Nombre de runs du job « Build & Push Docker images » sur `main` / période. | Ex. N déploiements / semaine | GitHub Actions |
| **MTTR** | Non mesuré automatiquement sur ce projet ; à estimer en cas d’incident (détection → correction → déploiement). | À documenter en cas d’incident | Incidents / ELK (temps de réaction) |
| **Change Failure Rate** | (Nombre de déploiements ayant entraîné un rollback ou un correctif) / (Nombre total de déploiements) × 100. | Ex. 0 % si aucun rollback | Suivi manuel / incidents |

### 2.2 KPI supplémentaires (3 à 5)

| KPI | Description | Méthode de calcul | Objectif |
|-----|-------------|-------------------|----------|
| **Temps de build back** | Durée du job « Backend – Build & Tests » (Gradle build + tests). | Moyenne sur les derniers runs (GitHub Actions). | Réduire (cache Gradle, parallélisation). |
| **Temps de build front** | Durée du job « Frontend – Build & Tests » (npm ci, build, tests Karma). | Idem, moyenne sur les runs. | Réduire (cache npm, tests ciblés). |
| **Taux de succès des tests** | % de runs CI où tous les tests (back + front) passent. | (Runs avec tests verts) / (Runs totaux) × 100. | Viser 100 %. |
| **Qualité SonarQube** | Évolution du statut Quality Gate (Pass / Fail) et du nombre d’issues. | Résultats SonarQube Cloud sur les PR / push. | Maintenir le gate vert, réduire les bugs/vulnérabilités. |
| **Fréquence des erreurs (logs)** | Nombre d’événements de niveau ERROR dans les logs applicatifs. | Comptage dans ELK/Kibana sur l’index `microcrm-logs-*`. | Détecter les pics et les corriger. |

---

## 3. Analyse commentée

- **Pipeline** : le CI (build + tests) et le CD (build & push des images) fournissent les données pour le Lead Time et la Deployment Frequency. Relever les durées des jobs sur plusieurs exécutions permet d’identifier les lenteurs (ex. cache Gradle/npm).
- **Qualité** : les métriques SonarQube (bugs, vulnérabilités, code smells) et le taux de succès des tests sont des indicateurs de la **Change Failure Rate** potentielle : moins d’anomalies dans le code et des tests systématiques limitent les déploiements défaillants.
- **Monitoring** : les indicateurs ELK (volume de logs, erreurs, tendances) permettent de relier les **incidents** au comportement de l’application et d’alimenter une estimation du **MTTR** (temps entre la détection d’une erreur et la remise en état).

Ce tableau et cette analyse sont à intégrer dans la documentation technique finale et à mettre à jour après chaque période d’observation (ex. après chaque sprint ou chaque lot de déploiements).
