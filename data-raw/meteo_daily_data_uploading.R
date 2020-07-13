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

prepare_daily_grid_raster <- function(date_i, topo) {

  topo_meteoland <- meteoland::SpatialPointsTopography(
    points = sf::as_Spatial(topo),
    elevation = topo$elevation,
    slope = topo$slope,
    aspect = topo$aspect
  )

  interpolation_cat_day <-
    lfcdata::meteoland()$points_interpolation(
      topo, user_dates = c(date_i, date_i), 'point_id', .topo = topo_meteoland
    )

  interpolation_data <-
    list(data = meteoland::extractdates(interpolation_cat_day)@data)
  names(interpolation_data) <- interpolation_cat_day@dates

  # taken from the raster tipo in the topology creation script.
  grid_specs_manual <- sp::GridTopology(
    cellcentre.offset = c(256500, 4488500),
    cellsize = c(1000, 1000),
    cells.dim = c(272, 264)
  )

  # we build a pixels object because then we can create the rasters easily
  res_pixels <- meteoland::SpatialPixelsMeteorology(
    points = interpolation_cat_day,
    data = interpolation_data,
    dates = interpolation_cat_day@dates,
    grid = grid_specs_manual
  )

  res_stars <- as(res_pixels, 'stars')
  res_MeanTemperature <- as(res_stars['MeanTemperature'], 'Raster')
  res_MinTemperature <- as(res_stars['MinTemperature'], 'Raster')
  res_MaxTemperature <- as(res_stars['MaxTemperature'], 'Raster')
  res_MeanRelativeHumidity <- as(res_stars['MeanRelativeHumidity'], 'Raster')
  res_MinRelativeHumidity <- as(res_stars['MinRelativeHumidity'], 'Raster')
  res_MaxRelativeHumidity <- as(res_stars['MaxRelativeHumidity'], 'Raster')
  res_Precipitation <- as(res_stars['Precipitation'], 'Raster')
  res_Radiation <- as(res_stars['Radiation'], 'Raster')
  res_WindSpeed <- as(res_stars['WindSpeed'], 'Raster')
  res_WindDirection <- as(res_stars['WindDirection'], 'Raster')

  res_stack <- raster::stack(
    res_MeanTemperature,
    res_MinTemperature,
    res_MaxTemperature,
    res_MeanRelativeHumidity,
    res_MinRelativeHumidity,
    res_MaxRelativeHumidity,
    res_Precipitation,
    res_Radiation,
    res_WindSpeed,
    res_WindDirection
  )
  names(res_stack) <- c(
    'MeanTemperature',
    'MinTemperature',
    'MaxTemperature',
    'MeanRelativeHumidity',
    'MinRelativeHumidity',
    'MaxRelativeHumidity',
    'Precipitation',
    'Radiation',
    'WindSpeed',
    'WindDirection'
  )

  return(res_stack)
}

daily_meto_data_update <- function(db_conn, path_cat, path_spa, overwrite) {
  # dates vector to check, they must be one year long ending in the day before of
  # the present day
  dates_vec <- as.Date(
    (Sys.Date() - 365):Sys.Date(), # one year long
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

    message(glue::glue("Updating the daily meteo table for {date_i}..."))
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

    message(glue::glue("daily raster for {date_i}"))
    # now the interpolation for grids
    grid_table_name <- glue::glue(
      "daily_raster_interpolated_{stringr::str_remove_all(date_i, '-')}"
    )
    is_raster_in_db <- dplyr::db_has_table(db_conn, grid_table_name)

    if (any(overwrite, !is_raster_in_db)) {
      # topology 1km
      topo_1km <- sf::read_sf(
        db_conn, 'topo_land_points_km'
      )

      message("creating raster stack...")
      res_stack <- prepare_daily_grid_raster(date_i, topo_1km)

      # Write Stack
      message("writing raster stack...")
      db_checkout <- pool::poolCheckout(db_conn)
      rpostgis::pgWriteRast(
        db_checkout, grid_table_name, res_stack, overwrite = TRUE
      )
      pool::poolReturn(db_checkout)
    }
  }

  # the last part is to remove previous dates from the database. We will make
  # a buffer of 30 days, this way we can be sure that previous days are really
  # removed
  dates_to_rem <- as.Date(
    (Sys.Date() - 396):(Sys.Date() - 366), # one year long
    format = '%j', origin = as.Date('1970-01-01')
  ) %>%
    as.character()

  for (date_r in dates_to_rem) {
    # table name
    table_name_rem <- glue::glue("daily_meteo_{stringr::str_remove_all(date_r, '-')}")
    # check if table exists and remove it
    if (dplyr::db_has_table(db_conn, table_name_rem)) {
      dplyr::db_drop_table(db_conn, table_name_rem, force = TRUE)
    }

    # precalculated grids remove
    grid_table_name_rem <- glue::glue(
      "daily_raster_interpolated_{stringr::str_remove_all(date_r, '-')}"
    )
    # check if table exists and remove it
    if (dplyr::db_has_table(db_conn, grid_table_name_rem)) {
      dplyr::db_drop_table(db_conn, grid_table_name_rem, force = TRUE)
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

tictoc::tic()
daily_meto_data_update(db_conn, path_cat, path_spa, overwrite)
tictoc::toc()

pool::poolClose(db_conn)
