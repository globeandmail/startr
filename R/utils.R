# load required packages
load_requirements <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, 'Package'])]
  if (length(new.pkg))
      install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

# returns all items in a list that are not contained in to_match
# to_match can be a single item or a list of items
exclude <- function (the_list, to_match) {
  return(setdiff(the_list, include(the_list, to_match)))
}

# returns all items in a list that ARE contained in to_match
# to_match can be a single item or a list of items
include <- function (the_list, to_match) {
  return(unique(grep(paste(to_match, collapse = '|'), the_list, value = TRUE)))
}

# run the gauntlet of basic exploratory data analysis on your data
run_basic_eda <- function(data) {
  glimpse(data)
  df_status(data)
  freq(data)
  profiling_num(data)
  plot_num(data)
  describe(data)
}

# read all the sheets of an Excel file and concatenate them into one long tibble
read_all_excel_sheets <- function(filepath, col_types = NULL, col_names = TRUE, skip = 0) {
  filepath %>%
    excel_sheets() %>%
    set_names() %>%
    map_df(~ read_excel(
      path = filepath,
      skip = skip,
      col_names = col_names,
      col_types = col_types,
      sheet = .x
    ), .id = 'sheet')
}

# geocoding function using OSM Nominatim API (http://wiki.openstreetmap.org/wiki/Nominatim)
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

# calculate the indexed change for a vector
index <- function(m) {
  (m - first(m)) / first(m)
}

# calculate the mode of a vector
mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# force accented characters to their non-accented versions
unaccent <- function(x) {
  iconv(x, to = 'ASCII//TRANSLIT')
}

# forcibly simplifies strings to just uppercase and single spaces, helpful when dealing with messy data. examples:
# defualt settings: "Hello! My name is   Tom " –> "HELLO MY NAME IS TOM"
# with digits = TRUE: "24th Ave..    Pizza / Restaurant / Bar" -> "24 AVE PIZZA RESTAURANT BAR"
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

# clean up column names by enforcing snake_case. examples:
# Excel files: read_excel(data, .name_repair = ~ clean_columns)
# Tibbles: data %>% rename_all(., ~ clean_columns(.))
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

# helper function to convert characters to logicals with some handy presets
convert_str_to_logical <- function(x, truthy = 'T|TRUE', falsy = 'F|FALSE') {
  x %>%
    toupper(.) %>%
    trimws(.) %>%
    str_replace_all(., truthy, 'TRUE') %>%
    str_replace_all(., falsy, 'FALSE') %>%
    as.logical(.)
}

# function called at the beginning of `process.r`
begin_processing <- function() {
  assign('curr_env', ls(.GlobalEnv), envir = .GlobalEnv)
}

# function called at the end of `process.R`, cleans up workspace
end_processing <- function() {
  ls(.GlobalEnv) %>%
    setdiff(., curr_env) %>%
    as.character() %>%
    rm(list = ., envir = .GlobalEnv)

  beep()
}

# some opinionated formatting and saving out for a less Excel-proficient users
add_to_workbook <- function(dataframe, workbook, worksheet_name, worksheet_number) {

  wb_header_style <- createStyle(fontSize = 13, textDecoration = "bold", fontColour = "#000000", halign = "left", border = "Bottom", borderColour = "#000000")
  wb_body_style <- createStyle(fontSize = 13, fontColour = "#000000", halign = "left", borderColour = "#000000")

  addWorksheet(workbook, worksheet_name)
  writeData(workbook, worksheet_number, dataframe)
  rowcount <- nrow(dataframe)
  colcount <-ncol(dataframe)
  addStyle(workbook, sheet = worksheet_number, wb_header_style, rows = 1, cols = 1:colcount, gridExpand = TRUE)
  addStyle(workbook, sheet = worksheet_number, wb_body_style, rows = 2:rowcount, cols = 1:colcount, gridExpand = TRUE)
  setColWidths(workbook, sheet = worksheet_number, cols = 1:colcount, widths = "auto")
  freezePane(workbook, worksheet_number, firstRow = TRUE)

}

# save a workbook with a timestamp in the filename
save_workbook_timestamp <- function(workbook, workbook_filename, export_directory = dir_data_out) {
  now <- Sys.time()
  workbook_file <- glue('{workbook_filename}{format(now, "%Y%m%d_%H%M%S_")}.xlsx')
  saveWorkbook(workbook, file = here::here(export_directory, workbook_file), overwrite = TRUE)
}

# one-liner that writes out an excel file based on a variable name
write_excel <- function(variable) {
  write.xlsx(variable, file = here::here(dir_data_out, glue('{deparse(substitute(variable))}.xlsx')))
}

# one-liner to write out a plot file from a variable, similar to `write_excel`
write_plot <- function(variable, width = NA, height = NA, format = NA, units = NA, dpi = NA) {
  default_format <- 'png'
  default_units <- 'in'
  default_dpi <- 300

  if(!is.na(format)) default_format <- format
  if(!is.na(units)) default_units <- units
  if(!is.na(dpi)) default_dpi <- dpi

  ggsave(
    plot = variable,
    file = here::here(dir_plots, glue('{deparse(substitute(variable))}.{default_format}')),
    units = default_units,
    dpi = default_dpi,
    width = width,
    height = height
  )
}

# render out a notebook
render_notebook <- function(notebook_file) {
  rmarkdown::render(
    notebook_file,
    output_dir = dir_reports,
    encoding = 'utf-8'
  )
}
