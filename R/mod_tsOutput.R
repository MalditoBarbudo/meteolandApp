#' mod_tsOutput and mod_ts
#'
#' @description A shiny module to generate and populate the time series output
#'
#' @param id shiny id
#'
#' @export
mod_tsOutput <- function(id) {
  # ns
  ns <- shiny::NS(id)

  # UI ####
  shiny::tagList(
    shiny::uiOutput(ns('mod_ts_panel'))
  )
}

#' mod_ts server function
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @param data_reactives,main_data_reactives reactives needed
#' @param lang lang value
#'
#' @export
#'
#' @rdname mod_tsOutput
mod_ts <- function(
  input, output, session,
  viz_reactives, main_data_reactives, map_reactives,
  lang
) {

  # time series data reactive
  # Two options:
  #   - For points, click in the buttton and activate the ts
  #   - For raster, record the click on the map and create the ts from
  #     the raster extraction


  # We need to take the sf object with the points info, filter the points
  # selected by the user, and convert to xts
  ts_data <- shiny::reactive({

    # validate if there is main data
    shiny::validate(
      shiny::need(main_data_reactives$main_data, 'no data yet')
    )

    # check if main data is an sf or not
    main_data <- main_data_reactives$main_data

    if (is(main_data, 'sf')) {

      date_index <- main_data_reactives$main_data$date %>%
        unique() %>%
        as.Date()

      # filter the sf object with the points selected
      main_data %>%
        dplyr::as_tibble() %>%
        dplyr::select(
          dplyr::all_of(c('date', 'geometry_id', viz_reactives$viz_color))
        ) %>%
        dplyr::filter(geometry_id %in% viz_reactives$ts_points) %>%
        # convert the sf object to a xts object to use with dygraphs
        tidyr::pivot_wider(
          names_from = 'geometry_id',
          values_from = viz_reactives$viz_color
        ) %>%
        dplyr::select(-date) %>%
        xts::as.xts(order.by = date_index)

    } else {

      # browser()

      shiny::validate(
        shiny::need(map_reactives$meteoland_map_click, 'no click')
      )

      date_index <- names(main_data) %>%
        unique() %>%
        as.Date()

      # we need to create the sf object from the coordinates on the map
      coordinates_sf <- tibble::tibble(
        lat = map_reactives$meteoland_map_click$lat,
        lng = map_reactives$meteoland_map_click$lng,
        geometry_id = glue::glue("click")
      ) %>%
        sf::st_as_sf(
          coords = c('lng', 'lat'), crs = sf::st_crs(4326)
        )

      main_data %>%
        purrr::map(
          ~ raster::extract(.x, coordinates_sf, sp = TRUE)
        ) %>%
        purrr::map(
          ~ dplyr::as_tibble(.x)
        ) %>%
        purrr::imap_dfr(
          ~ dplyr::mutate(.x, date = .y)
        ) %>%
        dplyr::select(
          dplyr::all_of(c('date', 'geometry_id', viz_reactives$viz_color))
        ) %>%
        # convert the sf object to a xts object to use with dygraphs
        tidyr::pivot_wider(
          names_from = 'geometry_id',
          values_from = viz_reactives$viz_color
        ) %>%
        dplyr::select(-date) %>%
        xts::as.xts(order.by = date_index)

    }



  })

  # renderUI
  output$mod_ts_panel <- shiny::renderUI({

    # ns
    ns <- session$ns

    # taglist
    shiny::tagList(
      shiny::fluidPage(
        dygraphs::dygraphOutput(ns('ts_plot'))
      )
    )
  })

  # dygraph
  output$ts_plot <- dygraphs::renderDygraph({

    ts_data() %>%
      dygraphs::dygraph(
        main = translate_app(viz_reactives$viz_color, lang())
      ) %>%
      dygraphs::dyHighlight(
        highlightCircleSize = 5,
        highlightSeriesBackgroundAlpha = 1,
        hideOnMouseOut = TRUE
      ) %>%
      dygraphs::dyLegend(show = "follow") %>%
      dygraphs::dyOptions(
        axisLineWidth = 1.5, drawGrid = FALSE
      )

  })

}
