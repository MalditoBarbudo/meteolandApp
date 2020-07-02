## code to prepare `app_translations` dataset goes here

app_translations <- tibble::tribble(
  ~text_id, ~translation_cat, ~translation_eng, ~translation_spa,
  # data mode choices
  'h4_data_selection', "Selecciona les dades", "Select the data", "Selecciona los datos",
  'data_mode', "Mode", "Modo", "Mode",
  'current', 'Actual', 'Current', 'Actual',
  'historic', 'Històric', 'Historic', 'Histórico',
  # data type choices
  'data_type', 'Tipus', 'Type', 'Tipo',
  "raster", "Ràster", "Raster", "Raster",
  'drawn_polygon', "Polígon dibuxat", "Drawn polygon", "Polígono dibujado",
  "file", "Arxiu de polìgons", "Polygon file", "Archivo de polígonos",
  # date range
  'date_range', 'Rang de dates', 'Dates range', 'Rango de fechas',
  'date_separator', " a ", " to ", " a ",
  # use file selection
  "user_file_sel_label", "Selecciona l'arxiu a carregar", "Select the file to upload", "Selecciona el archivo a cargar",
  "user_file_sel_buttonLabel", "Inspecciona...", "Browse...", "Inspecciona...",
  "user_file_sel_placeholder", "Cap fitxer seleccionat", "No file selected", "Ningún archivo seleccionado",
  "file_text", 'El fitxer pot ser un shapefile (comprimit en un fitxer zip) o un fitxer GeoPackage (.gpkg). Han de tenir un camp anomenat "id" amb els identificadors dels geometries continguts.', 'File can be a shapefile (compressed in a zip file) or GeoPackage file (.gpkg). They must have a field called "id" with the identifiers of the contained geometries.', 'El archivo puede ser un shapefile (comprimido en un archivo zip) o un archivo GeoPackage (.gpkg). Deben tener un campo llamado "id" con los identificadores de las geometrías contenidas.',
  # # map
  # 'Relief', 'Relleu (base)', 'Relief (base)', 'Relieve (base)',
  # 'Imaginery', 'Satèl·lit (base)', 'Imaginery (base)', 'Satélite (base)',
  # "cite_div", "Dades elaborades pel CTFC i el CREAF.", "Data prepared by the CTFC and CREAF.", "Datos elaborados por el CTFC y el CREAF.",
  # tabs translations
  "main_tab_translation", "Explora", "Explore", "Explora",
  "data_translation", "Dades", "Data", "Datos",
  "save_translation", "Guardar", "Save", "Guardar",
  "help_translation", "Ajuda", "Help", "Ayuda",
  "map_translation", "Mapa", "Map", "Mapa",
  "table_translation", "Taula", "Table", "Tabla",
  # apply module
  "apply", "Aplicar", "Apply", "Aplicar",
  # # metric choices
  # 'mean', 'Mitjana', 'Mean', 'Media',
  # 'min', 'Minim', 'Minimum', 'Mínimo',
  # 'max', 'Maxim', 'Maximum', 'Máximo',
  # 'se', 'ES', 'SE', 'ES',
  # 'q05', 'Quartil 5', 'Quantile 5', 'Cuartil 5',
  # 'q95', 'Quartil 95', 'Quantile 95', 'Cuartil 95',
  # 'n', 'Nombre parcel·las', 'Plot number', 'Número de parcelas',
  # # _metric
  # '_mean', ' mitjana', ' mean', ' media',
  # '_min', ' minim ', ' minimum', ' mínimo',
  # '_max', ' maxim', ' maximum', ' máximo de ',
  # '_se', ' ES', ' SE', ' ES',
  # '_q05', ' quartil 5', ' quantile 5', ' cuartil 5',
  # '_q95', ' quartil 95', ' quantile 95', ' cuartil 95',
  # '_n', ' nombre parcel·las', ' plot number', ' número de parcelas',
  # # viz
  # "h4_servei", "Fixa el servei", "Select the service", "Selecciona el servicio",
  # "h4_viz", "Visualització", "Visualization", "Visualización",
  # "deselect-all-text", "Ningú", "None selected...", "Ninguno",
  # "select-all-text", "Tots", "All selected...", "Todos",
  # "count-selected-text-value", "{0} valors seleccionats (de {1})", "{0} values selected (of {1})", "{0} valores seleccionados (de {1})",
  # "viz_color_input", "Indicador:", "Indicator:", "Indicador:",
  # "viz_statistic_input", "Estadístic:", "Statistic:", "Estadístico:",
  # "pal_high", "Discriminar valors alts", "Discriminate higher values", "Discriminar valores altos",
  # "pal_low", "Discriminar valors baixos", "Discriminate lower values", "Discriminar valores bajos",
  # "pal_normal", "Normal", "Normal", "Normal",
  # "viz_pal_config_input", "Configurar paleta", "Config palette", "Configurar paleta",
  # "viz_pal_reverse_input", "Invertir la paleta?", "Reverse the palette?", "¿Invertir la paleta?",
  # # save
  # 'save_map_btn', "Guarda el map", "Save the map", "Guarda el mapa",
  # 'save_table_btn', "Guarda la taula", "Save the table", "Guarda la tabla",
  # "csv", "Text (csv)", "Text (csv)", "Texto (csv)",
  # "xlsx", "MS Excel (xlsx)", "MS Excel (xlsx)", "MS Excel (xlsx)",
  # "table_output_options_input", "Selecciona el format", "Choose the output format", "Selecciona el formato",
  # # help module
  # "glossary_var_input", "Selecciona el indicador a descriure", "Choose the indicator to describe", "Selecciona el indicador a describir",
  # "link_to_tutorials_text", "Per obtenir més informació, aneu al tutorial de l'aplicació aquí", "For more info, please go to the application tutorial here", "Para obtener más información, vaya al tutorial de la aplicación aquí.",
  # "var_description_title", "Descripció:", "Description:", "Descripción:",
  # "var_units_title", "Unitats:", "Units:", "Unidades:",
  # "var_servei_title", "Servei:", "Service:", "Servicio:",
  # "dismiss", "Tancar", "Dismiss", "Cerrar",
  # # info module
  # "plot_id_info_plot_title", "Parcel·la seleccionada comparada amb les altres parcel·les al mapa", "Clicked plot compared to other plots in map", "Parcela seleccionada comparada con las otras parcelas en el mapa",
  # "admin_region_info_plot_title", "Comarca seleccionada comparada amb les altres comarques al mapa", "Clicked region compared to other regions in map", "Comarca seleccionada comparada con las otras comarcas en el mapa",
  # "admin_municipality_info_plot_title", "Municipi seleccionado comparad amb els altres municipis al mapa", "Clicked municipality compared to other municipalities in map", "Municipio seleccionada comparada con los otros municipios en el mapa",
  # "poly_id_info_plot_title", "Polìgon seleccionado comparado amb les altres polìgons al mapa", "Clicked polygon compared to other polygons in map", "Polígono seleccionada comparada con los otros polígonos en el mapa",
  # "admin_natura_network_2000_info_plot_title", "Àrea seleccionada comparada amb les altres àreas al mapa", "Clicked natural area compared to other natural areas in map", "Área seleccionada comparada con las otras áreas en el mapa",
  # "admin_special_protection_natural_area_info_plot_title", "Àrea seleccionada comparada amb les altres àreas al mapa", "Clicked natural area compared to other natural areas in map", "Área seleccionada comparada con las otras áreas en el mapa",
  # "admin_natural_interest_area_info_plot_title", "Àrea seleccionada comparada amb les altres àreas al mapa", "Clicked natural area compared to other natural areas in map", "Área seleccionada comparada con las otras áreas en el mapa",
  # # progress bar
  # "progress_message", "Obtenció de dades...", "Obtaining data...", "Obteniendo datos...",
  # "progress_detail_initial", "Escalant les dades", "Data scaling", "Escalando los datos",
  # # map
  # "stats_unavailable_title", "No hi ha dades", "No data available", "No hay datos disponibles",
  # "stats_unavailable", "El polígon actual conté menys de 3 parcel·les, no es calcularan estadístiques", "The current polygon contains less than 3 plots, no statistics will be calculated", "El polígono actual contiene menos de 3 gráficos, no se calcularán estadísticas",
  # # visual_aids
  # "diff_of_diffs", "Aquest indicador és una diferència de diferències, atès que el valor per a l'IFN3 és la diferència entre el període IFN2 - IFN3, i el valor per al IFN4 és la diferència per al període IFN3 - IFN4. D'aquesta manera, el valor presentat aquí és l'increment en la taxa, no una taxa per se", "This indicator is a difference of differences, as the value for the NFI3 is the difference for the period NFI2 - NFI3, and the value for NFI4 is the difference for the period NFI3 - NFI4. This way the value presented here is the increment on the rate, not a rate per se.", "Este indicador es una diferencia de diferencias, dado que el valor para el IFN3 es la diferencia entre el período IFN2 - IFN3, y el valor para el IFN4 es la diferencia para el período IFN3 - IFN4. De esta manera, el valor presentado aquí es el incremento en la tasa, no una tasa per se"
)

# internal data for package
usethis::use_data(
  # app_translations
  app_translations,

  internal = TRUE, overwrite = TRUE
)
