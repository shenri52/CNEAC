# Exporter les données au format CSV

export_club <- function(df_export) {
  
  write.table(df_export,
              "data/Club.csv",
              sep = ",",
              fileEncoding = "UTF-8",
              row.names = FALSE,
              na = "")
  
}

export_concours <- function(df_export, activite) {
  
    write.table(df_export,
                paste0("result/", activite, ".csv"),
                sep = ",",
                fileEncoding = "UTF-8",
                row.names = FALSE,
                na = "")
  
}