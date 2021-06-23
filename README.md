# startr

A template for data journalism projects in R.

This project structures the data analysis process, reducing the amount of time you'll spend setting up and maintaining a project. Essentially, it's an "opinionated framework" like Django, Ruby on Rails or React, but for data journalism.

Broadly, `startr` does a few things:

* **Standardizes your projects**: Eliminates the need to think about project structure so you can focus on the analysis.
* **Breaks analysis into discrete steps**: Supports a flexible analysis workflow with clearly-defined steps which can be shared easily across a team.
* **Helps you catch mistakes**: With structure and workflow baked in, you can focus on writing analysis code, reducing the opportunities for mistakes.
* **Bakes in flexibility**: Has a format that works for both large (multi-month) and small (single-day) projects.
* **De-clutters your code**: Improves the painstaking data verification/fact-checking process by cutting down on spaghetti code.
* **Improves communication**: Documents the analysis steps and questions to be answered for large, multi-disciplinary teams (say, developers, data journalists and traditional reporters).
* **Simplifies the generation of charts and reports**: Generates easily updatable RMarkdown reports, Adobe Illustrator-ready graphics, and datasets during analysis.

## Table of contents
* [startr](#startr)
* [Table of contents](#table-of-contents)
* [Installation](#installation)
* [Philosophy on data analysis](#philosophy-on-data-analysis)
* [Workflow](#workflow)
  1. [Set up your project](#step-1-set-up-your-project)
  2. [Import and process data](#step-2-import-and-process-data)
  3. [Analyze](#step-3-analyze)
  4. [Visualize](#step-4-visualize)
  5. [Write a notebook](#step-5-write-a-notebook)
* [Helper functions](#helper-functions)
* [Tips](#tips)
* [Directory structure](#directory-structure)
* [See also](#see-also)
* [Version](#version)
* [License](#license)
* [Get in touch](#get-in-touch)

## Installation

This template works with R and RStudio, so you'll need both of those installed. To scaffold a new `startr` project, we recommend using our command-line tool, [`startr-cli`](https://github.com/globeandmail/startr-cli), which will copy down the folder structure, rename some files, configure the project and initialize an empty Git repository.

Using [`startr-cli`](https://github.com/globeandmail/startr-cli), you can scaffold a new project by simply running `create-startr` in your terminal and following the prompts:

![startr-cli interface GIF](http://i.imgur.com/4qtiJar.gif)

Alternatively, you can run:
```sh
git clone https://github.com/globeandmail/startr.git <your-project-name-here>
```

(But, if you do that, be sure to rename your `startr.Rproj` file to `<project-name>.Rproj` and set up your settings in `config.R` manually.)

Once a fresh project is ready, double-click on the `.Rproj` file to start a scoped RStudio instance.

You can then start copying in your data and writing your analysis. At The Globe, we like to work in a code editor like Atom or Sublime Text, and use something like [`r-exec`](https://atom.io/packages/r-exec) to send code chunks to RStudio.

## Philosophy on data analysis

This analysis framework is designed to be flexible, reproducible and easy to jump into for a new user. `startr` works best when you assume The Globe’s own philosophy on data analysis:

- **Raw data is immutable**: Treat the files in `data/raw` as read-only. This means you only ever alter them programmatically, and never edit or overwrite files in that folder. If you need to manually rewrite certain columns in a raw data file, do so by creating a new spreadsheet with the new values, then join it to the original data file during the [processing step](#step-2-import-and-process-data).
- **Outputs are disposable**: Treat all project outputs (everything in `data/processed`, `data/out/`, `data/cache` and `plots/`) as disposable products. By default, this project's `.gitignore` file ignores those files, so they're never checked into source management tools. Unless absolutely necessary, do not alter `.gitignore` to check in those files — the analysis pipeline should be able to reproduce them all from your raw data files.
- **Shorter is not always better**: Your code should, as much as possible, be self-documenting. Keep it clean and as simple as possible. If an analysis chain is becoming particularly long or complex, break it out into smaller chunks, or consider writing a function to abstract out the complexity in your code.
- **Only optimize your code for performance when necessary**: It's easy to fall into a premature optimization rabbit hole, especially on larger or more complex projects. In most cases, there's no need to optimize your code for performance — only do this if your analysis process is taking several minutes or longer.
- **Never overwrite variables**: No variables should ever be overwritten or reassigned. Same goes for fields generated via [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html).
- **Order matters**: We only ever run our R code sequentially, which prevents reproducibility issues resulting from users running code chunks in different orders. For instance, do not run a block of code at line 22, then code at line 11, then some more code at line 37, since that may lead to unexpected results that another journalist won't be able to reproduce.
- **Wipe your environment often**: If using RStudio (our preferred tool for work in R), restart and clear the environment often to make sure your code is reproducible.
- **Use the tidyverse**: For coding style, we rely on the [tidyverse style guide](https://style.tidyverse.org/).

## Workflow

The heart of the project lies in these three files:

* **`process.R`**: Import your source data, tidy it, fix any errors, set types, apply upfront manipulations and save out a file ready for analysis. We recommend saving out a [`.feather`](https://github.com/wesm/feather) file, which will retain types and is designed to read extremely quickly — but you can also use a .CSV, .RDS file, shapefile or something else if you'd prefer.

* **`analyze.R`**: Here you'll consume the data files saved out by `process.R`. This is where all of the true "analysis" occurs, including grouping, summarizing, filtering, etc. If your analysis is complex enough, you may want to split it out into additional `analyze_step_X.R` files as required, and then call those files from `analyze.R` using `source()`.

* **`visualize.R`**: Draw and save out your graphics.

There's also an optional (but recommended) RMarkdown file (**`notebook.Rmd`**) you can use to generate an HTML codebook – especially useful for longer-term projects where you need to document the questions you're asking.

#### Step 1: Set up your project

The bulk of any `startr` project's code lives within the `R` directory, in files that are sourced and run in sequence by the `run.R` at the project's root.

Many of the core functions for this project are managed by a specialty package, [**upstartr**](https://github.com/globeandmail/upstartr). That package is installed and imported in `run.R` automatically.

Before starting an analysis, you'll need to set up your `config.R` file.

That file uses the [`initialize_startr()`](https://globeandmail.github.io/upstartr/reference/initialize_startr.html) function to prepare the environment for analysis. It will also load all the packages you'll need. For instance, you might want to add the [`cancensus`](https://github.com/mountainMath/cancensus) library. To do that, just add `'cancensus'` to the `packages` vector. Package suggestions for GIS work, scraping, dataset summaries, etc. are included in commented-out form to avoid bloat. The function also takes several other optional parameters — for a full list, see our [documentation](https://globeandmail.github.io/upstartr/reference/initialize_startr.html).

Once you've listed the packages you want to import, you'll want to reference your raw data filenames so that you can read them in during `process.R`. For instance, if you're adding pizza delivery data, you'd add this line to the filenames block in `config.R`:

```R
pizza.raw.file <- dir_data_raw('Citywide Pizza Deliveries 1998-2016.xlsx')
```

Our naming convention is to append `.raw` to variables that reference raw data, and `.file` to variables that are just filename strings.

#### Step 2: Import and process data

In `process.R`, you'll read in the data for the filename variables you assigned in `config.R`, do some clean-up, rename variables, deal with any errors, convert multiple files to a common data structure if necessary, and finally save out the result. It might look something like this:

```R
pizza.raw <- read_excel(pizza.raw.file, skip = 2) %>%
  select(-one_of('X1', 'X2')) %>%
  rename(
    date = 'Date',
    time = 'Time',
    day = 'Day',
    occurrence_id = 'Occurrence Identification Number',
    lat = 'Latitude',
    lng = 'Longitude',
    person = 'Delivery Person',
    size = 'Pizza Size (in inches)',
    price = 'Pizza bill \n after taxes'
  ) %>%
  mutate(
    price = parse_number(price),
    year_month = format(date, '%Y-%m-01'),
    date = ymd(date)
  ) %>%
  filter(!is.na(date))

write_feather(pizza.raw, dir_data_processed('pizza.feather'))
```

When called via the [`run_process()`](https://globeandmail.github.io/upstartr/reference/run_process.html) function in `run.R`, variables generated during processing will be removed once the step is completed to keep the working environment clean for analysis.

We prefer to write out our processed files using the binary [`.feather`](https://github.com/wesm/feather) format, which is designed to  read and write files extremely quickly (at roughly 600 MB/s). Feather files can also be opened in other analysis frameworks (i.e. Jupyter Notebooks) and, most importantly, embed column types into the data so that you don't have to re-declare a column as logicals, dates or characters later on. If you'd rather save out files in a different format, you can just use a different function, like the tidyverse's [`write_csv()`](https://readr.tidyverse.org/reference/write_delim.html).

Output files are written to `/data/processed` using the [`dir_data_processed()`](https://globeandmail.github.io/upstartr/reference/dir-data_processed.html) function. By design, processed files aren't checked into Git — you should be able to reproduce the analysis-ready files from someone else's project by running `process.R`.

#### Step 3: Analyze

This part's as simple as consuming that file in `analyze.R` and running with it. It might look something like this:

```R
pizza <- read_feather(dir_data_processed('pizza.feather'))

delivery_person_counts <- pizza %>%
  group_by(person) %>%
  count() %>%
  arrange(desc(n))

deliveries_monthly <- pizza %>%
  group_by(year_month) %>%
  summarise(
    n = n(),
    unique_persons = n_distinct(person)
  )
```

#### Step 4: Visualize

You can use `visualize.R` to consume the variables created in `analyze.R`. For instance:

```R
plot_delivery_persons <- delivery_person_counts %>%
  ggplot(aes(x = person, y = n)) +
  geom_col() +
  coord_flip()

plot_delivery_persons

write_plot(plot_delivery_persons)

plot_deliveries_monthly <- deliveries_monthly %>%
  ggplot(aes(x = year_month, y = n)) +
  geom_col()

plot_deliveries_monthly

write_plot(plot_deliveries_monthly)
```

#### Step 5: Write a notebook

TKTKTKTK

## Helper functions

`startr`'s companion package [`upstartr`](https://github.com/globeandmail/upstartr) comes with several functions to support `startr`, plus helpers we've found useful in daily data journalism tasks. A full list can be found on the [reference page here](https://globeandmail.github.io/upstartr/reference/index.html). Below is a partial list of some of its most handy functions:

- [`simplify_string()`](https://globeandmail.github.io/upstartr/reference/simplify_string.html): By default, takes strings and simplifies them by force-uppercasing, replacing accents with non-accented characters, removing every non-alphanumeric character, and simplifying double/mutli-spaces into single spaces. Very useful when dealing with messy human-entry data with people's names, corporations, etc.

    ```r
    pizza_deliveries %>%
      mutate(customer_simplified = simplify_string(customer_name))
    ```

- [`clean_columns()`](https://globeandmail.github.io/upstartr/reference/clean_columns.html): Renaming columns to something that doesn't have to be referenced with backticks (`` `Column Name!` ``) or square brackets (`.[['Column Name!']]`) gets tedious. This function speeds up the process by forcing everything to lowercase and using underscores – the tidyverse's preferred naming convention for columns. If there are many columns with the same name during cleanup, they'll be appended with an index number.

    ```r
    pizza_deliveries %>%
      rename_all(clean_columns)
    ```

- [`convert_str_to_logical()`](https://globeandmail.github.io/upstartr/reference/convert_str_to_logical.html): Does the work of cleaning up your True, TRUE, true, T, False, FALSE, false, F, etc. strings to logicals.

    ```r
    pizza_deliveries %>%
      mutate(was_delivered_logi = convert_str_to_logical(was_delivered))
    ```

- [`calc_index()`](https://globeandmail.github.io/upstartr/reference/calc_index.html): Calculate percentage growth by indexing values to the first value:

    ```r
    pizza_deliveries %>%
      mutate(year = year(date)) %>%
      group_by(size, year) %>%
      summarise(total_deliveries = n()) %>%
      arrange(year) %>%
      mutate(indexed_deliveries = calc_index(total_deliveries))
    ```

- [`calc_mode()`](https://globeandmail.github.io/upstartr/reference/calc_mode.html): Calculate the mode for a given field:

    ```r
    pizza_deliveries %>%
      group_by(pizza_shop) %>%
      summarise(most_common_size = calc_mode(size))
    ```

- [`write_excel()`](https://globeandmail.github.io/upstartr/reference/write_excel.html): Writes out an Excel file to `data/out` using the variable name as the file name. Useful for quickly generating summary tables for sharing with others. By design, doesn't take any arguments to keep things as simple as possible. If `should_timestamp_output_files` is set to TRUE in `config.R`, will append a timestamp to the filename in the format `%Y%m%d%H%M%S`.

    ```r
    undelivered_pizzas <- pizza_deliveries %>%
      filter(!was_delivered_logi)

    write_excel(undelivered_pizzas)
    ```

- [`write_plot()`](https://globeandmail.github.io/upstartr/reference/write_plot.html): Similar to [`write_excel()`](https://globeandmail.github.io/upstartr/reference/write_excel.html), designed to quickly save out a plot directly to `/plots`. Takes all the same arguments as [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html).

    ```r
    plot_undelivered_pizzas <- undelivered_pizzas %>%
      group_by(year) %>%
      summarise(n = n()) %>%
      ggplot(aes(x = year, y = n)) +
      geom_col()

    write_plot(plot_undelivered_pizzas)
    ```

- [`read_all_excel_sheets()`](https://globeandmail.github.io/upstartr/reference/read_all_excel_sheets.html): Combines all Excel sheets in a given file into a single dataframe, adding an extra column called `sheet` for the sheet name. Takes all the same arguments as [`readxl`](https://readxl.tidyverse.org/)'s [`read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).

    ```r
    pizza_deliveries <- read_all_excel_sheets(
        pizza_deliveries.file,
        skip = 3,
      )
    ```

- [`combine_csvs()`](https://globeandmail.github.io/upstartr/reference/combine_csvs.html): Read all CSVs in a given directory and concatenate them into a single file. Takes all the same arguments as [`read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)

    ```r
    pizzas <- combine_csvs(dir_data_raw())
    ```

- [`combine_excels()`](https://globeandmail.github.io/upstartr/reference/combine_excels.html): Read all Excel spreadsheets in a given directory and concatenate them.

    ```r
    pizzas_in_excel <- combine_excels(dir_data_raw())
    ```

- [`unaccent()`](https://globeandmail.github.io/upstartr/reference/unaccent.html): Remove accents from strings.

    ```r
    unaccent('Montréal')
    # [1] "Montreal"
    ```

- [`remove_non_utf8()`](https://globeandmail.github.io/upstartr/reference/remove_non_utf8.html): Remove non-UTF-8 characters from strings.

    ```r
    non_utf8 <- 'fa\xE7ile'
    Encoding(non_utf8) <- 'latin1'
    remove_non_utf8(non_utf8)
    # [1] "façile"
    ```

- [`%not_in%`](https://globeandmail.github.io/upstartr/reference/grapes-not_in-grapes.html): The opposite of the [`%in%`](https://stat.ethz.ch/R-manual/R-devel/library/base/html/match.html) operator.

    ```r
    c(1, 2, 3, 4, 5) %not_in% c(4, 5, 6, 7, 8)
    # [1]  TRUE  TRUE  TRUE FALSE FALSE
    ```

- [`not.na()`](https://globeandmail.github.io/upstartr/reference/not.na.html): The opposite of the [`is.na`](https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/NA) function.
- [`not.null()`](https://globeandmail.github.io/upstartr/reference/not.null.html): The opposite of the [`is.null`](https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/NULL) function.

## Tips

- **You don't always need to process your data**: If your [processing step](#step-2-import-and-process-data) takes a while and you've already generated your processed files during a previous run, you can tell `startr` to skip this step by setting `should_process_data` to `FALSE` in `config.R`'s [`initialize_startr()`](https://globeandmail.github.io/upstartr/reference/initialize_startr.html) function. Just be sure to set it back to `TRUE` if your processing code changes!
- **Consider timestamping your output files**: If you're using [`upstartr`](https://github.com/globeandmail/upstartr)'s [`write_excel()`](https://globeandmail.github.io/upstartr/reference/write_excel.html) helper, you can automatically timestamp your filenames by setting `should_timestamp_output_files` to `TRUE` in [`initialize_startr()`](https://globeandmail.github.io/upstartr/reference/initialize_startr.html).
- **Use the functions file**: Reduce repetition in your code by writing functions and putting them in the `functions.R` file, which gets `source()`'d when [`run_config()`](https://globeandmail.github.io/upstartr/reference/run_config.html) is run.
- **Help us make `startr` better**: Using this package? Find yourself wishing the structure were slightly different, or have an often-used function you're tired of copying and pasting between projects? Please [send us your feedback](#get-in-touch).

## Directory structure

```
├── data/
│   ├── raw/          # The original data files. Treat this directory as read-only.
│   ├── cache/        # Cached files, mostly used when scraping or dealing with packages such as `cancensus`. Disposable, ignored by version control software.
│   ├── processed/    # Imported and tidied data used throughout the analysis. Disposable, ignored by version control software.
│   └── out/          # Exports of data at key steps or as a final output. Disposable, ignored by version control software.
├── R/
│   ├── process.R     # Basic data processing (fixing column types, setting dates, pre-emptive filtering, etc.) ahead of analysis.
│   ├── analyze.R     # Your exploratory data analysis.
│   ├── visualize.R   # Where your visualization code goes.
│   └── functions.R   # Project-specific functions.
├── plots/            # Your generated graphics go here.
├── reports/
│   └── notebook.Rmd  # Your analysis notebook. Will be compiled into an .html file by `run.R`.
├── scrape/
│   └── scrape.R      # Scraping scripts that save collected data to the `/data/raw/` directory.
├── config.R          # Global project variables including packages, key project paths and data sources.
├── run.R             # Wrapper file to run the analysis steps, either inline or sourced from component R files.
└── startr.Rproj      # Rproj file for RStudio
```

An `.nvmrc` is included at the project root for Node.js-based scraping. If you prefer to scrape with Python, be sure to add `venv` and `requirements.txt` files, or a `Gemfile` if working in Ruby.

## See also

`startr` is part of a small ecosystem of R utilities. Those include:

- [**upstartr**](https://github.com/globeandmail/upstartr), a library of functions that support `startr` and daily data journalism tasks
- [**tgamtheme**](https://github.com/globeandmail/tgamtheme), The Globe and Mail's graphics theme
- [**startr-cli**](https://github.com/globeandmail/startr-cli), a command-line tool that scaffolds new `startr` projects

## Version

1.1.0

## License

startr © 2020 The Globe and Mail. It is free software, and may be redistributed under the terms specified in our MIT license.

## Get in touch

If you've got any questions, feel free to send us an email, or give us a shout on Twitter:

[![Tom Cardoso](https://avatars0.githubusercontent.com/u/2408118?v=3&s=65)](https://github.com/tomcardoso) | [![Michael Pereira](https://avatars0.githubusercontent.com/u/212666?v=3&s=65)](https://github.com/monkeycycle)
---|---
[Tom Cardoso](mailto:tcardoso@globeandmail.com) <br> [@tom_cardoso](https://www.twitter.com/tom_cardoso) | [Michael Pereira](mailto:hello@monkeycycle.org) <br> [@__m_pereira](https://www.twitter.com/__m_pereira)
