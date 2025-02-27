# ==================================================
# Script: 11_Sigprofilerextractorcnvs
# Description: Execution of SigProfilerExtractorCNVs for single samples of CNV files
# Author: Marta Portasany
# Created on: 2025-02-27
# Last modified: 2025-02-27
# Pipeline: PULPO
# Dependencies: reticulate, devtools, SigProfilerExtractorR
# ==================================================
#########################################
args <- commandArgs(trailingOnly = TRUE)
inputdata <- args[1]
pythondirectory <- args[2]
outputdata <- args[3]
min_signatures <- args[4]
max_signatures <- args[5]
nmf_replicates <- args[6]
errorlog <- args[7]
###########SIGPROFILER##############
library("reticulate")
library("devtools")

if (!requireNamespace("SigProfilerExtractorR") == TRUE){
  install.packages("devtools", repos = "http://cran.us.r-project.org")
  devtools::install_github("AlexandrovLab/SigProfilerExtractorR")
  library("SigProfilerExtractorR")
  SigProfilerExtractorR::install("GRCh38", rsync=FALSE, bash=TRUE)
  
}else {
  message("SigProfilerExtractorR is already installed")
  library("SigProfilerExtractorR")
}

use_python(pythondirectory)
py_config()
#########################################
directorylog <- dirname(errorlog)
dir.create(directorylog,recursive = TRUE)
file.create(errorlog)
exists(inputdata)
if (file.exists(inputdata) == FALSE) {
  dir.create(outputdata, recursive = TRUE)
  writeLines(inputdata, errorlog, sep = "\n")
} else{
  sigprofilerextractor("matrix", outputdata, inputdata, reference_genome = "GRCh38", minimum_signatures=min_signatures , maximum_signatures=max_signatures, nmf_replicates = nmf_replicates, min_nmf_iterations = 1000, max_nmf_iterations =100000, nmf_test_conv = 1000, nmf_tolerance = 0.00000001)
}


