library(dplyr)
library(stringr)
library(purrr)
library(meteoland)

# files
cv_files <- list.files(
  'data-raw/cv_files/CrossValidations/', '_calibrated.rds', full.names = TRUE
)

summarise_cv <- function(index) {
  index_year <- stringr::str_extract(cv_files[index], '[0-9]+')
  cv_files[index] %>%
    readRDS() %>%
    meteoland::summary.interpolation.cv() %>%
    tibble::rownames_to_column('variable') %>%
    dplyr::as_tibble() %>%
    dplyr::mutate(
      year = index_year
    ) %>%
    dplyr::select(
      variable, year, everything()
    )
}

cv_summary <- seq_along(cv_files) %>%
  purrr::map_dfr(summarise_cv)




db_conn <- pool::dbPool(
  RPostgres::Postgres(),
  dbname = 'meteoland', host = 'laboratoriforestal.creaf.cat', port = 5432,
  password = rstudioapi::askForPassword(), user = 'ifn'
)

dplyr::copy_to(
  db_conn, cv_summary, 'crossvalidation_summary',
  overwrite = TRUE, temp = FALSE
)

pool::poolClose(db_conn)

