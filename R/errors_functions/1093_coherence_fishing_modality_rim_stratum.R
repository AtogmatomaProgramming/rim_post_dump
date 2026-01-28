#' Function to check the coherence between the fishing ship's ESTRATO_RIM and its census modality 
#' with the master
#' in the work data
#' @param catches Data frame with catches data from sapmuebase::importRIMCatches()
#' @return Data frame with those ships and its ESTRATO_RIM do no match with the master


coherence_fishing_modality_rim_stratum <- function(catches){
  
  #' Use the FISHING_GROUND_CENSUS master to obtain the ESTRATO_RIM associated to each
  #' ship through its CENSO_MODALIDAD

  master_cfpo_estrato_rim <- merge(
    CFPO[, c("COD_SGPM", "CENSO_MODALIDAD")],
    FISHING_GROUND_CENSUS,
    by = "CENSO_MODALIDAD",
    all.x = TRUE
  )

  master_cfpo_estrato_rim <- master_cfpo_estrato_rim[, c("COD_SGPM", "ESTRATO_RIM")]

  # Improve and fix some problmes with master_cfpo_estrato_rim for the comparison

  master_cfpo_estrato_rim <- master_cfpo_estrato_rim[!is.na(master_cfpo_estrato_rim$ESTRATO_RIM), ]

  master_cfpo_estrato_rim$TEST <- "T"

  # Prepare catches for the comparison

  catches_for_comparison <- catches[, c(BASE_FIELDS, "COD_SGPM")]

  # Merge both dataframes to detect those ships whose ESTRATO_RIM do not match
  
  err <- merge(catches_for_comparison,
               master_cfpo_estrato_rim,
               by = c("COD_SGPM", "ESTRATO_RIM"),
               all.x = TRUE)
  
  # Filter those rows where the the TEST column has NA values
  
  err <- err[is.na(err$TEST), ]

  err$TEST <- NULL
  
  # Add warning message to the results obtained

  if (nrow(err) > 0) {
    err <- add_type_of_error(
      err,
      "WARNING 1093: La modalidad del barco no es coherente con el estrato RIM."
    )

    return(err)
  }
  
  return(NULL)

}

