# PULPO

PULPO is a Snakemake-based pipeline for analyzing structural variants (SVs) and copy number variations (CNVs) in Optical Genome Mapping (OGM) data.

## Installation

To run PULPO, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/youruser/PULPO.git
   cd PULPO
   ```

2. **Install Conda and Snakemake:**
   If you don’t have Conda installed, you can download Miniconda from [here](https://docs.conda.io/en/latest/miniconda.html).  
   Then, install Snakemake:
   ```bash
   conda install -c conda-forge -c bioconda snakemake
   ```

3. **Create and activate a Conda environment with the required dependencies:**
   ```bash
   conda env create -f environment.yaml
   conda activate pulpo_env
   ```

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
