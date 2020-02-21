############################################################
# This file sets the config for the project including
# specifying packages to load and global variables.
#
############################################################

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
sample.raw.file <- here::here(dir_data_raw, 'sample.csv')

# Primary and supplemental notebooks.
# Set should_render_notebook to TRUE if using notebooks
r_notebook <- here::here(dir_reports, 'notebook.Rmd')

# startr-specific configuration, consumed by helper functions
# Should a notebook be rendered in run.R?
should_render_notebook <- FALSE

# Should the processing step be run in run.R?
should_process_data <- TRUE

# Should files written with write_excel have a timestamp in the filename?
timestamp_output_files <- FALSE

# Should the variables created during process.R be cleaned up after processing?
clean_processing_variables <- TRUE

packages <- c(
  # essentials
  'here', 'devtools', 'tidyverse',
  # manipulation
  'lubridate', 'janitor', 'zoo', 'glue', 'clipr', 
  # modelling
  'tidymodels',
  # Read/write files
  'readxl', 'openxlsx', 'feather',
  # visualization
  'scales', 'ggthemes', 'gganimate',
  # scraping
  'rvest',
  # GIS
  'sf',
  # RMarkdown
  'knitr', 'ezknitr', 'kableExtra', 'DT',
  # other stuff
  # 'cansim', 'cancensus',
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
