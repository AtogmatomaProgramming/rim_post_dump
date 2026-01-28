#' Check if the COD_ID variable is filled
#' @details The COD_ID variable is filled when the data is dumped in SIRENO. But, if
#' a new sample is hand typed, the COD_ID it is not generated and is saved as
#' an empty field.
#' This function check that all the registers of COD_ID are filled
#' @param lengths Data frame with lengths data from sapmuebase::importRIMLengths()
#' @return Return a dataframe with the erroneus codes
#' @note Check code: 1060
validate_cod_id <- function(lengths) {
  if (variable_exists_in_df("COD_ID", lengths)) {
    err <- lengths[is.na(lengths[["COD_ID"]]), ]

    err <- err[, BASE_FIELDS]

    if (nrow(err) > 0) {
      err <- add_type_of_error(
        err,
        "ERROR: variable COD_ID vacía. Este error solo puede ser resuelto por los servicios informáticos de Madrid."
      )
    }

    return(err)
  } else {
    return(FALSE)
  }
}
