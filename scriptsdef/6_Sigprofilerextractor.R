# ==================================================
# Script: 5_Sigprofilermatrixgenerator.R
# Description: Execution of SigProfilerextractor
# Author: Marta Portasany
# Created on: 2025-02-27
# Last modified: 2025-02-27
# Pipeline: PULPO
# Dependencies: reticulate, devtools, SigProfilerExtractorR
# ==================================================
args <- commandArgs(trailingOnly = TRUE)
inputdata <- args[1]
pythondirectory <- args[2]
output <- args[3]
minimum_signatures <- args[4]
maximum_signatures <- args[5]
nmf_replicates <- args[6]
#########################################
library("reticulate")
library("devtools")
#########################################

if (!requireNamespace("SigProfilerExtractorR") == TRUE){
  install.packages("devtools", repos = "http://cran.us.r-project.org")
  devtools::install_github("AlexandrovLab/SigProfilerExtractorR")
  library("SigProfilerExtractorR")
  SigProfilerExtractorR::install("GRCh38", rsync=FALSE, bash=TRUE)
  
} else {
  message("SigProfilerExtractorR is now installed.")
  library("SigProfilerExtractorR")
}

use_python(pythondirectory)
py_config()
py_run_string("import sys")

#########################################
# Function to check if the file only has the header
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
  empty_output_file <- file.path(output, "empty_result.txt")
  file.create(empty_output_file)
  
  # Exit without error
  quit(status = 0)
}


sigprofilerextractor("matrix", output, inputdata, reference_genome = "GRCh38",opportunity_genome = "GRCh38", minimum_signatures = minimum_signatures, maximum_signatures = maximum_signatures, nmf_replicates =nmf_replicates)
