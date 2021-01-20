# =======================================================================
# Read raw data, clean it and save it out to `dir_data_processed()` here
# before moving to analysis. If run from `run.R`, all variables generated
# in this file will be wiped after completion to keep the environment
# clean. If your process step is complex, you can break it into several
# files like so: `source(dir_src('process_files', 'process_step_1.R'))`
# =======================================================================

# sample.raw <- read_csv(sample.raw.file) %>%
#   rename(
#     cma = 'CMA',
#     date = 'Date',
#     index = 'Index',
#     pairs = 'Pairs',
#     sale_avg = 'SaleAverage',
#     mom = 'MoM',
#     yoy = 'YoY',
#     ytd = 'YTD'
#   ) %>%
#   arrange(cma, desc(date))
#
# write_feather(sample.raw, dir_data_processed('sample.feather'))
