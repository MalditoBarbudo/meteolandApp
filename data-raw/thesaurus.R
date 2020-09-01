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
  "file", "Arxiu spaial", "Spatial file", "Archivo espacial",
  # date range
  'date_range', 'Rang de dates', 'Dates range', 'Rango de fechas',
  'date_separator', " a ", " to ", " a ",
  # use file selection
  "user_file_sel_label", "Selecciona l'arxiu a carregar", "Select the file to upload", "Selecciona el archivo a cargar",
  "user_file_sel_buttonLabel", "Inspecciona...", "Browse...", "Inspecciona...",
  "user_file_sel_placeholder", "Cap fitxer seleccionat", "No file selected", "Ningún archivo seleccionado",
  "file_text", 'El fitxer pot ser un shapefile (comprimit en un fitxer zip) o un fitxer GeoPackage (.gpkg). Han de tenir un camp anomenat "id" amb els identificadors dels geometries continguts.', 'File can be a shapefile (compressed in a zip file) or GeoPackage file (.gpkg). They must have a field called "id" with the identifiers of the contained geometries.', 'El archivo puede ser un shapefile (comprimido en un archivo zip) o un archivo GeoPackage (.gpkg). Deben tener un campo llamado "id" con los identificadores de las geometrías contenidas.',
  # map
  "cite_div", "Dades elaborades pel CTFC i el CREAF.", "Data prepared by the CTFC and CREAF.", "Datos elaborados por el CTFC y el CREAF.",
  # 'Relief', 'Relleu (base)', 'Relief (base)', 'Relieve (base)',
  # 'Imaginery', 'Satèl·lit (base)', 'Imaginery (base)', 'Satélite (base)',
  # tabs translations
  "main_tab_translation", "Explora", "Explore", "Explora",
  "data_translation", "Dades", "Data", "Datos",
  "save_translation", "Guardar", "Save", "Guardar",
  "help_translation", "Ajuda", "Help", "Ayuda",
  "map_translation", "Mapa", "Map", "Mapa",
  "table_translation", "Taula", "Table", "Tabla",
  "cv_translation", "Validacions creuades", "Cross-validations", "Validaciones cruzadas",
  # apply module
  "apply", "Aplicar", "Apply", "Aplicar",
  # variables
  'MeanTemperature', "Temperatura mitjana [ºC]", "Mean Temperature [ºC]", "Temperatura media [ºC]",
  'MinTemperature', "Temperatura mínima [ºC]", "Min Temperature [ºC]", "Temperatura mínima [ºC]",
  'MaxTemperature', "Temperatura màxima [ºC]", "Max Temperature [ºC]", "Temperatura máxima [ºC]",
  'MeanRelativeHumidity', "Humitat relativa mitjana [%]", "Mean Relative Humidity [%]", "Humedad relativa media [%]",
  'MinRelativeHumidity', "Humitat relativa mínima [%]", "Min Relative Humidity [%]", "Humedad relativa mínima [%]",
  'MaxRelativeHumidity', "Humitat relativa màxima [%]", "Max Relative Humidity [%]", "Humedad relativa máxima [%]",
  'Precipitation', "Precitpitació [mm]", "Precipitation [mm]", "Precipitación [mm]",
  'Radiation', "Radiació", "Radiation", "Radiación",
  'WindSpeed', "Velocitat del vent", "Wind Speed", "Velocidad del viento",
  'WindDirection', "Direcció del vent", "Wind Direction", "Dirección del viento",
  # viz
  "h4_viz", "Visualització", "Visualization", "Visualización",
  "viz_color_input", "Variable:", "Variable:", "Variable:",
  "viz_date_input", "Data:", "Date:", "Fecha:",
  "deselect-all-text", "Ningú", "None selected...", "Ninguno",
  "select-all-text", "Tots", "All selected...", "Todos",
  "count-selected-text-value", "{0} valors seleccionats (de {1})", "{0} values selected (of {1})", "{0} valores seleccionados (de {1})",
  # progress bar
  "progress_message", "Interpolant dades...", "Interpolating data...", "Interpolating datos...",
  "progress_detail_initial", "Això pot trigar uns minuts depenent de la franja de dates i el nombre de geometries", "This can take a while depending on the date range and number of geometries", "Esto puede tardar unos minutos dependiendo del rango de fechas y el número de geometrías",
  "progress_message_raster", "Interpolant dades per ", "Interpolating data for ", "Interpolando datos para ",
  "progress_message_drawn_polygon", "Interpolant dades per al polígon", "Interpolating data for the polygon", "Interpolando datos para el polígono",
  "progress_message_file", "Interpolant dades per a l'arxiu", "Interpolating data for the file", "Interpolando datos para el archivo",
  # sweet alerts
  'sweet_alert_date_missing_title', "No hi ha dades per a aquesta data", "No data for this date.", "No hay datos para esta fecha",
  'sweet_alert_date_missing_text', "Si us plau seleccioneu una altra data en el control de visualització", "Please select another one in the visualization control", "Por favor, seleccione otra fecha en el control de visualización",
  'sweet_alert_fileext_title', "Format de fitxer no acceptat", "File format not accepted", "Formato de archivo no aceptado",
  'sweet_alert_fileext_text', "L'arxiu carregat ha de ser un zip o gpkg", "Uploaded file must be a zip or a gpkg file", "El archivo cargado debe ser un zip o un gpkg",
  'sweet_alert_nodata_title', "No s'ha pogut accedir a les dades.", "No data can be retrieved.", "No se ha podido acceder a los datos.",
  'sweet_alert_nodata_text', "Això pot ser un problema de connexió amb la base de dades o que no es troben dades per a les dates proporcionades. Si us plau-ho a provar amb un altre rang de dates", "It can be a problem of the database connection or that no data can be retrieved for the dates provided. Please try with another set of dates.", "Esto puede ser un problema de conexión con la base de datos o que no se encuentran datos para las fechas proporcionadas. Por favor, inténtelo de nuevo con otro rango de fechas",
  'sweet_alert_res1km_title', 'Resolució de la interpolació', 'Interpolation resolution', 'Resolución de la interpolación',
  'sweet_alert_res1km_text', '1 km', '1 km', '1 km',
  'sweet_alert_res30m_title', 'Resolució de la interpolació', 'Interpolation resolution', 'Resolución de la interpolación',
  'sweet_alert_res30m_text', '30 m', '30 m', '30 m',
  # save
  'save_map_btn', "Guarda el map", "Save the map", "Guarda el mapa",
  'save_remarks', 'Tots els arxius espacials generats es troben en el sistema de referència de coordenades EPGS:3043:', 'All generated spatial files are in the EPGS: 3043 coordinate reference system.', 'Todos los archivos espaciales generados se encuentran en el sistema de referencia de coordenadas EPGS:3043:',
  'save_remarks_2', 'Els rásteres es guardaran en format GeoTiff (extensió .tif). Si la consulta es realitza per punts, es guardaran en format GeoPackage (extensió .gpkg).', 'The rasters will be saved in GeoTiff format (.tif extension). If the query is made for points, they will be saved in GeoPackage format (extension .gpkg).', 'Los rásteres se guardarán en formato GeoTiff (extensión .tif). Si la consulta se realiza para puntos, se guardarán en formato GeoPackage (extensión .gpkg).',
  # cv module
  'cv_intro', "Aquests són els resultats de la validació creuada per al procés d’interpolació de dades meteorològiques diàries. La validació es va fer fent prediccions sobre la ubicació de cada estació metereològica després d’excloure les dades del model. La validació creuada es va dur a terme per a cada any durant el període 1976-2017 per separat.", "These are the cross-validation results for the process of interpolating daily meteorological data. Validation was done by making predictions for the location of each metereological station after excluding its data from the model. Cross-validation was conducted for each year in the 1976-2017 period separately.", "Estos son los resultados de la validación cruzada para el proceso de interpolación de datos meteorológicos diarios. La validación se realizó haciendo predicciones para la ubicación de cada estación meteorológica después de excluir sus datos del modelo. La validación cruzada se realizó para cada año en el período 1976-2017 por separado.",
  'TemperatureRange', "Rang de temperatura [ºC]", "Temperature range [ºC]", "Rango de temperatura [ºC]",
  "RelativeHumidity", "Humitat relativa [%]", "Relative Humidity [%]", "Humedad relativa [%]",
  "Station.rainfall", "Precipitaciò per estaciò", "Rainfall by station", "Precipitación por estación",
  "Station.rainfall.relative", "Precipitaciò per estaciò relativa", "Rainfall by station (relative)", "Precipitación por estación relativa",
  "Station.precdays", "Dies amb precipitació per estació", "Days with rainfall by station", "Dias con precipitación por estación",
  "Station.precdays.relative", "Dies amb precipitació per estació relativo", "Days with rainfall by station (relative)", "Dias con precipitación por estación relativo",
  "Date.rainfall", "Precipitaciò per data", "Rainfall by date", "Precipitación por fecha",
  "Date.rainfall.relative", "Precipitaciò per data relativa", "Rainfall by date (relative)", "Precipitación por fecha relativa",
  "Date.precstations", "Dies amb precipitació per data", "Days with rainfall by date", "Dias con precipitación por fecha",
  "Date.precstations.relative", "Dies amb precipitació per data relativo", "Days with rainfall by date (relative)", "Dias con precipitación por fecha relativo",
  "variable", "Variable", "Variable", "Variable",
  "year", "Any", "Year", "Año",
  "n", "n", "n", "n",
  "r", "r", "r", "r",
  "MAE", "MAE", "MAE", "MAE",
  "sd.station.MAE", "MAE sd per estaciò", "MAE sd by station", "MAE sd por estación",
  "sd.dates.MAE", "MAE sd per data", "MAE sd by date", "MAE sd por fecha",
  "Bias", "Bias", "Bias", "Bias",
  "sd.station.Bias", "Bias sd per estaciò", "Bias sd by station", "Bias sd por estación",
  "sd.dates.Bias", "Bias sd per data", "Bias sd by date", "Bias sd por fecha",


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
  # "h4_servei", "Fixa el servei", "Select the service", "Selecciona el servicio",
  # "viz_statistic_input", "Estadístic:", "Statistic:", "Estadístico:",
  # "pal_high", "Discriminar valors alts", "Discriminate higher values", "Discriminar valores altos",
  # "pal_low", "Discriminar valors baixos", "Discriminate lower values", "Discriminar valores bajos",
  # "pal_normal", "Normal", "Normal", "Normal",
  # "viz_pal_config_input", "Configurar paleta", "Config palette", "Configurar paleta",
  # "viz_pal_reverse_input", "Invertir la paleta?", "Reverse the palette?", "¿Invertir la paleta?",
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
