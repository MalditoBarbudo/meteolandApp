# libraries
library(stars)
library(terra)
library(dplyr)
library(sf)
library(lfcdata)

# env
readRenviron("/data/25_secrets/lfc_development_env")

# db
db_conn <- pool::dbPool(
  drv = RPostgres::Postgres(),
  dbname = Sys.getenv("METEO_DB"),
  host = Sys.getenv("METEO_DB_HOST"),
  user = Sys.getenv("METEO_DB_USER"),
  password = Sys.getenv("METEO_DB_PASS"),
  idleTimeout = 3600,
  options = "-c client_min_messages=warning"
)
withr::defer(pool::poolClose(db_conn))


# 200m topo -----------------------------------------------------------------------------------

# Topology sf.
# the gpkg file was created by M. de Caceres for the app engine.
# It is a points sf with the cells coordinates for a grid of 200x200m (400128 points)
topology_sf <- sf::st_read("data-raw/sf_topo_cat.gpkg") |>
  dplyr::mutate(point_id = 1:length(geom))

# Save to db
sf::st_write(
  topology_sf, db_conn,
  layer = "topo_land_points_200", layer_options = "OVERWRITE=true"
)

# 1km topo ------------------------------------------------------------------------------------

# topology object
topology_data <- stars::read_ncdf("data-raw/Topology_grid.nc")
sf::st_crs(topology_data) <- "+proj=utm +zone=31 +ellps=WGS84 +datum=WGS84 +units=m +towgs84=0,0,0"
topology_data <- st_warp(topology_data, crs = 3043)

topology_elevation <- as(topology_data[1,,], "Raster")
topology_slope <- as(topology_data[2,,], "Raster")
topology_aspect <- as(topology_data[3,,], "Raster")

topology_stack <-
  raster::stack(topology_elevation, topology_slope, topology_aspect)
names(topology_stack) <- c('elevation', 'slope', 'aspect')

# topology_terra <- terra::rast(topology_data)
# names(topology_terra) <- names(topology_data)

# remove
rm(topology_data, topology_elevation, topology_slope, topology_aspect)
gc()

# write to db
# db_conn <- pool::dbPool(
#   drv = RPostgres::Postgres(),
#   dbname = Sys.getenv("METEO_DB"),
#   host = Sys.getenv("METEO_DB_HOST"),
#   user = Sys.getenv("METEO_DB_USER"),
#   password = Sys.getenv("METEO_DB_PASS"),
#   idleTimeout = 3600,
#   options = "-c client_min_messages=warning"
# )
# withr::defer(pool::poolClose(db_conn))

pc <- pool::poolCheckout(db_conn)

# rpostgis::pgWriteRast(
#   pc, "topology_cat", topology_stack, blocks = 50, overwrite = TRUE
# )

lfcdata:::write_raster_to_db(
  topology_terra, db_conn, "topology_cat", blocks = 50, .overwrite = TRUE
)

pool::poolReturn(pc)

# create index
pool::dbExecute(
  db_conn,
  "CREATE INDEX topology_rast_st_convexhull_idx ON topology_cat USING gist( ST_ConvexHull(rast) );"
)

# create the topology dataset with points
# raster_tipo (base on the topology created by Miquel)
raster_extent <- terra::ext(c(xmin = 256000, xmax = 528000, ymin = 4488000, ymax = 4752000))
raster_res <- c(1000, 1000)
raster_platon <- terra::rast(extent = raster_extent, resolution = raster_res, crs = "epsg:3043")

# points object
cells_sf <- terra::xyFromCell(raster_platon, terra::cells(raster_platon)) |>
  dplyr::as_data_frame() |>
  sf::st_as_sf(
    coords = c("x", "y"),
    crs = 3043
  )

mdb <- lfcdata::meteoland()
all_cells_topo <- mdb$.__enclos_env__$private$get_points_topography(cells_sf)

# we need to clip by catalonia
catalunya_poly <- sf::read_sf(
  '../../01_nfi_app/NFIappkg/data-raw/shapefiles/catalunya.shp'
) |>
  dplyr::select(poly_id = NOM_CA, geometry) |>
  sf::st_set_crs(value = 3043)

land_topo_1km <- all_cells_topo |>
  sf::st_filter(catalunya_poly)

land_topo_1km$point_id <- 1:nrow(land_topo_1km)

# now we save/load the objects, land_topo_1km and all_cells_land_sf to avoid time
# consuming step of extracting the points from the 30m raster table
save(
  all_cells_topo, land_topo_1km,
  file = 'data-raw/land_topo_1km.RData'
)
# load('data-raw/land_topo_1km.RData')

# write to db
sf::st_write(land_topo_1km, db_conn, layer = "topo_land_points_km", layer_options = "OVERWRITE=true")

