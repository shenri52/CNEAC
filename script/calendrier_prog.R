##### Chargement : librairies, fonctions, variables

source("script/librairie.R")
source("script/variables.R")
source("script/f_download.R")
source("script/f_geocode.R")
source("script/f_export.R")
#source("script/calendrier_test_v.R")

##### Mettre à jour la liste des clubs

if(mois_debut %in% c(1, 3, 6, 9)) {
  
  les_clubs <- club()
  
  geocodage_club <- geocode_club(les_clubs)
  
  liste_club <- geocodage_club
  
  export_club(geocodage_club)
  
  # Optimisation mémoire
  remove(les_clubs, geocodage_club, club, geocode_club, export_club)
  gc()
  
}

##### Récupération du calendrier des épreuves

# Concours
les_concours <- calendrier("Agility", "Aucune")
geocodage_concours <- geocode_concours(les_concours)
export_concours(geocodage_concours, "Agility")

# Optimisation mémoire
remove(les_concours, geocodage_concours)
gc()
Sys.sleep(2)

# Pass
les_pass <- calendrier("Pass", "PassAgility")
geocodage_pass <- geocode_concours(les_pass)
export_concours(geocodage_pass, "Pass")

# Optimisation mémoire
remove(les_pass, geocodage_pass)
gc()
Sys.sleep(2)

# CAESC
les_caesc <- calendrier("CAESC", "Aucune")
geocodage_caesc <- geocode_concours(les_caesc)
export_concours(geocodage_caesc, "CAESC")

# Optimisation mémoire
remove(les_caesc, geocodage_caesc)
gc()
