############################################################
# This file configures the project by specifying filenames,
# loading packages and setting up some project-specific
# variables.
#
############################################################

# This initializes your startr project
startr_config <- c(
  author = 'Firstname Lastname <firstlast@globeandmail.com>',
  title = 'startr',
  timezone = 'America/Toronto',
  should_render_notebook = FALSE,
  should_process_data = TRUE,
  should_timestamp_output_files = FALSE,
  packages = c(
    'janitor', 'zoo',
    'tidymodels',
    'scales', 'gganimate',
    'sf',
    'cansim', 'cancensus',
  )
)

initialize_startr(startr_config)

# Filenames: Refer to your source data filenames here
sample.raw.file <- dir_data_raw('sample.csv')
