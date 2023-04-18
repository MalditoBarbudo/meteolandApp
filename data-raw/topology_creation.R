library(stars)
library(rpostgis)
library(raster)
library(dplyr)
library(sf)
library(lfcdata)

## RAW (30m) TOPOGRAPHY (Raster)
# load the nc file
topology_data <- stars::read_ncdf('data-raw/Topology_grid.nc')
st_crs(topology_data) <-
  "+proj=utm +zone=31 +ellps=WGS84 +datum=WGS84 +units=m +towgs84=0,0,0"

# st_crs(topology_data) <- st_crs(25831)


topology_data <- st_warp(topology_data, crs = 3043)

topology_elevation <- as(topology_data[1,,], "Raster")
topology_slope <- as(topology_data[2,,], "Raster")
topology_aspect <- as(topology_data[3,,], "Raster")

topology_stack <-
  raster::stack(topology_elevation, topology_slope, topology_aspect)
names(topology_stack) <- c('elevation', 'slope', 'aspect')

# now, write the topology raster in the postgres db
# conn
conn <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  'meteoland', 'laboratoriforestal.creaf.cat',
  5432, rstudioapi::askForPassword(), 'ifn'
)

# Write Stack
rpostgis::pgWriteRast(
  conn, 'topology_cat', topology_stack, blocks = 50, overwrite = TRUE
)
# Indexes for each layer
dbExecute(
  conn,
  "CREATE INDEX topology_rast_st_convexhull_idx ON topology_cat USING gist( ST_ConvexHull(rast) );"
)


## TOPOGRAPHY 1km (Points)
# raster tipo for the grid
raster_tipo <- raster::raster(
  '../../03_lidar_app/lidarappkg/data-raw/AB.tif'
) |>
  raster::aggregate(fact = 50)

# get the center of cells from the raster tipo
centers_sf <- raster_tipo |>
  raster::coordinates() |>
  as.data.frame() |>
  sf::st_as_sf(
    coords = c('x', 'y'),
    crs = "+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
  ) |>
  sf::st_transform(crs = 3043) #|>
# dplyr::slice(1:544)

# the grid specs for later in the pixels step
grid_specs <- sp::points2grid(sf::as_Spatial(centers_sf))

# dates test
user_dates <- c("2020-05-01", "2020-05-01")

# LFCMeteoland object to work with methods
meteolanddb <- meteoland()

# lets extract the user topology !!! 3 HOURS !!!!!
all_cells_topo <-
  meteolanddb$.__enclos_env__$private$get_points_topography(centers_sf)

# we create now a sf table in the database with the topo data for 1km grid,
# this will be used in the daily grid update instead of retrieving from the db,
# as it is really time consuming. Here we remove all sea points, and also all
# points outside Catalunya, to reduce the points to check
catalunya_polys <- sf::read_sf(
  '../../01_nfi_app/NFIappkg/data-raw/shapefiles/catalunya.shp'
) |>
  dplyr::select(poly_id = NOM_CA, geometry) |>
  sf::st_set_crs(value = 3043)

all_cells_catalunya <-
  cbind(all_cells_topo@coords, all_cells_topo@data) |>
  sf::st_as_sf(coords = c('coords.x1', 'coords.x2'), crs = 3043) |>
  dplyr::slice(sf::st_intersects(catalunya_polys, .)[[1]]) |>
  dplyr::mutate(point_id = 1:nrow(.))

# now we need to recreate the topology object, but with the land data
land_topo_1km <- meteoland::SpatialPointsTopography(
  points = sf::as_Spatial(all_cells_catalunya),
  elevation = all_cells_catalunya$elevation,
  slope = all_cells_catalunya$slope,
  aspect = all_cells_catalunya$aspect
)

# now we save/load the objects, land_topo_1km and all_cells_land_sf to avoid time
# consuming step of extracting the points from the 30m raster table
save(
  all_cells_catalunya, land_topo_1km,
  file = 'data-raw/land_topo_1km.RData'
)
load('data-raw/land_topo_1km.RData')

sf::st_write(
  all_cells_catalunya,
  conn,
  layer = 'topo_land_points_km',
  layer_options = "OVERWRITE=true"
)

RPostgres::dbDisconnect(conn)
