# CNEAC - Analyse de Données

Ce dépôt contient les outils et scripts nécessaires pour récupérer les données des concours d'agility publiés sur le site de la **CNEAC** (Commission Nationale Éducation et Activités Cynophiles).

## 📂 Structure du projet

Le projet est organisé pour assurer une séparation claire entre le code et les données :

* **`script/`** : Contient tous les scripts R pour le traitement, le nettoyage et l'analyse.
* **`data/`** : Dossier réservé aux fichiers de configuration.
* **`result/`** : Dossier de sortie où sont générés les données récupérées.
* **`CNEAC.Rproj`** : Fichier de projet RStudio pour faciliter la gestion des chemins et de l'environnement de travail.

## 🛠️ Installation et Configuration

1.  **Ouvrir le projet** : Double-cliquez sur le fichier `CNEAC.Rproj` pour lancer RStudio dans le bon répertoire de travail.
2.  **Dépendances** : Assurez-vous d'installer les bibliothèques R nécessaires (ex: `tidyverse`) avant de lancer les scripts.

## 🚀 Utilisation

1.  Exécutez le script `calendrier_prog.R' dans `/script`.
3.  Récupérez les données dans le dossier `/result`.

---
