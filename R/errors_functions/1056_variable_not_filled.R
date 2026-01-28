#' Check if the a variable is filled in all the rows
#' @param df Data frame to check
#' @param var Variable name to check
#' @return A data frame with errors
#' @note Check code: 1056
variable_not_filled <- function(df, var) {
  tryCatch(
    {
      variable_exists_in_df(var, df)

      fields <- c(BASE_FIELDS, var)

      err <- df[df[[var]] == "" | is.na(df[[var]]) | is.null(df[[var]]), fields]

      err <- unique(err)

      if (nrow(err) > 0) {
        err <- add_type_of_error(err, "ERROR: campo ", substitute(var), " vacío.")
        return(err)
      }
    },
    error = function(e) {
      print(e)
      return(NULL)
    }
  )
}
