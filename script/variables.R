# Variables

# URL des pages
base_url <- "https://sportscanins.fr/calendrier/"
url_club <- "https://sportscanins.fr/calendrier/listeclubs.php?numdep="

# Déterminer l'année des concours et le mois de début (inutile de télécharger les concours passé)
if(month(Sys.Date()) == 12 & day(Sys.Date()) >= 1){ 
    annee <- year(Sys.Date()) + 1
    mois_debut <- 1
} else {
    annee <- year(Sys.Date())
    mois_debut <- month(Sys.Date())
}

mois_fin <- 12

# Charger la liste des clubs
liste_club <- read.csv2("data/Club.csv", sep = ",")

# Préparation du code département pour les DOM
dept_DOM <- tibble(DEP = "97", LIBELLE = "DOM")

# Récupération des codes des régions et ajout du code DOM
liste_dept <- read.csv2("data/departement_2025.csv", sep = ",") %>%
              select(DEP, LIBELLE) %>%
              filter(!(str_detect(DEP, "97"))) %>%
              rbind(dept_DOM)
      
remove(dept_DOM)