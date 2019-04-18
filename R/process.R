############################################################
# This file is used to read in raw data, tidy, clean it,
# and save a file to src *before* proceeding to analysis.
# If you're using `mutate()` for any actual analysis you're
# doing it wrong.
#
# Specify column types as required.
#
############################################################

# begin_processing()

# sample.raw <- read_csv(here::here(dir_data_raw, sample.raw.file)) %>%
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
# write_csv(sample.raw, here::here(dir_data_processed, 'sample.csv'))
#
# end_processing()
