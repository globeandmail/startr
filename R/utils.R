# PACKAGES THIS REQUIRES

'here'
'librarian'
'tidyverse'
'openxlsx'
'feather'
'knitr'
'beepr'
'ggthemes'
'clipr'

initialize_startr <- function(
    scipen = 999,
    timezone = 'America/Toronto',
    should_render_notebook = FALSE,
    should_process_data = TRUE,
    should_timestamp_output_files = FALSE,
    should_clean_processing_variables = TRUE,
    should_beep = TRUE,
    packages = c()
  ) {

    if (scipen) options(scipen = scipen)
    if (timezone) Sys.setenv(TZ = timezone)

    assign('should_render_notebook', should_render_notebook, envir = .GlobalEnv)
    assign('should_process_data', should_process_data, envir = .GlobalEnv)
    assign('should_timestamp_output_files', should_timestamp_output_files, envir = .GlobalEnv)
    assign('should_clean_processing_variables', should_clean_processing_variables, envir = .GlobalEnv)
    assign('should_beep', should_beep, envir = .GlobalEnv)

    # DO LIBRARIAN STUFF HERE
    # load_requirements(packages)
    ggthemes::theme_set(theme_minimal())

    knitr::opts_chunk$set(
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
      root.dir = here::here()
    )

    if ('cansim' %in% packages) {
      options(cansim.cache_path = dir_data_cache())
    }

    if ('cancensus' %in% packages) {
      options(
        # CANCENSUS_API should be set in your home directory's
        # .Renviron file, and will get pulled down from there
        cancensus.api_key = Sys.getenv(c('CANCENSUS_API')),
        cancensus.cache_path = dir_data_cache(),
      )
    }

}

dir_constructor <- function(path, ...) {
  here::here(path, ...)
}

dir_src <- function(...) {
  dir_constructor('R', ...)
}

dir_data_raw <- function(...) {
  dir_constructor('data/raw', ...)
}

dir_data_cache <- function(...) {
  dir_constructor('data/cache', ...)
}

dir_data_processed <- function(...) {
  dir_constructor('data/processed', ...)
}

dir_data_out <- function(...) {
  dir_constructor('data/out', ...)
}

dir_reports <- function(...) {
  dir_constructor('reports', ...)
}

dir_plots <- function(...) {
  dir_constructor('plots', ...)
}

run_config <- function() {
  source(here::here('config.R'))
  source(dir_src('functions.R'))
}

run_process <- function() {
  if (should_process_data) {
    begin_processing(clean = clean_processing_variables)
    source(dir_src('process.R'))
    end_processing(should_beep = should_beep)
  }
}

run_analyze <- function() {
  source(dir_src('analyze.R'))
}

run_visualize <- function() {
  source(dir_src('visualize.R'))
}

run_render_notebook <- function(path = r_notebook.file, should_beep = should_beep) {
  if (should_render_notebook) render_notebook(path)
  if (should_beep) beep()
}

# load_requirements <- function(pkg){
#   new.pkg <- pkg[!(pkg %in% installed.packages()[, 'Package'])]
#   if (length(new.pkg))
#       install.packages(new.pkg, dependencies = TRUE)
#   sapply(pkg, require, character.only = TRUE)
# }

# Contributed by Andy Lin of News Nerdery Slack
combine_csvs <- function(dir, ...) {
  list.files(dir, pattern = '*.csv', full.names = T) %>%
    map_dfr(function(x) {
      read_csv(path = filepath, ...)
    }, .id = 'filename')
}

read_all_excel_sheets <- function(filepath, ...) {
  filepath %>%
    excel_sheets() %>%
    set_names() %>%
    map_df(function(x) {
      read_excel(path = filepath, sheet = x, ...)
    }, .id = 'sheet')
}

combine_excels <- function(dir, all_sheets = FALSE, ...) {
  read_excel_constructor <- function(x) {
    if (all_sheets) {
      read_all_excel_sheets(path = filepath, ...)
    } else {
      read_excel(path = filepath, ...)
    }
  }

  list.files(dir, pattern = '.xls[x]?', full.names = T) %>%
    map_dfr(read_excel_constructor, .id = 'filename')
}

render_notebook <- function(notebook_file) {
  rmarkdown::render(
    notebook_file,
    output_dir = dir_reports(),
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

remove_non_utf8 <- function(x) {
  iconv(x, to = 'UTF-8', sub = '')
}

`%not_in%` <- purrr::negate(`%in%`)

not.na <- purrr::negate(is.na)

simplify_string <- function(
    x,
    alpha = TRUE,
    digits = FALSE,
    unaccent = TRUE,
    utf8_only = TRUE,
    uppercase = TRUE,
    trim = TRUE,
    stopwords = NA
  ) {

    x_temp <- x

    if (unaccent) {
      x_temp <- unaccent(x_temp)
    }

    if (utf8_only) {
      x_temp <- remove_non_utf8(x_temp)
    }

    if (uppercase) {
      x_temp <- str_to_upper(x_temp)
    }

    if (alpha | digits) {
      re <- '^\\s'
      if (alpha) re <- paste(re, 'a-zA-Z', sep = '')
      if (digits) re <- paste(re, '0-9', sep = '')
      x_temp <- str_replace_all(x_temp, paste('[', re, ']', sep = ''), '')
    }

    if (!any(is.na(stopwords))) {
      if (uppercase) stopwords <- str_to_upper(stopwords)
      stopwords_regex <- paste0('\\b', paste(stopwords, collapse = '\\b|\\b'), '\\b')
      x_temp <- str_replace_all(x_temp, stopwords_regex, '')
    }

    if (trim) {
      x_temp <- str_squish(x_temp)
    }

    return(x_temp)

  }

clean_columns <- function(x) {
  cols <- x %>%
    unaccent(.) %>%
    str_replace_all(., '[\\s]+', '_') %>%
    str_replace_all(., '[_]+', '_') %>%
    str_replace_all(., '[^_a-zA-Z]', '') %>%
    str_to_lower(.) %>%
    str_squish(.)

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

convert_str_to_logical <- function(x, truthy = 'T|TRUE|Y|YES', falsy = 'F|FALSE|N|NO') {
  x %>%
    str_to_upper(.) %>%
    str_squish(.) %>%
    str_replace_all(., truthy, 'TRUE') %>%
    str_replace_all(., falsy, 'FALSE') %>%
    as.logical(.)
}

write_excel <- function(variable, should_timestamp_output_files = should_timestamp_output_files) {
  filename <- deparse(substitute(variable))
  if (should_timestamp_output_files) {
    now <- Sys.time()
    filename <- glue('{filename}_{format(now, "%Y%m%d%H%M%S")}')
  }
  write.xlsx(variable, file = dir_data_out(glue('{filename}.xlsx')))
}

begin_processing <- function(should_clean_processing_variables = should_clean_processing_variables) {
  if (should_clean_processing_variables) {
    assign('curr_env', ls(.GlobalEnv), envir = .GlobalEnv)
  }
}

end_processing <- function(should_clean_processing_variables = should_clean_processing_variables, should_beep = should_beep) {
  if (should_clean_processing_variables) {
    ls(.GlobalEnv) %>%
      setdiff(., curr_env) %>%
      as.character() %>%
      rm(list = ., envir = .GlobalEnv)
  }
  if (should_beep) beep()
}

write_plot <- function(variable, filename = NA, format = 'png', ...) {

  if (is.na(filename)) filename <- deparse(substitute(variable))

  args <- list(
    plot = variable,
    format = format,
    file = dir_plots(glue('{filename}.{format}')),
    ...
  )

  if (format == 'pdf') args[['useDingbats']] <- FALSE

  do.call(ggsave, args)
}

write_shp <- function(shp, path) {
  if (file.exists(path)) {
    file.remove(path)
  }

  st_write(shp, path, update = TRUE)
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
