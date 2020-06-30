#' function to launch the lidar app
#'
#' @importFrom magrittr %>%
#'
#' @export
meteoland_app <- function() {
  ### DB access ################################################################
  meteolanddb <- lfcdata::meteoland()

  ### Language input ###########################################################
  shiny::addResourcePath(
    'images', system.file('resources', 'images', package = 'meteolandApp')
  )
  lang_choices <- c('cat', 'spa', 'eng')
  lang_flags <- c(
    glue::glue(
      "<img class='flag-image' src='images/cat.png'",
      " width=20px><div class='flag-lang'>%s</div></img>"
    ),
    glue::glue(
      "<img class='flag-image' src='images/spa.png'",
      " width=20px><div class='flag-lang'>%s</div></img>"
    ),
    glue::glue(
      "<img class='flag-image' src='images/eng.png'",
      " width=20px><div class='flag-lang'>%s</div></img>"
    )
  )

  ## UI ####
  ui <- shiny::tagList(

    # shinyjs
    shinyjs::useShinyjs(),

    # css
    shiny::tags$head(
      # corporative image css
      shiny::includeCSS(
        system.file('resources', 'corp_image.css', package = 'meteolandApp')
      ),
      # custom css
      shiny::includeCSS(
        system.file('resources', 'meteolandapp.css', package = 'meteolandApp')
      )
    ),

    navbarPageWithInputs(
      # opts
      title = 'Meteoland App',
      id = 'nav',
      collapsible = TRUE,

      # navbar with inputs (helpers.R) accepts an input argument, we use it for the lang
      # selector
      inputs = shinyWidgets::pickerInput(
        'lang', NULL,
        choices = lang_choices,
        selected = 'cat',
        width = '100px',
        choicesOpt = list(
          content = c(
            sprintf(lang_flags[1], lang_choices[1]),
            sprintf(lang_flags[2], lang_choices[2]),
            sprintf(lang_flags[3], lang_choices[3])
          )
        )
      ),

      # navbarPage contents
      shiny::tabPanel(
        title = mod_tab_translateOutput('main_tab_translation'),

        # Sidebar layout
        shiny::sidebarLayout(
          width = 5,
          # this is gonna be a tabsetPanel, for data selection, save and help.
          # tabset panel
          shiny::tabsetPanel(
            title = mod_tab_translateOutput('data_translation'),
            # 'data',
            value = 'data_inputs_panel',
            mod_dataInput('mod_dataInput')
          )



        ) # end of sidebarLayout

      ) # end of tabPanel

    ) # end of navbarPage


  ) # end of UI

  ## server ####
  server <- function(input, output, session) {

    # lang reactive ####
    lang <- shiny::reactive({
      input$lang
    })

    # modules ####
    # data inputs
    data_reactives <- shiny::callModule(
      mod_data, 'mod_dataInput', lang
    )

  } # end of server
}
