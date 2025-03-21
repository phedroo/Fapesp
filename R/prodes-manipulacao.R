# PRODES

# Carregando biblioteca
library(raster) # Ler dados GeoTIFF
library(geobr)
library(sf)
library(terra)

# Carregando basse de dados Raster
dados <- raster("data-raw/desmatamento_prodes/prodes_brasil_2023.tif")
# class(dados)

# Verificando metadados
plot(dados)

# Limites dos estados de interesse
estados <- read_state(year = 2020, code_state = "all", showProgress = FALSE) |> 
  filter(abbrev_state %in% c("MT", "MS", "GO"))

# Converter para o mesmo sistema de coordenadas do raster
estados <- st_transform(estados, crs(dados))

# Recorte do raster para a região de interesse
recorte <- crop(dados, estados)

# Visualizar
plot(recorte)
plot(vect(estados), add = TRUE, border = "red", lwd = 2)
