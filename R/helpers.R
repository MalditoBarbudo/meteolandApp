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

#' current_mode function
#'
#' check and retrieve the data for the current mode
current_mode_data <- function(
  data_type, date_range = NULL, custom_polygon = NULL,
  meteolanddb, geometry_id, progress_obj, lang
) {

  if (data_type == 'raster') {

    datevec <- date_range[1]:date_range[2] %>%
      as.Date(format = '%j', origin = as.Date('1970-01-01')) %>%
      as.character()

    progress_values <- ((80/length(datevec))*(1:length(datevec))) + 5

    get_with_progress <- function(
      date, progress_value, progress_obj, meteolanddb, lang
    ) {
      progress_obj$set(
        detail = glue::glue(
          "{translate_app('progress_detail_raster', lang())} {date}"
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

    current_data <- datevec %>%
      magrittr::set_names(., .) %>%
      purrr::map2(
        .y = progress_values,
        .f = ~ get_lowres_raster_safe(.x, .y, progress_obj, meteolanddb, lang())
      ) %>%
      purrr::keep(.p = ~ !rlang::is_na(.x))
  }

  if (data_type == 'file') {
    if (all(sf::st_is(custom_polygon, 'POINT'))) {
      pre_data <- meteolanddb$points_interpolation(
          custom_polygon, as.character(date_range), geometry_id
        )

      coords_df <- pre_data@coords %>%
        as.data.frame %>%
        dplyr::mutate(geometry_id = names(pre_data@data))

      meteo_df <- pre_data@data %>%
        purrr::imap_dfr(
          function(x, y) {
            x %>%
              dplyr::mutate(geometry_id = y, date = rownames(x))
          }
        )

      current_data <- meteo_df %>%
        dplyr::left_join(coords_df, by = 'geometry_id') %>%
        sf::st_as_sf(coords = c('coords.x1', 'coords.x2'), crs = 3043) %>%
        sf::st_transform(4326)

    }

    if (all(sf::st_is(custom_polygon, c('POLYGON', 'MULTIPOLYGON')))) {
      current_data <-
        meteolanddb$raster_interpolation(custom_polygon, as.character(date_range))
    }
  }

  if (data_type == 'drawn_polygon') {
    current_data <-
      meteolanddb$raster_interpolation(custom_polygon, as.character(date_range))
  }

  return(current_data)
}
