# Solicitacao de dados AppEEARS por API

# <https://appeears.earthdatacloud.nasa.gov/api/?r#task-object>

library(httr)
library(jsonlite)

# Login
secret <- base64_enc(paste("usuario", "senha", sep = ":"))
response <- POST("https://appeears.earthdatacloud.nasa.gov/api/login", 
                 add_headers("Authorization" = paste("Basic", gsub("\n", "", secret)),
                             "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"), 
                 body = "grant_type=client_credentials")
token_response <- prettify(toJSON(content(response), auto_unbox = TRUE))
token_response

# Defina seu token de autenticação 
# token <- paste("Bearer", fromJSON(token_response)$token)

# Defina seu token de autenticação manualmente (gerado em token_response), em caso de erro
token <- "seu_token" # Substitua pelo seu token

# Sair (fechar token, se necessário)
# response <- POST("https://appeears.earthdatacloud.nasa.gov/api/logout",
#                  add_headers(Authorization = token,
#                              "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"),
#                  body = "grant_type=client_credentials")
# response$status_code

# Parâmetros para requisição
request_body <- list(
  task_name = "MT MS GO MODIS",
  task_type = "area",
  params = list(
    layers = list( # Sensor MODIS TERRA
      list(product = "MOD13Q1.061", layer = "_250m_16_days_NDVI"),
      list(product = "MOD13Q1.061", layer = "_250m_16_days_EVI"),
      list(product = "MOD15A2H.061", layer = "Fpar_500m"), # PAR
      list(product = "MOD15A2H.061", layer = "Lai_500m"), # IAF 
      list(product = "MOD16A2.061", layer = "ET_500m") # Evapotranspiração total
    ),
    dates = list(
      list(
        startDate = "01-01-2015", # Formato correto MM-DD-YYYY
        endDate = "01-01-2024"
      )
    ),
    recurring = FALSE,
    output = list(
      format = list(
        type = "netcdf4"
      ),
      projection = "native"
    ),
    geo = list(
      type = "FeatureCollection",
      features = list(
        list(
          type = "Feature",
          properties = list(),
          geometry = list(
            type = "Polygon",
            coordinates = list(
              list(
                c(-62, -7), # Canto superior esquerdo
                c(-62, -25), # Canto inferior esquerdo
                c(-45, -25), # Canto inferior direito
                c(-45, -7), # Canto superior direito
                c(-62, -7)  # Fechar o polígono
              )
            )
          )
        )
      )
    )
  )
)

# Converter para JSON corretamente
request_json <- toJSON(request_body, auto_unbox = TRUE, pretty = TRUE)

# Enviar a requisição
response <- POST(
  url = "https://appeears.earthdatacloud.nasa.gov/api/task",
  body = request_json,
  add_headers(Authorization = paste("Bearer", token), "Content-Type" = "application/json")
)

# Verificar a resposta
response_content <- content(response, "text", encoding = "UTF-8") |> fromJSON()
print(response_content)


# Monitorar status da requisição 
task_id <- "seu-task_id"  # Substitua pelo task_id retornado na resposta anterior

status_response <- GET(
  url = paste0("https://appeears.earthdatacloud.nasa.gov/api/task/", task_id),
  add_headers(Authorization = paste("Bearer", token))
)

# Verificar o status
content(status_response, "text") |> fromJSON()


# Baixar os dados no formato netcdf4
# Para isso, aguardar status "completed" da requisição. Verifique:

token <- paste("Bearer", fromJSON(token_response)$token)

response <- GET(paste("https://appeears.earthdatacloud.nasa.gov/api/task/", task_id, sep = ""), add_headers(Authorization = token))
task_response <- prettify(toJSON(content(response), auto_unbox = TRUE))
task_response

# Download 
# (Realizado diretamente pelo site, informado no e-mail recebido)
# <https://appeears.earthdatacloud.nasa.gov>

# OU:
# Substitua "URL_DO_ARQUIVO" pela URL do arquivo NetCDF retornada na resposta anterior
download_url <- "URL_DO_ARQUIVO"
download.file(download_url, "modis_brasil_central.nc", mode = "wb")

  