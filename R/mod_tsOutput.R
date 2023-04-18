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

      date_index <- main_data_reactives$main_data$date |>
        unique() |>
        as.Date()

      # filter the sf object with the points selected
      res <- main_data |>
        dplyr::as_tibble() |>
        dplyr::select(
          dplyr::all_of(c('date', 'poly_id', viz_reactives$viz_color))
        ) |>
        dplyr::filter(poly_id %in% viz_reactives$ts_points) |>
        # convert the sf object to a xts object to use with dygraphs
        tidyr::pivot_wider(
          names_from = 'poly_id',
          values_from = viz_reactives$viz_color
        ) |>
        dplyr::select(-date) |>
        xts::as.xts(order.by = date_index)

    } else {

      # browser()

      shiny::validate(
        shiny::need(map_reactives$meteoland_map_click, 'no click')
      )

      date_index <- names(main_data) |>
        unique() |>
        as.Date()

      # we need to create the sf object from the coordinates on the map
      coordinates_sf <- tibble::tibble(
        lat = map_reactives$meteoland_map_click$lat,
        lng = map_reactives$meteoland_map_click$lng
      ) |>
        sf::st_as_sf(
          coords = c('lng', 'lat'), crs = sf::st_crs(4326)
        )

      res <- main_data |>
        purrr::map(
          ~ stars::st_extract(.x, sf::st_transform(coordinates_sf, crs = sf::st_crs(.x)))
        ) |>
        purrr::map(
          ~ dplyr::as_tibble(.x)
        ) |>
        purrr::imap_dfr(
          ~ dplyr::mutate(.x, date = .y, poly_id = glue::glue("click"))
        ) |>
        dplyr::select(
          dplyr::all_of(c('date', 'poly_id', viz_reactives$viz_color))
        ) |>
        # convert the sf object to a xts object to use with dygraphs
        tidyr::pivot_wider(
          names_from = 'poly_id',
          values_from = viz_reactives$viz_color
        ) |>
        dplyr::select(-date) |>
        xts::as.xts(order.by = date_index)

      attr(res, 'coords') <- glue::glue(
        "(long: {round(map_reactives$meteoland_map_click$lng, 2)}; ",
        "lat: {round(map_reactives$meteoland_map_click$lat, 2)})"
      )

    }

    return(res)



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

    # check if only one date and rise a warning in that case
    if (nrow(ts_data()) < 2) {
      shinyWidgets::sendSweetAlert(
        session = session,
        title = translate_app('ts_one_date', lang()),
        text = ''
      )
    }

    shiny::validate(
      shiny::need(
        nrow(ts_data()) > 1,
        translate_app('ts_one_date', lang())
      )
    )

    dygraph_main <- glue::glue(
      "{translate_app(viz_reactives$viz_color, lang())} ",
      "{if (is.null(attr(ts_data(), 'coords'))) {''} else {attr(ts_data(), 'coords')}}"
    )

    ts_data() |>
      dygraphs::dygraph(
        main = dygraph_main
      ) |>
      dygraphs::dyAxis("x", drawGrid = FALSE) |>
      dygraphs::dyHighlight(
        highlightCircleSize = 5,
        highlightSeriesBackgroundAlpha = 1,
        hideOnMouseOut = TRUE
      ) |>
      dygraphs::dyLegend(
        show = "follow", labelsSeparateLines = TRUE
      ) |>
      dygraphs::dyOptions(
        axisLineWidth = 1.5,
        # drawGrid = FALSE,
        axisLineColor = '#647a8d', axisLabelColor = '#647a8d',
        includeZero = TRUE, gridLineColor = '#647a8d'
      )

  })

}
