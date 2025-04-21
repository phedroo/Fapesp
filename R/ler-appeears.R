# Ler arquivos .csv do appeears

# Carregar biblioteca
library(tidyverse)

# Carregar dados
arquivos <- list.files("data-raw/appeears", pattern = ".csv", full.names = T)

# Combinar dados
appeears <- map_dfr(arquivos, read_csv)

# Selecinando camadas de interesse
appeears <- appeears |> 
  select(Latitude, Longitude, MOD15A2H_061_Lai_500m, MOD15A2H_061_Fpar_500m, 
         MOD13Q1_061__250m_16_days_EVI, MOD13Q1_061__250m_16_days_NDVI, 
         MOD16A2_061_ET_500m)

# Visualizar dados
glimpse(appeears)
View(appeears)

# Gerar arquivo com os dados
write.csv(appeears, 'data/appeears.csv')
