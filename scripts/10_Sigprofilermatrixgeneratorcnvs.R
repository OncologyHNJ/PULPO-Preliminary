# ==================================================
# Script: 10_Sigprofilermatrixgeneratorcnvs
# Description: Execution of SigProfilerMatrixgenerator for single samples of CNV files
# Author: Marta Portasany
# Created on: 2025-02-27
# Last modified: 2025-02-27
# Pipeline: PULPO
# Dependencies: reticulate, devtools, SigProfilerMatrixGeneratorR
# ==================================================
#############SIGPROFILERMATRIXGENERATOR###########
args <- commandArgs(trailingOnly = TRUE)
inputdata <- args[1]
pythondirectory <- args[2]
output <- args[3]
patient <- args[4]
sigprofilerfile <- args[5]
##################################################
library("reticulate")
library("devtools")
use_python(pythondirectory)
py_config()
py_run_string("import sys")
##################################################
tryCatch(
  {
    library(SigProfilerMatrixGeneratorR)  # Attempt to load the package
  },
  error = function(e) {
    # If there is an error, try to install the package
    message("The SigProfilerMatrixGeneratorR package is not installed. Proceeding to install it...")
    if (!requireNamespace("devtools", quietly = TRUE)) {
      install.packages("devtools")
    }
    devtools::install_github("AlexandrovLab/SigProfilerMatrixGeneratorR")
    library(SigProfilerMatrixGeneratorR)  # Attempt to reload again after installation
  }
)

tryCatch({
  # Read the file
  file <- read.table(inputdata, header = TRUE)
  
  # Check if the file has only headers (no data)
  if (nrow(file) == 0) {
    
    if (!dir.exists(output)) {
      dir.create(output, recursive = TRUE)
      message("Directory created:", output)
      # Create an empty file with only the headers
      file.create(sigprofilerfile)
    } else {
      message("The directory already exists:", output)
      # Create an empty file with only the headers
      file.create(sigprofilerfile)
    }
    
  } else {
    # Execute CNVMatrixGenerator function only if the file has data
    tryCatch({
      CNVMatrixGenerator(file_type = "PCAWG", input_file = inputdata, project = patient, output_path = output)
    }, error = function(e) {
      if (grepl("objeto 'sys' no encontrado", e$message)) {
        message("Warning: Error related to ‘sys’ not found was ignored.")
      } else {
        stop(e)  # Relates other errors
      }
    })
  }
}, error = function(e) {
  # Capture the error and display it
  message("An error occurred: ", e$message)
  print(patient)
  if (!dir.exists(output)) {
    dir.create(output, recursive = TRUE)
    message("Directory created:", output)
    # Create an empty file with only the headers
    file.create(sigprofilerfile)
  }
})

