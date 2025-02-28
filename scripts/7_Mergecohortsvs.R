# ==================================================
# Script: 7_Mergecohortsvs.R
# Description: Merge individual samples to get a cohort-file
# Author: Marta Portasany
# Created on: 2025-02-27
# Last modified: 2025-02-27
# Pipeline: PULPO
# Dependencies: reticulate, SigProfilerMatrixGeneratorR
# ==================================================
#########################################
args <- commandArgs(trailingOnly = TRUE)
directorypatients <- args[1]
outputcohort <- args[2]
#########################################

# List all files in the patients directory
patients <- list.files(directorypatients)
directories <- list()
files <- list()

# Build the full paths for each file
for (i in patients) {
  fulldirectory <- paste0(directorypatients, "/", i, "/SigProfiler/results/SVs/MatrixGenerator/", i, ".SV32.matrix.tsv")
  directories <- c(directories, fulldirectory)
}

# Read the files and combine them into the 'files' list
for (j in directories) {
  if (file.exists(j)) {
    file <- read.table(j, header = TRUE)
    files <- append(files, list(file))  # Almacenar cada archivo como un elemento de la lista
  } else {
    warning(paste("The file", j, "does not exist"))
  }
}

# Convert the list of files into a single data frame
cohortfile <- files[[1]][1]  # Start with the first file

for (k in 1:length(files)) {
  if (nrow(files[[k]]) > 0 && ncol(files[[k]]) > 1) {  # Check if file is not empty and has more than one column
    # Get the column names from the current file
    col_names <- colnames(files[[k]])
    
    # Exclude the first column (MutationType) but keep the second column
    cohortfile <- cbind(cohortfile, files[[k]][2])
  } 
  else {
    message(paste("Some file is either empty or has only one row Skipping."))
  }
}

write.table(cohortfile, file = outputcohort, sep = "\t", row.names = FALSE, quote = FALSE)


