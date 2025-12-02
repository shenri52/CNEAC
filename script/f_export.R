# Exporter les données au format CSV

export_club <- function(df_export) {
  
  write.table(df_export,
              "data/Club.csv",
              sep = ",",
              fileEncoding = "UTF-8",
              row.names = FALSE,
              na = "")
  
}

export_concours <- function() {

  # Consolidation des données  
  df_export <- bind_rows(geocodage_concours, geocodage_pass) %>%
               bind_rows(geocodage_caesc) %>%
               mutate(id_epreuve = row_number())
  
  
  write.table(df_export,
              paste0("result/Epreuve.csv"),
              sep = ",",
              fileEncoding = "UTF-8",
              row.names = FALSE,
              na = "")
}