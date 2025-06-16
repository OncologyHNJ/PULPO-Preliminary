import os
import re
import logging


#output_dir = f"{resultsdir}/",
#bionano_to_anonymised = bionano_to_anonymised,
#log_dir = f"{logsdir}/unzip_bionanocnv/"

inputdirectory = "/home/user/MARTA/DATA/Bionanocohort/RVA_LLA_Cohorte_paper/Cells_802/"
log_dir = "/home/user/MARTA/PULPO_ejecutadoprueba/logs/unzip_bionanocnv/Patient-1.log"
directory = "/home/user/MARTA/DATA/Bionanocohort/RVA_LLA_Cohorte_paper/"
output_dir = "/home/user/MARTA/PULPO_ejecutadoprueba/results"

# Setting up logging
#log_dir = params.log_dir.format(anonymised=wildcards.anonymised)
os.makedirs(log_dir, exist_ok=True)
log_file = os.path.join(log_dir)
#logging.basicConfig(filename=log_file, level=logging.INFO,   format='%(asctime)s - %(levelname)s - %(message)s')

# Accessing wildcards and params directly
bionano_key = "Cell_802"

try:
    anonymised_name = params.bionano_to_anonymised[bionano_key]
except KeyError:
    raise ValueError(f"Anonymised name not found for bionano '{bionano_key}'")

# Creating the output directory
output_dir = f"{output_dir}/Patient-1/Bionanodata"
os.makedirs(output_dir, exist_ok=True)

# Constructing the input directory path
input_directory = f"{inputdirectory}/"

# Logging information about the process
logging.info(f"Bionano code: {bionano_key}")
logging.info(f"Anonymised name: {anonymised_name}")
logging.info(f"Input directory: {input_directory}")

# Listing files in the input directory
files_in_input = os.listdir(inputdirectory)
logging.info(f"Files in input directory: {files_in_input}")

# Finding the matching ZIP file
matching_bed_zip = [f for f in files_in_input if f.startswith(f"{bionano_key}-BED_ALL.zip")]

if matching_bed_zip:
    zip_file = matching_bed_zip[0]
else:
    zip_files = [f for f in files_in_input if f.endswith(".zip")]
    if zip_files:
        zip_file = zip_files[0]
    else:
        raise ValueError(f"No valid ZIP file found in input directory for bionano '{bionano_key}'.")

zip_path = os.path.join(input_directory, zip_file)
logging.info(f"Found ZIP file: {zip_path}")

# Unzipping the ZIP file to the output directory
shell(f"unzip -d {output_dir} {zip_path}")
logging.info("Unzipped files.")

# Defining regular expression patterns
smap_pattern = re.compile(r"^(?!.*Annotated).*\.smap$")
cnv_csv_pattern = re.compile(r".*CNV.*\.csv$")

# Listing all files in the output directory
files_in_output = os.listdir(output_dir)
logging.info(f"Files in output directory: {files_in_output}")

# Removing files that do not match any of the patterns
for file_in_output in files_in_output:
    file_path = os.path.join(output_dir, file_in_output)
    if os.path.isfile(file_path) and not (
            smap_pattern.match(file_in_output) or
            cnv_csv_pattern.match(file_in_output)):
        os.remove(file_path)
        logging.info(f"Removed file: {file_in_output}")

# Creating the output file with the required content
output_file = output.log_file
with open(output_file, 'w') as f:
    f.write(f"Bionano code: {bionano_key}\nAnonymised name: {anonymised_name}")
logging.info(f"Created output file: {output_file}")

