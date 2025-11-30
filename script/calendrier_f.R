# Fonction : récupération du calendrier des épreuves

calendrier <- function(activite, discipline) {

    # Parcours des mois
    for (m in 1:12) {
      
        # Construction de l'url d'accès aux données mensuelles
        url_mois <- paste0(base_url, "calendrier.php?annee=", annee, "&mois=", m, "&Activite=", activite)
        
        # Vérification de l'a définition de l'indication d'une discipline
        if(discipline != "Aucune") {
          url_mois <- paste0(url_mois, "&Discipline_Pass=", discipline)
        }
        
        # Lecture de la page
        page_mois <- read_html(url_mois)
        
        # Récupération de la liste des concours
        liste_concours <- page_mois %>%
                          html_table(fill = TRUE) %>%
                          as.data.frame()
        
        # Vérification de la publication de concours
        if(nrow(liste_concours) >= 1) {
          
          # Préparation du dataframe
          liste_concours <- liste_concours %>%
                            select(X3) %>%
                            mutate(Mois = first(X3)) %>%
                            slice(-1)
        
          # Création de la liste des concours                  
          liste_concours <- liste_concours %>%
                           mutate(# Remplacer toutes les séquences de plus de 2 esapces - plus de 2 espaces par |
                                  X3_nettoyee = str_replace_all(X3,pattern = "\\s{2,}-\\s{2,}", replacement = "|") %>%
                                  # Remplacer  toutes les séquences de 1 esapces - plus de 2 espaces par |
                                  str_replace_all(pattern = "\\s{1,}-\\s{2,}", replacement = "|") %>%
                                  # Remplacer toutes les séquences de plus de 2 esapces par |
                                  str_replace_all(pattern = "\\s{2,}", replacement = "|")
                                 ) %>%
                           # Mettre en forme les données en colonne
                           separate(col = X3_nettoyee,
                                    into = c("Jour_Date", "Type_Evenement", "Region", "Lieu", "Club"),
                                    sep = "\\|",
                                    extra = "drop" # Important si la ligne contient plus de 5 séparateurs
                                   ) %>%
                           # 3. Nettoyage final des valeurs des nouvelles colonnes
                           
                           
                           mutate(# Supprimer les espaces inutiles en début et fin de chaque nouvelle colonne
                                  across(c(Jour_Date:Club), str_trim),
                                  # Remplacer les 01, 02, 03 ... par 1, 2, 3...
                                  Jour_Date = paste0(Jour_Date, " ", str_to_lower(Mois)) %>%
                                              str_replace_all(pattern = " 0([1-9])", replacement = " \\1"),
                                  Adresse = NA,
                                  Lat = NA,
                                  Lon = NA
                                 ) %>%
                           select(-X3)
          
          # Récupération des liens vers les fiches concours
          concours <- page_mois %>%
                      html_node("table") %>%
                      html_nodes("a") %>%
                      html_attr("href") %>%
                      as.data.frame() %>%
                      mutate(Lien_CNEAC = paste0(base_url, .)) %>%
                      select(-.)
          
          # Ajouter les liens à la liste des concours
          liste_concours <- bind_cols(liste_concours, concours)
          
          Sys.sleep(2)
          
          # Parcours des fiches concours
          for (f in 1:nrow(liste_concours)) {
            
            # Lecture de la page
            page_concours <- read_html(liste_concours[f, "Lien_CNEAC"])
            
            # Extraire tout le texte de la page html et nettoyer les espaces
            fiche <- page_concours %>%
                     html_node("body") %>%
                     html_text(trim = TRUE)
            
            # Pattern pour l'Adresse: cherche "Adresse : " suivi de n'importe quel contenu jusqu'à "Coordonnées GPS"
            adresse_pattern <- "Adresse\\s*:\\s*(.*?)(?=\\s*Coordonnées GPS|\\s*GT Informatique et Licences)"
            
            # Récupérer l'adresse à l'aide du pattern
            adresse <- str_match(fiche, adresse_pattern)[, 2] %>% str_trim() %>%
                                 str_replace_all(pattern = "\\s{2,}", replacement = " ")
            
            # Pattern pour les Coordonnées GPS: cherche "Coordonnées GPS : " uivi de n'importe quel contenu jusqu'à "GT Informatique et Licences"
            coordonnees_pattern <- "Coordonnées GPS\\s*:\\s*(.*?)(?=\\s*GT Informatique et Licences|\\s*partenaires)"
            
            # Récupérer les coordonnées à l'aide du pattern
            coordonnees_brutes <- str_match(fiche, coordonnees_pattern)[, 2] %>% str_trim()
                                  
            # Séparer les deux coordonnées par la virgule
            lat_lon <- str_split(coordonnees_brutes, "\\s*,\\s*", simplify = TRUE)

            # Ajouter les informationsà la liste des concours
            liste_concours[f, "Adresse"] <- adresse
            liste_concours[f, "Lat"] <- lat_lon[1, 1]
            liste_concours[f, "Lon"] <- lat_lon[1, 2]
            
            Sys.sleep(2)
            
          }
          
          # Fusionner les mois
          if(exists("df_final")) {
              df_final <- bind_rows(df_final, liste_concours)
          } else {
              df_final <- liste_concours
           }
        }
      }
      
      # Modifier le type des champs latitude et longitude
      df_final <- df_final %>%
                  mutate(Lat = as.numeric(Lat),
                         Lon = as.numeric(Lon))
                  
      # Filtrer les concours sans coordonnées mais avec une adresse 
      df_ss_coord <- df_final %>%
                     filter(Lat == 0 & Adresse != "") 
      
      # Géocoder l'adresse
      if(nrow(df_ss_coord) >= 1) {
        df_ss_coord <- df_ss_coord %>%
                       mutate(precision = "Moyenne",
                              adresse2 = paste0(Club, ",", Adresse, ", ", Lieu, ",", Region, ", ", "France")) %>%
                       geocode(address = adresse2, method = 'arcgis', lat = latitude, long = longitude) %>%
                       mutate(Lat = latitude,
                              Lon = longitude) %>%
                       select(-latitude, -longitude, -adresse2)
      }
      
      # Filtrer les concours sans adresses et sans coordonnées
      df_ss_coord2 <- df_final %>%
                      filter(Lat == 0 & Adresse == "")
      
      # Géocoder l'adresse
      if(nrow(df_ss_coord2) >= 1) {
        df_ss_coord2 <- df_ss_coord2 %>%
                        mutate(precision = "Médiocre",
                               adresse2 = paste0(Club, ", ", Lieu, ", ", Region, ", ", "France")) %>%
                        geocode(address = adresse2, method = 'arcgis', lat = latitude, long = longitude) %>%
                        mutate(Lat = latitude,
                               Lon = longitude) %>%
                        select(-latitude, -longitude, -adresse2)
      }
      
      # Filtrer les adresses avec coordonnées
      df_avec_coord <- df_final %>%
                       filter(Lat != 0) %>%
                       mutate(precision = "Exacte")

      # Réasambler les adresses
      df_coord <- bind_rows(df_avec_coord, df_ss_coord) %>%
                  bind_rows(df_ss_coord2) %>%
                  mutate(Mois = case_when(
                                  str_detect(Mois, "Janvier") ~ paste0("01 - ", Mois),
                                  str_detect(Mois, "Février") ~ paste0("02 - ", Mois),
                                  str_detect(Mois, "Mars") ~ paste0("03 - ", Mois),
                                  str_detect(Mois, "Avril") ~ paste0("04 - ", Mois),
                                  str_detect(Mois, "Mai") ~ paste0("05 - ", Mois),
                                  str_detect(Mois, "Juin") ~ paste0("06 - ", Mois),
                                  str_detect(Mois, "Juillet") ~ paste0("07 - ", Mois),
                                  str_detect(Mois, "Août") ~ paste0("08 - ", Mois),
                                  str_detect(Mois, "Septembre") ~ paste0("09 - ", Mois),
                                  str_detect(Mois, "Octobre") ~ paste0("10 - ", Mois),
                                  str_detect(Mois, "Novembre") ~ paste0("11 - ", Mois),
                                  str_detect(Mois, "Décembre") ~ paste0("12 - ", Mois)
                                  )
                         )
      
      # Exporter le tableau au format CSV
      write.table(df_coord, paste0("result/", activite, ".csv"), sep = ",", fileEncoding = "UTF-8", row.names = FALSE, na = "")
}
