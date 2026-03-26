
#' Check if the sampled vessels are present in fleet SIRENO's master
#' that contains the vessels that are registered in the project and if 
#' it is active or not
#'
#' @param catches Data frame with catches data from sapmuebase::importRIMCatches().
#' @param fleet_sireno Data frame with fleet information from SIRENO master, 
#' containing vessel codes (COD_BARCO) and their status.
#' @return Data frame with records where the vessel code is not found in the fleet SIRENO master, 
#' with error message added. 
#'
#' @details
#' The function performs the following steps:
#' 1. Take the unique registers for the BASE_FIELDS values
#' 2. See if the COD_BARCO of catches' data frame matches with the FLEET_SIRENO one's
#' 3. Obtain a new data frame with the name "err" with the registers that do not match
#' and return it.
#'
#' @note Requires global objects: BASE_FIELDS, FLEET_SIRENO

check_vessel_status <- function(catches, fleet_sireno){

  sampled_vessels <- unique(catches[, c(BASE_FIELDS)])
  
  err <- sampled_vessels[!(sampled_vessels$COD_BARCO %in% fleet_sireno$COD_BARCO), ]

    if (nrow(err) > 0) {
    err <- add_type_of_error(
      err,
      "WARNING 1094: El barco no se encuentra o bien dado de ALTA o FILTRADO al proyecto. REVISAR"
    )

    return(err)
  }

}