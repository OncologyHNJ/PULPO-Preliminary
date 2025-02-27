# ==================================================
# Script: 5_Sigprofilermatrixgenerator.R
# Description: Execution of SigProfilermatrixgenerator 
# Author: Marta Portasany
# Created on: 2025-02-27
# Last modified: 2025-02-27
# Pipeline: PULPO
# Dependencies: reticulate, SigProfilerMatrixGeneratorR
# ==================================================
args <- commandArgs(trailingOnly = TRUE)
inputdata <- args[1]
pythondirectory <- args[2]
output <- args[3]
patientid <- args[4]

library(reticulate)
use_python(pythondirectory)
py_config()
py_run_string("import sys")
library(SigProfilerMatrixGeneratorR)

########SIGPROFILERMATRIXGENERATOR############################

is_empty_or_header_only <- function(file) {
  lines <- readLines(file, warn = FALSE)
  return(length(lines) == 1)  # If there is only one line (the header), there are no data
}

# Check if the input file is empty or has only the header
if (!file.exists(inputdata) || file.info(inputdata)$size == 0 || is_empty_or_header_only(inputdata)) {
  message("The input file is empty or contains only the header. Creating an empty output file and exiting without error.")
  
  # Ensure that the output directory exists
  if (!dir.exists(output)) {
    dir.create(output, recursive = TRUE)
  }
  
  # Create an empty file so that Snakemake does not crash
  empty_output_file <- file.path(output, patientid, ".SV32.matrix.tsv")
  file.create(empty_output_file)
  
  # Exit without error
  quit(status = 0)
}

tryCatch({
  SigProfilerMatrixGeneratorR::SVMatrixGenerator(input_dir = inputdata, project = patientid, output_dir = output)
}, error = function(e) {
  message("Captured error: ", e)
})
