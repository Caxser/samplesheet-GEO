# samplesheet-GEO
semi-automatic script used for create samplesheet to analyze methylation array from IDAT files, downloaded from GEO
# Authors: Gonzalez, C.P. & Flores, A. (2025)

Este script está pensado para semi automatizar la descarga de los archivos IDAT y la creacion de la samplesheet
necesaria para el análisis de metilación diferencial (usando minfi-Bioconductor). 
Está pensado para la descarga directa desde GEO, por lo que se debe tener el accesion number necesario para
la descarga. Además, se debe comprobar de que en dicho depósito se encuentren los IDAT files.
El samplesheet se genera con informacion de metadatos, por lo que es necesario conocer de antemano el origen de los datos.

El script también cuenta con comentarios dentro del codigo para posibles adaptaciones.
