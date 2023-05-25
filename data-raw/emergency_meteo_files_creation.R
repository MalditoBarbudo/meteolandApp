## Emergency init of meteo data (one year + 1 month)
library(meteospain)
library(dplyr)
library(purrr)

# env
readRenviron("/data/25_secrets/lfc_development_env")

# prepare dates for loop
start_dates <- seq(Sys.Date()-395, Sys.Date()-1, "months")
end_dates <- seq(Sys.Date()-365, Sys.Date()+30, "months") - 1

# aemet loop
aemet_data <- purrr::map2(
  .x = start_dates[1:3], .y = end_dates[1:3],
  .f = \(start_date, end_date) {
    res <- get_meteo_from(
      "aemet",
      aemet_options(
        api_key = Sys.getenv("AEMET"),
        resolution = "daily",
        start_date = start_date,
        end_date = end_date
      )
    )
    Sys.sleep(0.8)
    return(res)
  }
) |>
  purrr::list_rbind()

meteocat_data <- purrr::map(
  .x = start_dates[1:3],
  .f = \(start_date) {
    res <- get_meteo_from(
      "meteocat",
      meteocat_options(
        api_key = Sys.getenv("METEOCAT"),
        resolution = "daily",
        start_date = start_date
      )
    )
    Sys.sleep(0.3)
    return(res)
  }
) |>
  purrr::list_rbind()

# Now we have
