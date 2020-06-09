library(dplyr)

get_all_stations_daily_data <- function(cat, spa) {

  if (all(!file.exists(cat), !file.exists(spa))) {
    return()
  }

  if (file.exists(cat)) {
    cat_res <- read.table(cat, TRUE, '\t') %>%
      dplyr::mutate(
        stationCode = row.names(.),
        stationOrigin = 'SMC'
      ) %>%
      dplyr::as_tibble()
  } else {
    cat_res <- NULL
  }

  if (file.exists(spa)) {
    spa_res <- read.table(spa, TRUE, '\t') %>%
      dplyr::mutate(
        stationCode = row.names(.),
        stationOrigin = 'AEMET'
      ) %>%
      dplyr::as_tibble()
  } else {
    spa_res <- NULL
  }

  # return the join if both exists or the one that exists
  if (all(!is.null(cat_res), !is.null(spa_res))) {
    res <- dplyr::full_join(cat_res, spa_res)
    return(res)
  } else {
    if (!is.null(cat_res)) {
      return(cat_res)
    } else {
      return(spa_res)
    }
  }
}

daily_meto_data_update <- function(db_conn, path_cat, path_spa, overwrite) {
  # dates vector to check, they must be one year long ending in the day before of
  # the present day
  dates_vec <- as.Date(
    (Sys.Date() - 366):(Sys.Date() - 1), # one year long
    format = '%j', origin = as.Date('1970-01-01')
  ) %>%
    as.character()

  # Loop the dates for the following:
  # Now we are going to check if the table for the corresponding day exists in the
  # database. If not, we create it with the data. If it exists, we check overwrite
  # argument and if is TRUE we overwrite with the new data, if is FALSE we skip it
  for (date_i in dates_vec) {
    # table name
    table_name <- glue::glue("daily_meteo_{stringr::str_remove_all(date_i, '-')}")
    # check if table exists
    is_table_in_db <- dplyr::db_has_table(db_conn, table_name)

    # only go ahead if overwirte is on or table does not exist
    if (any(overwrite, !is_table_in_db)) {

      file_name <- glue::glue("{date_i}.txt")
      file_path_cat <- file.path(path_cat, file_name)
      file_path_spa <- file.path(path_spa, file_name)

      all_stations_data <-
        get_all_stations_daily_data(file_path_cat, file_path_spa)

      # if data exists, write it!!
      if (!is.null(all_stations_data)) {
        dplyr::copy_to(
          db_conn, all_stations_data, table_name,
          overwrite = TRUE, temp = FALSE
        )
      }
    }
  }

  # the last part is to remove previous dates from the database. We will make
  # a buffer of 30 days, this way we can be sure that previous days are really
  # removed
  dates_to_rem <- as.Date(
    (Sys.Date() - 397):(Sys.Date() - 367), # one year long
    format = '%j', origin = as.Date('1970-01-01')
  ) %>%
    as.character()

  for (date_r in dates_to_rem) {
    # table name
    table_name_r <- glue::glue("daily_meteo_{stringr::str_remove_all(date_i, '-')}")
    # check if table exists and remove it
    if (dplyr::db_has_table(db_conn, table_name_r)) {
      dplyr::db_drop_table(db_conn, table_name_r, force = TRUE)
    }
  }

  return(invisible(TRUE))
}


# arguments
overwrite <- TRUE
db_conn <- pool::dbPool(
  RPostgres::Postgres(),
  dbname = 'meteoland', host = 'laboratoriforestal.creaf.uab.cat', port = 5432,
  password = rstudioapi::askForPassword(), user = 'ifn'
)
path_cat <- # file.path("/home", "miquel", "Climate", "Sources", "SMC", "Download", "DailyCAT")
  "data-raw/daily_meteo_data/DailyCAT"
path_spa <- # file.path("/home", "miquel", "Climate", "Sources", "AEMET", "Download", "DailySPAIN")
  "data-raw/daily_meteo_data/DailySPAIN"
daily_meto_data_update(db_conn, path_cat, path_spa, overwrite)

pool::poolClose(db_conn)
