# Extrair dados de latitude e longitude (coordenadas) da faxina Climate TRACE (CT)
# para posterior requisicao no site do APPEEARS

# Carregar biblioteca
# library(readr)
# 
# # Carregar base de dados
# data <- read_rds("data/emissions_sources.rds")
# 
# # Visualizar dados
# View(data) #completa
# glimpse(data) #resumida
# 
# # Manipular dados
# # Objetiva-se extrair 1 coordenada (lat, lon) de cada municipio do Brasil Central
# # pelo arquivo do CT tratado na faxina
# requisitar_appeears <- data |>
#   select(sigla_uf, city_ref, lat, lon) |>
#   # filter(sigla_uf == c("MT", "GO", "MS", "DF")) |>
#   select(lat, lon) |>
#   unique()
# 
# # Obter arquivo
# write_csv(requisitar_appeears, "data/requisicao_appeears.csv")



# Leitura arquivos .csv do appeears

# Carregar bibliotecas
library(tidyverse)
library(dplyr)

# Carregar dados
arquivos <- list.files("data-raw/appeears", pattern = ".csv", full.names = T)

# Compilar dados
appeears <- map_dfr(arquivos, read_csv)

# Selecinando camadas de interesse
# Renomeando colunas
# Extraindo ano das datas no formato YYYY-MM-DD
# Filtrando para nos anos que serão analisados
# Agrupando
# Fazendo a média das variáveis por ano
# Ordenando sequência dos anos
appeears <- appeears |> 
  select(Latitude, Longitude, Date, MOD15A2H_061_Lai_500m, MOD15A2H_061_Fpar_500m, 
         MOD13Q1_061__250m_16_days_EVI, MOD13Q1_061__250m_16_days_NDVI, 
         MOD16A2_061_ET_500m) |>
  rename(date = Date,
         lat = Latitude,
         lon = Longitude,
         lai = MOD15A2H_061_Lai_500m,
         fpar = MOD15A2H_061_Fpar_500m,
         evi = MOD13Q1_061__250m_16_days_EVI,
         ndvi = MOD13Q1_061__250m_16_days_NDVI,
         et = MOD16A2_061_ET_500m) |> 
  mutate(ano = year(date),
         mes = month(date),
         dia = day(date)) %>%
  filter(
    ano >= 2015 & ano <= 2023
  ) |> 
  group_by(lat, lon, ano, mes) %>%
  summarise(
    across(c(fpar, lai, evi, ndvi, et), 
           ~ mean(., na.rm = TRUE),
           .names = "media_{.col}"),
    n_observacoes = n(),
    .groups = 'drop'
  ) %>%
  arrange(lat, lon, ano)
# Observe que existem valores NA na coluna ET
# embora solicitado dados para o período de 01/01/2015 a 01/01/2024
# somente forneceram dados de 2021 a 2024

# Visualizar dados
glimpse(appeears)
# View(appeears)


br_country <- geobr::read_country(showProgress = FALSE)

br_country |> 
  ggplot()+
  geom_sf()+
  geom_point(
    data=appeears |> 
      filter(ano == 2017), 
      aes(lon,lat)
  )

appeears |> 
  filter(ano == 2017) |> 
  ggplot(aes(lon,lat)) +
  geom_point()

# Gerar arquivo com os dados
# write.csv(appeears, 'data/appeears.csv')



# Incorporar variáveis appeears na base de dados do Climate TRACE

# 1° Ler dados CT
ct <- read_rds('data/emissions_sources.rds')

# 2° Ler arquivo "appeears" para incorporação aos dados CT
appeears <- read.csv('data/appeears.csv') #ja lido (linha 35)

# 3° Incorporando bases
dados_incorporados <- full_join(ct, appeears, by = c("lat", "lon")) 
# full_join retorna todas as linahs de ambos os df
# left_join retorna linhas do df esquerda, (NA para não correspondência direita)
# right_join retorna linhas do df direita, (NA para não correspondência esquerda)
# inner_join retorna apenas linhas correspondentes

# 4° Baixar dados incorporados
write_rds(dados_incorporados, 'data/ct+appeears.rds')

# write.csv(dados_incorporados, 'data/ct+appeears.csv') # mais leve
