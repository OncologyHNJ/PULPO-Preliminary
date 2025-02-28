# PULPO

PULPO es un pipeline basado en Snakemake para el análisis de variantes estructurales (SVs) y copy number variations (CNVs) en datos de Optical Genome Mapping (OGM).

## Instalación

Para ejecutar PULPO, sigue los siguientes pasos:

1. **Clona el repositorio:**
   ```bash
   git clone https://github.com/tuusuario/PULPO.git
   cd PULPO
   ```

2. **Instala Conda y Snakemake:**
   Si aún no tienes Conda instalado, puedes descargar Miniconda desde [aquí](https://docs.conda.io/en/latest/miniconda.html).
   Luego, instala Snakemake:
   ```bash
   conda install -c conda-forge -c bioconda snakemake
   ```

3. **Crea y activa un entorno Conda con las dependencias necesarias:**
   ```bash
   conda env create -f environment.yaml
   conda activate pulpo_env
   ```

## Uso

Para ejecutar el pipeline en modo estándar:
```bash
snakemake --cores <n>
```
Donde `<n>` es el número de hilos que quieres usar.

Si deseas ejecutar PULPO en un clúster:
```bash
snakemake --profile cluster
```

### Ejecución por etapas
Puedes ejecutar etapas específicas de la pipeline con:
```bash
snakemake <regla> --cores <n>
```
Por ejemplo, para ejecutar solo el preprocesamiento de SVs:
```bash
snakemake 1.1_Preprocessing_SVs --cores 4
```

### Reglas principales
PULPO está estructurado en varias etapas:

1. **Preprocesamiento de datos:**
   - `1.1_Preprocessing_SVs`
   - `1.2_Preprocessing_CNVs`
2. **Análisis individual de muestras:**
   - `2.1_Individualanalysis_SVs`
   - `2.2_Individualanalysis_CNVs`
3. **Análisis de cohortes:**
   - `3.1_Cohortanalysis_SVs`
   - `3.2_Cohortanalysis_CNVs`

### Manejo de errores y depuración
Para ver los logs detallados de una ejecución:
```bash
snakemake --cores <n> --printshellcmds --keep-going --rerun-incomplete
```
## Estructura del repositorio

- `Snakefile` - Archivo principal del pipeline.
- `rules/` - Reglas de Snakemake organizadas por etapas del análisis.
- `scripts/` - Scripts adicionales para procesamiento de datos.
- `config/` - Archivos de configuración.

## Contacto
Si tienes dudas o problemas, abre un issue en GitHub o contacta a los desarrolladores.

