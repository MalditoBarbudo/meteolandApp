#' mod_vizInput and mod_viz
#'
#' @description A shiny module to generate and populate the visualization inputs
#'
#' @param id shiny id
#'
#' @export
mod_vizInput <- function(id) {
  # ns
  ns <- shiny::NS(id)

  # UI ####
  shiny::tagList(
    shiny::br(),
    shiny::uiOutput(ns('mod_viz_panel')),
    shiny::hr(),
    shiny::uiOutput(ns('ts_inputs_panel'))
  )
}

#' mod_viz server function
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @param data_reactives,main_data_reactives reactives needed
#' @param lang lang value
#'
#' @export
#'
#' @rdname mod_vizInput
mod_viz <- function(
  input, output, session,
  data_reactives, main_data_reactives,
  lang
) {

  ## renderUI ####
  output$mod_viz_panel <- shiny::renderUI({

    # validation
    shiny::validate(
      shiny::need(data_reactives$data_mode, 'no inputs yet'),
      shiny::need(data_reactives$date_range, 'no dates yet')
    )

    # ns
    ns <- session$ns

    # data reactives needed
    date_range <- data_reactives$date_range

    # precalculated choices
    color_choices <- c(
      'MeanTemperature', 'MinTemperature', 'MaxTemperature', "ThermalAmplitude",
      'MeanRelativeHumidity', 'MinRelativeHumidity', 'MaxRelativeHumidity',
      'Precipitation', 'Radiation', 'WindSpeed', 'PET'
    ) |>
      purrr::set_names(translate_app(c(
        'MeanTemperature', 'MinTemperature', 'MaxTemperature', "ThermalAmplitude",
        'MeanRelativeHumidity', 'MinRelativeHumidity', 'MaxRelativeHumidity',
        'Precipitation', 'Radiation', 'WindSpeed', 'PET'
      ), lang()))

    date_choices <- date_range[1]:date_range[2] |>
      as.Date(format = '%j', origin = as.Date('1970-01-01')) |>
      as.character()

    # tagList ####
    shiny::tagList(
      shiny::fluidRow(
        shiny::column(
          8, shiny::h4(translate_app('h4_viz', lang()))
        )
      ),
      shiny::fluidRow(
        shiny::column(
          6,
          shinyWidgets::pickerInput(
            ns('viz_color'),
            translate_app('viz_color_input', lang()),
            choices = color_choices,
            options = shinyWidgets::pickerOptions(
              actionsBox = FALSE,
              noneSelectedText = translate_app(
                'deselect-all-text', lang()
              ),
              selectAllText = translate_app(
                'select-all-text', lang()
              ),
              selectedTextFormat =  'count',
              countSelectedText = translate_app(
                'count-selected-text-value', lang()
              ),
              size = 10,
              liveSearch = TRUE,
              tickIcon = 'glyphicon-tree-deciduous'
            )
          )
        ),
        shiny::column(
          6,
          shinyWidgets::pickerInput(
            ns('viz_date'),
            translate_app('viz_date_input', lang()),
            choices = date_choices,
            options = shinyWidgets::pickerOptions(
              actionsBox = FALSE,
              noneSelectedText = translate_app(
                'deselect-all-text', lang()
              ),
              selectAllText = translate_app(
                'select-all-text', lang()
              ),
              selectedTextFormat =  'count',
              countSelectedText = translate_app(
                'count-selected-text-value', lang()
              ),
              size = 10,
              liveSearch = TRUE,
              tickIcon = 'glyphicon-tree-deciduous'
            )
          )
        )
      ), # end of fluidRow (var and date)
      shiny::fluidRow(
        shiny::column(
          6,
          # reverse palette
          shinyWidgets::awesomeCheckbox(
            ns('viz_pal_reverse'),
            label = translate_app('viz_pal_reverse_input', lang()),
            status = 'info'
          )
        )
      ) # end of fluidRow (palette)
    )
  })

  output$ts_inputs_panel <- shiny::renderUI({

    shiny::validate(
      shiny::need(main_data_reactives$main_data, 'no main data yet')
    )

    # ns
    ns <- session$ns

    # needed reactives
    main_data <- main_data_reactives$main_data

    if (is(main_data, 'sf')) {

      data_choices <- main_data |>
        dplyr::pull('poly_id') |>
        unique()

      shiny::tagList(
        shiny::h4(translate_app('ts_title', lang())),
        shiny::fluidRow(
          shiny::column(
            6, #align = 'center',
            shinyWidgets::pickerInput(
              ns('ts_points'),
              label = translate_app('ts_points', lang()),
              choices = data_choices,
              selected = data_choices,
              multiple = TRUE,
              options = shinyWidgets::pickerOptions(
                actionsBox = TRUE,
                noneSelectedText = translate_app(
                  'deselect-all-text', lang()
                ),
                selectAllText = translate_app(
                  'select-all-text', lang()
                ),
                deselectAllText = translate_app(
                  'deselect-all-text', lang()
                ),
                selectedTextFormat =  'count',
                countSelectedText = translate_app(
                  'count-selected-text-value', lang()
                ),
                size = 10,
                liveSearch = TRUE,
                tickIcon = 'glyphicon-tree-deciduous'
              )
            )
          ),
          shiny::column(
            6, align = 'center',
            shiny::br(),
            shiny::actionButton(
              ns('ts_button'),
              label = translate_app('ts_button', lang()),
              # icon = shiny::icon('creative-commons-sampling')
              icon = shiny::icon('chart-area')
            )
          )
        )
      )
    } else {

      shiny::tagList(
        shiny::h4(translate_app('ts_title', lang())),
        shiny::fluidRow(
          shiny::column(
            5,
            shiny::br(),
            shinyWidgets::awesomeCheckbox(
              ns('activate_tsraster'),
              label = translate_app('activate_tsraster', lang()),
              status = 'info'
            )
          ),
          shiny::column(
            7,
            shiny::p(translate_app('tsraster_info', lang()))
          )
        )
      )

    }


  })


  # return the viz inputs
  viz_reactives <- shiny::reactiveValues()
  shiny::observe({
    viz_reactives$viz_color <- input$viz_color
    viz_reactives$viz_date <- input$viz_date
    viz_reactives$viz_pal_reverse <- input$viz_pal_reverse
    viz_reactives$ts_points <- input$ts_points
    viz_reactives$ts_button <- input$ts_button
    viz_reactives$activate_tsraster <- input$activate_tsraster
  })
  return(viz_reactives)


}
