# =================================================================
# This file configures the project by specifying filenames, loading
# packages and setting up some project-specific variables.
# =================================================================

# This initializes your startr project
initialize_startr(
  title = 'startr',
  author = 'Firstname Lastname <firstlast@globeandmail.com>',
  timezone = 'America/Toronto',
  should_render_notebook = FALSE,
  should_process_data = TRUE,
  should_timestamp_output_files = FALSE,
  packages = c(
    'tidyverse', 'glue', 'magrittr', 'lubridate', 'hms',
    'readxl', 'feather', 'rvest',
    # 'globeandmail/tgamtheme',
    # 'janitor', 'zoo',
    # 'tidymodels',
    # 'scales', 'gganimate',
    # 'sf',
    # 'cansim', 'cancensus',
  )
)

# Refer to your source data filenames here
sample.raw.file <- dir_data_raw('your-filename-here.csv')
