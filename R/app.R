#' function to launch the lidar app
#'
#' @importFrom terra has.RGB
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

  ## JS code needed ############################################################
  js_script <- shiny::HTML(
    '$(document).on("shiny:idle", function(event) {
  Shiny.setInputValue("first_time", "true", {priority: "event"});
});'
  )

  keep_alive_script <- shiny::HTML(
    "var socket_timeout_interval;
var n = 0;

$(document).on('shiny:connected', function(event) {
  socket_timeout_interval = setInterval(function() {
    Shiny.onInputChange('alive_count', n++)
  }, 10000);
});

$(document).on('shiny:disconnected', function(event) {
  clearInterval(socket_timeout_interval)
});"
  )

  ## only once alarm ####
  under_construction <- 0

  ## UI ####
  ui <- shiny::tagList(

    # shinyjs
    shinyjs::useShinyjs(),
    # waiter
    waiter::use_waiter(),
    waiter::use_hostess(),

    # css
    shiny::tags$head(
      # js script,
      shiny::tags$script(js_script),
      shiny::tags$script(keep_alive_script),
      # corporative image css
      shiny::includeCSS(
        system.file('apps_css', 'corp_image.css', package = 'lfcdata')
      ),
      # custom css
      shiny::includeCSS(
        system.file('apps_css', 'meteolandapp.css', package = 'lfcdata')
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

      # footer
      footer = shiny::tags$footer(
        shiny::fluidRow(
          shiny::column(
            width = 12, align = "right",
            shiny::HTML(glue::glue(
              '<img src="images/emf_white_logo.svg" width="120px" class="d-inline-block" alt="" loading="lazy">
              <img src="images/creaf_white_logo.svg" width="135px" class="d-inline-block" alt="" loading="lazy">
              <span>({lubridate::year(Sys.Date())})</span>'
            ))
          )
        )
      ),

      # navbarPage contents
      shiny::tabPanel(
        title = mod_tab_translateOutput('main_tab_translation'),

        ########################################################### debug ####
        # shiny::absolutePanel(
        #   id = 'debug', class = 'panel panel-default', fixed = TRUE,
        #   draggable = TRUE, width = 640, height = 'auto',
        #   # top = 100, left = 100, rigth = 'auto', bottom = 'auto',
        #   top = 'auto', left = 10, right = 'auto', bottom = 15,
        #   # top = 60, left = 'auto', right = 50, bottom = 'auto',
        #
        #   shiny::h3("DEBUG"),
        #   shiny::textOutput('debug1'),
        #   shiny::textOutput('debug2'),
        #   shiny::textOutput('debug3')
        # ),
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
                mod_dataInput('mod_dataInput')#,
                # mod_vizInput('mod_vizInput')
              ), # end of data panel
              # viz panel
              shiny::tabPanel(
                title = mod_tab_translateOutput('viz_translation'),
                value = 'viz_inputs_panel',
                mod_vizInput('mod_vizInput')
              ),
              # save panel
              shiny::tabPanel(
                title = mod_tab_translateOutput('save_translation'),
                value = 'save_panel',
                mod_saveOutput('mod_saveOutput')
              )
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

      ), # end of main tabPanel
      # shiny::tabPanel(
      #   title = mod_tab_translateOutput('cv_translation'),
      #   value = 'cv_panel',
      #   mod_cvOutput('mod_cvOutput')
      # ), # end of cv tabPanel
      shiny::tabPanel(
        title = mod_tab_translateOutput('tech_specs_translation'),
        value = 'tech_spec_panel',
        mod_techSpecsOutput('mod_techSpecsOutput')
      )

    ) # end of navbarPage


  ) # end of UI

  ## server ####
  server <- function(input, output, session) {

    # lang reactive ####
    lang <- shiny::reactive({
      input$lang
    })

    ####### Maintenance notice
    # send an alarm when loading app or change langs
    # shiny::observeEvent(
    #   eventExpr = lang(),
    #   handlerExpr = {
    #     # if (under_construction < 1) {
    #       # under_construction <- 1
    #       shinyWidgets::show_alert(
    #         title = translate_app('under_construction_title', lang()),
    #         text = translate_app('under_construction_text', lang())
    #       )
    #     # }
    #   }
    # )
    ########

    # modules ####
    # data inputs
    data_reactives <- shiny::callModule(
      mod_data, 'mod_dataInput', meteolanddb, lang
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
      data_reactives, main_data_reactives, lang
    )
    # map
    map_reactives <- shiny::callModule(
      mod_map, 'mod_mapOutput',
      data_reactives, viz_reactives, main_data_reactives,
      lang
    )
    # save
    shiny::callModule(
      mod_save, 'mod_saveOutput',
      main_data_reactives, data_reactives,
      lang
    )
    # cv module
    shiny::callModule(
      mod_cv, 'mod_cvOutput',
      meteolanddb, lang
    )
    # technical specifications module
    shiny::callModule(
      mod_techSpecs, 'mod_techSpecsOutput',
      lang
    )
    # ts modules
    shiny::callModule(
      mod_ts, 'mod_tsOutput',
      viz_reactives, main_data_reactives, map_reactives,
      lang
    )
    shiny::callModule(
      mod_ts, 'mod_tsOutput_raster',
      viz_reactives, main_data_reactives, map_reactives,
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
      mod_tab_translate, 'viz_translation',
      'viz_translation', lang
    )
    shiny::callModule(
      mod_tab_translate, 'map_translation',
      'map_translation', lang
    )
    shiny::callModule(
      mod_tab_translate, 'save_translation',
      'save_translation', lang
    )
    shiny::callModule(
      mod_tab_translate, 'cv_translation',
      'cv_translation', lang
    )
    shiny::callModule(
      mod_tab_translate, 'tech_specs_translation',
      'tech_specs_translation', lang
    )

    ## observers ####
    # first time observer
    shiny::observeEvent(
      once = TRUE, priority = 1,
      eventExpr = {
        input$first_time
        shiny::isolate(data_reactives$data_mode)
      },
      handlerExpr = {
        shinyjs::click("mod_applyButtonInput-apply", asis = TRUE)
      }
    )

    # time series modal observers
    # 1. points
    shiny::observeEvent(
      eventExpr = viz_reactives$ts_button,
      handlerExpr = {
        shiny::showModal(
          shiny::modalDialog(
            mod_tsOutput('mod_tsOutput'),
            footer = shiny::modalButton(
              translate_app('dismiss', lang())
            ),
            size = 'l', easyClose = FALSE
          )
        )
      }
    )
    # 2. raster
    shiny::observeEvent(
      eventExpr = map_reactives$meteoland_map_click,
      handlerExpr = {

        # check first that the activator is on
        shiny::validate(
          shiny::need(viz_reactives$activate_tsraster, 'no activator')
        )

        shiny::showModal(
          shiny::modalDialog(
            mod_tsOutput('mod_tsOutput_raster'),
            footer = shiny::modalButton(
              translate_app('dismiss', lang())
            ),
            size = 'l', easyClose = FALSE
          )
        )
      }
    )


    ## debug #####
    # output$debug1 <- shiny::renderPrint({
    #   map_reactives$meteoland_map_center
    # })
    # output$debug2 <- shiny::renderPrint({
    #   main_data_reactives$custom_polygon
    # })
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
