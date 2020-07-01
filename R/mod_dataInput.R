#' @title mod_dataInput and mod_data
#'
#' @description A shiny module to create and populate the data inputs
#'
#' @param id shiny id
#'
#' @export
mod_dataInput <- function(id) {
  # ns
  ns <- shiny::NS(id)

  # UI ####
  shiny::tagList(
    shiny::br(),
    shiny::uiOutput(
      ns('mod_data_container')
    )
  )
}

#' mod_data server function
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @param lang lang reactive
#'
#' @export
mod_data <- function(
  input, output, session,
  lang
) {

  # renderUI ####
  output$mod_data_container <- shiny::renderUI({

    ns <- session$ns

    ## preacalculated choices
    # mode (historic, current)
    data_mode_choices <- c(
      'current', 'historic'
    ) %>%
      magrittr::set_names(translate_app(., lang()))
    # type (raster, points, custom)
    data_type_choices <- c(
      'raster', 'drawn_polygon', 'file'
    ) %>%
      magrittr::set_names(translate_app(., lang()))
    # lang for dates
    dates_lang <- switch(
      lang(),
      'spa' = 'es',
      'cat' = 'ca',
      'eng' = 'en'
    )

    # tagList
    shiny::tagList(
      shiny::h4(translate_app('h4_data_selection', lang())),
      # data mode row
      shiny::fluidRow(
        shiny::column(
          width = 6,
          shinyWidgets::pickerInput(
            ns('data_mode'),
            label = translate_app('data_mode', lang()),
            choices = data_mode_choices,
            selected = 'current'
          )
        ),
        # explanation of the mode
        shiny::column(
          width = 6,
          shiny::br(),
          shiny::textOutput(
            ns('data_mode_explanation')
          )
        )
      ), # end of data mode row
      # data type row
      shiny::fluidRow(
        shiny::column(
          width = 6,
          shinyWidgets::pickerInput(
            ns('data_type'),
            label = translate_app('data_type', lang()),
            choices = data_type_choices,
            selected = 'raster'
          )
        )
      ), # end of data type row
      shinyjs::hidden(
        shiny::div(
          id = ns('file_upload_panel'),
          shiny::fluidRow(
            shiny::column(
              7, align = 'center',
              shiny::fileInput(
                ns('user_file_sel'),
                translate_app('user_file_sel_label', lang()),
                accept = c('zip', 'gpkg'),
                buttonLabel = translate_app(
                  'user_file_sel_buttonLabel', lang()
                ),
                placeholder = translate_app(
                  'user_file_sel_placeholder', lang()
                )
              )
            ),
            shiny::column(
              5, align = 'center',
              shiny::p(translate_app('file_text', lang()))
            )
          )
        )
      ), # end of hidden file selector
      # date selection row
      shiny::fluidRow(
        shiny::column(
          width = 6,
          shiny::dateRangeInput(
            ns('date_range'),
            label = translate_app('date_range', lang()),
            start = Sys.Date()-1, end = Sys.Date()-1,
            min = Sys.Date()-366, max = Sys.Date()-1,
            weekstart = 1, language = dates_lang,
            separator = translate_app('date_separator', lang())
          )
        )
      ) # end of dates row
    ) # end of tagList
  }) # end of renderUI

  # mode explanation
  output$data_mode_explanation <- shiny::renderText({
    shiny::validate(
      shiny::need(input$data_mode, 'no mode')
    )

    data_mode <- input$data_mode
    text_identifier <- glue::glue("{data_mode}_mode_explanation")

    translate_app(text_identifier, lang())

  })

  ## observers ####
  # observer to show the file upload panel if needed
  shiny::observe({

    shiny::validate(
      shiny::need(input$data_type, 'no type')
    )
    data_type <- input$data_type

    if (data_type == 'file') {
      shinyjs::show('file_upload_panel')
    } else {
      shinyjs::hide('file_upload_panel')
    }
  })

  ## returning inputs ####
  # reactive values to return and use in other modules
  data_reactives <- shiny::reactiveValues()

  shiny::observe({
    data_reactives$data_mode <- input$data_mode
    data_reactives$data_type <- input$data_type
    data_reactives$date_range <- input$date_range
    data_reactives$user_file_sel <- input$user_file_sel
  })

  return(data_reactives)
}
