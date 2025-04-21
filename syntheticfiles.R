# Cargar librerías necesarias
library(synthpop)

#SVs
# Paso 1: Leer el archivo SMAP real
# Asegúrate de que el archivo tenga la ruta correcta
archivo_real <- "/home/unidad2/Marta/TESIS/OGM+WES/syntheticPULPO/802.tsv"


# Leer el archivo .smap como data.frame
smap_real <- read.table(archivo_real)

# (Opcional) Verificar las primeras filas para asegurar que se cargó correctamente
head(smap_real)

# Número de archivos sintéticos a generar
n_archivos <- 10

# Bucle para generar y guardar archivos
for (i in 1:n_archivos) {
  set.seed(100 + i)  # Cambiá la semilla para obtener resultados distintos
  smap_sintetico <- syn(smap_real)$syn
  
  # Ruta de salida para cada archivo
  archivo_salida <- sprintf("/home/unidad2/Marta/TESIS/OGM+WES/syntheticPULPO/sinteticos/SVs/smap_sintetico_%02d.smap", i)
  
  # Guardar el archivo
  write.table(smap_sintetico, archivo_salida, sep = "\t", row.names = FALSE, quote = FALSE)
  
  cat("✅ Archivo guardado:", archivo_salida, "\n")
}


#CNVs
archivo_real_cnv <- "/home/unidad2/Marta/TESIS/OGM+WES/syntheticPULPO/Cells_821_-_Rare_Variant_Analysis_CNV_10_11_2021_5_31_17.csv"


cnv_real <-read.csv(archivo_real_cnv, header = TRUE)

head(cnv_real)



# Número de archivos sintéticos a generar
n_archivos <- 10

# Bucle para generar y guardar archivos
for (i in 1:n_archivos) {
  set.seed(100 + i)  # Cambiá la semilla para obtener resultados distintos
  cnv_sintetico <- syn(cnv_real)$syn
  
  # Ruta de salida para cada archivo
  archivo_salida <- sprintf("/home/unidad2/Marta/TESIS/OGM+WES/syntheticPULPO/sinteticos/CNVs/csv_sintetico_%02d.smap", i)
  
  # Guardar el archivo
  write.table(cnv_sintetico, archivo_salida, sep = "\t", row.names = FALSE, quote = FALSE)
  
  cat("✅ Archivo guardado:", archivo_salida, "\n")
}
