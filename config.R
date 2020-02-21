############################################################
# This file sets the config for the project including
# specifying packages to load and global variables.
#
############################################################

options(
  startr.config_author = 'Firstname Lastname <firstlast@globeandmail.com>',
  startr.config_title = 'startr',
  startr.config_timezone = 'America/Toronto',
  startr.config_dir_data = 'data',
  startr.config_dir_src = 'R',
  startr.config_dir_data_raw = 'data/raw',
  startr.config_dir_data_cache = 'data/cache',
  startr.config_dir_data_processed = 'data/processed',
  startr.config_dir_data_out = 'data/out',
  startr.config_dir_reports = 'reports',
  startr.config_dir_plots = 'plots',
  startr.config_should_render_notebook = FALSE, # Should a notebook be rendered in run.R?
  startr.config_should_process_data = TRUE, # Should the processing step be run in run.R?
  startr.config_timestamp_output_files = FALSE, # Should files written with write_excel have a timestamp in the filename?
  startr.config_clean_processing_variables = TRUE, # Should the variables created during process.R be cleaned up after processing?
  startr.config_r_notebook = dir_reports('notebook.Rmd'),
  startr.config_knitr = list(
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
    root.dir = dir_here()
  ),
  startr.config_packages = c(
    # essentials
    'here', 'devtools', 'tidyverse', 'startr',
    # manipulation
    'lubridate', 'janitor', 'zoo', 'glue', 'clipr', 'beepr',
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
    'cansim', 'cancensus'
  ),
  # CANCENSUS_API should be set in your home directory's .Renviron file
  cancensus.api_key = Sys.getenv(c('CANCENSUS_API')),
  cancensus.cache = dir_data_cache(),
  cansim.cache_path = dir_data_cache(),
  scipen = 999
)

initialize_startr()
# does several things:
# 1. installs default core packages so that we can remove them from the package object
# 2. consumes the startr config stuff to set up the environment
# 3. exposes all the functions listed in utils, plus a few more TK, namely:
#      - initialize_startr()
#      - dir_data_* functions

# Files: You'll want to edit this to add your source data file names
sample.raw.file <- here::here(dir_data_raw, 'sample.csv')
