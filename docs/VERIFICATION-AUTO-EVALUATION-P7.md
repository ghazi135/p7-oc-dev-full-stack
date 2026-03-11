# Vérification – Auto-évaluation P7 (FAE)

Ce document est aligné sur la **Fiche d’auto-évaluation (FAE) P7 FDSJA** (Options A et B). Chaque indicateur reprend le libellé exact du PDF pour que vous puissiez cocher les cases en toute confiance et renseigner la colonne « Notes » si besoin.

**Livrables à déposer :** repo GitHub (workflow + Dockerfiles + README) + documentation CI/CD complète. Quand toutes les cases de la FAE sont cochées, vous pouvez déposer vos livrables.

---

## 1. Concevoir et préparer les environnements de développement et de tests

**Livrables :** Repo GitHub (workflow CI/CD) • Documentation : étapes de mise en œuvre du pipeline et de l’environnement de test

| Indicateur (libellé FAE) | Où c’est dans le projet | Note possible pour la FAE |
|--------------------------|--------------------------|----------------------------|
| Mon environnement de tests permet d'exécuter les tests automatisés et d'en récupérer les résultats. | `.github/workflows/ci-cd.yml` : jobs `back-build-test` et `front-build-test` ; rapports JaCoCo (back) et LCOV (front). Local : `./gradlew test`, `npm test`. [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 1. | Ex. : « CI : back + front ; rapports JaCoCo + LCOV » |
| J'ai vérifié que mon workflow CI/CD du repo GitHub comprend bien toutes les étapes attendues. | Build back + front, tests, SonarQube Cloud (si activé), build & push Docker (CD). [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 1, [ci-cd.yml](../.github/workflows/ci-cd.yml). | Ex. : « 5 étapes : build, tests, Sonar, CD » |
| J'ai justifié les actions, outils ou scripts utilisés pour chaque étape du workflow. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 1 (tableau des étapes et justification). | — |
| Je suis satisfait de la clarté et de l'organisation des étapes de mise en œuvre dans ma documentation. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) Partie 1, [README.md](../README.md) (livrables + choix techniques). | — |

## 2. Automatiser les pipelines CI/CD

**Livrables :** Repo GitHub (Dockerfiles) • Documentation : plan de conteneurisation et déploiement

| Indicateur (libellé FAE) | Où c’est dans le projet | Note possible pour la FAE |
|--------------------------|--------------------------|----------------------------|
| Mes outils et actions utilisés dans le pipeline sont adaptés au projet full-stack Java/Angular. | Gradle (back), npm/Angular CLI (front), SonarQube, Docker (cibles front, back, standalone). [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 2, [Dockerfile](../Dockerfile). | — |
| Ma configuration CI/CD assure bien l'automatisation complète des tâches demandées. | Compilation, tests, build, analyse qualité, déploiement (build & push images). [ci-cd.yml](../.github/workflows/ci-cd.yml). | — |
| Mes scripts ou actions intégrés au pipeline ne comportent pas d'étapes inutiles ou manquantes par rapport aux attentes. | Workflow ciblé : build, test, SonarQube, CD ; pas d’étape superflue. [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 1. | — |
| Je suis satisfait de la clarté de mon plan de conteneurisation : il permet de comprendre, exécuter et maintenir le pipeline CI/CD. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 2 ; README (Docker Compose). | — |
| J'ai décrit fidèlement ma méthodologie et mes choix techniques dans ce plan. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 2 (Dockerfile, stratégie). | — |

## 3. Renforcer la sécurité des environnements de développement avec des plans de test

**Livrables :** Repo GitHub (tests automatisés dans le pipeline) • Documentation : plan de testing périodique, plan de sécurité

| Indicateur (libellé FAE) | Où c’est dans le projet | Note possible pour la FAE |
|--------------------------|--------------------------|----------------------------|
| J'ai vérifié que : l'exécution des tests est automatique, les dépendances sont installées, les tests sont positionnés au bon moment dans le workflow. | Jobs `back-build-test` et `front-build-test` ; `npm ci` / Gradle ; tests avant SonarQube et CD. [ci-cd.yml](../.github/workflows/ci-cd.yml), [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 3. | — |
| J'ai vérifié que les tests sont déclenchés selon les règles prévues en cohérence avec le plan de testing périodique. | Push et PR sur `main`/`master`. [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 3. | — |
| J'ai vérifié que les tests automatisés permettent de vérifier si l'application a bien le comportement attendu. | JUnit (Spring, repositories), Karma/Jasmine (composants, services). [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 3. | — |
| J'ai vérifié que le plan de testing périodique précise bien quand les tests sont exécutés. | Tableau « Moments d’exécution » : push, PR, merge. [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 3. | — |
| J'ai vérifié que mon plan de testing périodique est bien complet. | Types de tests, moments, objectifs, rapports de couverture. [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 3. | — |
| Je suis satisfait de mon plan de sécurité et de la description de l'intégration des tests : ils sont cohérents avec le code et le workflow réel. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 6. | — |

## 4. Améliorer les pipelines CI/CD

**Livrables :** Documentation : KPI proposés et métriques

| Indicateur (libellé FAE) | Où c’est dans le projet | Note possible pour la FAE |
|--------------------------|--------------------------|----------------------------|
| J'ai vérifié que la mise en place de mon monitoring est méthodique, et que j'ai respecté des étapes d'installation, de configuration minimale et de sélection des sources de logs pertinentes. | Stack ELK (docker-compose-elk.yml, Logstash). [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 4–5 ; README. | — |
| J'ai vérifié que les dashboards créés permettent de visualiser les éléments demandés. | Kibana : index `microcrm-logs-*`, erreurs, volumétrie. Captures dans `docs/screenshots/`. [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 5. | — |
| Je suis satisfait de mon calcul et de mon interprétation des métriques DORA dans la documentation. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 4–5. | — |
| Je suis satisfait de mon choix des KPI et de leur analyse : elle permet d'identifier des pistes d'amélioration. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 4–5 et § 9. | — |
| Je suis satisfait de l'identification détaillée des anomalies ou risques faites depuis les logs, métriques ou visualisations. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 5–6. | — |
| J'ai vérifié que ma documentation est complète, depuis la mise en place du monitoring jusqu'aux recommandations. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) Partie 2 et § 9. | — |

## 5. Planifier et documenter la mise en production

**Livrables :** Documentation : plan de testing périodique, plan de sauvegarde des données, plan des mises à jour

| Indicateur (libellé FAE) | Où c’est dans le projet | Note possible pour la FAE |
|--------------------------|--------------------------|----------------------------|
| Mes plans présentent des risques pouvant survenir lors de la mise en production. | Risques et reprise (indisponibilité, échec déploiement). [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 7–8. | — |
| J'ai détaillé une procédure de reprise. | Redémarrage/recréation des conteneurs ; restauration à partir du dépôt et du pipeline. [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 7. | — |
| J'ai décrit au moins une action automatisée facilitant la restauration dans mon plan de sauvegarde. | Reconstruction et republication des images via le pipeline CI/CD. [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 7. | Ex. : « Pipeline = build reproductible + republication images » |
| J'ai intégré et détaillé la nécessité d'ajuster régulièrement les processus en fonction de l'évolution de l'application ou des outils. | Plan de mise à jour (code, dépendances, images Docker). [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 8. | — |

## 6. Optimiser la solution en réduisant la dette technique

**Livrables :** Documentation : analyse des métriques

| Indicateur (libellé FAE) | Où c’est dans le projet | Note possible pour la FAE |
|--------------------------|--------------------------|----------------------------|
| Je me suis appuyé sur les résultats de SonarQube, des métriques DORA et des KPI pour identifier les éléments contribuant à la dette technique. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 5–6. | — |
| Je me suis assuré que le processus d'amélioration que j'ai proposé est cohérent. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 9 – recommandations. | — |
| J'ai vérifié que mes outils et mes sources analysées sont adaptés au contexte. | SonarQube (Java/TS), GitHub Actions, ELK, Gradle, npm. [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 5–6. | — |
| J'ai pu mettre en évidence au moins un point critique. | Vulnérabilités / règles critiques SonarQube ; fiabilité ; erreurs (ELK). [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 5–6. | — |
| Je suis satisfait de mes conclusions. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 5 et § 9. | — |
| J'ai proposé des préconisations réalistes, adaptées au contexte et techniquement cohérentes. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) § 9 (tableau des recommandations). | — |
| Ma documentation finale est complète : elle intègre les métriques DORA, les KPI, les résultats SonarQube, des observations issues des logs et dashboards et des recommandations. | [DOCUMENTATION-CICD-LIVRABLE.md](DOCUMENTATION-CICD-LIVRABLE.md) Partie 2 et § 9. | — |

---

## À faire de votre côté (FAE PDF)

1. **Cocher chaque case** du PDF FAE « Mission - Mettez en oeuvre l'intégration et le déploiement continus... Options A et B » en vous aidant des tableaux ci-dessus (chaque ligne = une case du PDF).
2. **Renseigner la colonne « Notes »** du PDF avec des commentaires courts si besoin (ex. chemins des fichiers, références aux sections de la doc) pour la soutenance / le bilan.
3. **Ajouter des captures d’écran** des dashboards Kibana (et éventuellement SonarQube, GitHub Actions) dans `docs/screenshots/` et les citer dans la documentation pour illustrer les visualisations.
4. Quand **toutes les cases sont cochées**, vous pouvez déposer vos livrables sur la plateforme.
