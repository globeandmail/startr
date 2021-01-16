############################################################
# This file is used to read in raw data, clean it, and save
# a file to `dir_data_processed()` *before* proceeding to
# analysis. If this file is run from run.R, all variables
# created by this step will be erased after the step is
# complete to keep a clean working environment. Tip: If your
# analysis is complicated enough that you need to break the
# processing out into multiple files, simply source them
# from this file by calling something like
# `source(dir_src('process_files', 'process_step_1.R'))`
#
############################################################

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
