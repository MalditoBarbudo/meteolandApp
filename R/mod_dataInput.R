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
#' @param meteolanddb lfcdata database accesss object
#' @param lang lang reactive
#'
#' @export
mod_data <- function(
  input, output, session,
  meteolanddb, lang
) {

  # renderUI ####
  output$mod_data_container <- shiny::renderUI({

    ns <- session$ns

    ## preacalculated choices
    # mode (historic, current)
    data_mode_choices <- c('current', 'historic') |>
      purrr::set_names(translate_app(c('current', 'historic'), lang()))
    # type (raster, points, custom)
    data_type_choices <- c('raster', 'drawn_polygon', 'file') |>
      purrr::set_names(translate_app(c('raster', 'drawn_polygon', 'file'), lang()))
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
          ),
          shinyWidgets::pickerInput(
            ns('data_type'),
            label = translate_app('data_type', lang()),
            choices = data_type_choices,
            selected = 'raster'
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
      # # data type row
      # shiny::fluidRow(
      #   shiny::column(
      #     width = 6,
      #     shinyWidgets::pickerInput(
      #       ns('data_type'),
      #       label = translate_app('data_type', lang()),
      #       choices = data_type_choices,
      #       selected = 'raster'
      #     )
      #   )
      # ), # end of data type row
      shinyjs::hidden(
        shiny::div(
          id = ns('file_upload_panel'),
          shiny::fluidRow(
            shiny::column(
              6,
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
              6,
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
            min = Sys.Date()-365, max = Sys.Date()-1,
            weekstart = 1, language = dates_lang,
            separator = translate_app('date_separator', lang())
          )
          # shinyWidgets::airDatepickerInput(
          #   ns('date_range'),
          #   label = translate_app('date_range', lang()), range = TRUE,
          #   firstDay = 1,
          #   minDate = Sys.Date()-365, maxDate = Sys.Date()-1,
          #   value = c(Sys.Date()-2, Sys.Date()-1),
          #   startView = Sys.Date()-1, position = 'top right', update_on = 'close',
          #   addon = 'none', separator = translate_app('date_separator', lang()),
          #   language = dates_lang
          # )
        ),
        shiny::column(
          width = 6,
          shiny::br(),
          shiny::textOutput(
            ns('date_range_explanation')
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

  # date range explanation
  output$date_range_explanation <- shiny::renderText({
    shiny::validate(
      shiny::need(input$data_mode, 'no mode')
    )

    translate_app('date_range_explanation', lang())
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

  # observer to update the date range input when in historic
  shiny::observe({
    shiny::validate(
      shiny::need(input$data_mode, 'no mode')
    )

    data_mode <- input$data_mode

    if (data_mode == 'current') {

      # We need to check which is the last date available without cuts (dates
      # in a row) and set this as the start, end and max values in the date
      # range input
      tables_list <- DBI::dbListTables(meteolanddb$.__enclos_env__$private$pool_conn)
      current_daily_tables <-
        tables_list |>
        magrittr::extract(stringr::str_detect(tables_list, "daily_raster_interpolated")) |>
        sort()

      accepted_dates <- as.Date(
        (Sys.Date() - 366):(Sys.Date() - 1), # one year long + 30 days buffer
        format = '%j', origin = as.Date('1970-01-01')
      ) |>
        as.character()

      current_accepted_tables <-
        glue::glue(
          "daily_raster_interpolated_{stringr::str_remove_all(accepted_dates, pattern = '-')}"
        )

      index_missing <- which(!current_accepted_tables %in% current_daily_tables)

      # 31 is the removing buffer in the database
      if (length(index_missing) > 0) {
        # first date must be the first available: which(!1:366 %in% index_missing)[1]
        # last date must be the previous one to the first index missing (except if the first index missing is
        # the first date accepted, i.e. index_missing[1]==1)
        first_date_accepted <- which(!1:366 %in% index_missing)[1]
        last_date_accepted <- index_missing[1] - 1
        if (index_missing[1] == 1) {
          last_date_accepted <- index_missing[2] - 1
        }
        accepted_dates <- accepted_dates[first_date_accepted:last_date_accepted]
      } else {
        accepted_dates <- accepted_dates[1:length(accepted_dates)]
      }


      # there is a bug in shiny: https://github.com/rstudio/shiny/issues/2703,
      # so here we need a convoluted way of setting the start, end, min and max
      # arguments. Explained in:
      # https://stackoverflow.com/questions/62171194/problems-with-shinyupdatedaterangeinput

      # first we set end and max
      shiny::updateDateRangeInput(
        session, 'date_range',
        label = translate_app('date_range', lang()),
        end = accepted_dates[length(accepted_dates)],
        max = accepted_dates[length(accepted_dates)]
      )
      # and now start and min
      shiny::updateDateRangeInput(
        session, 'date_range',
        label = translate_app('date_range', lang()),
        start = accepted_dates[length(accepted_dates)],
        min = accepted_dates[1]
      )

    } else {
      # shinyWidgets::updateAirDateInput(
      #   session, 'date_range',
      #   label = translate_app('date_range', lang()),
      #   value = c('1976-01-01', '1976-01-02'),
      #   options = list(
      #     minDate = '1976-01-01', maxDate = Sys.Date()-366
      #   )
      # )
      shiny::updateDateRangeInput(
        session, 'date_range',
        label = translate_app('date_range', lang()),
        start = '1976-01-01', end = '1976-01-01',
        min = '1976-01-01', max = Sys.Date() - 366
      )
    }
  })

  # observer to limit the dates selected to 30 days.
  shiny::observe({
    shiny::validate(
      shiny::need(input$date_range, 'no dates')
    )

    date_range <- input$date_range
    date_seq <- as.Date(date_range[1]):as.Date(date_range[2])

    # if we have more than 30 days, issue an alert and update
    # the airDatepicker to the 30 days.
    if (length(date_seq) > 31) {
      shinyWidgets::sendSweetAlert(
        session = session,
        title = translate_app('sweet_alert_30days_title', lang()),
        text = translate_app('sweet_alert_30days_text', lang())
      )

      # shinyWidgets::updateAirDateInput(
      #   session, 'date_range',
      #   label = translate_app('date_range', lang()),
      #   value = c(as.Date(date_range[1]), as.Date(date_range[1]) + 30)
      # )
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
