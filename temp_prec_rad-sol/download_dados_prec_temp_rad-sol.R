# install.packages("tidyverse")
# install.packages("geobr")
# install.packages("nasapower")

library(tidyverse)
library(geobr)
library(nasapower)
# source('r/my-function.R')

## Filtrando estados de interesse pelas coordenadas limites

library(dplyr)

# Definir as coordenadas de interesse

## Coordenadas do MS
### longitude esquerda: -58.2
### latitude inferior: -24.1
### longitude direita: -50.90
### latitude superior: -17.17

# Coordenadas do MT
### longitude esquerda: -61.7
### latitude inferior: -18.13
### longitude direita: -50.17
### latitude superior:-7.3

# Coordenadas de GO
### longitude esquerda: -53.3
### latitude inferior: -19.55
### longitude direita: -45.91
### latitude superior: -12.4


# Carregar o banco de dados de coordenadas
df <- read.csv('temp_prec_rad-sol/brazil_coord.csv') 

# Definir os limites para vários estados
limites_estados <- data.frame(
  estado = c("Mato Grosso do Sul", "Mato Grosso", "Goias"),
  lat_min = c(-24.1, -18.13, -19.55),  # Limite inferior de latitude
  lat_max = c(-17.17, -7.3, -12.4),  # Limite superior de latitude
  lon_min = c(-58.2, -61.7, -53.3),  # Limite inferior de longitude
  lon_max = c(-50.90, -50.17, -45.91)   # Limite superior de longitude
)

# Filtrar os dados por estado
filtrar_por_estado <- function(df, estado, lat_min, lat_max, lon_min, lon_max) {
  df_filtrado <- df %>%
    filter(lat >= lat_min & lat <= lat_max &
             lon >= lon_min & lon <= lon_max)
  return(df_filtrado)
}

# Loop para filtrar os dados para cada estado
df_filtrado_total <- NULL
for (i in 1:nrow(limites_estados)) {
  estado <- limites_estados$estado[i]
  lat_min <- limites_estados$lat_min[i]
  lat_max <- limites_estados$lat_max[i]
  lon_min <- limites_estados$lon_min[i]
  lon_max <- limites_estados$lon_max[i] 
  
# Filtrar e concatenar os dados de cada estado
  df_estado <- filtrar_por_estado(df, estado, lat_min, lat_max, lon_min, lon_max)
  df_filtrado_total <- bind_rows(df_filtrado_total, df_estado)
}

# Visualizar os dados filtrados
head(df_filtrado_total)

##########################
df <- read.csv('temp_prec_rad-sol/brazil_coord.csv') |> select(lon,lat)


# download dados precipitação

for (i in 1:nrow(df)){
  repeat{
    dw <- try(
      power_data_download(df[i,1],df[i,2],
                          startdate='2015-01-01',
                          enddate = '2025-01-01')
    )
    if (!(inherits(dw,"try-error")))
      break
  }
}


### criação base de dados

files_names <- list.files('temp_prec_rad/data-raw/',full.names = T)
for (i in 1:length(files_names)){
  if(i ==1){
    df <- read.csv(files_names[i])
  }else{
    df_a <- read.csv(files_names[i])
    df <- rbind(df,df_a)
  }
}


readr::write_rds(df,'precipitation/data/nasa_power_data.rds')