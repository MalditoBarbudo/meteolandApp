# Call this function with an input (such as `textInput("text", NULL, "Search")`)
# if you want to add an input to the navbar (from dean attali,
# https://github.com/daattali/advanced-shiny)
navbarPageWithInputs <- function(..., inputs) {
  navbar <- shiny::navbarPage(...)
  form <- shiny::tags$form(class = "navbar-form", inputs)

  # browser()

  navbar[[3]][[1]]$children[[1]]$children[[2]] <- htmltools::tagAppendChild(
    navbar[[3]][[1]]$children[[1]]$children[[2]], form
  )
  navbar
}

#' translate app function
#'
#' translate the app based on the lang selected
translate_app <- function(id, lang) {

  app_translations

  id %>%
    purrr::map_chr(
      ~ app_translations %>%
        dplyr::filter(text_id == .x) %>% {
          data_filtered <- .
          if (nrow(data_filtered) < 1) {
            message(glue::glue("{.x} not found in app thesaurus"))
            .x
          } else {
            dplyr::pull(data_filtered, !! rlang::sym(glue::glue("translation_{lang}")))
          }
        }
    )
}

# get data function. As it results that the only difference between current and historic is
# in the special case of file with points, lets do all in one function:
#' get data function
#'
#' check and retrieve the data for the selected mode and type
get_data <- function(
  data_type, data_mode, date_range = NULL, custom_polygon = NULL,
  meteolanddb, geometry_id, progress_obj, lang
) {

  # browser()

  # raster type, works for both current and historic
  if (data_type == 'raster') {
    datevec <- date_range[1]:date_range[2] %>%
      as.Date(format = '%j', origin = as.Date('1970-01-01')) %>%
      as.character()

    progress_values <- ((80/length(datevec))*(1:length(datevec))) + 5

    query_data <- datevec %>%
      magrittr::set_names(., .) %>%
      purrr::map2(
        .y = progress_values,
        .f = ~ get_lowres_raster_safe(.x, .y, progress_obj, meteolanddb, lang)
      ) %>%
      purrr::keep(.p = ~ !rlang::is_na(.x))
  }

  # drawn_polygon, works for both current and historic
  if (data_type == 'drawn_polygon') {
    progress_obj$set(
      message = glue::glue(
        "{translate_app('progress_message_drawn_polygon', lang())}"
      ),
      value = 45
    )

    query_data <-
      meteolanddb$raster_interpolation(custom_polygon, as.character(date_range))

    progress_obj$set(
      value = 85
    )
  }

  # file, here we have two options:
  #   - POINTS, in this case the function to call is different for historical and current
  #   - POLYGONS, in this case is the same for current and historical
  if (data_type == 'file') {
    progress_obj$set(
      message = glue::glue(
        "{translate_app('progress_message_file', lang())}"
      ),
      value = 45
    )

    if (all(sf::st_is(custom_polygon, c('POLYGON', 'MULTIPOLYGON')))) {
      query_data <-
        meteolanddb$raster_interpolation(custom_polygon, as.character(date_range))
    }

    if (all(sf::st_is(custom_polygon, 'POINT'))) {
      if (data_mode == 'current') {
        query_data <- meteolanddb$points_interpolation(
          custom_polygon, as.character(date_range), geometry_id, .as_sf = TRUE
        ) %>%
          sf::st_transform(4326)
      }

      if (data_mode == 'historic') {
        query_data <- meteolanddb$historical_points_interpolation(
          custom_polygon, as.character(date_range), geometry_id
        ) %>%
          sf::st_transform(4326)
      }
    }

    progress_obj$set(
      value = 85
    )

  }

  return(query_data)
}

# helpers for current and historical modes raster retrieving
get_with_progress <- function(
  date, progress_value, progress_obj, meteolanddb, lang
) {

  progress_obj$set(
    message = glue::glue(
      "{translate_app('progress_message_raster', lang())} {date}"
    ),
    value = progress_value
  )

  res <- meteolanddb$get_lowres_raster(date, 'raster')
  return(res)
}

get_lowres_raster_safe <- purrr::possibly(
  .f = get_with_progress,
  otherwise = NA
)
