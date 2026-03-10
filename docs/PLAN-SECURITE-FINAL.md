# Plan de sécurité (finalisé) – MicroCRM

Ce document finalise le **plan de sécurité** à partir des résultats SonarQube et du contexte de l’application (étape 3). Il complète le [PLANS-CICD.md](PLANS-CICD.md).

---

## 1. Éléments à identifier à partir de SonarQube

Après intégration de SonarQube dans le pipeline CI, les points à suivre sont :

| Catégorie | Description | Où les trouver |
|------------|-------------|----------------|
| **Vulnérabilités** | Failles de sécurité (injection, exposition de données, dépendances vulnérables). | SonarQube Cloud, onglet « Security » / « Vulnerabilities ». |
| **Duplications** | Code dupliqué (augmente la dette et le risque d’erreurs). | SonarQube, métrique « Duplications ». |
| **Zones à forte complexité** | Fichiers ou méthodes avec une complexité cyclomatique élevée. | SonarQube, « Complexity », « Cognitive Complexity ». |
| **Règles critiques violées** | Violations des règles SonarSource (Java, TypeScript) classées « Blocker » ou « Critical ». | SonarQube, onglet « Issues », filtres par sévérité. |
| **Couverture de tests** | % de lignes/branches couvertes par les tests. | SonarQube (rapports de couverture Gradle/Karma) et métriques du projet. |

**Références** : [Rules SonarSource](https://rules.sonarsource.com/), [OWASP Top 10 – 2021](https://owasp.org/Top10/).

---

## 2. Différenciation vulnérabilité / code smell

- **Vulnérabilité** : problème de **sécurité** (ex. injection SQL, XSS, dépendance CVE). Priorité haute, à corriger en priorité.
- **Code smell** : problème de **maintenabilité** ou de conception (dette technique), sans impact direct de sécurité. À traiter pour réduire la dette et faciliter les évolutions.

Le plan de sécurité se concentre en premier sur les **vulnérabilités** et les **règles critiques** ; les code smells sont suivis dans le cadre de la qualité et de la dette technique.

---

## 3. Croisement SonarQube et logs ELK

- **Erreurs fréquentes dans ELK** (niveau ERROR, stack traces) peuvent pointer vers des zones du code déjà signalées par SonarQube (complexité, bugs potentiels).
- Utiliser les **logger_name** et les **messages** dans Kibana pour identifier les composants concernés, puis vérifier dans SonarQube les issues sur les mêmes fichiers.
- Ce croisement aide à prioriser les corrections (zones à la fois « à risque » dans SonarQube et génératrices d’erreurs en exécution).

---

## 4. Bonnes pratiques déjà en place

- **Secrets** : pas de secrets en clair dans le code ni dans les workflows ; utilisation des secrets et variables GitHub (ex. `SONAR_TOKEN`).
- **Images Docker** : bases officielles (Alpine, Temurin), images légères, pas de données sensibles dans les images.
- **Pipeline** : tests automatiques (back + front) et analyse SonarQube (si activée) avant merge.

---

## 5. Pistes d’amélioration réalistes

| Priorité | Action | Justification |
|----------|--------|----------------|
| 1 | Corriger toutes les **vulnérabilités** et **issues critiques** remontées par SonarQube. | Réduction directe du risque sécurité. |
| 2 | Augmenter la **couverture de tests** sur les parties critiques (repositories, services). | Réduction de la Change Failure Rate et meilleure détection des régressions. |
| 3 | Réduire les **duplications** et la **complexité** des méthodes les plus complexes (refactoring ciblé). | Réduction de la dette technique et des bugs. |
| 4 | Serrer les **règles SonarQube** (Quality Gate) pour bloquer les PR en cas de dégradation (nouvelles vulnérabilités, baisse de couverture). | Garantir que la qualité ne régresse pas. |
| 5 | Exécuter **npm audit** (front) et un audit des dépendances back (ex. OWASP Dependency Check) en CI. | Détection des CVE dans les dépendances. |

Ce plan de sécurité est cohérent avec l’application (full-stack Java/Angular), le pipeline CI/CD et les indicateurs ELK ; il est à mettre à jour au fil des analyses SonarQube et des retours d’incidents.
