# startr

A template for data journalism projects in R.

This project structures the data analysis process around an expected set of files and steps. This lowers the upfront effort of starting and maintaining a project and supports easier verification by providing reviewers with an expected and logically organized project. Think of it like Ruby on Rails or React, but for R analysis.

Broadly, the goals of `startr` are to:

* Remove the need for thinking about how to structure your project so you can focus on actual analysis
* Support a flexible analysis workflow
  * Clearly defined stages can be shared across a team
  * Adapt to large and small projects
* Improve analysis verification process
  * Make it easier to verify logic of the analysis by cutting down on spaghetti code
  * Track any logical errors by enforcing certain standards (e.g. no variable reassignment)
* In cases where a large, multi-disciplinary team is working on a project, improve communication between data journalists and reporters throughout the analysis
  * Document data details including dimensions, column names and field types and glossary
  * Capture reporting questions and answers from the data
  * Generate updatable reports, graphics, and datasets throughout the analysis

Input files are treated as raw and read-only while outputs, including data, plots and reports, are treated as a disposable product. No variables should ever be overwritten or reassigned to prevent order-of-execution accidents.


## How do I use this?

This template works with R and RStudio, so you'll need both of those installed. Then, just clone down this project, or, better yet, use our scaffolding tool, [`startr-cli`](https://www.github.com/globeandmail/startr-cli).

Once the project's cloned, double-click on the `.Rproj` file to start a scoped RStudio instance.

You can then start adding your data and writing your analysis. At The Globe, we like to work in a code editor like Atom or Sublime Text, and use something like [`r-exec`](https://atom.io/packages/r-exec) to send code chunks to RStudio.


## Example workflow using `startr`

Here's how we use `startr` for our own analysis workflow right now. The heart of the project lies in these three files:

* **`process.R`**: Imports source data, tidies it, fixes errors, sets types, applies manipulations and saves out a CSV ready for analysis (or, in other cases, a shapefile, etc.).

* **`analyze.R`**: Consumes the data files saved out by `process.R`, and is where all of the true "analysis" occurs, including grouping, summarizing, filtering, etc. All descriptive and relational statistical analysis. More complicated analysis can be split into additional `analyze_somestep.R` files as required.

* **`visualize.R`**: Generates plots.

#### Step 1: Set up your project

Packages are managed through the `packages` list in the `config.R` file. `devtools` and `here` are loaded by default. The `load_requirements()` function loads, and optionally installs, required packages.

The bulk of the analysis is based on a set of files within the `R` directory which are sourced and run in order by `run.R` at the project root.

Before starting an analysis, you'll want to point to your data files in `config.R` and make sure it's loading all the packages you'll need. For instance, you might want to add the [`cancensus`](https://github.com/mountainMath/cancensus) package. To do that, just add `'cancensus'` to the `packages` vector. Package suggestions for GIS work, scraping, dataset summaries, etc.  are included and commented out to avoid bloat.

Once that's done, you'll want to reference your raw data filenames. For instance, if you're adding pizza delivery data, you'd add this line to the "Files" block in `config.R`:

```R
pizza.raw.file <- 'Citywide Pizza Deliveries 1998-2016.xlsx'
```

Our naming convention is to append `.raw` to variables that reference raw data, and `.file` to variables that are just filename strings.

#### Step 2: Import and process your data

In `process.R`, you'll consume the variables you created in `config.R`, clean them up, rename variables, deal with any errors, convert multiple data files to a common structure if necessary, and save out the result, plus some cleanup at the end so as to not pollute the environment. It might look something like this:

```R
pizza.raw <- read_excel(here::here(dir_data_raw, pizza.raw.file), skip = 2) %>%
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

write_csv(pizza.raw, here::here(dir_data_processed, 'pizza.csv'))

rm(pizza.raw)
```

The output files written to `dir_data_processed` (that is, `/data/processed`) aren't checked into Git by design — you should be able to reproduce the analysis-ready files from someone else's project by running `process.R`.

#### Step 2: Do your analysis

This part's as simple as consuming that file in `analyze.R` and running with it. It might look something like this:

```R
pizza <- read_csv(here::here(dir_data_processed, 'pizza.csv'))

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

ggsave(plot_deliveries_monthly, file = here::here(dir_plots, 'plot_deliveries_monthly.png'), width = 6.5, height = 6.5)
```

## Directory structure

```bash
├── data/
│   ├── raw         # The original data files. Treat this directory as read-only.
│   ├── cache       # Cached files, mostly used when scraping or dealing with packages such as `cancensus`
│   ├── processed   # Imported and tidied data used throughout the analysis.
│   └── out         # Exports of data at key steps or as a final output.
├── R/
│   ├── process.R   # Data processing including tidying, processing and manupulation.
│   ├── analyze.R   # The primary analysis steps.
│   ├── visualize.R # Generate plots as png, pdf, etc.
│   ├── utils.R     # Commonly-used functions.
│   └── functions.R # Project-specific functions.
├── scrape/
│   └── scrape.R    # Scraping scripts that save collected data to the `/data/raw/` directory.
├── plots/          # Visualizations saved out plot files in standard formats.
├── reports/        # Generated reports and associated files.
├── config.R        # Global project variables including packages, key project paths and data sources.
├── run.R           # Wrapper file to run the analysis steps, either inline or sourced from component R files.
├── notebook.Rmd    # Standard notebook to render reports.
└── startr.Rproj    # Rproj file for RStudio
```

An `.nvmrc` is included at the project root for scraping with Node. A `venv` and `requirements.txt` file should be included within the scraper directory if Python is used for scraping.

## Version

1.0.1

## License

startr © 2019 The Globe and Mail. It is free software, and may be redistributed under the terms specified in our MIT license.

## Get in touch

If you've got any questions, feel free to send us an email, or give us a shout on Twitter:

[![Michael Pereira](https://avatars0.githubusercontent.com/u/212666?v=3&s=200)](https://github.com/monkeycycle)| [![Tom Cardoso](https://avatars0.githubusercontent.com/u/2408118?v=3&s=200)](https://github.com/tomcardoso)
---|---
[Michael Pereira](mailto:mpereira@globeandmail.com) <br> [@__m_pereira](https://www.twitter.com/__m_pereira) | [Tom Cardoso](mailto:tcardoso@globeandmail.com) <br> [@tom_cardoso](https://www.twitter.com/tom_cardoso)
