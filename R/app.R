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

        ########################################################### debug ####
        shiny::absolutePanel(
          id = 'debug', class = 'panel panel-default', fixed = TRUE,
          draggable = TRUE, width = 640, height = 'auto',
          # top = 100, left = 100, rigth = 'auto', bottom = 'auto',
          top = 'auto', left = 10, right = 'auto', bottom = 15,
          # top = 60, left = 'auto', right = 50, bottom = 'auto',

          shiny::h3("DEBUG"),
          shiny::textOutput('debug1'),
          shiny::textOutput('debug2'),
          shiny::textOutput('debug3')
        ),
        ####################################################### end debug ####

        # Sidebar layout
        shiny::sidebarLayout(
          ## options
          position = 'left', fluid = TRUE,
          sidebarPanel = shiny::sidebarPanel(
            width = 5,
            # apply button module
            mod_applyButtonInput("mod_applyButtonInput"),
            shiny::br(),
            # this is gonna be a tabsetPanel, for data selection, save and help.
            # tabset panel
            shiny::tabsetPanel(
              id = 'sidebar_tabset', type = 'pills',
              # data panel
              shiny::tabPanel(
                title = mod_tab_translateOutput('data_translation'),
                value = 'data_inputs_panel',
                mod_dataInput('mod_dataInput'),
                mod_vizInput('mod_vizInput')
              ) # end of data panel
            ) # end of tabsetPanel
          ), # end of sidebarPanel
          mainPanel = shiny::mainPanel(
            width = 7,
            shiny::tabsetPanel(
              id = 'main_panel_tabset', type = 'pills',
              shiny::tabPanel(
                title = mod_tab_translateOutput('map_translation'),
                # 'map',
                value = 'map_panel',
                mod_mapOutput('mod_mapOutput')
              )
            )
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
    # apply button
    apply_reactives <- shiny::callModule(
      mod_applyButton, 'mod_applyButtonInput',
      lang, data_reactives
    )
    # main data
    main_data_reactives <- shiny::callModule(
      mod_mainData, 'mod_mainDataOutput',
      data_reactives, map_reactives, apply_reactives,
      meteolanddb, lang, session
    )
    # viz
    viz_reactives <- shiny::callModule(
      mod_viz, 'mod_vizInput',
      data_reactives, lang
    )
    # map
    map_reactives <- shiny::callModule(
      mod_map, 'mod_mapOutput',
      data_reactives, viz_reactives, main_data_reactives,
      lang
    )

    ## tab translations ####
    shiny::callModule(
      mod_tab_translate, 'main_tab_translation',
      'main_tab_translation', lang
    )
    shiny::callModule(
      mod_tab_translate, 'data_translation',
      'data_translation', lang
    )
    shiny::callModule(
      mod_tab_translate, 'map_translation',
      'map_translation', lang
    )


    ## debug #####
    output$debug1 <- shiny::renderPrint({
      main_data_reactives$main_data
    })
    output$debug2 <- shiny::renderPrint({
      main_data_reactives$custom_polygon
    })
    # output$debug3 <- shiny::renderPrint({
    #   data_reactives$date_range
    # })

  } # end of server


  # Run the application
  meteoland_app_res <- shiny::shinyApp(
    ui = ui, server = server
  )

  # shiny::runApp(meteoland_app)
  return(meteoland_app_res)
}
