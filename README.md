
# Fapesp
¹
---
title: PROJETO FAPESP - Modelagem Computacional da Concentração 
Atmosférica de CO2 e CH4 no Brasil Central
author: "Pedro Henrique Marucio"
date: "2025-01-14"
output: html_document
---

## OBJETIVO

Analisar a variabilidade espaçotemporal das concentrações atmosféricas 
de CO2 e CH4 em áreas do Brasil Central, identificando fontes e 
possíveis sumidouros desses gases ao longo dos anos de 2015 a 
2023, bem como suas relações com índices vegetativos e 
climáticos, por meio de dados de GOSAT, OCO-2 e Climate TRACE.

## ORGANIZAÇÃO DO DOCUMENTO Rmd GERADO

```{r setup, include=FALSE}
knitr::opts_chunk$set(
	echo = TRUE,
	error = FALSE,
	message = FALSE,
	warning = FALSE
)

```
## CARREGANDO OS PACOTES E FUNÇÕES NECESSÁRIAS

```{r}
library(tidyverse)
library(dplyr)
library(nasapower)
library(geobr)
library(sf)
source('../R/my-function.R')
```

##### echo = T

*O código será mostrado no documento final.*

##### error = F, message = F, warning = F

*Erros, mensagens e avisos não aparecerão no documento final*

## FONTE DOS DADOS

### Relatórios Climate TRACE

Dados baixados para o Brasil, para todo o período (2015-2024), em 
CO2e 100 anos, no dia 15/01/2025.

Dados salvos na pasta data-raw ("climate-trace")

### Estação meteorológica

### Aquisição dos dados de focos de incêndio (NASA-FIRMS e INPE-BDQUEIMADAS)

#### NASA-FIRMS

Dados requisitados no link: 
<https://firms.modaps.eosdis.nasa.gov/download/list.php>

Atributos dos dados solicitados: Country: "Brasil", Fire source: "MODIS", 
from "01/01/2015" to "01/01/2025", ".csv".

Passo a Passo para requisição dos dados de focos de incêndio para o 
Brasil, no período de 01/01/2015 a 01/01/2025:

1° Acesse: <https://firms.modaps.eosdis.nasa.gov>;

2° Selecione "ARCHIVE DOWNLOAD";

3° Selecione "Create New Request" (certifique-se que esta logado);

4° Selecione os atributos dos dados requeridos para download;

5° Aguarde e-mail com os dados solicitados (~ 6 horas);

Dados salvos na pasta data-raw ("firms_nasa").

#### BDQUEIMADAS

Dados requisitados no link:
<https://terrabrasilis.dpi.inpe.br/queimadas/bdqueimadas/#exportar-dados>

Atributos dos dados solicitados:

América do Sul, Brasil, Todos os estados, Satélite de referência 
(Aqua/MODIS), todos os biomas, período de 01/01/2015 a 01/01/2025 
(período solicitado ano a ano, em razão do limite estabelecido pela 
plataforma), e-mail institucional, formato ".csv".

Dados salvos na pasta data-raw ("focos_deter_bdqueimadas").

#### DETER

##### BR

Dados de focos de fogo do período de 08/2018 a 01/2025 para o Brasil 
adquiridos no link: 
<https://terrabrasilis.dpi.inpe.br/app/dashboard/fires/biomes/aggregated/#> 
Dados salvos em .csv na pasta "data-raw/focos_deter" como "br-18-24"

Satélite referência - AQUA/MODIS

##### Estados BRCentral

Dados de focos de fogo ativo para os estados do Brasil Central 
(Goiás, MT e MS) desde 1998 a 21/01/2025 no link: 
<https://terrabrasilis.dpi.inpe.br/queimadas/situacao-atual/estatisticas/estatisticas_estados/>

Dados salvos em .csv na pasta "data-raw/focos_deter" como "brgo", "brmt" e "brms"

Satélite referência - AQUA/MODIS

## Produtos de mapeamento digital

### Desmatamento - INPE

#### PRODES

Dados baixados para o Brasil, para todo o período (31/07/2000-30/07/2023), no dia 16/01/2025.

Mais informações no link: <https://terrabrasilis.dpi.inpe.br/geonetwork/srv/eng/catalog.search#/metadata/fe02f2bf-2cc0-49d5-ab72-a3954f997408>

Dados salvos na pasta "data-raw/desmatamento_prodes".

## Variáveis climáticas, dados do nasapower 

### <https://power.larc.nasa.gov/>

### Temperatura (T2M), precipitação (PRECTOTCORR), radiação solar (ALLSKY) e umidade relativa a 2 m (RH2M)

Processamento dos dados por API

Dados diários para o período de 01/01/2015 a 01/01/2024, para a região do
Brasil Central (MS, MT e GO)

Código no script "download_dados_prec_temp_rad" e funções no "my_function"

```{r}
# df_nasa <- read_csv('../data/dados_nasapower.csv')
```

## Aquisição dados XCO2 e SIF do satélite OCO-2 (GESDISC)

Acesso no link: <https://disc.gsfc.nasa.gov>

### XCO2

Os dados de XCO2 foram obtidos do Earthdata (NASA), do site:   <https://disc.gsfc.nasa.gov/datasets/OCO2_L2_Lite_FP_11.2r/summary?keywords=OCO2>

"Explore..." \> "Data collections" \> digitar "OCO2" \> Selecionar "OCO-2 Level 2 bias-corrected XCO2 and other select fields from the full-physics retrieval aggregated as daily files, Retrospective processing V11.2r (OCO2_L2_Lite_FP 11.2r)"

Dados baixados para todo o Brasil, para o período de 01/01/2015 a 01/01/2024, em formato netCDF (nc)

Versão 11.2r

Resolução espacial dos dados: 2,25 km x 1,29 km 

Resolução temporal dos dados: 16 dias

DOI:10.5067/70K2B2W8MNGY

Código para download e extração obtido de: <https://github.com/lm-costa/curso-gp-01-aquisicao/tree/master>

### SIF

Os dados de SIF foram obtidos do Earthdata (NASA), do site: <https://disc.gsfc.nasa.gov/datasets/OCO2_L2_Lite_SIF_11r/summary?keywords=OCO2>

"Explore..." \> "Data collections" \> digitar "OCO2" \> OCO-2 Level 2 bias-corrected solar-induced fluorescence and other select fields from the IMAP-DOAS algorithm aggregated as daily files, Retrospective processing V11r (OCO2_L2_Lite_SIF)

Dados serão baixados para todo o Brasil, para o período de 01/01/2015 a 01/01/2024, em formato netCDF (nc)

Resolução espacial dos dados: 2,25 km x 1,29 km 

Resolução temporal dos dados: 16 dias


## Aquisição dos dados XCH4 do satélite GOSAT

Artigo referência: ATMOSPHERIC CONCENTRATIONS OF GREENHOUSE GASES (Luciano de Souza Maria).

Dados da coluna total de metano foram obtidos da University of
Leicester GOSAT Proxy XCH4, versão 9.0. 

Arquivo baixado: "CH4_GOS_OCPR_v9.0_final_nceo_2009_2021.tar.gz" 
(4,8gb), contendo dados da coluna total de metano do período de 23/04/2009 
a 31/12/2021, e extraídos para pasta "data-raw/gosat-xch4", em formato nc.

Site acessado: <https://data.ceda.ac.uk/neodc/gosat/data/ch4/nceov1.0/CH4_GOS_OCPR/>

O conjunto de dados GOSAT Proxy XCH4 v9.0 da University of Leicester contém 
fração molar de metano (XCH4) de ar seco com média de coluna gerada a partir 
de dados do Greenhouse Gas Observing Satellite (GOSAT) Nível 1B usando o 
esquema de recuperação Full-Physics da University of Leicester (UoL-FP) 
usando a abordagem de recuperação Proxy. Esses dados são uma 
atualização/extensão financiada pelo NCEO para a Iniciativa de Mudanças 
Climáticas da Agência Espacial Europeia (CCI) CH4_GOS_OCPR V7.0 e os 
conjuntos de dados Copernicus Climate Change Service (C3S) CH_4 v7.2. 
É um reprocessamento completo, com base em diferentes dados de radiância 
L1B subjacentes com alterações adicionais. A versão mais recente dos arquivos 
GOSAT Nível 1B (versão 210.210) foi adquirida diretamente do National 
Institute for Environmental Studies (NIES) GOSAT Data Archive Service (GDAS) 
Data Server e é processada com o Leicester Retrieval Preparation Toolset 
para extrair as radiâncias medidas junto com todas as informações auxiliares 
específicas de sondagem necessárias, como o tempo de medição, localização e 
geometria. Essas radiâncias medidas têm as correções de calibração e 
degradação radiométricas recomendadas aplicadas conforme Yoshida et al., 
2013 com uma estimativa do ruído espectral derivado do desvio padrão do 
sinal fora de banda. Os dados espectrais foram então inseridos no algoritmo 
de recuperação UoL-FP, onde a abordagem de recuperação Proxy é usada para 
obter a fração molar de metano (XCH4) de ar seco com média de coluna. 
A pós-filtragem e a correção de viés contra a Total Carbon Column Observing 
Network são então realizadas. Veja as informações do processo e a 
documentação para mais detalhes.

Para mais informações: <https://catalogue.ceda.ac.uk/uuid/18ef8247f52a4cb6a14013f8235cc1eb/?search_url=%2F%253Fq%253Dxch4%2Bgosat%26results_per_page%253D20%26sort_by%253Drelevance%26objects_related_to_uuid%253D%26record_type%253DObservation%26permissions_option%253Dany%26latest%253Don%26geo_option%253DTrue%26north_bound%253D%26west_bound%253D%26east_bound%253D%26south_bound%253D%26start_date%253D%26end_date%253D%26date_option%253Dpublication_date%26start_date_pub%253D%26end_date_pub%253D>

Referenciar (mendeley): PARKER, R.; HARTMUT, B. Universidade de Leicester GOSAT Proxy XCH4 v9.0. Centre for Environmental Data Analysis. 7 maio 2020. 

## GOSAT-2 

Data de lançamento: 29/10/2018

Constelação: GOSAT

Satélite: GOSAT-2

Instrumento (sensor): TANSO-FTS-2

Cobertura temporal: 2009 - presente

Mais informações: 

<https://earth.esa.int/eogateway/catalog/gosat-2-tanso-fts-2-and-cai-2-full-archive-and-new-products> 

<https://prdct.gosat-2.nies.go.jp/documents/documents.html.en>

## Aquisição dos dados de XCO2 e XCH4 do satélite GOSAT-2

Dados requisitados no dia 20/02/2025 

Dados no formato H5

Para baixar os dados do GOSAT-2, após recebido email com instruões, siga estes passos:

1. Verifique seu acesso;

Certifique-se de que recebeu o e-mail contendo a senha de acesso, caso seja necessário;

2. Conecte-se ao FTP (Você pode usar um cliente FTP como FileZilla);

Usando FileZilla

Baixe e instale o FileZilla (cliente);

Abra o FileZilla e vá em Arquivo > Gerenciador de Sites;

Clique em Novo Site e configure:

Protocolo: FTP

Host: gosat-ds.eo.esa.int

Criptografia: "Usar FTP simples" ou "Requer FTP sobre TLS implícito" 
(caso FTPS seja necessário)

Porta: 990

Usuário: "GOSAT2";

Senha: (insira a senha recebida no e-mail separado);

Clique em Conectar;

Em endereço local, selecione a pasta na qual deseja que os arquivos 
sejam baixados
(FTS-2 L2 Column-averaged Dry-air Mole Fraction (FTS-2_0)
FTS-2 L2 Chlorophyll Fluorescence and Proxy Method (FTS-2_02_SWPR);

No painel contendo os arquivos desejados (direito inferior), selecione os 
arquivos necessários > Clique direito > Baixar;

Por fim, as pastas serão baixadas para o diretório selecionado.

Produtos FTS-2 Nível 2 (FTS-2 L1B):  
  Produtos "Fração molar de ar seco média em coluna" armazenam fração molar 
  de ar seco média em coluna de gases atmosféricos recuperados usando dados 
  de radiância espectral de Banda 1-3 em TANSO-FTS-2 L1B; Produtos "Método 
  de fluorescência e proxy de clorofila (FTS-2_02_SWPR)" armazenam dados de 
  fluorescência de clorofila induzida solar recuperados de dados de radiância 
  espectral de Banda 1 em Produto L1B, bem como fração molar de ar seco média 
  em coluna de gases atmosféricos recuperados de dados de radiância espectral 
  de Banda 2 e 3 em Produto L1B. Ambos os produtos são obtidos usando o método 
  de preenchimento físico máximo a posteriori (MAP) e sob a suposição 
  de condições de céu limpo
  
  

