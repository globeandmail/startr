# Load required packages
load_requirements <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, 'Package'])]
  if (length(new.pkg))
      install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

# Run the gauntlet of basic exploratory data analysis on your data
run_basic_eda <- function(data){
  glimpse(data)
  df_status(data)
  freq(data)
  profiling_num(data)
  plot_num(data)
  describe(data)
}

read_all_excel_sheets <- function(
    filepath,
    range = NULL,
    col_types = NULL,
    col_names = TRUE,
    na = '',
    trim_ws = TRUE,
    skip = 0,
    n_max = Inf,
    guess_max = min(1000, n_max),
    .name_repair = 'unique'
  ) {
  filepath %>%
    excel_sheets() %>%
    set_names() %>%
    map_df(~ read_excel(
      path = filepath,
      skip = skip,
      range = range,
      na = na,
      trim_ws = trim_ws,
      guess_max = guess_max,
      col_names = col_names,
      col_types = col_types,
      n_max = n_max,
      sheet = .x,
      .name_repair = .name_repair
    ), .id = 'sheet')
}

# geocoding function using OSM Nominatim API
# details: http://wiki.openstreetmap.org/wiki/Nominatim
# made by: D.Kisler
nominatim_osm <- function(address = NULL) {
  if(suppressWarnings(is.null(address)))
    return(data.frame())
  tryCatch(
    d <- jsonlite::fromJSON(
      gsub('\\@addr\\@', gsub('\\s+', '\\%20', address),
           'http://nominatim.openstreetmap.org/search/@addr@?format=json&addressdetails=0&limit=1')
    ), error = function(c) return(data.frame())
  )
  if(length(d) == 0) return(data.frame())
  return(data.frame(lon = as.numeric(d$lon), lat = as.numeric(d$lat)))
}

render_notebook <- function(notebook_file) {
  rmarkdown::render(
    notebook_file,
    output_dir = dir_reports,
    encoding = 'utf-8'
  )
}

index <- function(m) {
  (m - first(m)) / first(m)
}

mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

unaccent <- function(x) {
  iconv(x, to = 'ASCII//TRANSLIT')
}

simplify_string <- function(x, alpha = TRUE, digits = FALSE) {
  re <- '^\\s'

  if (alpha) re <- paste(re, 'a-zA-Z', sep = '')
  if (digits) re <- paste(re, '0-9', sep = '')

  # TODO: add corporate stop words like INC, LTD, CORP?

  x %>%
    unaccent(.) %>%
    str_replace_all(., paste('[', re, ']', sep = ''), '') %>%
    str_replace_all(., '[\\s]+', ' ') %>%
    toupper(.) %>%
    trimws(.)
}

clean_columns <- function(x) {
  cols <- x %>%
    unaccent(.) %>%
    str_replace_all(., '[\\s]+', '_') %>%
    str_replace_all(., '[_]+', '_') %>%
    str_replace_all(., '[^_a-zA-Z]', '') %>%
    tolower(.) %>%
    trimws(.)

  for (i in 1:length(cols)) {
    if (!as.logical(str_count(cols[i]))) {
      cols[i] <- glue('column_{i}')
    }
    if (any(cols[1:i - 1] == cols[i])) {
      cols[i] <- glue('{cols[i]}_{i}')
    }
  }

  return(cols)
}

convert_str_to_logical <- function(x, truthy = 'T|TRUE', falsy = 'F|FALSE') {
  x %>%
    toupper(.) %>%
    trimws(.) %>%
    str_replace_all(., truthy, 'TRUE') %>%
    str_replace_all(., falsy, 'FALSE') %>%
    as.logical(.)
}

write_excel <- function(variable, timestamp = FALSE) {
  filename <- deparse(substitute(variable))
  if (timestamp) {
    now <- Sys.time()
    filename <- glue('{filename}_{format(now, "%Y-%m-%d_%H:%M:%S")}')
  }
  write.xlsx(variable, file = here::here(dir_data_out, glue('{filename}.xlsx')))
}

begin_processing <- function() {
  assign('curr_env', ls(.GlobalEnv), envir = .GlobalEnv)
}

end_processing <- function() {
  ls(.GlobalEnv) %>%
    setdiff(., curr_env) %>%
    as.character() %>%
    rm(list = ., envir = .GlobalEnv)

  beep()
}

write_plot <- function(variable, filename = NA, width = NA, height = NA, format = NA, units = NA, dpi = NA) {
  default_format <- 'png'
  default_units <- 'in'
  default_dpi <- 300
  default_filename <- deparse(substitute(variable))

  if(!is.na(format)) default_format <- format
  if(!is.na(units)) default_units <- units
  if(!is.na(dpi)) default_dpi <- dpi
  if(!is.na(filename)) default_filename <- filename

  args <- list(
    plot = variable,
    file = here::here(dir_plots, glue('{default_filename}.{default_format}')),
    units = default_units,
    dpi = default_dpi,
    width = width,
    height = height
  )

  if (default_format == 'pdf') args[['useDingbats']] <- FALSE

  do.call(ggsave, args)
}

# FROM https://github.com/dgrtwo/drlib/blob/master/R/reorder_within.R

reorder_within <- function(x, by, within, fun = mean, sep = "___", ...) {
  new_x <- paste(x, within, sep = sep)
  stats::reorder(new_x, by, FUN = fun)
}

scale_x_reordered <- function(..., sep = "___") {
  reg <- paste0(sep, ".+$")
  ggplot2::scale_x_discrete(labels = function(x) gsub(reg, "", x), ...)
}

scale_y_reordered <- function(..., sep = "___") {
  reg <- paste0(sep, ".+$")
  ggplot2::scale_y_discrete(labels = function(x) gsub(reg, "", x), ...)
}
