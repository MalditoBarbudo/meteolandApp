# Call this function with an input (such as `textInput("text", NULL, "Search")`)
# if you want to add an input to the navbar (from dean attali,
# https://github.com/daattali/advanced-shiny)
navbarPageWithInputs <- function(..., inputs) {
  navbar <- shiny::navbarPage(...)
  form <- shiny::tags$form(class = "navbar-form", inputs)

  # browser()

  navbar[[4]][[1]][[1]]$children[[1]]$children[[2]] <- htmltools::tagAppendChild(
    navbar[[4]][[1]][[1]]$children[[1]]$children[[2]], form
  )
  navbar
}

#' translate app function
#'
#' translate the app based on the lang selected
translate_app <- function(id, lang) {
  # recursive call for vectors
  if (length(id) > 1) {
    res <- purrr::map_chr(
      id,
      .f = \(.id) {
        translate_app(.id, lang)
      }
    )
    return(res)
  }

  # get id translations
  id_row <- app_translations |>
    dplyr::filter(text_id == id)

  # return raw id if no matching id found
  if (nrow(id_row) < 1) {
    return(id)
  }

  # get the lang translation
  return(dplyr::pull(id_row, glue::glue("translation_{lang}")))
}

# get data function. As it results that the only difference between current and historic is
# in the special case of file with points, lets do all in one function:
#' get data function
#'
#' check and retrieve the data for the selected mode and type
get_data <- function(
  data_type, data_mode, date_range = NULL, custom_polygon = NULL,
  meteolanddb, geometry_id, lang, session
) {

  # browser()

  # raster type, works for both current and historic
  if (data_type == 'raster') {

    datevec <- date_range[1]:date_range[2] |>
      as.Date(format = '%j', origin = as.Date('1970-01-01')) |>
      as.character()

    # progress_values <- ((80/length(datevec))*(1:length(datevec))) + 5

    query_data <- datevec |>
      purrr::set_names() |>
      purrr::map(
        .f = ~ get_lowres_raster_safe(.x, meteolanddb, lang)
      ) |>
      purrr::keep(.p = ~ !rlang::is_na(.x))
  }

  # drawn_polygon, works for both current and historic
  if (data_type == 'drawn_polygon') {
    query_data <-
      meteolanddb$raster_interpolation(
        custom_polygon, as.character(date_range)
      )
  }

  # file, here we have two options:
  #   - POINTS, in this case the function to call is different for historical
  #     and current
  #   - POLYGONS, in this case is the same for current and historical
  if (data_type == 'file') {
    if (all(sf::st_is(custom_polygon, c('POLYGON', 'MULTIPOLYGON')))) {
      query_data <-
        meteolanddb$raster_interpolation(
          custom_polygon, as.character(date_range)
        )
    }

    if (all(sf::st_is(custom_polygon, 'POINT'))) {
      if (data_mode == 'current') {
        query_data <- meteolanddb$points_interpolation(
          custom_polygon, as.character(date_range), geometry_id, .as_sf = TRUE
        )
      }

      if (data_mode == 'historic') {
        query_data <- meteolanddb$historical_points_interpolation(
          custom_polygon, as.character(date_range), geometry_id
        )
      }
    }

  }

  return(query_data)
}

# helpers for current and historical modes raster retrieving
get_with_progress <- function(
  date, meteolanddb, lang
) {

  res <- meteolanddb$get_lowres_raster(date, 'stars')
  return(res)
}

get_lowres_raster_safe <- purrr::possibly(
  .f = get_with_progress,
  otherwise = NA
)


viz_date_mode_check <- function(date_range, viz_date) {
  dates_vec <- as.Date(
    (as.Date(date_range[1])):(as.Date(date_range[2])),
    format = '%j', origin = as.Date('1970-01-01')
  ) |> as.character()

  viz_date %in% dates_vec

}
