library(stars)
library(rpostgis)
library(raster)
library(dplyr)
library(sf)

# load the nc file
topology_data <- stars::read_ncdf('data-raw/Topology_grid.nc')
stars::write_stars(topology_data, 'data-raw/elevation.tiff', 'Elevation')
stars::write_stars(topology_data, 'data-raw/aspect.tiff', 'Aspect')
stars::write_stars(topology_data, 'data-raw/slope.tiff', 'Slope')

# convert to raster
topology_stack <- raster::stack(
  'data-raw/elevation.tiff', 'data-raw/aspect.tiff', 'data-raw/slope.tiff'
) %>%
  raster::flip(direction = 'y')

raster::crs(topology_stack) <- raster::crs(
  "+proj=utm +zone=31 +ellps=WGS84 +datum=WGS84 +units=m +towgs84=0,0,0"
)

# now, write the topology raster in the postgres db
# conn
conn <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  'meteoland', 'laboratoriforestal.creaf.uab.cat',
  5432, rstudioapi::askForPassword(), 'ifn'
)

# Add postgis extension to database (only once)
# rpostgis::pgPostGIS(conn)

# Write Brick
rpostgis::pgWriteRast(
  conn, 'topology', topology_stack, blocks = 50, overwrite = TRUE
)
# Indexes for each layer
dbExecute(
  conn,
  "CREATE INDEX topology_rast_st_convexhull_idx ON topology USING gist( ST_ConvexHull(rast) );"
)

RPostgres::dbDisconnect(conn)
