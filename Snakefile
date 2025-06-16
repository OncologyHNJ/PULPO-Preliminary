####IMPORTS
import pandas as pd
import os
import yaml

configfile: "./config/configpulpo.yaml"

# Load the configuration YAML file
with open("./config/configpulpo.yaml", 'r') as file:
    config = yaml.safe_load(file)

# Read sample table and check columns
sample_table = pd.read_table(config['input']['samples'], sep='\t', lineterminator='\n', dtype=str)
#print("Dataframe columns", sample_table.columns)

# Verify that the expected columns are present
expected_columns = {'sample', 'family', 'bionano', 'anonymised'}
if not expected_columns.issubset(sample_table.columns):
    raise KeyError(f"The sample file does not contain the necessary columns: {expected_columns}")

# Dictionaries for easy access
bionano_to_anonymised = sample_table.set_index('bionano')['anonymised'].to_dict()
# Create the reverse dictionary
anonymised_to_bionano = {v: k for k, v in bionano_to_anonymised.items()}

# Wildcards
wildcard_constraints:
    bionano = "|".join(sample_table['bionano'].unique()),
    anonymised = "|".join(sample_table['anonymised'].unique())

# Working directory from config.yaml
workdirectory = config['directories']['workdirectory']
logsdir = f"{workdirectory}/logs"
resultsdir = f"{workdirectory}/results"

os.makedirs(workdirectory, exist_ok=True)
os.makedirs(logsdir, exist_ok=True)
os.makedirs(resultsdir, exist_ok=True)

include: "rules/0_prepare_ogm_data.smk"

#Validate analysis options

def validate_config(config):
    print("PULPO v1.0 is running. Please take care of the analysis!")
    valid_types = {"SVs", "CNVs", "SVs_and_CNVs"}
    valid_cohort = {"TRUE","FALSE"}

    analysis_config = config.get('analysis', {})

    if 'analysis_type' not in analysis_config:
        raise KeyError("The configuration file is missing the 'analysis_type' under 'analysis'.")

    # Check if ‘analysis_type’ is valid
    if analysis_config['analysis_type'] not in valid_types:
        raise ValueError(f"Invalid analysis_type: {analysis_config['analysis_type']}. Must be one of {valid_types}.")

    # Print the corresponding message according to the type of analysis.
    if analysis_config['analysis_type'] == "SVs":
        print("You have selected 'SVs' as the analysis type. Proceeding with SVs analysis...")
    elif analysis_config['analysis_type'] == "CNVs":
        print("You have selected 'CNVs' as the analysis type. Proceeding with CNVs analysis...")
    elif analysis_config['analysis_type'] == "SVs_and_CNVs":
        print("You have selected 'SVs_and_CNVs' as the analysis type. Proceeding with both SVs and CNVs analysis...")

    cohort_config = config.get('run_cohort_analysis', {})

    # Check if the key ‘analysis’ exists in the config
    analysis_config = config.get('analysis',{})
    run_cohort_analysis = analysis_config.get("run_cohort_analysis",False)
    if run_cohort_analysis:
        print("Cohort analysis is enabled.")
    else:
        print("Running individual analysis only.")

    # Confirmation that the configuration is valid
    print("Configuration is valid! Proceeding with the pipeline...")

validate_config(config)
################################################################################################################################################################################
###########################################################################DEFINITIONSOFPULPOS'OPTIONS##########################################################################
################################################################################################################################################################################

# Python env directory from config.yaml
pythonenvdir = config['directories']['pythonenvdir']
snakefiles_to_include = []
all_targets = []

ruleorder: prepare_ogm_data > descompressOGM

if config['analysis']['run_cohort_analysis'] == True:
    if config['analysis']['analysis_type'] == "SVs":
        if config['file_types']['SVs'] == "smap":
            snakefiles_to_include.append("rules/1.1_Preprocessing_SVs.smk")
            all_targets.extend([rules.prepare_ogm_data.output.done,
                                f"{logsdir}/DATA/descompressOGM/succesfulldescompresion.txt",
                                f"{resultsdir}/DATA/Patients/{{anonymised}}/OGMdata/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/Check/check_svs_done.txt",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/ProcessData/{{anonymised}}.bedpe",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/data/SigProfilerSVdf.bedpe"
                                ])
            snakefiles_to_include.append("rules/2.1_Individualanalysis_SVs.smk")
            all_targets.extend([f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.SV32.matrix.tsv",
                                f"{logsdir}/SVs/Patients/{{anonymised}}/SigProfiler/sigprofilermatrix.log",
                                ])

            snakefiles_to_include.append("rules/3.1_Cohortanalysis_SVs.smk")
            all_targets.extend([f"{resultsdir}/SVs/Cohort/Cohort.SV32.matrix.tsv",
                                f"{resultsdir}/SVs/Cohort/SigProfiler/",
                                ])

        elif config['file_types']['SVs'] == "bedpe":
            snakefiles_to_include.append("rules/2.1_Individualanalysis_SVs.smk")
            all_targets.extend([f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.SV32.matrix.tsv",
                                f"{logsdir}/SVs/Patients/{{anonymised}}/SigProfiler/sigprofilermatrix.log",
                                ])

            snakefiles_to_include.append("rules/3.1_Cohortanalysis_SVs.smk")
            all_targets.extend([f"{resultsdir}/SVs/Cohort/Cohort.SV32.matrix.tsv",
                                f"{resultsdir}/SVs/Cohort/SigProfiler/",
                                ])
        else:
            raise ValueError(f"Error in config file_types SVs: {config['file_types']['SVs']}. The options are: smap or bedpe. Please check your config file (configpulpo.yaml) and try it again.")


    elif config['analysis']['analysis_type'] == "CNVs":
        if config['file_types']['CNVs'] == "csv" or config['file_types']['CNVs'] == "txt":
            snakefiles_to_include.append("rules/1.2_Preprocessing_CNVs.smk")
            all_targets.extend([rules.prepare_ogm_data.output.done,
                                f"{logsdir}/DATA/descompressOGM/succesfulldescompresion.txt",
                                f"{resultsdir}/CNVs/Patients/{{anonymised}}/Check/check_cnvs_done.txt",
                                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/data/SigProfilerCNVdf.tsv",
                                f"{logsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/sigprofilercnvmatrixgenerator.log",
                                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",

                                ])
            snakefiles_to_include.append("rules/2.2_Individualanalysis_CNVs.smk")
            all_targets.extend([
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/"
            ])

            snakefiles_to_include.append("rules/3.2_Cohortanalysis_CNVs.smk")
            all_targets.extend([
                f"{resultsdir}/CNVs/Cohort/SigProfiler/MatrixGenerator/Cohort.CNV48.matrix.tsv",
                f"{resultsdir}/CNVs/Cohort/SigProfiler/Extractor/"
            ])


        elif config['file_types']['CNVs'] == "bed":
            snakefiles_to_include.append("rules/2.2_Individualanalysis_CNVs.smk")
            all_targets.extend([
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/"
            ])

            snakefiles_to_include.append("rules/3.2_Cohortanalysis_CNVs.smk")
            all_targets.extend([
                f"{resultsdir}/CNVs/Cohort/SigProfiler/MatrixGenerator/Cohort.CNV48.matrix.tsv",
                f"{resultsdir}/CNVs/Cohort/SigProfiler/Extractor/"

            ])
        else:
            raise ValueError(f"Error in {config['file_types']['CNVs']}. The options for CNVs file extensions are: csv, txt or bed. Please check your configfile (default: configpulpo.yml) and try it again.")

    elif config['analysis']['analysis_type'] == "SVs_and_CNVs":
        if config['file_types']['SVs'] == "smap" and config['file_types']['CNVs'] == "csv" or config['file_types']['CNVs'] == "txt":
            snakefiles_to_include.append("rules/1.1_Preprocessing_SVs.smk")
            all_targets.extend([rules.prepare_ogm_data.output.done,
                                f"{logsdir}/DATA/descompressOGM/succesfulldescompresion.txt",
                                f"{resultsdir}/DATA/Patients/{{anonymised}}/OGMdata/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/Check/check_svs_done.txt",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/ProcessData/{{anonymised}}.bedpe",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/data/SigProfilerSVdf.bedpe"
                ])
            snakefiles_to_include.append("rules/2.1_Individualanalysis_SVs.smk")
            all_targets.extend([ f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/",
                                 f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/",
                                 f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.SV32.matrix.tsv",
                                 f"{logsdir}/SVs/Patients/{{anonymised}}/SigProfiler/sigprofilermatrix.log",
                                 ])

            snakefiles_to_include.append("rules/3.1_Cohortanalysis_SVs.smk")
            all_targets.extend([f"{resultsdir}/SVs/Cohort/Cohort.SV32.matrix.tsv",
                                f"{resultsdir}/SVs/Cohort/SigProfiler/",
                                ])

            snakefiles_to_include.append("rules/1.2_Preprocessing_CNVs.smk")
            all_targets.extend([f"{logsdir}/DATA/descompressOGM/succesfulldescompresion.txt",
                                f"{resultsdir}/CNVs/Patients/{{anonymised}}/Check/check_cnvs_done.txt",
                                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/data/SigProfilerCNVdf.tsv",
                                f"{logsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/sigprofilercnvmatrixgenerator.log",
                                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
            ])

            snakefiles_to_include.append("rules/2.2_Individualanalysis_CNVs.smk")
            all_targets.extend([
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/"
            ])

            snakefiles_to_include.append("rules/3.2_Cohortanalysis_CNVs.smk")
            all_targets.extend([
                f"{resultsdir}/CNVs/Cohort/SigProfiler/MatrixGenerator/Cohort.CNV48.matrix.tsv",
                f"{resultsdir}/CNVs/Cohort/SigProfiler/Extractor/"
            ])

        elif config['file_types']['SVs'] == "bedpe" and config['file_types']['CNVs'] == "bed":
            snakefiles_to_include.append("rules/2.1_Individualanalysis_SVs.smk")
            all_targets.extend([f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.SV32.matrix.tsv",
                                f"{logsdir}/SVs/Patients/{{anonymised}}/SigProfiler/sigprofilermatrix.log"
                                ])

            snakefiles_to_include.append("rules/3.1_Cohortanalysis_SVs.smk")
            all_targets.extend([f"{resultsdir}/SVs/Cohort/Cohort.SV32.matrix.tsv",
                                f"{resultsdir}/SVs/Cohort/SigProfiler/"
                                ])

            snakefiles_to_include.append("rules/2.2_Individualanalysis_CNVs.smk")
            all_targets.extend([
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/"
            ])

            snakefiles_to_include.append("rules/3.2_Cohortanalysis_CNVs.smk")
            all_targets.extend([
                f"{resultsdir}/CNVs/Cohort/SigProfiler/MatrixGenerator/Cohort.CNV48.matrix.tsv",
                f"{resultsdir}/CNVs/Cohort/SigProfiler/Extractor/"
            ])

    else:
            raise ValueError(f"Error in config file_types CNVs: {config['file_types']['CNVs']} or SVs {config['file_types']['SVs']}. The options are for CNVs are: csv,txt or bed and for SVs: smap or bedpe. Please check your config file (configpulpo.yaml) and try it again.")

elif config['analysis']['run_cohort_analysis'] == False:
    if config['analysis']['analysis_type'] == "SVs":
        if config['file_types']['SVs'] == "smap":
            snakefiles_to_include.append("rules/1.1_Preprocessing_SVs.smk")
            all_targets.extend([rules.prepare_ogm_data.output.done,
                                f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/data/{{anonymised}}.bedpe",
                                f"{resultsdir}/Patients/{{anonymised}}/OGMdata/check_svs_done.txt"
                                ])

        elif config['file_types']['SVs'] == "bedpe":
            snakefiles_to_include.append("rules/2.1_Individualanalysis_SVs.smk")
            all_targets.extend([f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/results/SVs/MatrixGenerator/",
                                f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/results/SVs/Extractor/"])

        else:
            raise ValueError(f"Error in config file_types SVs: {config['file_types']['SVs']}. The options are: smap or bedpe. Please check your config file (configpulpo.yaml) and try it again.")


    elif config['analysis']['analysis_type'] == "CNVs":
        if config['file_types']['CNVs'] == "csv" or config['file_types']['CNVs'] == "txt":
            snakefiles_to_include.append("rules/1.2_Preprocessing_CNVs.smk")
            all_targets.extend([rules.prepare_ogm_data.output.done,
                                f"{resultsdir}/Patients/{{anonymised}}/OGMdata/check_cnvs_done.txt"
                                f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/data/SigProfilerCNVdf.tsv"])
            snakefiles_to_include.append("rules/2.2_Individualanalysis_CNVs.smk")
            all_targets.extend([
                f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/results/CNVs/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
                f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/results/CNVs/Extractor/"
            ])

        elif config['file_types']['CNVs'] == "bed":
            snakefiles_to_include.append("rules/2.2_Individualanalysis_CNVs.smk")

            all_targets.extend([
                f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/results/CNVs/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
                f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/results/CNVs/Extractor/"
            ])

        else:
            raise ValueError(f"Error in {config['file_types']['CNVs']}. The options for CNVs file extensions are: csv, txt or bed. Please check your configfile (default: configpulpo.yml) and try it again.")

    elif config['analysis']['analysis_type'] == "SVs_and_CNVs":

        if config['file_types']['SVs'] == "smap" and config['file_types']['CNVs'] == "csv" or config['file_types'][
            'CNVs'] == "txt":
            snakefiles_to_include.append("rules/1.1_Preprocessing_SVs.smk")
            all_targets.extend([rules.prepare_ogm_data.output.done,
                                f"{logsdir}/DATA/descompressOGM/succesfulldescompresion.txt",
                                f"{resultsdir}/DATA/Patients/{{anonymised}}/OGMdata/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/Check/check_svs_done.txt",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/ProcessData/{{anonymised}}.bedpe",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/data/SigProfilerSVdf.bedpe"
                                ])
            snakefiles_to_include.append("rules/2.1_Individualanalysis_SVs.smk")
            all_targets.extend([f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.SV32.matrix.tsv",
                                f"{logsdir}/SVs/Patients/{{anonymised}}/SigProfiler/sigprofilermatrix.log"
                                ])

            snakefiles_to_include.append("rules/1.2_Preprocessing_CNVs.smk")
            all_targets.extend([f"{logsdir}/DATA/descompressOGM/succesfulldescompresion.txt",
                                f"{resultsdir}/CNVs/Patients/{{anonymised}}/Check/check_cnvs_done.txt",
                                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/data/SigProfilerCNVdf.tsv",
                                f"{logsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/sigprofilercnvmatrixgenerator.log",
                                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv"
                                ])

            snakefiles_to_include.append("rules/2.2_Individualanalysis_CNVs.smk")
            all_targets.extend([
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/"
            ])


        elif config['file_types']['SVs'] == "bedpe" and config['file_types']['CNVs'] == "bed":
            snakefiles_to_include.append("rules/2.1_Individualanalysis_SVs.smk")
            all_targets.extend([f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/",
                                f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.SV32.matrix.tsv",
                                f"{logsdir}/SVs/Patients/{{anonymised}}/SigProfiler/sigprofilermatrix.log"
                                ])

            snakefiles_to_include.append("rules/2.2_Individualanalysis_CNVs.smk")
            all_targets.extend([
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
                f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/"
            ])

        else:
            raise ValueError(f"Error in config file_types CNVs: {config['file_types']['CNVs']} or SVs {config['file_types']['SVs']}. The options are for CNVs are: csv,txt or bed and for SVs: smap or bedpe. Please check your config file (configpulpo.yaml) and try it again.")

    else:
        raise ValueError(f"Error in config analysis_type: {config['analysis']['analysis_type']}. The options are: SVs, CNVs or SVs_and_CNVs.")

else:
    raise ValueError(f"Error in config analysis_type: {config['analysis']['run_cohort_analysis']}. The options are: TRUE or FALSE. Please check your answer and try it again.")

################################################################################################################################################################################
for snakefile in snakefiles_to_include:
    include: snakefile
################################################################################################################################################################################
#PULPO ANIMATION
import subprocess
import time

# Hook to be executed at the start of Snakemake
onstart:
    animation_process = subprocess.Popen(["python", "animate_pulpo.py", "start"])
    time.sleep(3)  # Animation runs for 3 seconds only
    animation_process.terminate()

# Hook to be executed if Snakemake ends successfully
onsuccess:
    subprocess.run(["python", "animate_pulpo.py", "success"])

# Hook to be executed if Snakemake fails
onerror:
    subprocess.run(["python", "animate_pulpo.py", "error"])


################################################################################################################################################################################

rule all:
    input:
        expand(all_targets,anonymised=sample_table['anonymised'], allow_missing=True)


rule descompressOGM:
    input:
        ogmdirectory = config['input']['bionanodata'],
        workdirectory = f"{workdirectory}",
        samplesfile = config['input']['samples']
    output:
       # done = f"{logsdir}/DATA/descompressOGM/succesfulldescompresion.txt",
        OGM = directory(expand(f"{resultsdir}/DATA/Patients/{{anonymised}}/OGMdata",anonymised = sample_table['anonymised']))

    params:
        script = f"{config['directories']['scriptsdir']}/1.0_DESCOMPRESSOGM.R"
    log:
        logfile = f"{logsdir}/DATA/descompressOGM/descompress.log",
        done = f"{logsdir}/DATA/descompressOGM/succesfulldescompresion.txt",

    shell:
        """
        Rscript {params.script} {input.ogmdirectory} {input.workdirectory} {input.samplesfile} &> {log.logfile} || true
        touch {log.done}
        """

