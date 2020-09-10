#' @title mod_saveOutput and mod_save
#'
#' @description module for creating the astounding viz when click
#'
#' @param id shiny id
#'
#' @export
mod_saveOutput <- function(id) {
  # ns
  ns <- shiny::NS(id)
  # ui
  shiny::tagList(
    shiny::br(),
    shiny::uiOutput(ns("save_container"))
  )
}

#' mod_save
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @param lang lang selected
#' @param main_data_reactives reactives needed
#'
#' @export
#'
#' @rdname mod_saveOutput
mod_save <- function(
  input, output, session,
  main_data_reactives, data_reactives,
  lang
) {

  ## renderUI ####
  output$save_container <- shiny::renderUI({

    ns <- session$ns

    shiny::tagList(
      shiny::br(),
      shiny::fluidRow(
        # save remarks column
        # shiny::column(
        #   6, align = 'center',
        #   shiny::br(),
        #   shiny::br(),
        #   shiny::downloadButton(
        #     ns('save_map_btn'),
        #     label = translate_app('save_map_btn', lang())
        #   )
        # ),
        shiny::column(
          8, align = 'left', offset = 0,
          shiny::p(translate_app('save_remarks_2', lang())),
          shiny::span(
            shiny::p(
              translate_app('save_remarks', lang()),
              shiny::tags$a(
                "https://epsg.io/3043",
                href = "https://epsg.io/3043"
              )
            )
          ),
          shiny::br(),shiny::br(),
          shiny::downloadButton(
            ns('save_map_btn'),
            label = translate_app('save_map_btn', lang())
          )
        )
      ) # end of fluidRow
    ) # end of tagList
  }) # end of renderUI

  output$save_map_btn <- shiny::downloadHandler(
    filename = function() {

      # browser()

      date_range <- data_reactives$date_range

      file_name_base <- glue::glue(
        "{stringr::str_remove_all(date_range[1], '-')}-",
        "{stringr::str_remove_all(date_range[2], '-')}_meteo_interpolation."
      )

      if (is(main_data_reactives$main_data, 'sf')) {
        extension <- 'gpkg'
      } else {
        extension <- 'zip'
      }

      glue::glue("{file_name_base}{extension}")
    },
    content = function(filename) {
      main_data <- main_data_reactives$main_data

      # browser()

      if (is(main_data_reactives$main_data, 'sf')) {
        sf::st_write(main_data, filename)
      } else {
        # when saving rasters, we need to write the individual date tiffs to a
        # temp dir, compresses them in a zip file and move the file to the
        # filename argument
        tmp_dir <- tempdir()

        writting_step <- main_data %>%
          purrr::map(
            function(.x) {
              .x@crs <- sp::rebuild_CRS(.x@crs)
              .x
            }
          ) %>%
          purrr::imap(
            ~ raster::writeRaster(
              .x,
              filename = file.path(
                tmp_dir, glue::glue("{.y}_meteo_interpolation.tif")
              )
            )
          )

        tif_files <- list.files(tmp_dir, '.tif', full.names = TRUE)
        utils::zip(
          file.path(tmp_dir, 'tif_files.zip'),
          tif_files
        )
        file.copy(file.path(tmp_dir, 'tif_files.zip'), filename)
        file.remove(file.path(tmp_dir, 'tif_files.zip'), tif_files)
      }
    }
  )


}
