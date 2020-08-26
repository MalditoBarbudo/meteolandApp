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
    shiny::uiOutput(ns('mod_viz_panel'))
  )
}

#' mod_viz server function
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @param data_reactives reactives needed
#' @param lang lang value
#'
#' @export
#'
#' @rdname mod_vizInput
mod_viz <- function(
  input, output, session,
  data_reactives,
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
      'MeanTemperature', 'MinTemperature', 'MaxTemperature',
      'MeanRelativeHumidity', 'MinRelativeHumidity', 'MaxRelativeHumidity',
      'Precipitation', 'Radiation', 'WindSpeed', 'WindDirection'
    ) %>%
      magrittr::set_names(translate_app(., lang()))

    date_choices <- date_range[1]:date_range[2] %>%
      as.Date(format = '%j', origin = as.Date('1970-01-01')) %>%
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
      )
    )
  })


  # return the viz inputs
  viz_reactives <- shiny::reactiveValues()
  shiny::observe({
    viz_reactives$viz_color <- input$viz_color
    viz_reactives$viz_date <- input$viz_date
  })
  return(viz_reactives)


}
