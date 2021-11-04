library(raster)
library(stars)
library(tidyverse)

# list of files, we remove 1975 because we already did it in the tests
nc_files <- list.files(
  "../miquel/Climate/Products/Pixels1k/Historical/Daily/", "nc$",
  full.names = TRUE
)

db_conn <- pool::dbPool(
  RPostgres::Postgres(),
  dbname = 'meteoland', host = 'laboratoriforestal.creaf.cat', port = 5432,
  password = 'IFN2018creaf', user = 'ifn'
)
db_checkout <- pool::poolCheckout(db_conn)

# iterate over year files
for (file_year in nc_files) {

  year_data <- stars::read_stars(file_year, proxy = TRUE, sub = c(3:11, 13))

  # iterate over dayss in the year file, as we create a table for each day
  # 1:stars::st_dimensions(year_data)$time$to %>% as.numeric()
  for (d in 1:stars::st_dimensions(year_data)$time$to %>% as.numeric()) {

    tictoc::tic()
    date_posix <- st_get_dimension_values(year_data, 'time')[d]
    date_name <- date_posix %>%
      as.character() %>%
      stringr::str_sub(1, 10) %>%
      stringr::str_remove_all('-')
    table_name <- glue::glue("daily_historic_raster_interpolated_{date_name}")
    message(glue::glue("Creating raster table: {table_name}\n\n"))

    message(pryr::mem_used())
    res_stack <- year_data[,,,d, drop = TRUE] %>%
      st_as_stars() %>%
      merge() %>%
      as('Raster') %>%
      magrittr::set_names(names(year_data))
    res_stack[['ThermalAmplitude']] <- res_stack[['MaxTemperature']] - res_stack[['MinTemperature']]
    raster::projection(res_stack) <- crs('+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
    message(pryr::mem_used())
    message(pryr::object_size(res_stack))

    write_raster_try <- try({
      rpostgis::pgWriteRast(
        db_checkout, table_name, res_stack, overwrite = TRUE
      )
    })

    if (class(write_raster_try) == 'try-error') {
      pool::poolReturn(db_checkout)
      pool::poolClose(db_conn)
      Sys.sleep(60)

      db_conn <- pool::dbPool(
        RPostgres::Postgres(),
        dbname = 'meteoland', host = 'laboratoriforestal.creaf.cat', port = 5432,
        password = 'IFN2018creaf', user = 'ifn'
      )
      db_checkout <- pool::poolCheckout(db_conn)

      rpostgis::pgWriteRast(
        db_checkout, table_name, res_stack, overwrite = TRUE
      )
    }
    tictoc::toc()
  }
}

pool::poolReturn(db_checkout)
pool::poolClose(db_conn)
