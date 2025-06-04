<img src="./PULPOlogo.png" width="220" align="right">
<br><br><br>
<br><br><br>
<br><br><br>


# PULPO: Pipeline of understanding large-scale patterns of oncogenomic signatures

###### Implemented by: 
***Marta Portasany-Rodríguez***

*Gonzalo Soria-Alcaide*

*Jorge García-Martínez*

## Introduction
<img src="./.figs/GraphicalAbstractPULPO (1).png" align="right" width="500"/>
<br clear="left"/>

PULPO is a Snakemake-based pipeline for analyzing structural variants (SVs) and copy number variations (CNVs) from Optical Genome Mapping (OGM) data.

## Table of Contents

1. [Installation](#installation)  
2. [Configuration](#configuration)  
   - [configpulpo.yaml](#configpulpoyaml)  
      - [Input Files and Directories](#1-input-files-and-directories)  
      - [Directory Paths](#2-directory-paths)  
      - [Analysis Configuration](#3-analysis-configuration)  
      - [File Type Specification](#4-file-type-specification)  
      - [BionanoAccess Software Version](#5-bionanoaccess-software-version)  
3. [Usage](#usage)  
   - [Running specific steps](#running-specific-steps)  
   - [Main rules](#main-rules)  
   - [Error handling and debugging](#error-handling-and-debugging)  
4. [Repository structure](#repository-structure)  
5. [Contact](#contact)  
## Installation

To run PULPO, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/OncologyHNJ/PULPO.git
   cd PULPO
   ```

2. **Install Conda and Snakemake:**
   If you don’t have Conda installed, you can download Miniconda from [here](https://docs.conda.io/en/latest/miniconda.html).  
   Then, install Snakemake:
   ```bash
   conda install -c conda-forge -c bioconda snakemake
   ```

3. **Create and activate the PULPO Conda environment with the required dependencies:**
   ```bash
   cd path/to/PULPO/config
   conda env create -f PULPO.yml
   conda activate PULPO
   ```

## Configuration

The pipeline uses two configuration files located in the `/config/` folder:

- **`PULPO.yml`**: Configuration file for creating the Conda environment where the pipeline will be executed.  
- **`configpulpo.yaml`**: The main configuration file of the pipeline. Here, you can select the type of analysis or a combination of them.

---

### `configpulpo.yaml`

This configuration file defines key settings for running the PULPO pipeline, including input files, directories, analysis types, and software versions.

   #### 1. Input Files and Directories
- **`input.bionanodata`**: Directory containing raw Optical Genome Mapping (OGM) data folders.  
- **`input.samples`**: Path to a TSV file listing sample names and their corresponding anonymized names.  

   #### 2. Directory Paths
- **`directories.workdirectory`**: Working directory where all pipeline outputs (results, logs, intermediate files) will be stored.  
- **`directories.pythonenvdir`**: Path to the Python 3.10 executable within the Conda environment used by PULPO.  
  - If the pipeline setup was done correctly, this path should not require modification.  
  - In case of issues, manually specify the correct Python 3.10 path.  
- **`directories.scriptsdir`**: Directory where the pipeline scripts are located.  
  - After cloning the repository, scripts will be found under `/path/to/repository/PULPO/scripts`.  

   #### 3. Analysis Configuration
- **`analysis.analysis_type`**: Defines the type of analysis to be performed. Options include:  
  - `"SVs"` → Structural Variants analysis  
  - `"CNVs"` → Copy Number Variants analysis  
  - `"SVs_and_CNVs"` → Both SVs and CNVs analysis  
- **`analysis.run_cohort_analysis`**:  
  - `TRUE` → Runs a cohort analysis (multiple samples together).  
  - `FALSE` → Performs individual sample analysis only.  

   #### 4. File Type Specification
- **`file_types.CNVs`**: Format of the CNV input files. Options: `"bed"`, `"txt"`, or `"csv"`.  
- **`file_types.SVs`**: Format of the SV input files. Options: `"bedpe"` or `"smap"`.  

   #### 5. BionanoAccess Software Version
- **`BionanoAccess.version`**: Specifies the BionanoAccess software version.  
  - Supported versions: `"1.6.1"` or `"1.8.1"`.  

## Usage

To run the pipeline in standard mode:
```bash
snakemake --cores <n>
```
Where `<n>` is the number of threads you want to use.

If you want to run PULPO on a cluster:
```bash
snakemake --profile cluster
```

### Running specific steps
You can execute specific pipeline steps with:
```bash
snakemake <rule> --cores <n>
```
For example, to run only SV preprocessing:
```bash
snakemake 1.1_Preprocessing_SVs --cores 4
```

### Main rules
PULPO is structured into several stages:

1. **Data preprocessing:**
   - `1.1_Preprocessing_SVs`
   - `1.2_Preprocessing_CNVs`
2. **Individual sample analysis:**
   - `2.1_Individualanalysis_SVs`
   - `2.2_Individualanalysis_CNVs`
3. **Cohort analysis:**
   - `3.1_Cohortanalysis_SVs`
   - `3.2_Cohortanalysis_CNVs`

### Error handling and debugging
To view detailed logs of an execution:
```bash
snakemake --cores <n> --printshellcmds --keep-going --rerun-incomplete
```

## Repository structure

- `Snakefile` - Main pipeline file.
- `rules/` - Snakemake rules organized by analysis stages.
- `scripts/` - Additional scripts for data processing.
- `config/` - Configuration files.

## Contact

If you have any questions, issues or bug reports open an issue on GitHub or contact us in bioinformaticafibhunj@gmail.com.


