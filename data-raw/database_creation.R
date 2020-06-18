# database creation
library(RPostgres)

# source data
# source("data-raw/")
# source("data-raw/")
# source("data-raw/")

# # connection
# conn <- RPostgres::dbConnect(
#   RPostgres::Postgres(),
#   'ifn', 'laboratoriforestal.creaf.uab.cat', 5432, rstudioapi::askForPassword(),
#   'ifn'
# )
#
# # create database and activate postgis
# sql_table_creation_1 <- glue::glue_sql(
#   .con = conn,
#   "
#   CREATE DATABASE meteoland;
#   "
# )
# sql_table_creation_2 <- glue::glue_sql(
#   .con = conn,
#   "
#   GRANT ALL PRIVILEGES ON DATABASE meteoland TO ifn;
#   "
# )
# sql_table_creation_3 <- glue::glue_sql(
#   .con = conn,
#   "
#   GRANT CONNECT ON DATABASE meteoland TO guest;
#   "
# )
#
# RPostgres::dbExecute(conn, sql_table_creation_1)
# RPostgres::dbExecute(conn, sql_table_creation_2)
# RPostgres::dbExecute(conn, sql_table_creation_3)
#
# # change conn
# RPostgres::dbDisconnect(conn)
conn <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  'meteoland', 'laboratoriforestal.creaf.uab.cat',
  5432, rstudioapi::askForPassword(), 'ifn'
)

sql_guest_activation_1 <- glue::glue_sql(
  "
  GRANT USAGE ON SCHEMA public TO guest;
  "
)
sql_guest_activation_2 <- glue::glue_sql(
  "
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO guest;
  "
)
sql_guest_activation_3 <- glue::glue_sql(
  "
  ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO guest;
  "
)

RPostgres::dbExecute(conn, sql_guest_activation_1)
RPostgres::dbExecute(conn, sql_guest_activation_2)
RPostgres::dbExecute(conn, sql_guest_activation_3)

# postgis extension
rpostgis::pgPostGIS(conn, topology = TRUE, sfcgal = TRUE)

RPostgres::dbDisconnect(conn)
