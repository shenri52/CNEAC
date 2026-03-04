# Exporter les données au format CSV

export_club <- function(df_export) {
  
  write.table(df_export,
              "data/Club.csv",
              sep = ",",
              fileEncoding = "UTF-8",
              row.names = FALSE,
              na = "")
  
  # Liste des clubs sans les DOM
  df_export  <- df_export %>%
                filter(Dept_Club != "97 - DOM") %>%
                mutate(id_club = row_number())
  
  write.table(df_export,
              "result/Club_sans_DOM.csv",
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