# Variables

base_url <- "https://sportscanins.fr/calendrier/"

# Déterminer l'année des concours
annee <- if(month(Sys.Date()) == 11 & day(Sys.Date()) >= 15){ 
              year(Sys.Date()) + 1
         } else {
            year(Sys.Date())
           }


      