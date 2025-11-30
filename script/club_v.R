# Variables
url_club <- "https://sportscanins.fr/calendrier/listeclubs.php?numdep="
base_url <- "https://sportscanins.fr/calendrier/"

# Préparation du code département pour les DOM
dept_DOM <- data_frame(DEP = "97", LIBELLE = "DOM")

# Récupération des codes des régions et ajout du code DOM
liste_dept <- read.csv2("data/departement_2025.csv", sep = ",") %>%
              select(DEP, LIBELLE) %>%
              filter(!(str_detect(DEP, "97"))) %>%
              rbind(dept_DOM)