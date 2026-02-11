#' Check Coherence Between Fishing Modality and RIM Stratum
#'
#' Verifies that vessel fishing modality matches the expected RIM stratum
#' according to the fishing ground census master data.
#'
#' @param catches Data frame with catches data from sapmuebase::importRIMCatches().
#' @return Data frame with records where the vessel's modality does not match
#'   the expected RIM stratum, with error message added. Returns NULL if no
#'   errors are found.
#'
#' @details
#' The function performs the following steps:
#' 1. Extracts unique trip records with vessel codes (COD_SGPM)
#' 2. Merges with CFPO to obtain the fishing modality (CENSO_MODALIDAD)
#' 3. Compares the CENSO_MODALIDAD and ESTRATO_RIM combination against the
#'    FISHING_GROUND_CENSUS master data
#' 4. Returns records where the combination is not found in the master
#'
#' @note Requires global objects: BASE_FIELDS, CFPO, FISHING_GROUND_CENSUS
coherence_fishing_modality_rim_stratum <- function(catches){
  catches_clean <- catches[, c(BASE_FIELDS,"ARTE", "COD_SGPM")]
  catches_clean <- unique(catches_clean)

  catches_cfpo <- merge(catches_clean,
               CFPO[, c("COD_SGPM", "CENSO_MODALIDAD")],
               by = "COD_SGPM",
               all.x = TRUE)
  
  FISHING_GROUND_CENSUS$test <- "T"

  catches_cfpo_master <- merge(catches_cfpo,
               FISHING_GROUND_CENSUS,
               by = c("CENSO_MODALIDAD", "ESTRATO_RIM"),
               all.x = TRUE)
  
  err <- catches_cfpo_master[is.na(catches_cfpo_master$test), ]

  if (nrow(err) > 0) {
    err <- add_type_of_error(
      err,
      "WARNING 1093: La modalidad del barco no es coherente con el estrato RIM."
    )

    return(err)
  }
  
  return(NULL)

}
