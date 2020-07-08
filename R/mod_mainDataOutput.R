#' @title mod_mainDataOutput and mod_mainData
#'
#' @description Shiny module to get the data
#'
#' @param id
#'
#' @export
mod_mainDataOutput <- function(id) {
  ns <- shiny::NS(id)
  return()
}

#' @title mod_mainData server function
#'
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @param data_reactives,map_reactives,apply_reactives reactives from modules
#' @param meteolanddb object to access the meteoland db
#' @param lang lang selected
#' @param parent_session parent session to be able to update tabset panel
#'
#' @importFrom dplyr n
#'
#' @export
#'
#' @rdname mod_mainDataOuput
mod_mainData <- function(
  input, output, session,
  data_reactives, map_reactives, apply_reactives,
  meteolanddb, lang, parent_session
) {

  # custom polygon ####
  # we need to check if custom polygon, to retrieve it and build the data later
  custom_polygon <- shiny::reactive({

    shiny::validate(
      shiny::need(data_reactives$data_type, 'no inputs yet')
    )

    data_type <- data_reactives$data_type
    path_to_file <- data_reactives$user_file_sel$datapath

    # TODO check extensions and throw an exception if not zip or gpkg

    # file
    if (data_type == 'file') {
      # check if there is user file
      if (is.null(path_to_file)) {
        user_file_polygons <- NULL
      } else {
        # check if zip (shapefile) or gpkg to load the data
        if (stringr::str_detect(path_to_file, 'zip')) {
          tmp_folder <- tempdir()
          utils::unzip(path_to_file, exdir = tmp_folder)

          user_file_polygons <- sf::st_read(
            list.files(tmp_folder, '.shp', recursive = TRUE, full.names = TRUE),
            as_tibble = TRUE
          ) %>%
            sf::st_transform(3043)
        } else {
          # gpkg
          user_file_polygons <- sf::st_read(path_to_file) %>%
            sf::st_transform(3043)
        }
      }

      shiny::validate(
        shiny::need(user_file_polygons, 'no file provided')
      )

      # rename the poly_id
      names(user_file_polygons)[1] <- 'geometry_id'

      return(user_file_polygons)
    }

    if (data_type == 'drawn_polygon') {

      # validation
      drawn_polygon <- map_reactives$meteoland_map_draw_all_features
      # When removing the features (custom polygon) the
      # input$map_draw_new_feature is not cleared, so is always filtering the
      # sites, even after removing. For that we need to control when the removed
      # feature equals the new, that's it, when we removed the last one
      shiny::validate(
        shiny::need(drawn_polygon, 'no draw polys yet'),
        shiny::need(length(drawn_polygon[['features']]) != 0, 'removed poly')
      )
      res <-
        drawn_polygon[['features']][[1]][['geometry']][['coordinates']] %>%
        purrr::flatten() %>%
        purrr::modify_depth(1, purrr::set_names, nm = c('long', 'lat')) %>%
        dplyr::bind_rows() %>%
        {list(as.matrix(.))} %>%
        sf::st_polygon() %>%
        sf::st_sfc() %>%
        sf::st_sf(crs = 4326) %>%
        sf::st_transform(crs = 3043) %>%
        dplyr::mutate(geometry_id = 'drawn_polygon')
      return(res)
    }
  })

  ## main data.
  # Let's get the data inputs, and depending on mode and type lets use the
  # metelanddb method (points or raster).
  main_data <- shiny::eventReactive(
    eventExpr = apply_reactives$apply_button,
    valueExpr = {

      # browser()
      # inputs
      data_mode <- data_reactives$data_mode
      data_type <- data_reactives$data_type
      date_range <- data_reactives$date_range
      # custom polygons
      user_polygon <- custom_polygon()

      if (data_mode == 'current') {
        main_data <- try(current_mode_data(
          data_type, date_range, user_polygon, meteolanddb, 'geometry_id'
        ))
        ## TODO add sweet alert indicating data can not be retrieved
        # validate that main_data is not try-error
        shiny::validate(
          shiny::need(class(main_data) != 'try-error', 'no data')
        )
      }

      if (data_mode == 'historic') {
        main_data <- NULL
        ## TODO Complete when historic method is implemented
      }

      return(main_data)
    }
  )

  ## reactives to return ####
  main_data_reactives <- shiny::reactiveValues()
  shiny::observe({
    main_data_reactives$custom_polygon <- custom_polygon()
    main_data_reactives$main_data <- main_data()
  })
  return(main_data_reactives)

}
