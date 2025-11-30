##### Chargement : librairies, fonctions, variables

source("script/club_lib.R")
source("script/club_v.R")

# Parcours des départements
for (c in 1:nrow(liste_dept)) {
  
  # Préparation de l'url
  url_fiche <- paste0(url_club, liste_dept[c, "DEP"])
  
  # Lecture de la page
  page_dept <- read_html(url_fiche)
  
  # Récupération de la liste des clubs
  liste_club <- page_dept %>%
                html_table(fill = TRUE) %>%
                as.data.frame() %>%
                mutate(DEPT = paste0(liste_dept[c, "DEP"], " - ", liste_dept[c, "LIBELLE"]))
  
  # Vérification de la présence de clubs
  if(nrow(liste_club) >= 1) {
    
    # Récupération des liens vers les fiches des clubs
    lien_club <- page_dept %>%
                 html_nodes("tr") %>%
                 html_attr("onclick") %>%
                 as.data.frame() %>%
                 filter(!(is.na(.))) %>%
                 mutate(Lien_CNEAC = str_extract(., "location\\.href='(.+?)'"),
                        Lien_CNEAC = str_replace(Lien_CNEAC, "location\\.href='", ""),
                        Lien_CNEAC = paste0(base_url, str_replace(Lien_CNEAC, "'", ""))) %>%
                 select(Lien_CNEAC)
    
    # Ajouter les liens à la liste des clubs
    liste_club <- liste_club %>%
                  bind_cols(lien_club)
    
    # Parcours des clubs
    for(i in 1:nrow(liste_club)) {
 
      # Lecture de la page
      page_club <- read_html(liste_club[i, "Lien_CNEAC"])
      
      # Extraire tout le texte et nettoyer les espaces
      page_text <- page_club %>%
                   html_node("body") %>%
                   html_text(trim = TRUE)
      
      # Pattern pour le territoire: cherche "Territoire : " suivi de n'importe quel contenu jusqu'à "Adresse"
      #territoire_pattern <- "Territoriale\\s*:\\s*(.*?)(?=\\s*Adresse|$)"
      
      # Récupérer l'information concernant le territoire
      #territoire <- str_match(page_text, territoire_pattern)[, 2] %>% 
      #              str_trim() %>%
      #              str_replace_all(pattern = "\\s{2,}", replacement = " ")
      
      # Pattern pour la latitude: cherche "Latitude : " suivi de n'importe quel contenu jusqu'à "-"
      #latitude_pattern <- "Latitude\\s*:\\s*(.*?)(?=\\s*- Longitude|$)"
      
      # Récupérer l'information concernant la latitude
      #gps_latitude <- str_match(page_text, latitude_pattern)[, 2] %>% 
      #                str_trim() %>%
      #                str_replace_all(pattern = "\\s{2,}", replacement = " ")

      # Pattern pour la longitude: cherche "Longitude : " suivi de n'importe quel contenu jusqu'à "Google"
      #longitude_pattern <- "Longitude\\s*:\\s*(.*?)(?=\\s*Google|$)"
      
      # Récupérer l'information concernant la longitude
      #gps_longitude <- str_match(page_text, longitude_pattern)[, 2] %>% 
      #                 str_trim() %>%
      #                 str_replace_all(pattern = "\\s{2,}", replacement = " ")
      
      # Pattern pour les activités: cherche "Activités pratiquées" suivi de n'importe quel contenu jusqu'à "Coordonnées"
      activite_pattern <- "Activités pratiquées\\s*(.*?)(?=\\s*Coordonnées du président|$)"
      
      # Insérer un séparateur uniquement entre une minuscule et une majuscule (mots collés)
      separateur_pattern <- "(?<=[[:lower:]])([[:upper:]])"
      
      # Récupérer l'information concernant les activités
      activite <- str_match(page_text, activite_pattern)[, 2] %>% 
                  str_trim() %>%
                  str_replace_all(separateur_pattern, " - \\1") %>%
                  str_replace_all(pattern = "\\s{2,}", replacement = " ")
      
      # Ajout les informations à la liste des clubs
      club_info <- liste_club[i, ] %>%
                   mutate(Territoire = territoire,
                          #Lat = gps_latitude,
                          #Lon = gps_longitude,
                          Activite = activite)
      
      # Fusionner les données départementales
      if(exists("df_final")) {
          df_final <- bind_rows(df_final, club_info)
      } else {
          df_final <- club_info
      }
    }
  }
  Sys.sleep(2)
}

# Insérer un séparateur uniquement entre une majuscule et un chiffre (code postal)
separateur_pattern <- "(?<=[[:upper:]])([[:digit:]])"

# Préparer la base de donnée finale
df_final <- df_final %>%
            rename.variable("Nom.du.Club", "Club") %>%
            mutate(Adresse = gsub(separateur_pattern, " \\1", Adresse, perl = TRUE)) %>%
            select(-Ville)

# Préparer un dataframe avec la liste des activites
liste_activite <- df_final %>%
                  select(Activite) %>%
                  filter(Activite != "") %>%
                  # Diviser la colonne 'Activite' en plusieurs lignes
                  separate_rows(Activite, sep = " - ") %>%
                  distinct() %>%
                  mutate(valeur = "") %>%
                  # Pivoter de ligne en colonne
                  pivot_wider(names_from = Activite, 
                              values_from = valeur
                             )

# Ajouter les colonnes d'activités
df_final <- bind_cols(df_final, liste_activite)

# Ajouter le nom de l'activité dans la colonne si elle est présente
for(a in 1:ncol(liste_activite)) {
  
  nom_activite <- names(liste_activite[,a])
  
  df_final[, nom_activite] <- ifelse(str_detect(df_final$Activite, nom_activite), nom_activite, NA)
}

# Suppression des colonnes inutiles
df_final <- df_final %>%
            select(-Activite, -Ville)

# Géocodage des adresses (beaucoup de club ont des coordonnées erronées)
df_final <- df_final %>%
            mutate(localisation = "Géocodage",
                   adresse2 = paste0(Club, ", ", Adresse, ", ", str_sub(DEPT, 6), ", ", "France")) %>%
            geocode(address = adresse2, method = 'arcgis', lat = lat, long = lon) %>%
            select(-adresse2)

# Exporter les tableaux au format CSV
write.table(df_final, "result/Club.csv", sep = ",", fileEncoding = "UTF-8", row.names = FALSE, na = "")
