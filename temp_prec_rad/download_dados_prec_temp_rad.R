library(tidyverse)
library(geobr)
library(nasapower)
library(sf)
source('r/my-function.R')

# Lendo os estados brasileiros pelo pacote geobr

estados_br <- geobr::read_state(year = 2020, showProgress = FALSE)

# Filtrando estados de interesse (Centro-Oeste)

estados <- estados_br |> filter(name_region == 'Centro Oeste')

# Unindo polígono dos estados

pol_estados <- estados |> st_union()

# Criar grid de pontos
grid_pontos <- st_make_grid(pol_estados, 
                            cellsize = 0.5, 
                            what = "centers") |> 
  st_as_sf()

# class(grid_pontos)
# pontos_sf <- st_as_sf(grid_pontos, wkt = "x", crs = 4326)

# Filtrar pontos dentro do Centro-Oeste
pontos_filtro <- grid_pontos[st_within(grid_pontos, 
                                       pol_estados, 
                                       sparse = FALSE), ]

# Extrair coordenadas de cada ponto no grid
coord <- st_coordinates(pontos_filtro)

# Gerando df com latitude e longitude
df_coords <- data.frame(lon = coord[,1], lat = coord[,2])

# Conferindo pontos
ggplot() +
    geom_sf(data = pol_estados, fill = "black", color = "black") +
    geom_point(data = df_coords, aes(x = lon, y = lat), color = "red", size = 1.5) + 
    theme_bw()

# Baixar dados nasa power
for (i in 1:nrow(df_coords)) {
  repeat {
    dw <- try(
      power_data_download(df_coords$lon[i], df_coords$lat[i],
                          startdate = '2015-01-01',
                          enddate = '2024-01-01')
    )
    if (!(inherits(dw, "try-error")))
      break
  }
}

# Criar df com os arquivos baixados
files_names <- list.files('data-raw/nasa_power', full.names = TRUE)

df_final <- map_dfr(files_names, read.csv)

# Salvar o banco de dados final
readr::write_csv(df_final, 'data/dados_nasapower.csv')

# ------------------- RODAR ATÉ AQUI ----------------------------------

#######################

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

###
# Carregar pacotes necessários
library(tidyverse)
library(sf)
library(geobr)
library(nasapower)

# Ler os estados do Brasil e filtrar apenas os do Centro-Oeste
estados_br <- geobr::read_state(year = 2020, showProgress = FALSE)
centro_oeste <- estados_br |> filter(name_region == 'Centro Oeste')

# Criar um único polígono que representa a região
poligono_centro_oeste <- centro_oeste |> st_union()

# Criar grid de pontos **somente dentro do Centro-Oeste**
grid_pontos <- st_make_grid(poligono_centro_oeste, cellsize = 0.5, what = "centers") |> 
  st_as_sf()

# Filtrar apenas os pontos dentro do polígono
pontos_filtro <- grid_pontos[st_within(grid_pontos, poligono_centro_oeste, sparse = FALSE), ]

# Extrair coordenadas corretamente

