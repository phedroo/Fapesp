states <- geobr::read_state(year = 2020, showProgress = FALSE) #Brazilian states shp

# ----------------------------------------------------------------------------

# Climate TRACE

biomes <- geobr::read_biomes(showProgress = FALSE) #brazilian biomes shp
conservation <- geobr::read_conservation_units(showProgress = FALSE) #brazilian conservation units shp
indigenous <- geobr::read_indigenous_land(showProgress = FALSE) #brazilian indigeous land shp

# Climate TRACE

get_geobr_pol <- function(i) {
  states$geom |> purrr::pluck(i) |> as.matrix()
}

get_geobr_biomes_pol <- function(i) {
  biomes$geom |> purrr::pluck(i) |> as.matrix()
}

get_geobr_conservation_pol <- function(i) {
  conservation$geom |> purrr::pluck(i) |> as.matrix()
}

get_geobr_indigenous_pol <- function(i) {
  indigenous$geom |> purrr::pluck(i) |> as.matrix()
}


def_pol <- function(x, y, pol){
  as.logical(sp::point.in.polygon(point.x = x,
                                  point.y = y,
                                  pol.x = pol[,1],
                                  pol.y = pol[,2]))
}

###
names_biomes <- biomes |>
  filter(name_biome!='Sistema Costeiro') |>
  pull(name_biome)

list_pol_biomes <- map(1:6, get_geobr_biomes_pol)
names(list_pol_biomes) <- names_biomes

# Funções Climate TRACE (usadas em faxina-metadados.R)
get_geobr_biomes <- function(x,y){
  x <- as.vector(x[1])
  y <- as.vector(y[1])
  resul <- "Other"
  lgv <- FALSE
  for(i in 1:6){
    lgv <- def_pol(x,y,list_pol_biomes[[i]])
    if(lgv){
      resul <- names(list_pol_biomes[i])
    }else{
      resul <- resul
    }
  }
  return(as.vector(resul))
}

###
abbrev_states <- states$abbrev_state
list_pol <- map(1:27, get_geobr_pol)
names(list_pol) <- abbrev_states

get_geobr_state <- function(x,y){
  x <- as.vector(x[1])
  y <- as.vector(y[1])
  resul <- "Other"
  lgv <- FALSE
  for(i in 1:27){
    lgv <- def_pol(x,y,list_pol[[i]])
    if(lgv){
      resul <- names(list_pol[i])
    }else{
      resul <- resul
    }
  }
  return(as.vector(resul))
}

###
list_pol_conservation <- map(1:1934, get_geobr_conservation_pol)
list_pol_indigenous <- map(1:615, get_geobr_indigenous_pol)
names(list_pol_biomes) <- names_biomes

get_geobr_conservation <- function(x,y){
  x <- as.vector(x[1])
  y <- as.vector(y[1])
  lgv <- FALSE
  for(i in 1:1934){
    lgv <- def_pol(x,y,list_pol_conservation[[i]])
    if(lgv) break
  }
  return(lgv)
}

###
get_geobr_indigenous <- function(x,y){
  x <- as.vector(x[1])
  y <- as.vector(y[1])
  lgv <- FALSE
  for(i in 1:615){
    lgv <- def_pol(x,y,list_pol_indigenous[[i]])
    if(lgv) break
  }
  return(lgv)
}


conservation$geom %>% tibble() #1,934
indigenous$geom %>% tibble() #615


### Função para o download dos dados do BR no CT
download_arquivo <- function(url, dir){
  download.file(url, dir)
  return(dir)
}
# ----------------------------------------------------------------------------

# Função para leitura de arquivos
my_file_read <- function(sector_name){
  read.csv(sector_name) %>%
    select(!starts_with("other")) %>%
    mutate(directory = sector_name)
}

# ----------------------------------------------------------------------------

### Download dos dados NASA power

## Glossário de parâmetros/variáveis nasapower e mais informações: 
## <https://power.larc.nasa.gov/beta/parameters/>

## Precipitação Corrigida (mm, PRECTOTCORR)
## Irradiância solar de onda curta na superfície de todo o céu (W m−2 dia−1, no projeto: MJ m-2 dia-1. All Sky Surface Shortwave Downward Irradiance) 
## Temperatura média do ar (ºC, Temperature at 2 Meters, T2M)
## Umidade relativa a 2 m (%, Relative Humidity at 2 Meters, RH2M)
## Velocidade do vento a 2 m (m/s, WS2M)
## Pressão de superfície (Hectopascal (hPa), PS)

power_data_download <- function(lon,lat, startdate, enddate){
  df <- nasapower::get_power(
    community = 'ag',
    lonlat = c(lon,lat),
    pars = c('ALLSKY_SFC_SW_DWN','T2M','PRECTOTCORR', 'RH2M'), #sigla das variáveis
    dates = c(startdate,enddate),
    temporal_api = 'daily'
  )
  write.csv(df, paste0('data-raw/nasa_power/tpruvp',lon,'_',lat,'.csv'))
}

# , 'WS2M', 'PS'

### Função para download e extração dados oco2

## https://github.com/lm-costa/curso-gp-01-aquisicao/blob/master/R/my-functions.R

#' Função utilizada para extração de colunas
#' específicas de arquivo ncdf4 para xco2
my_ncdf4_extractor <- function(ncdf4_file){
  data_frame_name <- ncdf4::nc_open(ncdf4_file)
  if(data_frame_name$ndims!=0){
    dft <- data.frame(
      "longitude"=ncdf4::ncvar_get(data_frame_name,varid="longitude"),
      "latitude"=ncdf4::ncvar_get(data_frame_name,varid="latitude"),
      "time"=ncdf4::ncvar_get(data_frame_name,varid="time"),
      "xco2"=ncdf4::ncvar_get(data_frame_name,varid="xco2"),
      "xco2_quality_flag"=ncdf4::ncvar_get(data_frame_name,varid="xco2_quality_flag"),
      "xco2_incerteza"=ncdf4::ncvar_get(data_frame_name,varid="xco2_uncertainty")
    ) |>
      dplyr::filter(xco2_quality_flag==0) |>
      tibble::as_tibble()
  }
  ncdf4::nc_close(data_frame_name)
  return(dft)
}

#' Função utilizada para downloads
my_ncdf4_download <- function(url_unique,
                              user="input your user",
                              password="input your password"){
  if(is.character(user)==TRUE & is.character(password)==TRUE){
    n_split <- length(
      stringr::str_split(url_unique,
                         "/",
                         simplify=TRUE))
    filenames_nc <- stringr::str_split(url_unique,
                                       "/",
                                       simplify = TRUE)[,n_split]
    repeat{
      dw <- try(download.file(url_unique,
                              paste0("data-raw/",filenames_nc),
                              method="wget",
                              extra= c(paste0("--user=", user,
                                              " --password ",
                                              password))
      ))
      if(!(inherits(dw,"try-error")))
        break
    }
  }else{
    print("seu usuário ou senha não é uma string")
  }
}

# Função utilizada para extração de colunas
# específicas de arquivo ncdf4 para xco2
my_ncdf4_extractor <- function(ncdf4_file){
  data_frame_name <- ncdf4::nc_open(ncdf4_file)
  if(data_frame_name$ndims!=0){
    dft <- data.frame(
      "longitude"=ncdf4::ncvar_get(data_frame_name,varid="longitude"),
      "latitude"=ncdf4::ncvar_get(data_frame_name,varid="latitude"),
      "time"=ncdf4::ncvar_get(data_frame_name,varid="time"),
      "xco2"=ncdf4::ncvar_get(data_frame_name,varid="xco2"),
      "xco2_quality_flag"=ncdf4::ncvar_get(data_frame_name,varid="xco2_quality_flag"),
      "xco2_incerteza"=ncdf4::ncvar_get(data_frame_name,varid="xco2_uncertainty")
    ) |>
      dplyr::filter(xco2_quality_flag==0) |>
      dplyr::filter(longitude < -30,longitude > -75,
                    latitude < 7, latitude > -35) |> 
      tibble::as_tibble()
  }
  ncdf4::nc_close(data_frame_name)
  return(dft)
}

# Função utilizada para downloads
my_ncdf4_download <- function(url_unique,
                              user="input your user",
                              password="input your password"){
  if(is.character(user)==TRUE & is.character(password)==TRUE){
    n_split <- length(
      stringr::str_split(url_unique,
                         "/",
                         simplify=TRUE))
    filenames_nc <- stringr::str_split(url_unique,
                                       "/",
                                       simplify = TRUE)[,n_split]
    repeat{
      dw <- try(download.file(url_unique,
                              paste0("data-raw/",filenames_nc),
                              method="wget",
                              extra= c(paste0("--user=", user,
                                              " --password ",
                                              password))
      ))
      if(!(inherits(dw,"try-error")))
        break
    }
  }else{
    print("seu usuário ou senha não é uma string")
  }
}
