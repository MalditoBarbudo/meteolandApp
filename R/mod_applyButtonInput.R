#' @title mod_applyButtonInput and mod_applyButton
#'
#' @description A shiny module to create and populate the buttons inputs
#'
#' @param id shiny id
#'
#' @export
mod_applyButtonInput <- function(id) {
  # ns
  ns <- shiny::NS(id)

  # tagList
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(
        9, align = 'left',
        # data requested summary
        shiny::uiOutput(ns('data_requested_info'))
      ),
      shiny::column(
        3, align = 'center',
        shiny::uiOutput(ns("apply_panel"))
      )
    )
  )


}

#' mod_applyButton
#' @param input internal
#' @param output internal
#' @param session internal
#' @param lang language selected
#' @param data_reactives reactives needed
#'
#' @export
#'
#' @rdname mod_applyButtonInput
mod_applyButton <- function(
  input, output, session,
  lang, data_reactives
) {

  # data_requested_info ####
  output$data_requested_info <- shiny::renderUI({

    shiny::validate(
      shiny::need(data_reactives$data_mode, 'no inputs yet')
    )

    ## TODO data selected info
  })

  # renderUI ####
  output$apply_panel <- shiny::renderUI({
    ns <- session$ns

    # button
    shiny::fluidRow(
      shiny::actionButton(
        ns('apply'),
        translate_app('apply', lang()),
        icon = shiny::icon('check-circle')
      )
    )
  })

  # return reactive ####
  apply_reactives <- shiny::reactiveValues()
  shiny::observe({
    apply_reactives$apply_button <- input$apply
  })
  return(apply_reactives)

}
