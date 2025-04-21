# Ler arquivos .csv do appeears

# *os arquivos foram requisitados em 4 etapas:
# Após extraidas as coordenadas do Climate TRACE (cerca de 1150),
# foram solicitadas as primeiras
# 999 (requisição do appeears não aceita mais que 1000),
# 1. Solicitadas 999 para ET
# 2. Solicitadas 999 para Fpar e Lai
# 3. Solicitadas 999 para EVI e NDVI (único arquivo csv)
# 4. Solicitadas as coordenadas restantes para todas as camadas anteriores (único arquivo csv)

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
