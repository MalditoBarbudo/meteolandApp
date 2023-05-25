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

pool::dbExecute(db_conn_meteo, sql_guest_activation_1)
pool::dbExecute(db_conn_meteo, sql_guest_activation_2)
pool::dbExecute(db_conn_meteo, sql_guest_activation_3)

# add postgis extensions
pool::dbExecute(db_conn_meteo, "CREATE EXTENSION postgis;")
pool::dbExecute(db_conn_meteo, "CREATE EXTENSION postgis_topology;")
pool::dbExecute(db_conn_meteo, "CREATE EXTENSION postgis_sfcgal;")
