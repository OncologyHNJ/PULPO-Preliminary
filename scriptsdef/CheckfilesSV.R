# ==================================================
# Script: CheckfilesSV.R
# Description: Checking whether raw decompressed SV files of OGM are empty or not
# Author: Marta Portasany
# Created on: 2025-02-27
# Last modified: 2025-02-27
# Pipeline: PULPO
# Dependencies: Base R (no external packages required)
# ==================================================

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
patient <- args[1]
inputsv <- args[2]
error_log <- file.path(inputsv, "check_svs_error.txt")


# Error handling function
handle_error <- function(e) {
  error_message <- paste0("ERROR: ", e$message, " in the sample ", patient, ".\n")
  writeLines(error_message, con = error_log)  
  stop(error_message) 
}

# Attempt to run the main code and capture errors
tryCatch({
  # Search for files with .smap extension in the input directory
  smap_files <- list.files(inputsv, pattern = "\\.smap$", full.names = TRUE)
  
  # Check if .smap files were found
  if (length(smap_files) == 0) {
    stop("No .smap files were found in the directory.")
  }
  
  # Process each .smap file found
  for (smap_file in smap_files) {
    # Read all lines of the file
    all_lines <- readLines(smap_file)
    
    # Filter lines without #
    variant_lines <- grep("^[^#]", all_lines, value = TRUE)
    
    # Check for variants after filtering
    if (length(variant_lines) == 0) {
      stop(paste0("The file ", smap_file, " for sample ", patient, " is empty."))
    } else {
      message(paste0("OK: THe file ", smap_file, " for sample ", patient, " has variants."))
    }
  }
}, error = handle_error)
