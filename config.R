############################################################
# This file sets the config for the project including
# specifying packages to load and global variables.
#
############################################################

# install_github('globeandmail/tgamRtheme')

options(scipen = 999)
Sys.setenv(TZ = 'America/Toronto')

# Project-specific
config_author <- 'Firstname Lastname <firstlast@globeandmail.com>'
config_title <- 'startr'

# Directories to read from and write to
dir_data <- 'data'
dir_src <- 'R'
dir_data_raw <- 'data/raw'
dir_data_cache <- 'data/cache'
dir_data_processed <- 'data/processed'
dir_data_out <- 'data/out'
dir_reports <- 'reports'
dir_plots <- 'plots'

# Files: You'll want to edit this to add your source data file names
r_notebook <- 'notebook.Rmd'
sample.raw.file <- 'sample.csv'

# Misc. vars: In some cases, you might not want to re-process the
# data every time (say, if you're ingesting several gigabytes), so
# you can disable that below.
should_render_notebook <- FALSE
should_process_data <- TRUE

packages <- c(
  # essentials
  'here', 'devtools',
  # manipulation
  'tidyverse', 'lubridate', 'janitor', 'zoo', 'glue', 'clipr',
  # Read/write XLS and XLSX files
   'readxl', 'openxlsx',
  # summarize data
  # 'summarytools', 'DataExplorer', 'funModeling', 'anomalize',
  # visualization
  'scales',
  # scraping
  'rvest',
  # GIS
  # 'sf', 'rgdal', 'raster', 'ggmap', 'maps', 'maptools', 'geojsonio', 'geojsonR',
  # RMarkdown
  'knitr', 'ezknitr', 'kableExtra', 'DT',
  # other stuff
  # 'cansim', 'cancensus',
  # 'log4r',
  'beepr'
)

source(here::here(dir_src, 'utils.R'))
source(here::here(dir_src, 'functions.R'))

load_requirements(packages)

options(
  # CANCENSUS_API should be set in your home directory's .Renviron file,
  # and will get pulled down from there
  cancensus.api_key = Sys.getenv(c('CANCENSUS_API')),
  cancensus.cache = here::here(dir_data_cache),
  cansim.cache_path = here::here(dir_data_cache)
)

knitr::opts_chunk$set(
  eval = TRUE,
  echo = FALSE,
  message = FALSE,
  cache = FALSE,
  warning = FALSE,
  error = FALSE,
  comment = '#',
  tidy = FALSE,
  collapse = TRUE,
  results = 'asis',
  fig.width = 12,
  dpi = 150,
  root.dir = here::here()
)
