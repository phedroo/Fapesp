#Extrair dados de latitude e longitude da faxina CT

# Carregar bibliotecas
library(tidyverse)
library(readr)


# Carregar base de dados
data <- read_rds("data/emissions_sources.rds")

# Visualizar dados
View(data) #completa
glimpse(data) #resumida

# Manipular dados
# Objetiva-se extrair 1 coordenada (lat, lon) de cada municipio do Brasil Central
# pelo arquivo do CT tratado na faxina
Requisitar_appeears <- data |> 
  select(sigla_uf, city_ref, lat, lon) |> 
  filter(sigla_uf == c("MT", "GO", "MS", "DF")) |> 
  select(lat, lon) |> 
  unique()

# Obter arquivo
write_csv(Requisitar_appeears, "data/requisicao_appeears")
