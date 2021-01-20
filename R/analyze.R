# =======================================================================
# This file handles the primary analysis using the tidied  data as input.
# Should never read from `dir_data_raw()`, only `dir_data_processed()`.
# =======================================================================

# sample <- read_feather(dir_data_processed('sample.feather')) %>%
#   group_by(cma) %>%
#   arrange(desc(date)) %>%
#   mutate(sale_avg_3mo = rollmean(sale_avg, k = 3, fill = NA)) %>%
#   ungroup() %>%
#   drop_na()
