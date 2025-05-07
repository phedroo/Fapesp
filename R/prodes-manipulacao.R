# PRODES

# Carregando biblioteca
library(raster) # Ler dados GeoTIFF
library(geobr)
library(dplyr)
library(sf)
library(terra)

# Carregando base de dados Raster
dados <- raster("data-raw/desmat_prodes/prodes_br_2023.tif")

dados2 <- rast("data-raw/desmat_prodes/prodes_br_2023.tif") # Verificando
# class(dados)

# Verificando metadados
plot(dados2)

# Limites dos estados de interesse
estados <- read_state(year = 2020, code_state = "all", showProgress = FALSE) |> 
  filter(abbrev_state %in% c("MT", "MS", "GO"))

# Converter para o mesmo sistema de coordenadas do raster
estados <- st_transform(estados, crs(dados2))

# Recorte do raster para a região de interesse
recorte <- crop(dados2, estados)

# Visualizar
plot(recorte)
plot(vect(estados), add = TRUE, border = "red", lwd = 2)



# Transformar dados tif em dados editáveis (ainda n feito)
# install.packages(c("terra", "sf", "dplyr", "ggplot2"))
library(terra)
library(sf)
library(dplyr)
library(ggplot2)

# Converter classes específicas para polígonos vetoriais
# Exemplo para área desmatada (valor 2 no PRODES):
desmatamento <- as.polygons(recorte == 2) %>% 
  st_as_sf() %>% 
  filter(layer == 100)  # Filtrar apenas onde a condição é verdadeira

# Simplificar geometria para reduzir tamanho do arquivo
desmatamento_simplificado <- st_simplify(desmatamento, dTolerance = 0.001)
