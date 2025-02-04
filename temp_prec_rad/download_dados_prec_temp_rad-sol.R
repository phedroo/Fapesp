library(tidyverse)
library(dplyr)
library(geobr)
library(nasapower)
library(sf)
source('r/my-function.R')

# Lendo os estados brasileiros pelo pacote geobr

estados_br <- geobr::read_state(year = 2020, showProgress = FALSE)

# Filtrando estados de interesse (MS, MT, GO + DF)

estados <- estados_br |> filter(name_region == 'Centro Oeste')

# Visualizar

print(estados)

# Extraindo latitude e longitude dos estados
df_coords <- estados %>%
  st_cast("MULTIPOLYGON") %>% 
  st_cast("POLYGON") %>%       
  st_cast("POINT") %>%         
  mutate(lon = st_coordinates(.)[,1],  # Extrai longitude
         lat = st_coordinates(.)[,2])  # Extrai latitude

# Gerando banco de dados com os dados extraídos

readr::write_csv(df_coords, 'temp_prec_rad/estados_coords.csv')

# Carregar o banco de dados de coordenadas

df <- read.csv('temp_prec_rad/estados_coords.csv') |> select(lon,lat)


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


# readr::write_rds(df,'precipitation/data/nasa_power_data.rds')