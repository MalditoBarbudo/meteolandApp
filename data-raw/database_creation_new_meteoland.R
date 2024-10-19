# test database creation
readRenviron(Sys.getenv("LFC_ENV_PATH"))

# Create db from su account
db_conn_su <- pool::dbPool(
  RPostgres::Postgres(),
  dbname = Sys.getenv("SU_DB"),
  host = Sys.getenv("METEO_DB_HOST"),
  port = Sys.getenv("METEO_DB_PORT"),
  password = Sys.getenv("METEO_DB_PASS"),
  user = Sys.getenv("METEO_DB_USER"),
  idleTimeout = 3600
)

withr::defer(pool::poolClose(db_conn_su))

# create database and activate postgis
sql_table_creation_1 <- glue::glue_sql(
  .con = db_conn_su,
  "
  CREATE DATABASE new_meteoland;
  "
)
sql_table_creation_2 <- glue::glue_sql(
  .con = db_conn_su,
  "
  GRANT ALL PRIVILEGES ON DATABASE new_meteoland TO ifn;
  "
)
sql_table_creation_3 <- glue::glue_sql(
  .con = db_conn_su,
  "
  GRANT CONNECT ON DATABASE new_meteoland TO guest;
  "
)

pool::dbExecute(db_conn_su, sql_table_creation_1)
pool::dbExecute(db_conn_su, sql_table_creation_2)
pool::dbExecute(db_conn_su, sql_table_creation_3)

# enter the new db and config
db_conn_meteo <- pool::dbPool(
  RPostgres::Postgres(),
  dbname = Sys.getenv("METEO_DB"),
  host = Sys.getenv("METEO_DB_HOST"),
  port = Sys.getenv("METEO_DB_PORT"),
  password = Sys.getenv("METEO_DB_PASS"),
  user = Sys.getenv("METEO_DB_USER"),
  idleTimeout = 3600
)
withr::defer(pool::poolClose(db_conn_meteo))

sql_guest_activation_1 <- glue::glue_sql(
  "
  GRANT USAGE ON SCHEMA public TO guest;
  ", .con = db_conn_meteo
)
sql_guest_activation_2 <- glue::glue_sql(
  "
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO guest;
  ", .con = db_conn_meteo
)
sql_guest_activation_3 <- glue::glue_sql(
  "
  ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO guest;
  ", .con = db_conn_meteo
)

schema_query <- glue::glue_sql(
  "CREATE SCHEMA IF NOT EXISTS daily;",
  .con = db_conn_meteo
)

sql_guest_activation_4 <- glue::glue_sql(
  "
  GRANT USAGE ON SCHEMA daily TO guest;
  ",
  .con = db_conn_meteo
)
sql_guest_activation_5 <- glue::glue_sql(
  "
  GRANT SELECT ON ALL TABLES IN SCHEMA daily TO guest;
  ",
  .con = db_conn_meteo
)
sql_guest_activation_6 <- glue::glue_sql(
  "
  ALTER DEFAULT PRIVILEGES IN SCHEMA daily
    GRANT SELECT ON TABLES TO guest;
  ",
  .con = db_conn_meteo
)

pool::dbExecute(db_conn_meteo, sql_guest_activation_1)
pool::dbExecute(db_conn_meteo, sql_guest_activation_2)
pool::dbExecute(db_conn_meteo, sql_guest_activation_3)
pool::dbExecute(db_conn_meteo, schema_query)
pool::dbExecute(db_conn_meteo, sql_guest_activation_4)
pool::dbExecute(db_conn_meteo, sql_guest_activation_5)
pool::dbExecute(db_conn_meteo, sql_guest_activation_6)

# add postgis extensions
pool::dbExecute(db_conn_meteo, "CREATE EXTENSION postgis;")
pool::dbExecute(db_conn_meteo, "CREATE EXTENSION postgis_topology;")
pool::dbExecute(db_conn_meteo, "CREATE EXTENSION postgis_sfcgal;")
pool::dbExecute(db_conn_meteo, "CREATE EXTENSION postgis_raster;")

# create original tables
drop_table_query_low <- glue::glue_sql(
  "DROP TABLE IF EXISTS daily.meteoland_low CASCADE;",
  .con = db_conn_meteo
)
drop_table_query_pngs <- glue::glue_sql(
  "DROP TABLE IF EXISTS daily.pngs CASCADE;",
  .con = db_conn_meteo
)

create_table_query_low <- glue::glue_sql(
  .con = db_conn_meteo,
  "
   CREATE TABLE daily.meteoland_low (
       id serial NOT NULL PRIMARY KEY,
       rid int NOT NULL,
       band_names text[],
       day date NOT NULL,
       rast raster
   );
   "
)

create_table_query_pngs <- glue::glue_sql(
  .con = db_conn_meteo,
  "
   CREATE TABLE daily.pngs (
       date character(8),
       var varchar(20),
       palette_selected varchar(15),
       base64_string text,
       left_ext numeric,
       down_ext numeric,
       right_ext numeric,
       up_ext numeric,
       min_value numeric,
       max_value numeric
   );
  "
)

pool::dbExecute(db_conn_meteo, drop_table_query_low)
pool::dbExecute(db_conn_meteo, create_table_query_low)
pool::dbExecute(db_conn_meteo, drop_table_query_pngs)
pool::dbExecute(db_conn_meteo, create_table_query_pngs)
