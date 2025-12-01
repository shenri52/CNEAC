##### Geocodage des clubs

geocode_concours <- function(df_concours) {
  
  # Modifier le type des champs latitude et longitude
  df_concours <- df_concours %>%
                 mutate(Lat = as.numeric(Lat),
                        Lon = as.numeric(Lon)) %>%
                 left_join(liste_club, by = c("Club" = "Club"), copy = FALSE)
  
  # Filtrer les concours sans coordonnées
  df_ss_coord <- df_concours %>%
                 filter(Lat == 0) 
  
  # Ajout des coordonnées du club
  if(nrow(df_ss_coord) >= 1) {
      df_ss_coord <- df_ss_coord %>%
                     mutate(Lat = as.numeric(ifelse(!is.na(Lat_club), Lat_club, 0)),
                            Lon = as.numeric(ifelse(!is.na(Lon_Club), Lon_Club, 0)),
                            precision = localisation
                            )
  }
  
  # Récupérer les concours non raccrocher à la liste des club
  df_ss_coord2 <- df_ss_coord %>%
                  filter(Lat == 0)
  
  # Retirer les concours non raccrocher
  df_ss_coord <- df_ss_coord %>%
                 filter(Lat != 0)
  
  
  # Géocoder par la nom
  if(nrow(df_ss_coord2) >= 1) {
        df_ss_coord2 <- df_ss_coord2 %>%
                        mutate(precision = "Médiocre (géocodage nom)",
                               adresse2 = paste0(Club, ", ", Lieu, ", ", "France")) %>%
                        geocode(address = adresse2, method = 'arcgis', lat = latitude, long = longitude) %>%
                        mutate(Lat = as.numeric(latitude),
                               Lon = as.numeric(longitude)
                               ) %>%
                        select(-latitude, -longitude, -adresse2)
  }
  
  # Filtrer les adresses avec coordonnées
  df_avec_coord <- df_concours %>%
                   filter(Lat != 0) %>%
                   mutate(precision = "Exacte")
  
  # Réasambler les adresses
  df_coord <- bind_rows(df_avec_coord, df_ss_coord) %>%
              bind_rows(df_ss_coord2) %>%
              select(-Lat_club, -Lon_Club, -localisation)
  
  return(df_coord)
}

##### Geocodage des clubs

geocode_club <- function(df_concours) {
  
    # Géocodage des adresses (beaucoup de club ont des coordonnées erronées)
    df_final <- df_concours %>%
                mutate(localisation = "Estimée (géocodage adresse)",
                       adresse2 = paste0(Club, ", ", Adresse, ", ", str_sub(Dept, 6), ", ", "France")) %>%
                geocode(address = adresse2, method = 'arcgis', lat = Lat_club, long = Lon_Club) %>%
                select(-adresse2)
    
    return(df_final)
    
}
