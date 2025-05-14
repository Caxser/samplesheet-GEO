# Cargar librerías
library(GEOquery)
library(minfi)
library(dplyr)
library(tidyr)
library(R.utils)

# Parámetros
geo_id <- "GSEXXXXXX"  # Cambia por el GSE que necesites
output_dir <- "data2" # Directorio por defecto, cambiar si es necesario

# Crear carpeta si no existe
dir.create(output_dir, showWarnings = FALSE)

# 1. Descargar metadatos de GEO
gset <- getGEO(geo_id, GSEMatrix = TRUE, destdir = output_dir)
pheno <- as.data.frame(pData(gset[[1]]))  # Convertir para usar dplyr
pheno$GSM <- rownames(pheno)

# En caso de que falle la descarga, se puede descargar manualmente el archivo series matrix
# este se coloca dentro del directorio data2 (o el seleccionado) y se ejecuta:
# local_soft <- "data2/GSEXXXXXX_series_matrix.txt.gz" #RECUERDA CAMBIAR AQUI TAMBIEN EL GSE (ACCESION NUMBRE)
# gset <- GEOquery::getGEO(filename = local_soft)

# En estos casos, es probable que se requiera usar:
# pheno <- as.data.frame(pData(gset)) 


# 2. Descargar archivos suplementarios (IDATs)
getGEOSuppFiles(geo_id, baseDir = output_dir)

# Al igual que el anterior, en caso de fallar, se puede hacer manual y colocar
# los datos en la carpeta data2

#_________Importante______________#
# El directorio siempre es el mismo, por lo que se debe asegurar
# de estar colocando los archivos en el directorio adecuado 
# en caso de estar descargandolos de manera manual

# 3. Descomprimir archivo tar
tar_file <- list.files(file.path(output_dir, geo_id), pattern = ".tar$", full.names = TRUE)
untar(tar_file, exdir = file.path(output_dir, "idat_files")) 
# el nombre de la carpeta de los idat es idat_files, se puede cambiar
# pero verifique que sea la misma cada que se llama esa variable "idat_files"

# 4. Descomprimir todos los .idat.gz
idat_dir <- file.path(output_dir, "idat_files")
idat_gz <- list.files(idat_dir, pattern = "\\.idat\\.gz$", full.names = TRUE)
for (f in idat_gz) {
  gunzip(f, remove = FALSE, overwrite = TRUE)
}

# 5. Leer los IDAT con minfi
rgSet <- read.metharray.exp(base = idat_dir, verbose = TRUE)

# 6. Construir samplesheet desde los nombres de archivo IDAT
idat_files <- list.files(idat_dir, pattern = "idat$", full.names = FALSE)
basenames <- unique(sub("_(Red|Grn)\\.idat$", "", idat_files))

samplesheet <- data.frame(Basename = basenames) %>%
  separate(Basename, into = 
             c("GSM", "Sentrix_ID", "Sentrix_Position"), sep = "_") %>%
             #c("GSM", "index", "Sentrix_ID", "Sentrix_Position"), sep = "_") %>%
  mutate(Sample_Name = GSM)

#_______________Importante_______________
# En el comando anterior, el codigo comentado sirve como una opcion adicional
# en caso de que contengan in "Index" -revisa de manera manual al menos uno de
# los IDAT para conocer la estructura de sus nombres-
# Posiblemente, la mayoria funcione bien con el codigo tal como esta

# 7. Unir con metadatos GEO
# REVISA EL NOMBRE DE SAMPLESHEET Y PHENO
#Se puede cambiar el join_by por by si ambas columnas en pheno y samplesheet tienen el mismo nombre
samplesheet <- left_join(samplesheet, pheno, join_by( "GSM"== "geo_accession"))

# 8. Seleccionar columnas finales
# Ten en cuenta que las columnas pueden cambiar de nombre, así que se recomienda ver a pheno
# " View(pheno)" para conocer las columnas de interés
samplesheet_final <- samplesheet %>%
  select(GSM, Sample_Name, Sentrix_ID, Sentrix_Position, # Estas son la base del ID, no modificar
         sample_type = `tissue:ch1`, #Cambie por el nombre de columna interes
         diagnosis = `characteristics_ch1`, #Cambie por el nombre de columna interes
         disease_state = `pregestational obesity:ch1`, #Cambie por el nombre de columna interes
         sex = `offspring's sex:ch1`, #Cambie por el nombre de columna interes
         tissue = `tissue:ch1`) #Cambie por el nombre de columna interes

# Las columnas deben tener el nombre identico de pheno
# además, se pueden agregar más columnas solo siguiendo el siguiente patron:

# Nombre_columna = `nombre_columna_pheno`

# RECUERDA REVISAR QUE EXISTA COMA ENTRE CADA COLUMNA, pero no al final

# 9. Guardar como CSV
write.csv(samplesheet_final, "samplesheet-ori.csv", row.names = FALSE)

# El nombre entrecomillado puede cambiarse.
# Recordar que el archivo se creará en el working directory
# Usa "getwd()" para conocer cual es la ubicación
