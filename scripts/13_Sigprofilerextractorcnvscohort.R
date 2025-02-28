# ==================================================
# Script: 13_Sigprofilerextractorcnvscohort
# Description: Signature extraction of the cohort
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
errorlog <- args[7]
###########SIGPROFILER##############
library("SigProfilerExtractorR")
library("reticulate")
library("devtools")
#########################################
use_python(pythondirectory)
py_config()
#########################################

sigprofilerextractor("matrix", output, inputdata, reference_genome = "GRCh38",opportunity_genome = "GRCh38", minimum_signatures=minimum_signatures, maximum_signatures=maximum_signatures, nmf_replicates=nmf_replicates, min_nmf_iterations = 1000, max_nmf_iterations =100000, nmf_test_conv = 1000, nmf_tolerance = 0.00000001)

