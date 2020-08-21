library(stars)
library(sf)
library(raster)
library(fasterize)
library(tidyverse)

db_conn <- pool::dbPool(
  RPostgres::Postgres(),
  dbname = 'meteoland', host = 'laboratoriforestal.creaf.uab.cat', port = 5432,
  password = rstudioapi::askForPassword(), user = 'ifn'
)

# year_1976 <- stars::read_ncdf('data-raw/1976_historical_netCDF.nc')

year_1976 <- stars::read_stars('data-raw/1976_historical_netCDF.nc', proxy = TRUE)

for (day in 1:stars::st_dimensions(year_1976)$time$to %>% as.numeric()) {

  date_posix <- st_get_dimension_values(year_1976, 'time')[day]
  date_name <- date_posix %>%
    as.character() %>%
    stringr::str_sub(1, 10) %>%
    stringr::str_remove_all('-')
  table_name <- glue::glue("daily_historic_raster_interpolated_{date_name}")
  message(glue::glue("Creating raster table: {table_name}"))

  res_MeanTemperature <- as(year_1976['MeanTemperature',,,day, drop = TRUE], 'Raster')
  raster::projection(res_MeanTemperature) <- crs('+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
  res_MinTemperature <- as(year_1976['MinTemperature',,,day, drop = TRUE], 'Raster')
  raster::projection(res_MinTemperature) <- crs('+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
  res_MaxTemperature <- as(year_1976['MaxTemperature',,,day, drop = TRUE], 'Raster')
  raster::projection(res_MaxTemperature) <- crs('+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
  res_MeanRelativeHumidity <- as(year_1976['MeanRelativeHumidity',,,day, drop = TRUE], 'Raster')
  raster::projection(res_MeanRelativeHumidity) <- crs('+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
  res_MinRelativeHumidity <- as(year_1976['MinRelativeHumidity',,,day, drop = TRUE], 'Raster')
  raster::projection(res_MinRelativeHumidity) <- crs('+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
  res_MaxRelativeHumidity <- as(year_1976['MaxRelativeHumidity',,,day, drop = TRUE], 'Raster')
  raster::projection(res_MaxRelativeHumidity) <- crs('+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
  res_Precipitation <- as(year_1976['Precipitation',,,day, drop = TRUE], 'Raster')
  raster::projection(res_Precipitation) <- crs('+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
  res_Radiation <- as(year_1976['Radiation',,,day, drop = TRUE], 'Raster')
  raster::projection(res_Radiation) <- crs('+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
  res_WindSpeed <- as(year_1976['WindSpeed',,,day, drop = TRUE], 'Raster')
  raster::projection(res_WindSpeed) <- crs('+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
  res_WindDirection <- as(year_1976['WindDirection',,,day, drop = TRUE], 'Raster')
  raster::projection(res_WindDirection) <- crs('+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')

  res_stack <- raster::stack(
    res_MeanTemperature, res_MinTemperature, res_MaxTemperature,
    res_MeanRelativeHumidity, res_MinRelativeHumidity, res_MaxRelativeHumidity,
    res_Precipitation, res_Radiation, res_WindSpeed, res_WindDirection
  )
  names(res_stack) <- c(
    'MeanTemperature', 'MinTemperature', 'MaxTemperature',
    'MeanRelativeHumidity', 'MinRelativeHumidity', 'MaxRelativeHumidity',
    'Precipitation', 'Radiation', 'WindSpeed', 'WindDirection'
  )

  db_checkout <- pool::poolCheckout(db_conn)
  rpostgis::pgWriteRast(
    db_checkout, table_name, res_stack, overwrite = TRUE
  )
  pool::poolReturn(db_checkout)

}

pool::poolClose(db_conn)
