# =================================================================
# This file configures the project by specifying filenames, loading
# packages and setting up some project-specific variables.
# =================================================================

# This initializes your startr project
initialize_startr(
  title = 'startr',
  author = 'Firstname Lastname <firstlast@example.com>',
  timezone = 'America/Toronto',
  should_render_notebook = FALSE,
  should_process_data = TRUE,
  should_timestamp_output_files = FALSE,
  packages = c(
    'tidyverse', 'glue', 'magrittr', 'lubridate', 'hms',
    'readxl', 'feather',
    'scales', 'knitr', 'DT', 'kableExtra'
    # 'rvest'
    # 'tgamtheme',
    # 'janitor', 'zoo',
    # 'tidymodels',
    # 'gganimate',
    # 'sf',
    # 'cansim', 'cancensus',
  )
)

# Refer to your source data filenames here. These can be either references
# to files in your `data/raw` folder, or paths to files hosted on the web.
# For example:
# sample.raw.file <- dir_data_raw('your-filename-here.csv')
# sample.raw.path <- 'https://github.com/tidyverse/dplyr/raw/master/data-raw/starwars.csv'
