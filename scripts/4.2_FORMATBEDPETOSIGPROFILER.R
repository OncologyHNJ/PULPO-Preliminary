# ==================================================
# Script: 4.2_FORMATBEDPETOSIGPROFILER
# Description: Formatting bedpe file to Sigprofiler input
# Author: Marta Portasany
# Created on: 2025-02-27
# Last modified: 2025-02-27
# Pipeline: PULPO
# Dependencies: reticulate, devtools, dplyr, magrittr
# ==================================================

# Load required libraries
library(reticulate)
library(devtools)
library(dplyr)
library(magrittr)

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
bedpedirectory <- args[1]
patientid <- args[2]
inputdata <- args[3]
outputdirectoryfile <- args[4]

# Read the .bedpe file into a dataframe
df <- tryCatch(
  {
    read.table(bedpedirectory, header = FALSE)
  },
  error = function(e) {
    message("The file is empty or cannot be read. Creating an empty output file.")
    df_total <- data.frame()  # Create an empty data frame
    write.table(df_total, file = outputdirectoryfile, sep = "\t", row.names = FALSE, quote = FALSE)
    return(NULL)  # Return NULL to avoid further processing
  }
)

# If df is NULL, terminate the script here
if (is.null(df) || nrow(df) == 0) {
  message("Skipping processing due to empty file.")
  quit(save = "no")  # End script execution
}


end1 <- df[3] - 10000
end2 <- df[6] - 10000

df1 <- cbind(df[c(1,2)], end1, df[c(4,5)], end2) 
df3 <- patientid
df4 <- df[8]

df_total <- cbind(df1,df3,df4)
colnames(df_total) <- c("chrom1","start1","end1","chrom2","start2","end2","sample","svclass")
df_total <- df_total %>% filter(svclass != "inversion_partial")


df_total <- df_total %>%
  mutate(svclass = case_when(
    svclass == "translocation_interchr" ~ "translocation",
    svclass == "translocation_intrachr" ~ "translocation",
    svclass == "duplication" ~ "tandem-duplication",
    svclass == "duplication_inverted" ~ "tandem-duplication",
    svclass == "duplication_split" ~ "tandem-duplication",
    svclass == "inversion_paired" ~ "inversion",
    svclass == "inversion_partial" ~ "inversion",
    
    TRUE ~ svclass  # Hold values that do not match any conditions
  ))

df_total <- subset(df_total, svclass != "insertion")
df_total <- subset(df_total, svclass != "insertion_nbase")


# Create the directory if it does not exist
if (!dir.exists(inputdata)) {
  dir.create(inputdata, recursive = TRUE)
}

write.table(df_total, file = outputdirectoryfile, sep = "\t", row.names = FALSE, quote = FALSE)
