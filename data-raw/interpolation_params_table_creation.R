library(dplyr)
library(stringr)
library(purrr)

# files
interpolator_files <- list.files(
  'data-raw/interpolation_objects', '_calibrated.rds', full.names = TRUE
)

# function to use in map, it loads the file and extract the parameters, buidling
# a tibble with an extra column indicating the year
interpolation_params_extractor <- function(file) {
  interpolator <- readRDS(file)
  dplyr::as_tibble(interpolator@params) %>%
    mutate(year = stringr::str_extract(file, pattern = "[0-9]+"))
}

# map_dfr
interpolation_params_table <-
  interpolator_files %>%
  purrr::map_dfr(interpolation_params_extractor) %>%
  dplyr::arrange(year)

db_conn <- pool::dbPool(
  RPostgres::Postgres(),
  dbname = 'meteoland', host = 'laboratoriforestal.creaf.cat', port = 5432,
  password = rstudioapi::askForPassword(), user = 'ifn'
)

dplyr::copy_to(
  db_conn, interpolation_params_table, 'interpolation_parameters',
  overwrite = TRUE, temp = FALSE
)

pool::poolClose(db_conn)






