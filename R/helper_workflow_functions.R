#' Make a backup of the errors files
#' @return NULL (creates backup directory and copies files)
#' @details Creates a timestamped backup directory and copies all CSV files from PATH_ERRORS to it
backup_files <- function() {
  date <- Sys.time()
  date <- as.POSIXlt(date)

  directory_backup <- paste(PATH_BACKUP, "/", YEAR, "_", MONTH, "_backup_", date$mday,
    "_", date$mon + 1, "_", date$year + 1900, "_", date$hour, "_",
    date$min, "_", round(date$sec, 0), "/",
    sep = ""
  )
  dir.create(directory_backup, recursive = TRUE) # create the directory backup

  files <- list.files(PATH_ERRORS, pattern = "*.csv", full.names = TRUE)

  lapply(as.list(files), function(x) {
    file.copy(x, directory_backup)
  })
}

#' Add variable with type of error to a dataframe
#' @param df Data frame to add error type to
#' @param ... Character strings to concatenate as error type
#' @return Data frame with added TIPO_ERROR column
add_type_of_error <- function(df, ...) {
  arguments <- list(...)

  type <- paste(arguments, collapse = "", sep = " ")

  if (nrow(df) != 0) {
    # df[["TIPO_ERROR"]] <- type
    df <- df %>% mutate(TIPO_ERROR = type)
  }
  return(df)
}

#' Format the errors list
#' @param errors_list List of error dataframes (default: ERRORS)
#' @param separate_by_ia Logical indicating whether to separate by influence area (default: TRUE)
#' @return List of formatted error dataframes, optionally separated by influence area
#' @details Combines all dataframes, orders columns, separates by influence area, and removes empty columns
format_errors_list <- function(errors_list = ERRORS, separate_by_ia = TRUE) {
  if (length(errors_list)==0) {
    message("There are no errors.")
    return(invisible(NULL))
  }

    # Combine all the dataframes of ERRORS list:
  # Reduce uses a binary function to successively combine the elements of a
  # given vector. In this case, merge the dataframes in the ERRORS list
  # errors <- Reduce(function(x, y) merge(x, y, all=TRUE), errors_list)
  # better with full_join because doesn't change the order of columns:
  errors <- Reduce(function(x, y) dplyr::full_join(x, y), errors_list)

  if (separate_by_ia == FALSE) {
    areas_influencia <- areas_influencia[, c("COD_PUERTO", "AREA_INF")]
    errors <- merge(errors, areas_influencia, by = "COD_PUERTO", all.x = TRUE)
    errors <- list(total = errors)
  } else if (separate_by_ia == TRUE) {
    # Separate dataframe by influece area
    errors <- separateDataframeByInfluenceArea(errors, "COD_PUERTO")
  } else {
    stop("separete_by_ia must be TRUE or FALSE")
  }

  # Remove dataframes empties in list
  errors <- Filter(nrow, errors)

  # Select the minimum columns to export.
  cols_to_export <- c(
    "AREA_INF", "COD_ID", "COD_PUERTO", "PUERTO", "FECHA_MUE", "COD_BARCO", "BARCO", "ESTRATO_RIM",
    "TIPO_MUE", "COD_ESP_MUE", "ESP_MUE", "COD_CATEGORIA", "CATEGORIA", "P_DESEM",
    "P_VIVO", "COD_ESP_CAT", "ESP_CAT", "SEXO"
  )

  # Filter only existing columns. This is mandatory because the arrange function
  # used below doesn't work with non existing columns.
  existing_cols <- intersect(cols_to_export, colnames(errors))

  # Order the errors and remove columns with only NA values
  errors <- lapply(errors, function(x) {
    x
    # Order columns
    x <- x %>%
      select(all_of(existing_cols), everything()) %>%
      select(-one_of("TIPO_ERROR"), one_of("TIPO_ERROR")) %>% # remove TIPO_ERROR, and add it to the end
      arrange(across(all_of(existing_cols)))

    # Remove columns with only NA values
    # Filter extracts the elements of a vector for which a predicate (logical) function gives true
    x <- Filter(function(x) {
      !all(is.na(x))
    }, x)

    # Add column checked
    if (length(x) > 0) {
      x[["comprobado"]] <- ""
    }

    return(x)
  })

  return(errors)
}

#' Export error list to Excel files
#' @param list List of error dataframes to export
#' @param filename Base filename for export (without extension)
#' @param separation Separator character (unused in current implementation)
#' @return NULL (creates Excel files in PATH_ERRORS directory)
#' @details Creates Excel files with formatting, including borders between different COD_ID values
export_errors_list <- function(list, filename, separation = "") {
  # Create errors subdirectory in case it doesn't exists:
  if (!file.exists(file.path(PATH_ERRORS))) {
    dir.create(file.path(PATH_ERRORS))
  }

  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    stop("Openxlsx package needed for this function to work. Please install it.",
      call = FALSE
    )
  }
  lapply(seq_along(list), function(i) {
    if (is.data.frame(list[[i]])) {
      list_name <- names(list)[[i]]
      filename <- paste0(
        PATH_ERRORS, "/", list_name, "_",
        filename, ".xlsx"
      )
      wb <- openxlsx::createWorkbook()
      # name_worksheet <- paste("0", MONTH, sep = "")

      if (length(MONTH) > 1) {
        name_worksheet <- paste("0", MONTH_AS_CHARACTER, sep = "")
      } else if (length(MONTH) == 1) {
        name_worksheet <- sprintf("%02d", as.numeric(MONTH))
      }
      openxlsx::addWorksheet(wb, name_worksheet)

      openxlsx::writeData(wb, name_worksheet, list[[i]])
      num_cols_df <- length(list[[i]])
      num_rows_df <- nrow(list[[1]])
      head_style <- openxlsx::createStyle(
        fgFill = "#EEEEEE",
        fontName = "Calibri", fontSize = "11", halign = "center",
        valign = "center"
      )
      openxlsx::addStyle(wb,
        sheet = name_worksheet, head_style,
        rows = 1, cols = 1:num_cols_df
      )
      openxlsx::setColWidths(wb, name_worksheet,
        cols = c(1:num_cols_df),
        widths = "auto"
      )

      id_changes <- which(!duplicated(list[[i]]$COD_ID))

      number_cod_id <- length(id_changes)

      # colors_to_use <- grDevices::colors()[grep('gr(a|e)y', grDevices::colors(), invert = T)]
      # colors_to_use <- sample(colors_to_use, number_cod_id)

      # colors_to_use <- grDevices::gray.colors(number_cod_id, start = 0.5)


      counter <- 1

      for (r in id_changes) {
        # style_cells <- openxlsx::createStyle(fgFill = colors_to_use[counter])

        stile_first_row <- openxlsx::createStyle(
          border = "top",
          borderColour = "black",
          borderStyle = "medium"
        )

        if (!is.na(id_changes[r + 1])) {
          rows <- (r + 1):id_changes[counter + 1]
        } else if (is.na(id_changes[r + 1])) {
          rows <- (r + 1):num_rows_df
        } else {
          stop("Error: see function exportErrorsList.")
        }
        # openxlsx::addStyle(wb, sheet = name_worksheet, style_cells,
        #                    rows = rows, cols = 1:num_cols_df, gridExpand=T, stack = T)

        openxlsx::addStyle(wb,
          sheet = name_worksheet, stile_first_row,
          rows = r + 1, cols = 1:num_cols_df, gridExpand = T, stack = T
        )

        counter <- counter + 1
      }

      Sys.setenv(R_ZIPCMD = "C:/Rtools/bin/zip.exe")
      openxlsx::saveWorkbook(wb, filename, overwrite = TRUE)
    } else {
      return(paste("This isn't a dataframe"))
    }
  })
}

#' Export error list to Google Sheets
#' @param list List of error dataframes to export
#' @param prefix Prefix for file names (default: "")
#' @param suffix Suffix for file names (default: "")
#' @param separation Separator between prefix/suffix and name (default: "")
#' @return NULL (uploads files to Google Drive)
#' @details Exports dataframes as CSV files locally, then uploads them as Google Sheets to specified Google Drive path
export_list_to_google_sheet <- function(list, prefix = "", suffix = "", separation = "") {
  # check if package openxlsx is instaled:
  if (!requireNamespace("googlesheets", quietly = TRUE)) {
    stop("Googlesheets package needed for this function to work. Please install it.",
      call = FALSE
    )
  }

  # sep_along(list): generate regular sequences. With a list, generates
  # the sequence 1, 2, ..., length(from). Return a integer vector.
  lapply(seq_along(list), function(i) {
    if (is.data.frame(list[[i]])) {
      list_name <- names(list)[[i]]

      if (prefix != "") prefix <- paste0(prefix, separation)

      if (suffix != "") suffix <- paste0(separation, suffix)

      # Before export to google drive, is mandatory export file to csv in local:
      # When the googlesheet4 packages have the oauth implemented, we can
      # use it instead of googledrive package. Googlesheet4 already have the
      # oauth implemented --> CHANGE!!!
      filename <- paste0(PATH_ERRORS, "/", prefix, list_name, suffix, ".csv")

      write.table(
        list[[i]],
        file = filename,
        quote = FALSE,
        sep = ",",
        dec = ".",
        row.names = FALSE,
        na = ""
      )

      # export to google drive
      google_drive_path <- paste0(GOOGLE_DRIVE_PATH, list_name, "/")


      drive_upload(
        media = filename,
        path = as_dribble(google_drive_path),
        type = "spreadsheet"
      )
    } else {
      return(paste("This isn't a dataframe"))
    }
  })
}

#' Copy all the error files generated to a shared folder
#' @param path_errors_from Source path of error files
#' @param path_errors_to Destination path for error files
#' @return NULL (copies files from source to destination)
#' @details Used to copy errors files generated to the shared folder. Tests if source path exists and has files, creates destination folder if needed, and prevents overwriting existing files
copy_files_to_folder <- function(path_files_from, path_files_to) {
  tryCatch(
    {
      # test if path_files_from exists
      ifelse(!file.exists(path_files_from),
        stop(paste(
          "Folder",
          path_files_from,
          "does not exists."
        )),
        FALSE
      )

      # test if path_errors_from have files
      ifelse(length(list.files(path_files_from)) == 0,
        stop(paste(
          "Folder",
          path_files_from,
          "doesn't have files."
        )),
        FALSE
      )

      # if the share errors folder does not exists, create it, with its subfolders
      folders <- list.dirs(path_files_from,
        recursive = TRUE,
        full.names = FALSE
      )

      lapply(
        folders,
        function(x) {
          ifelse(!dir.exists(file.path(path_files_to, x)),
            dir.create(file.path(path_files_to, x),
              recursive = TRUE
            ),
            FALSE
          )
        }
      )

      # test if there are files with the same name in folder. In this case,
      # nothing is saved.
      files_list_to <- list.files(path_files_to, recursive = TRUE)

      files_list_from <- list.files(path_files_from, recursive = TRUE)

      if (any(files_list_from %in% files_list_to)) {
        ae <- which(files_list_from %in% files_list_to)
        ae <- paste(files_list_from[ae], collapse = ", ")
        stop(paste("The file(s)", ae, "already exist(s). Nothing has been saved"))
      }

      # Copy all the files from path_files_from to path_files_to
      lapply(
        files_list_from,
        function(x) {
          file.copy(
            from = file.path(path_files_from, x),
            to = file.path(path_files_to, x)
          )
        }
      )
    },
    error = function(e) {
      cat("An error occurred:", conditionMessage(e), "\n")
    },
    warning = function(w) {
      cat("A warning occurred:", conditionMessage(w), "\n")
    }
  )
}

#' Create character with month, months, or any other tag to name the months used in the names of files
#' @param month Month or months used (default: MONTH)
#' @param suffix_multiple_months Suffix used when multiple months are used
#' @return Character string representing the month(s)
create_month_as_character <- function(month = MONTH, suffix_multiple_months = suffix_multiple_months) {
  if (length(month) == 1 && month %in% seq(1:12)) {
    return(sprintf("%02d", month))
  } else if (length(month) > 1 & all(month %in% seq(1:12))) {
    return(suffix_multiple_months)
  } else {
    stop("Is there any error in the MONTH variable?")
  }
}

#' Create identifier of the month/months with suffix, used to create filenames and folders
#' @param month Month or months used
#' @param year Year used
#' @param month_as_character Month as character
#' @param suffix_multiple_months Suffix used when multiple months are used
#' @param suffix Suffix used at the end of the file name (useful to have multiple error detections of the same month or year)
#' @return Character string with the identifier in format YYYY_MM or YYYY_suffix
create_identifier <- function(month,
                              year,
                              month_as_character,
                              suffix_multiple_months,
                              suffix) {
  suffix_complete <- ""

  if (suffix != "") {
    suffix_complete <- paste0("_", suffix)
  }

  if (length(month) == 1 && month %in% seq(1:12)) {
    return(paste0(year, "_", month_as_character, suffix_complete))
  } else if (length(month) > 1 & all(month %in% seq(1:12))) {
    return(paste0(year, "_", suffix_multiple_months, suffix_complete))
  }
}

#' Send errors files by email
#' @param accessory_email_info Data frame with two variables: AREA_INF (with the values GC, GS, GN and AC) and INTERNAL_LINK, with the link to the file
#' @param contacts Contacts data frame
#' @param credentials_file File created with the function creds_file() from blastula package (stored in private folder)
#' @param identification_sampling Identification string for the sampling period
#' @return NULL (sends emails via SMTP)
#' @details
#' The accessory_email_info data frame must have two variables:
#' - AREA_INF: influence area with the values GC, GS, GN and AC
#' - LINK: with the link to the error file in its AREA_INF. If there
#' aren't any error file of a certain AREA_INF, the LINK must be set
#' to "" or NA.
#'
#' The contacts data frame contains the different roles of the personal and its
#' email to send them the error files. The roles are:
#' - GC, GS, GN and AC: the supervisors of the influence areas. In the email,
#' correspond to "to" field.
#' - sender: person responsible for sending the files. In the email correspond
#' to "from" field.
#' - cc: related people to whom the email should also be sent. In the email
#' correspond to "cc" field.
#' This data set is obtained from the file contacts.csv stored in private folder
#' due to the confidential information contained in it. The contacts.csv file
#' must have a comma separated format with two fields: ROLE and EMAIL. The first
#' line must contain the name of the variables.
send_errors_by_email <- function(accessory_email_info, contacts, credentials_file,
                                 identification_sampling) {
  apply(accessory_email_info, 1, function(x) {
    if (x[["LINK"]] != "") {
      to <- contacts[contacts[["ROLE"]] == x[["AREA_INF"]] | contacts[["ROLE"]] == "sender", "EMAIL"]
      from <- contacts[contacts[["ROLE"]] == "sender", "EMAIL"]
      cc <- contacts[contacts[["ROLE"]] == "cc", "EMAIL"]

      # subject = paste0(YEAR,
      #                  "_",
      #                  sprintf("%02d", as.numeric(MONTH)),
      #                  "_",
      #                  x[["AREA_INF"]],
      #                  " -- errores muestreos RIM")

      subject <- paste0(
        identification_sampling, " ",
        x[["AREA_INF"]],
        " -- errores muestreos RIM"
      )

      rmd_email <- render_email(EMAIL_TEMPLATE)

      smtp_send(
        email = rmd_email,
        to = to,
        from = from,
        cc = cc,
        subject = subject,
        credentials = creds_file(file.path(PRIVATE_FOLDER_NAME, credentials_file))
      )
    } else {
      print(paste("The", x[["AREA_INF"]], "influence area hasn't any error"))
    }
  })
}
