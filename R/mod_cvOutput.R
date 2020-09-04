#' @title mod_cvOutput and mod_cv
#'
#' @description Shiny module to show the corssvalidations table
#'
#' @param id shiny id
#'
#' @export
mod_cvOutput <- function(id) {
  # ns
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::p(shiny::textOutput(ns('cv_intro'))),
    shiny::br(),
    DT::DTOutput(ns('cv_table'))
  )
}

#' mod_cv server function
#'
#' @details mod_cv generates the crossvalidations table
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @param meteolandb object to access the meteolanddb
#' @param lang lang selected
#'
#' @export
#'
#' @rdname mod_cvOutput
mod_cv <- function(
  input, output, session,
  meteolanddb, lang
) {

  output$cv_intro <- shiny::renderText({
    translate_app('cv_intro', lang())
  })

  output$cv_table <- DT::renderDT({

    cv_df <- dplyr::tbl(
      meteolanddb$.__enclos_env__$private$pool_conn, 'crossvalidation_summary'
    ) %>%
      dplyr::collect() %>%
      dplyr::select(
        variable,
        year,
        n,
        MAE,
        Bias,
        sd.station.MAE,
        sd.dates.MAE,
        sd.station.Bias,
        sd.dates.Bias
      ) %>%
      dplyr::mutate(
        variable = translate_app(variable, lang())
      ) %>%
      dplyr::mutate_if(
        is.numeric,
        round, digits = 1
      ) %>%
      magrittr::set_names(
        translate_app(names(.), lang())
      )

    DT::datatable(
      cv_df,
      rownames = FALSE,
      class = 'hover order-column stripe nowrap',
      filter = list(position = 'top', clear = FALSE, plain = FALSE),
      # extensions = 'Buttons',
      options = list(
        pageLength = 13,
        dom = 'tip',
        # buttons = I('colvis'),
        autoWidth = FALSE,
        initComplete = DT::JS(
          "function(settings, json) {",
          "$(this.api().table().header()).css({'font-family': 'Montserrat'});",
          "$(this.api().table().body()).css({'font-family': 'Montserrat'});",
          "}"
        )
      )
    )
  })

}
