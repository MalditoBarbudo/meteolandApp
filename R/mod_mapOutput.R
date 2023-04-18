#' @title mod_mapOutput and mod_map
#'
#' @description Shiny module to generate the map
#'
#' @param id shiny id
#'
#' @export
mod_mapOutput <- function(id) {
  # ns
  ns <- shiny::NS(id)
  shiny::tagList(
    leaflet::leafletOutput(ns("meteoland_map"), height = 600),
    shiny::uiOutput(ns('map_container'))
  )
}

#' mod_map server function
#'
#' @details mod_map is in charge of setting the points/polygons (sf) and rasters
#'   in the leaflet projection.
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @param data_reactives,viz_reactives,main_data_reactives reactives
#' @param lang lang selected
#'
#' @export
#'
#' @rdname mod_mapOutput
mod_map <- function(
  input, output, session,
  data_reactives, viz_reactives, main_data_reactives,
  lang
) {

  ## renderUI ####
  output$map_container <- shiny::renderUI({
    shiny::tags$div(
      id = 'cite',
      translate_app('cite_div', lang())
    )
  }) # end of renderUI

  ## leaflet output (empty map) ####
  output$meteoland_map <- leaflet::renderLeaflet({

    # we need data, and we need color var at least
    leaflet::leaflet() |>
      leaflet::setView(2.36, 41.70, zoom = 8) |>
      leaflet::addProviderTiles(
        leaflet::providers$Esri.WorldShadedRelief, group = 'Relief',
        # avoid raster disappearing when base tiles change
        options = leaflet::providerTileOptions(zIndex = -10)
      ) |>
      leaflet::addProviderTiles(
        leaflet::providers$Esri.WorldImagery, group = 'Imaginery',
        # avoid raster disappearing when base tiles change
        options = leaflet::providerTileOptions(zIndex = -10)
      ) |>
      leaflet::addProviderTiles(
        leaflet::providers$OpenStreetMap,
        group = translate_app('OSM', lang()),
        # avoid raster disappearing when base tiles change
        options = leaflet::providerTileOptions(zIndex = -10)
      ) |>
      leaflet::addProviderTiles(
        leaflet::providers$Esri.WorldGrayCanvas,
        group = translate_app('WorldGrayCanvas', lang()),
        # avoid raster disappearing when base tiles change
        options = leaflet::providerTileOptions(zIndex = -10)
      ) |>
      leaflet::addProviderTiles(
        leaflet::providers$CartoDB.PositronNoLabels,
        group = translate_app('PositronNoLabels', lang()),
        # avoid raster disappearing when base tiles change
        options = leaflet::providerTileOptions(zIndex = -10)
      ) |>
      leaflet::addMapPane('raster', zIndex = 410) |>
      leaflet::addMapPane('plots', zIndex = 420) |>
      leaflet::addLayersControl(
        baseGroups = c('Relief', 'Imaginery', 'OSM', 'WorldGrayCanvas', 'PositronNoLabels'),
        options = leaflet::layersControlOptions(collapsed = TRUE, autoZIndex = FALSE)
      ) |>
      # leaflet.extras plugins
      leaflet.extras::addDrawToolbar(
        targetGroup = 'drawn_poly',
        position = 'topleft',
        polylineOptions = FALSE, circleOptions = FALSE,
        rectangleOptions = FALSE, markerOptions = FALSE,
        circleMarkerOptions = FALSE,
        polygonOptions = leaflet.extras::drawPolygonOptions(
          shapeOptions = leaflet.extras::drawShapeOptions()
        ),
        editOptions = leaflet.extras::editToolbarOptions(
          edit = TRUE, remove = TRUE
        ),
        singleFeature = TRUE
      )
  }) # end of leaflet output (empty map)

  ## reactives ####
  map_data <- shiny::reactive({

    # map_data reactive is in cahrge to transform to the leaflet projection

    shiny::validate(
      shiny::need(main_data_reactives$main_data, 'no data yet'),
      shiny::need(viz_reactives$viz_date, 'no viz inputs yet')
    )

    # needed reactives
    main_data <- main_data_reactives$main_data
    # data_mode <- data_reactives$data_mode
    # data_type <- data_reactives$data_type
    date_range <- data_reactives$date_range
    # viz_color <- viz_reactives$viz_color
    viz_date <- viz_reactives$viz_date

    # here we validate that viz_date is in the correct mode
    shiny::validate(
      shiny::need(viz_date_mode_check(date_range, viz_date), 'incorrect data mode')
    )

    # browser()

    if (is(main_data, 'sf')) {
      data_res <- main_data |>
        sf::st_transform(crs = 4326) |>
        dplyr::filter(date == viz_date)

      # validation of the filtering
      if (nrow(data_res) < 1) {
        shinyWidgets::sendSweetAlert(
          session = session,
          title = translate_app('sweet_alert_date_missing_title', lang()),
          text = translate_app('sweet_alert_date_missing_text', lang())
        )

        shiny::validate(
          shiny::need(nrow(data_res) > 0, 'no data for this date')
        )
      }

    } else {

      data_res <- main_data |>
        magrittr::extract2(viz_date)
      # validation of the filtering
      if (is.null(data_res)) {
        shinyWidgets::sendSweetAlert(
          session = session,
          title = translate_app('sweet_alert_date_missing_title', lang()),
          text = translate_app('sweet_alert_date_missing_text', lang())
        )
        shiny::validate(
          shiny::need(data_res, 'no data for this date')
        )
      }

      # data_res <- data_res |>
      #   leaflet::projectRasterForLeaflet('bilinear')
    }

    # return the map data
    return(data_res)
  })

  ## observers ####
  # observers to update the map. Here also we need to check if we have a raster
  # or an sf, and update map proxy accordingly
  shiny::observe({
    shiny::validate(
      shiny::need(map_data(), 'no map data yet'),
      shiny::need(viz_reactives$viz_color, 'no viz inputs yet')
    )

    # needed reactives
    pre_map_data <- map_data()
    # data_mode <- data_reactives$data_mode
    # data_type <- data_reactives$data_type
    # date_range <- data_reactives$date_range
    viz_color <- viz_reactives$viz_color
    viz_date <- viz_reactives$viz_date
    viz_pal_reverse <- viz_reactives$viz_pal_reverse

    # validate that pre_map_data has a viz_color variable or layer. In this
    # case is the same for rasters or sf, as we use names
    if (!viz_color %in% names(pre_map_data)) {
      shinyWidgets::sendSweetAlert(
        session = session,
        title = translate_app('sweet_alert_all_nas_title', lang()),
        text = translate_app('sweet_alert_all_nas_text', lang())
      )
    }
    shiny::validate(
      shiny::need(viz_color %in% names(pre_map_data), 'no variable present')
    )

    # viz_color palette, both for sf and raster
    viridis_pal_name <- switch(
      viz_color,
      'MeanTemperature' = viridis::rocket(256),
      'MinTemperature' = viridis::rocket(256),
      'MaxTemperature' = viridis::plasma(256),
      "ThermalAmplitude" = viridis::rocket(256),
      'MeanRelativeHumidity' = viridis::mako(256, direction = -1),
      'MinRelativeHumidity' = viridis::mako(256, direction = -1),
      'MaxRelativeHumidity' = viridis::mako(256, direction = -1),
      'Precipitation' = viridis::cividis(256, direction = -1),
      'Radiation' = viridis::inferno(256),
      'WindSpeed' = viridis::viridis(256),
      'PET' = viridis::cividis(256)
    )

    # branching to show raster or points, depending on nature of map data
    if (is(pre_map_data, 'sf')) {
      # palette configuration
      color_vector <- pre_map_data |>
        dplyr::pull(!! rlang::sym(viz_color))

      # we need values on the variable, not all NAs, so
      #   1. we check and show a warning in case all NAs
      if (all(is.na(color_vector))) {
        shinyWidgets::sendSweetAlert(
          session = session,
          title = translate_app('sweet_alert_all_nas_title', lang()),
          text = translate_app('sweet_alert_all_nas_text', lang())
        )
      }
      #   2. we validate to avoid continuing the calculations and hence the
      #      error.
      shiny::validate(
        shiny::need(!all(is.na(color_vector)), 'all NAs')
      )

      color_palette <- leaflet::colorNumeric(
        viridis_pal_name, color_vector, reverse = viz_pal_reverse,
        na.color = 'black'
      )
      color_palette_legend <- leaflet::colorNumeric(
        viridis_pal_name, color_vector, reverse = !viz_pal_reverse,
        na.color = 'black'
      )

      # update the map
      leaflet::leafletProxy('meteoland_map') |>
        leaflet::clearGroup('plots') |>
        leaflet::clearGroup('raster') |>
        leaflet::addCircles(
          data = pre_map_data,
          group = 'plots', label = ~poly_id, layerId = ~poly_id,
          stroke = FALSE, fillOpacity = 0.7,
          fillColor = color_palette(color_vector),
          radius = 750,
          options = leaflet::pathOptions(pane = 'plots')
        ) |>
        leaflet::addLegend(
          position = 'bottomright', pal = color_palette_legend,
          values = color_vector,
          title = glue::glue("{translate_app(viz_color, lang())} {viz_date}"),
          layerId = 'color_legend', opacity = 1,
          na.label = '', className = 'info legend na_out',
          labFormat = leaflet::labelFormat(
            transform = function(x) {sort(x, decreasing = TRUE)}
          )
        )

    } else {

      layer_data <- pre_map_data[viz_color]
      color_vector <- layer_data[[1]] |> as.numeric()

      # we need values on the variable, not all NAs, so
      #   1. we check and show a warning in case all NAs
      if (all(is.na(color_vector))) {
        shinyWidgets::sendSweetAlert(
          session = session,
          title = translate_app('sweet_alert_all_nas_title', lang()),
          text = translate_app('sweet_alert_all_nas_text', lang())
        )
      }
      #   2. we validate to avoid continuing the calculations and hence the
      #      error.
      shiny::validate(
        shiny::need(!all(is.na(color_vector)), 'all NAs')
      )

      # palette configuration
      color_palette <- leaflet::colorNumeric(
        viridis_pal_name, color_vector, reverse = viz_pal_reverse,
        na.color = 'transparent'
      )
      color_palette_legend <- leaflet::colorNumeric(
        viridis_pal_name, color_vector, reverse = !viz_pal_reverse,
        na.color = 'transparent'
      )

      # update the map
      leaflet::leafletProxy('meteoland_map') |>
        leaflet::clearGroup('plots') |>
        leaflet::clearGroup('raster') |>
        leaflet::addRasterImage(
          terra::rast(layer_data), project = TRUE, colors = color_palette, opacity = 0.8,
          group = 'raster', layerId = 'raster'
        ) |>
        leaflet::addLegend(
          position = 'bottomright', pal = color_palette_legend,
          values = color_vector,
          title = glue::glue("{translate_app(viz_color, lang())} {viz_date}"),
          layerId = 'color_legend', opacity = 1,
          na.label = '', className = 'info legend na_out',
          labFormat = leaflet::labelFormat(
            transform = function(x) {sort(x, decreasing = TRUE)}
          )
        )
    }
  })

  ## reactives to return ####
  map_reactives <- shiny::reactiveValues()
  shiny::observe({
    map_reactives$meteoland_map_shape_click <- input$meteoland_map_shape_click
    map_reactives$meteoland_map_draw_all_features <-
      input$meteoland_map_draw_all_features
    map_reactives$meteoland_map_click <- input$meteoland_map_click
  })
  return(map_reactives)
}
