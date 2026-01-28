#### Check monthly data recorded in SIRENO.
#### Return xls files by influence area with errors detected.

# INSTRUCTIONS -----------------------------------------------------------------

# The default folder organization is:
#   - data
#     - YYYY  (year with four digits)
#       - YYYY_MM  (MM is the month with two digits: 01, 02, ..., 12)
#          - input (folder with the files obtained from the subcontracted
#                       company)
#          - backup (folder with the backup of the scripts, files used in the
#                     process and final files)
#          - errors (folder with the errors found in the data)
#          - finals (folder with the final files to dump in SIRENO database)
#   - data-raw (folder with reference data: species lists, taxonomic confusion, etc.)
#   - private (folder with sensitive information, like contacts, cfpo, etc.)
#   - R (folder with individual check and helper function files)
#     - Individual check function files named: {code}_{function_name}.R (e.g., 1016_detect_false_mt1.R)
#     - Helper function files named: helper_{function_name}.R
#     - rim_post_dump_functions_final.R (sources all check and helper functions)
#
# To use this script:
# - Change variables in "YOU HAVE ONLY TO CHANGE THIS VARIABLES" section of this
#   script.
# - A file "contacts.csv" must be stored in private folder. This data set
# contains the different person roles and its email, used in the distribution of
# error files.
# The possible roles are:
#   - GC, GS, GN and AC: the supervisors of the influence areas.
#   - sender: person responsible for sending the files.
#   - cc: related people to whom the email should also be sent.
# The contacts file must have a comma separated format with two fields: ROLE and
# EMAIL. The first line must contain the name of the variables.
# - A CFPO file must be stored in private folder.
# - Run all the script
# - A file by influence area is generated in "errors" directory.


# FOLDER STRUCTURE -------------------------------------------------------------
# Name of the folder where the input files must be stored.
DATA_FOLDER_NAME <- "input"
# Name of the folder where will be stored the errors generated in this script.
ERRORS_FOLDER_NAME <- "errors"
# Name of the folder where will be stored the backup files generated in this
BACKUP_FOLDER_NAME <- "backup"
# Name of the folder where are stored private files with sensitive information.
PRIVATE_FOLDER_NAME <- "private"
# Name of the folder where are stored raw data files.
DATA_RAW_FOLDER_NAME <- "data-raw"

# USER SETTINGS -------------------------------------------------------------
# This file contains the user settings:
# - FILENAME_DES_TOT: name of the file with the total catches data.
# - FILENAME_DES_TAL: name of the file with the total lengths data.
# - FILENAME_TAL: name of the file with the lengths data.
# - PATH_SHARE_FOLDER: path of cloud service where the files will be shared.
source(file.path(PRIVATE_FOLDER_NAME, "user_settings.R"))

# YOU ONLY HAVE TO CHANGE THIS VARIABLES ---------------------------------------

# Name of the files obtained from SIRENO database and share path.
# By default, this file names are stored in the user_settings.R file. You can override
# them here if you want to use different names.
# FILENAME_DES_TOT <- "IEOUPMUEDESTOTSIRENO.TXT"
# FILENAME_DES_TAL <- "IEOUPMUEDESTALSIRENO.TXT"
# FILENAME_TAL <- "IEOUPMUETALSIRENO.TXT"

# MONTH: 1 to 12, or vector with month in numbers
MONTH <- c(11)

# YEAR
YEAR <- 2025

# Suffix to add to path. Use only in case MONTH is a vector of months. This
# suffix will be added to the end of the path with a "_" as separation.
suffix_multiple_months <- ""

# Suffix to add at the end of the export file name. This suffix will be added to
# the end of the file name with a "_" as separation.
suffix <- ""

# cfpo to use in the script
cfpo_to_use <- "CFPO2024 DEF.xlsx"

# PACKAGES ---------------------------------------------------------------------
library(dplyr)
library(blastula) # to send emails
library(devtools)
library(openxlsx) # to read directly CFPO from a excel file

# install sapmuebase from github
# remove.packages("sapmuebase")
# .rs.restartR()
# install_github("eucrow/sapmuebase")

library(sapmuebase)

# FUNCTIONS --------------------------------------------------------------------
source('R/rim_post_dump_functions.R')

# GLOBAL VARIABLES -------------------------------------------------------------

# Month as character
MONTH_AS_CHARACTER <- create_month_as_character(MONTH, suffix_multiple_months)

# Identifier of the month/months, with suffixes
IDENTIFIER <- create_identifier(
  MONTH,
  YEAR,
  MONTH_AS_CHARACTER,
  suffix_multiple_months,
  suffix
)

# Path where the files of the month and year will be stored.
PATH_FILES <- file.path(getwd(), "data", YEAR, IDENTIFIER)

# Path where private files are stored.
PATH_PRIVATE_FILES <- file.path(getwd(), PRIVATE_FOLDER_NAME)

# list with the common fields used in all tables
BASE_FIELDS <- c( "COD_ID", "COD_PUERTO", "PUERTO", "LOCODE", "FECHA_MUE",
  "COD_BARCO", "BARCO", "ESTRATO_RIM", "COD_TIPO_MUE", "TIPO_MUE")

# path where the input files must be stored
PATH_INPUT_FILES <- file.path(PATH_FILES, DATA_FOLDER_NAME)
# path to store errors files
PATH_ERRORS <- file.path(PATH_FILES, ERRORS_FOLDER_NAME)
# path to store backup files
PATH_BACKUP <- file.path(PATH_FILES, BACKUP_FOLDER_NAME)
# path to data-raw folder
PATH_DATA_RAW <- file.path(getwd(), DATA_RAW_FOLDER_NAME)
# path to shared folder
PATH_SHARED_ERRORS <- file.path(PATH_SHARE_FOLDER, YEAR, IDENTIFIER, ERRORS_FOLDER_NAME)

# path to SIRENO folder.
PATH_SIRENO <- "C:/sireno"

# files to backup
FILES_TO_BACKUP <- c(
  "rim_post_dump.R",
  list.files("R", pattern = "\\.R$", full.names = TRUE, recursive = TRUE),
  file.path(PATH_DATA_RAW, "especies_sujetas_a_posible_confusion_taxonomica.csv"),
  file.path(PATH_DATA_RAW, "especies_no_permitidas.csv"),
  file.path(PATH_DATA_RAW, "historical_species_sampled.csv"),
  file.path(PATH_DATA_RAW, "censo_modalidad_caladero.csv")

)

ERRORS_FILENAME <- paste0("errors", "_", IDENTIFIER)

EMAIL_TEMPLATE <- "errors_email.Rmd"


# CREATE WORKING FOLDERS -------------------------------------------------------
working_folders <- list(
  backup = PATH_BACKUP,
  errors = PATH_ERRORS,
  input = PATH_INPUT_FILES)

lapply(working_folders, dir.create, recursive = TRUE)

# MOVE FILES FROM DOWNLOAD FOLDER TO INPUT DIRECTORY ---------------------------
# list_files <- list(
#   des_tal = FILENAME_DES_TAL,
#   des_tot = FILENAME_DES_TOT,
#   tal = FILENAME_TAL
# )
#
# lapply(
#   list_files,
#   move_file,
#   PATH_SIRENO,
#   PATH_INPUT_FILES
# )

# IMPORT DATA ------------------------------------------------------------------

# Get the mixed species data set.
mixed_species <- especies_mezcla

# Get the no mixed species data set.
sampled_species_no_mixed <- especies_no_mezcla

# Get the not allowed species data set.
NOT_ALLOWED_SPECIES <- read.csv(file.path(PATH_DATA_RAW, "especies_no_permitidas.csv"))

# Get the fishing ground census master data set.
FISHING_GROUND_CENSUS <- read.csv(
  file.path(PATH_DATA_RAW, "censo_modalidad_caladero.csv"),
  sep = ";"
)

# Get the historical sampled species dataset
historical_species_sampled <- read.csv(
  file.path(PATH_DATA_RAW, "historical_species_sampled.csv"),
  sep = ";"
)

# Get the species susceptible to taxonomic confusion data set.
ESP_TAXONOMIC_CONFUSION <- read.csv(
  file.path(PATH_DATA_RAW, "especies_sujetas_a_posible_confusion_taxonomica.csv"),
  sep = ";",
  colClasses = c("factor", "factor", "factor", "factor", "factor",
    "factor", "character", "character")
)

# Get the CFPO
CFPO <- read.xlsx(
  file.path(PATH_PRIVATE_FILES, cfpo_to_use),
  detectDates = TRUE
)
CFPO <- CFPO[, c("Código", "CFR", "Matrícula", "Estado.actual", "Censo.por.modalidad")]
colnames(CFPO) <- c("COD_SGPM", "CFR", "MATRICULA", "ESTADO", "CENSO_MODALIDAD")

# Get the contacts data set.
CONTACTS <- read.csv(file.path(PATH_PRIVATE_FILES, "contacts.csv"))

# IMPORT "muestreos UP" files
muestreos_up <- importRIMFiles(
  catches = FILENAME_DES_TOT,
  catches_in_lengths = FILENAME_DES_TAL,
  lengths = FILENAME_TAL,
  path = PATH_INPUT_FILES
  # ,  by_month = MONTH
)

# TODO: Create a coherence check rim_stratum-origin
# SEARCHING ERRORS -------------------------------------------------------------
errors <- rim_check(muestreos_up)
# errors <- rim_check_annual(muestreos_up)
# errors <- rim_check_annual_nvdp_matched(muestreos_up)

errors <- list("GS" = errors[["GS"]][errors[["GS"]]$PUERTO == "Muros", ])

# Check oab data dumped in rim:
#   - sampled type 4, MT2B
# errors <- oab_check(muestreos_up)

# All the errors in a single data frame:
# errors_complete <- Reduce( function(x, y) { merge(x, y, all=TRUE)}, errors)

# EXPORT ERRORS ----------------------------------------------------------------
# by influence area
export_errors_list(errors, ERRORS_FILENAME, separation = "_")
# complete
# write.xlsx(
#   errors_complete,
#   file.path(PATH_ERRORS, paste0(ERRORS_FILENAME, ".xlsx"))
# )


# CHECK CODE_ID ----------------------------------------------------------------
# This check is not for send to the sups, so it's out the ERRORS dataframe
# errors_cod_id <- validate_cod_id(muestreos_up$catches)

# BACKUP SCRIPTS AND RELATED FILES ---------------------------------------------
# first save all files opened
rstudioapi::documentSaveAll()
# and the backup the scripts and files:
sapmuebase::backupScripts(FILES_TO_BACKUP, path_backup = PATH_BACKUP)

# SAVE FILES TO SHARED FOLDER --------------------------------------------------
copy_files_to_folder(PATH_FILES, PATH_SHARED_ERRORS)

# SEND EMAILS AUTOMATICALLY ----------------------------------------------------
# The first time the errors will be sent by email, a credential file must be
# generated with create_smtp_creds_file. The credentials file is generated in
# the private folder:
# blastula::create_smtp_creds_file(file = file.path(PRIVATE_FOLDER_NAME, "credentials"),
#                        user = "",
#                        host = "",
#                        port = ,
#                        use_ssl = )

# The internal_links data frame must have two variables:
# - AREA_INF: influence area with the values GC, GS, GN and AC.
# - INTERNAL_LINK: with the link to the error file in its AREA_INF. If there
# aren't any error file of a certain AREA_INF, must be set to "".
# - NOTES: any notes to add to the email. If there aren't, must be set to "".
accessory_email_info <- data.frame(
  AREA_INF = c("AC", "GC", "GN", "GS"),
  LINK = c("",
           "",
           "",
           ""),

  NOTES = c("",
            "",
            "",
            "")
)


send_errors_by_email(
  accessory_email_info = accessory_email_info,
  contacts = CONTACTS,
  credentials_file = "credentials",
  identification_sampling = IDENTIFIER
)
