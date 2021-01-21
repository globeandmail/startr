# startr

A template for data journalism projects in R.

This project structures the data analysis process, reducing the amount of time you'll spend setting up and maintaining a project. Essentially, it's an "opinionated framework" like Django, Ruby on Rails or React, but for data journalism.

Broadly, `startr` does a few things:

* **Standardizes your projects**: Eliminates the need to think about project structure so you can focus on the analysis
* **Breaks analysis into discrete steps**: Supports a flexible analysis workflow with clearly-defined steps which can be shared easily across a team
* **Bakes in flexibility**: Has a format that works for both large (multi-month) and small (single-day) projects
* **De-clutters your code**: Improves the painstaking data verification/fact-checking process by cutting down on spaghetti code
* **Improves communication**: Documents the analysis steps and questions to be answered for large, multi-disciplinary teams (say, developers, data journalists and traditional reporters)
* **Simplifies the generation of charts and reports**: Generates easily updatable RMarkdown reports, Adobe Illustrator-ready graphics, and datasets during analysis

## How do I use this?

This template works with R and RStudio, so you'll need both of those installed. To scaffold a new `startr` project, we recommend using our command-line tool, [`startr-cli`](https://www.github.com/globeandmail/startr-cli), which will rename some files, configure the project and initialize an empty Git repository. Alternatively, you can run:
```sh
git clone https://github.com/globeandmail/startr.git <your-project-name-here>
```

Once the project's cloned, double-click on the `.Rproj` file to start a scoped RStudio instance.

You can then start copying in your data and writing your analysis. At The Globe, we like to work in a code editor like Atom or Sublime Text, and use something like [`r-exec`](https://atom.io/packages/r-exec) to send code chunks to RStudio.

## Example workflow using `startr`

Here's how we use `startr` for our own analysis workflow right now. The heart of the project lies in these three files:

* **`process.R`**: Import your source data, tidy it, fix any errors, set types, apply upfront manipulations and save out a file ready for analysis. We recommend saving out a `.feather` file, which will retain types and reads extremely quickly — but you can also use a CSV, shapefile, RDS file or something else if you'd prefer.

* **`analyze.R`**: Here you'll consume the data files saved out by `process.R`. This is where all of the true "analysis" occurs, including grouping, summarizing, filtering, etc. If your analysis is complex enough, you may want to split it into additional `analyze_step_X.R` files as required.

* **`visualize.R`**: Draw and save out your graphics.

There's also an optional (but recommended) RMarkdown file (**`notebook.Rmd`**) you can use to generate a report – especially useful for longer-term projects where you need to document the questions you're asking.

#### Step 1: Set up your project

The bulk of any `startr` project's code lives within the `R` directory, in files that are sourced and run in sequence by the `run.R` at the project's root.

Many of the core functions for this project are managed by a specialty package, [**upstartr**](https://www.github.com/globeandmail/upstartr). That package is installed and imported in `run.R`.

Before starting an analysis, you'll want to point to your data files in `config.R` and make sure it's loading all the packages you'll need. For instance, you might want to add the [`cancensus`](https://github.com/mountainMath/cancensus) package. To do that, just add `'cancensus'` to the `packages` vector. Package suggestions for GIS work, scraping, dataset summaries, etc. are included and commented out to avoid bloat. The [`initialize_startr()`](https://globeandmail.github.io/upstartr/reference/initialize_startr.html) function also takes several other optional parameters — for a full list, see the [function's](https://globeandmail.github.io/upstartr/reference/initialize_startr.html) documentation.

Once you've listed the packages you want to import, you'll want to reference your raw data filenames. For instance, if you're adding pizza delivery data, you'd add this line to the filenames block in `config.R`:

```R
pizza.raw.file <- dir_data_raw('Citywide Pizza Deliveries 1998-2016.xlsx')
```

Our naming convention is to append `.raw` to variables that reference raw data, and `.file` to variables that are just filename strings.

#### Step 2: Import and process your data

In `process.R`, you'll consume the variables you created in `config.R`, clean them up, rename variables, deal with any errors, convert multiple data files to a common structure if necessary, and save out the result. It might look something like this:

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

When called via the `run_process()` function in `run.R`, variables generated during processing will be removed once the step is completed to keep the working environment clean for analysis.

We prefer to write out our outputs as a `.feather` file, which is a binary format designed to read and write files extremely fast (at roughly 600 MB/s). Feather files can also be opened in other analysis frameworks (i.e. Jupyter Notebooks) and, most importantly, have embedded column type data so that you don't have to re-assert them later. If you'd rather save out files in a different format, you can just use a different function, like the Tidyverse's `write_csv`.

Output files are written to `/data/processed` using the `dir_data_processed()` function. By design, processed files aren't checked into Git — you should be able to reproduce the analysis-ready files from someone else's project by running `process.R`.

#### Step 2: Do your analysis

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

#### Step 3: Visualize your analysis

You can use `visualize.R` to consume the variables created in `analyze.R`. For instance:

```R
plot_delivery_persons <- ggplot(delivery_person_counts, aes(x = person, y = n)) +
  geom_col() +
  coord_flip()

plot(plot_delivery_persons)

plot_deliveries_monthly <- ggplot(deliveries_monthly, aes(x = year_month, y = n)) +
  geom_col()

plot(plot_deliveries_monthly)

write_plot(plot_deliveries_monthly)
```

## Helper functions

`startr`'s companion package [`upstartr`](https://www.github.com/globeandmail/upstartr) comes with several functions to support `startr`, plus helpers we've found useful in daily data journalism tasks. A full list can be found on the [reference page here](https://globeandmail.github.io/upstartr/reference/index.html). Below is a partial list of some of its most handy functions:

- [`simplify_string`](https://globeandmail.github.io/upstartr/reference/simplify_string.html): By default, takes strings and simplifies them by force-uppercasing, replacing accents with non-accented characters, removing every non-alphanumeric character, and simplifying double/mutli-spaces into single spaces. Very useful when dealing with messy human-entry data with people's names, corporations, etc.

    ```r
    pizza_deliveries %>%
      mutate(customer_simplified = simplify_string(customer_name))
    ```

- [`clean_columns`](https://globeandmail.github.io/upstartr/reference/clean_columns.html): Renaming columns to something that doesn't have to be referenced with backticks (`` `Column Name!` ``) or square brackets (`.[['Column Name!']]`) gets tedious. This function speeds up the process by forcing everything to lowercase and using underscores – the tidyverse's preferred naming convention for columns. If there are many columns with the same name during cleanup, they'll be appended with an index number.

    ```r
    pizza_deliveries %>%
      rename_all(clean_columns)
    ```

- [`convert_str_to_logical`](https://globeandmail.github.io/upstartr/reference/convert_str_to_logical.html): Does the work of cleaning up your True, TRUE, true, T, False, FALSE, false, F, etc. strings to logicals.

    ```r
    pizza_deliveries %>%
      mutate(was_delivered_logi = convert_str_to_logical(was_delivered))
    ```

- [`calc_index`](https://globeandmail.github.io/upstartr/reference/calc_index.html): Calculate percentage growth by indexing values to the first value:

    ```r
    pizza_deliveries %>%
      mutate(year = year(date)) %>%
      group_by(size, year) %>%
      summarise(total_deliveries = n()) %>%
      arrange(year) %>%
      mutate(indexed_deliveries = index(total_deliveries))
    ```

- [`calc_mode`](https://globeandmail.github.io/upstartr/reference/calc_mode.html): Calculate the mode for a given field:

    ```r
    pizza_deliveries %>%
      group_by(pizza_shop) %>%
      summarise(most_common_size = mode(size))
    ```

- [`write_excel`](https://globeandmail.github.io/upstartr/reference/write_excel.html): Writes out an Excel file to `data/out` using the variable name as the file name. Useful for quickly generating summary tables for sharing with others. By design, doesn't take any arguments to keep things as simple as possible. If `should_timestamp_output_files` is set to TRUE in `config.R`, will append a timestamp to the filename in the format `%Y%m%d%H%M%S`.

    ```r
    undelivered_pizzas <- pizza_deliveries %>%
      filter(!was_delivered_logi)

    write_excel(undelivered_pizzas)
    ```

- [`write_plot`](https://globeandmail.github.io/upstartr/reference/write_plot.html): Similar to `write_excel`, designed to quickly save out a plot directly to `/plots`. Takes all the same arguments as `ggsave`.

    ```r
    plot_undelivered_pizzas <- undelivered_pizzas %>%
      group_by(year) %>%
      summarise(n = n()) %>%
      ggplot(aes(x = year, y = n)) +
      geom_col()

    write_plot(plot_undelivered_pizzas)
    ```

- [`read_all_excel_sheets`](https://globeandmail.github.io/upstartr/reference/read_all_excel_sheets.html): Combines all Excel sheets in a given file into a single dataframe, adding an extra column called `sheet` for the sheet name. Takes all the same arguments as `readxl`'s `read_excel`.

    ```r
    pizza_deliveries <- read_all_excel_sheets(
        pizza_deliveries.file,
        skip = 3,
      ) %>%
      rename(pizza_shop = 'sheet')
    ```

- [`combine_csvs`](https://globeandmail.github.io/upstartr/reference/combine_csvs.html): Read all CSVs in a given directory and concatenate them into a single file.

    ```r
    pizzas <- combine_csvs(dir_data_raw())
    ```

- [`combine_excels`](https://globeandmail.github.io/upstartr/reference/combine_excels.html): Read all Excel spreadsheets in a given directory and concatenate them.

    ```r
    pizzas_in_excel <- combine_excels(dir_data_raw())
    ```

- [`unaccent`](https://globeandmail.github.io/upstartr/reference/unaccent.html): Remove accents from strings.

    ```r
    unaccent('Montréal')
    ```

- [`remove_non_utf8`](https://globeandmail.github.io/upstartr/reference/remove_non_utf8.html): Remove non-UTF-8 characters from strings.

    ```r
    non_utf8 <- 'fa\xE7ile'
    Encoding(non_utf8) <- 'latin1'
    remove_non_utf8(non_utf8)
    ```

- [`%not_in%`](https://globeandmail.github.io/upstartr/reference/grapes-not_in-grapes.html): The opposite of the `%in%` operator.

    ```r
    c(1, 2, 3, 4, 5) %not_in% c(4, 5, 6, 7, 8)
    ```

- [`not.na`](https://globeandmail.github.io/upstartr/reference/not.na.html): The opposite of the `is.na` function.
- [`not.null`](https://globeandmail.github.io/upstartr/reference/not.null.html): The opposite of the `is.null` funciton.

## Tips for using `startr`

`startr` works best when you assume certain coding standards:
1. No variables should ever be overwritten or reassigned. Same goes for fields generated via `mutate()`.
2. If using RStudio (our preferred tool for work in R), restart and clear the environment often to make sure your code is reproducible.
3. Only ever run code sequentially to prevent order-of-execution accidents. In other words: don't jump around. For example, avoid running a block of code at line 22, then code at line 11, then some more code at line 37, since that may lead to unexpected results that another journalist won't be able to reproduce.
4. Treat raw data files (those in `data/raw`) as immutable and read-only.
5. Conversely, treat all outputs (everything else, including data, plots and reports) as a disposable product. By default, this project's `.gitignore` file ignores them, so they're never checked into source management tools.
6. For coding style, we rely on the [tidyverse style guide](https://style.tidyverse.org/).

## Directory structure

```bash
├── data/
│   ├── raw           # The original data files. Treat this directory as read-only.
│   ├── cache         # Cached files, mostly used when scraping or dealing with packages such as `cancensus`
│   ├── processed     # Imported and tidied data used throughout the analysis.
│   └── out           # Exports of data at key steps or as a final output.
├── R/
│   ├── process.R     # Data processing including tidying, processing and manupulation.
│   ├── analyze.R     # The primary analysis steps.
│   ├── visualize.R   # Generate plots as png, pdf, etc.
│   └── functions.R   # Project-specific functions.
├── scrape/
│   └── scrape.R      # Scraping scripts that save collected data to the `/data/raw/` directory.
├── plots/            # Visualizations saved out plot files in standard formats.
├── reports/          # Generated reports and associated files.
│   └── notebook.Rmd  # Standard notebook to render reports.
├── config.R          # Global project variables including packages, key project paths and data sources.
├── run.R             # Wrapper file to run the analysis steps, either inline or sourced from component R files.
└── startr.Rproj      # Rproj file for RStudio
```

An `.nvmrc` is included at the project root for scraping with Node. A `venv` and `requirements.txt` file should be included within the scraper directory if Python is used for scraping.

## See also

`startr` is part of a small ecosystem of R utilities. Those include:

- [**upstartr**](https://www.github.com/globeandmail/upstartr), a library of functions that support `startr` and daily data journalism tasks
- [**tgamtheme**](https://www.github.com/globeandmail/tgamtheme), The Globe and Mail's graphics theme
- [**startr-cli**](https://www.github.com/globeandmail/startr-cli), a command-line tool that scaffolds new `startr` projects

## Version

1.0.2

## License

startr © 2020 The Globe and Mail. It is free software, and may be redistributed under the terms specified in our MIT license.

## Get in touch

If you've got any questions, feel free to send us an email, or give us a shout on Twitter:

[![Michael Pereira](https://avatars0.githubusercontent.com/u/212666?v=3&s=200)](https://github.com/monkeycycle)| [![Tom Cardoso](https://avatars0.githubusercontent.com/u/2408118?v=3&s=200)](https://github.com/tomcardoso)
---|---
[Michael Pereira](mailto:mpereira@globeandmail.com) <br> [@__m_pereira](https://www.twitter.com/__m_pereira) | [Tom Cardoso](mailto:tcardoso@globeandmail.com) <br> [@tom_cardoso](https://www.twitter.com/tom_cardoso)
