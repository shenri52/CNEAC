##### Chargement : librairies, fonctions, variables

source("script/librairie.R")
source("script/variables.R")
source("script/f_download.R")
source("script/f_geocode.R")
source("script/f_export.R")
#source("script/calendrier_test_v.R")

##### Mettre à jour la liste des clubs

if(mois_debut %in% c(1, 3, 6, 9) & month(Sys.Date()) <= 11) {
  
  les_clubs <- club()
  
  geocodage_club <- geocode_club(les_clubs)
  
  # Remplacer les données déjà chargées
  liste_club <- geocodage_club
  
  # Exporter les nouvelles données
  export_club(geocodage_club)
  
  # Optimisation mémoire
  remove(les_clubs, geocodage_club, club, geocode_club, export_club, url_club)
  gc()
  
} else {
  
  # Optimisation mémoire
  remove(geocode_club, export_club, club, url_club)
  gc()
  
}

##### Récupération du calendrier des épreuves

# Lister les concours
les_concours <- calendrier("Agility", "Aucune")
geocodage_concours <- geocode_concours(les_concours)

# Optimisation mémoire
remove(les_concours)
gc()
Sys.sleep(2)

# Lister les pass
les_pass <- calendrier("Pass", "PassAgility")
geocodage_pass <- geocode_concours(les_pass)

# Optimisation mémoire
remove(les_pass)
gc()
Sys.sleep(2)

# Lister les CAESC
les_caesc <- calendrier("CAESC", "Aucune")
geocodage_caesc <- geocode_concours(les_caesc)

# Optimisation mémoire
remove(les_caesc, liste_dept)
gc()

# Export des épreuves
export_concours()
