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
  'date_range_explanation', "L'interval de dates es limita a un màxim de 31 dies des de la data d'inici. Seleccioneu la data de finalització en conseqüència.", "Date range is limited to a max of 31 days from start date. Please select the end date accordingly.", "El rango de fechas está limitado a un máximo de 31 días desde la fecha de inicio. Seleccione la fecha final en consecuencia.",
  # use file selection
  "user_file_sel_label", "Selecciona l'arxiu a carregar", "Select the file to upload", "Selecciona el archivo a cargar",
  "user_file_sel_buttonLabel", "Inspecciona...", "Browse...", "Inspecciona...",
  "user_file_sel_placeholder", "Cap fitxer seleccionat", "No file selected", "Ningún archivo seleccionado",
  "file_text", 'El fitxer pot ser un shapefile (comprimit en un fitxer zip) o un fitxer GeoPackage (.gpkg). Han de tenir un camp anomenat "poly_id" amb els identificadors dels geometries continguts.', 'File can be a shapefile (compressed in a zip file) or GeoPackage file (.gpkg). They must have a field called "poly_id" with the identifiers of the contained geometries.', 'El archivo puede ser un shapefile (comprimido en un archivo zip) o un archivo GeoPackage (.gpkg). Deben tener un campo llamado "poly_id" con los identificadores de las geometrías contenidas.',
  # map
  "cite_div", "Dades elaborades pel CTFC i el CREAF a partir de les xarxes d'estacions meteorològiques automàtiques del SMC i AEMET.", "Data prepared by the CTFC and CREAF from the networks of automatic weather stations of the SMC and AEMET.", "Datos elaborados por el CTFC y el CREAF a partir de las redes de estaciones meteorológicas automáticas del SMC y AEMET.",
  # 'Relief', 'Relleu (base)', 'Relief (base)', 'Relieve (base)',
  # 'Imaginery', 'Satèl·lit (base)', 'Imaginery (base)', 'Satélite (base)',
  # tabs translations
  "main_tab_translation", "Explora", "Explore", "Explora",
  "data_translation", "Dades", "Data", "Datos",
  "viz_translation", "Visualització", "Visualization", "Visualización",
  "save_translation", "Guardar", "Save", "Guardar",
  "help_translation", "Ajuda", "Help", "Ayuda",
  "map_translation", "Mapa", "Map", "Mapa",
  "table_translation", "Taula", "Table", "Tabla",
  "cv_translation", "Validació de la interpolació", "Interpolation validation", "Validación de la interpolación",
  "tech_specs_translation", "Especificacions tècniques", "Technical specifications", "Especificaciones técnicas",
  # apply module
  "apply", "Aplicar", "Apply", "Aplicar",
  # variables
  'MeanTemperature', "Temperatura mitjana [°C]", "Mean Temperature [°C]", "Temperatura media [°C]",
  'MinTemperature', "Temperatura mínima [°C]", "Min Temperature [°C]", "Temperatura mínima [°C]",
  'MaxTemperature', "Temperatura màxima [°C]", "Max Temperature [°C]", "Temperatura máxima [°C]",
  'MeanRelativeHumidity', "Humitat relativa mitjana [%]", "Mean Relative Humidity [%]", "Humedad relativa media [%]",
  'MinRelativeHumidity', "Humitat relativa mínima [%]", "Min Relative Humidity [%]", "Humedad relativa mínima [%]",
  'MaxRelativeHumidity', "Humitat relativa màxima [%]", "Max Relative Humidity [%]", "Humedad relativa máxima [%]",
  'Precipitation', "Precipitació [mm]", "Precipitation [mm]", "Precipitación [mm]",
  'Radiation', "Radiació [MJ/m2]", "Radiation [MJ/m2]", "Radiación [MJ/m2]",
  'WindSpeed', "Velocitat del vent [m/s]", "Wind Speed [m/s]", "Velocidad del viento [m/s]",
  'WindDirection', "Direcció del vent [° des del N]", "Wind Direction [° from N]", "Dirección del viento [° desde N]",
  'ThermalAmplitude', "Amplitud Tèrmica [°C]", "Thermal Amplitude [°C]", "Amplitud Térmica [°C]",
  'PET', "PET [mm]", "PET [mm]", "PET [mm]",
  # viz
  "h4_viz", "Visualització", "Visualization", "Visualización",
  "viz_color_input", "Variable:", "Variable:", "Variable:",
  "viz_date_input", "Data:", "Date:", "Fecha:",
  "viz_pal_reverse_input", "Invertir la paleta?", "Inverse pallete", "¿Invertir la paleta?",
  "deselect-all-text", "Ningú", "None selected...", "Ninguno",
  "select-all-text", "Tots", "All selected...", "Todos",
  "count-selected-text-value", "{0} valors seleccionats (de {1})", "{0} values selected (of {1})", "{0} valores seleccionados (de {1})",
  # ts module
  'ts_button', "Sèries temporals", "Time series", "Series temporales",
  "dismiss", "Tancar", "Dismiss", "Cerrar",
  "ts_points", "Seleccioneu els punts per la sèrie temporal", "Select the points for the time series", "Selecciona los puntos para la serie temporal",
  "ts_title", "Sèries temporals", "Time series", "Series temporales",
  "activate_tsraster", "Activeu sèries temporals", "Activate time series", "Activar series temporales",
  "tsraster_info", "Quan aquesta està activa, permet fer clic al mapa per visualitzar una sèrie temporal de les coordenades en què es va fer clic.", "When this is active, it allows to click on the map to visualize a time series for the coordinates clicked.", "Cuando está activo, permite hacer click en el mapa para visualizar una serie temporal para las coordenadas seleccionadas.",
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
  'sweet_alert_nopoly_title', "No s'ha dibuixat cap polígon", "No polygon has been drawn", "No se ha dibujado ningún polígono",
  'sweet_alert_nopoly_text', "Dibuixa un polígon amb l'eina de l'map i prova de nou", "Draw a polygon with the map tool and try again", "Dibuja un polígono con la herramienta del map y prueba de nuevo",
  'sweet_alert_res1km_title', 'Resolució de la interpolació', 'Interpolation resolution', 'Resolución de la interpolación',
  'sweet_alert_res1km_text', '1 km', '1 km', '1 km',
  'sweet_alert_res30m_title', 'Resolució de la interpolació', 'Interpolation resolution', 'Resolución de la interpolación',
  'sweet_alert_res30m_text', '30 m', '30 m', '30 m',
  'sweet_alert_30days_title', "El rang de dates està limitat a 31 dies", "Date range is limited to 31 days", "El rango de fechas está limitado a 31 días",
  'sweet_alert_30days_text', "La data final s'ha canviat a 31 dies des de la data inicial.", "Ending date has been changed to 31 days from start date.", "La fecha final se ha cambiado a 31 días desde la fecha inicial.",
  "sweet_alert_all_nas_title", "Aquesta variable no té valors,", "This variable has not values,", "Esta variable no tiene valores,",
  "sweet_alert_all_nas_text", "si us plau selecciona una altra", "please select another", "por favor selecciona otra",
  "ts_one_date", "No s'ha pogut crear una sèrie temporal amb una sola data", "Could not create a time series with a single date", "No se pudo crear una serie temporal con una sola fecha",
  "under_construction_title", "Meteoland App està en manteniment.", "Meteoland App is under maintenance.", "Meteoland App está bajo mantenimiento.",
  "under_construction_text", "Algunes funcionalitats i dades poden faltar temporalment. Es poden produir errors (pantalles grises) en consultar les dades que falten.", "Some functionality, data can be temporally missing. Errors (gray screens) can happen when consulting missing data.", "Alguna funcionalidad o datos pueden faltar temporalmente. Pueden ocurrir errores (pantallazo gris) al consultar estos datos faltantes.",
  # save
  'save_map_btn', "Descarrega", "Download", "Descarga",
  'save_remarks', 'Tots els arxius espacials generats es troben en el sistema de referència de coordenades EPGS:3043:', 'All generated spatial files are in the EPGS: 3043 coordinate reference system.', 'Todos los archivos espaciales generados se encuentran en el sistema de referencia de coordenadas EPGS:3043:',
  'save_remarks_2', 'Els rásteres es guardaran en format GeoTiff (extensió .tif). Si la consulta es realitza per punts, es guardaran en format GeoPackage (extensió .gpkg).', 'The rasters will be saved in GeoTiff format (.tif extension). If the query is made for points, they will be saved in GeoPackage format (extension .gpkg).', 'Los rásteres se guardarán en formato GeoTiff (extensión .tif). Si la consulta se realiza para puntos, se guardarán en formato GeoPackage (extensión .gpkg).',
  # cv module
  'cv_intro', "Aquests són els resultats de la validació creuada per al procés d’interpolació de dades meteorològiques diàries. La validació es va fer fent prediccions sobre la ubicació de cada estació metereològica després d’excloure les dades del model. La validació creuada es va dur a terme per a cada any durant el període 1976-2017 per separat.", "These are the cross-validation results for the process of interpolating daily meteorological data. Validation was done by making predictions for the location of each metereological station after excluding its data from the model. Cross-validation was conducted for each year in the 1976-2017 period separately.", "Estos son los resultados de la validación cruzada para el proceso de interpolación de datos meteorológicos diarios. La validación se realizó haciendo predicciones para la ubicación de cada estación meteorológica después de excluir sus datos del modelo. La validación cruzada se realizó para cada año en el período 1976-2017 por separado.",
  'TemperatureRange', "Rang de temperatura [°C]", "Temperature range [°C]", "Rango de temperatura [°C]",
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
  "MAE", "MAE", "MAE", "MAE",
  "sd.station.MAE", "MAE sd per estaciò", "MAE sd by station", "MAE sd por estación",
  "sd.dates.MAE", "MAE sd per data", "MAE sd by date", "MAE sd por fecha",
  "Bias", "Bias", "Bias", "Bias",
  "sd.station.Bias", "Bias sd per estaciò", "Bias sd by station", "Bias sd por estación",
  "sd.dates.Bias", "Bias sd per data", "Bias sd by date", "Bias sd por fecha",
  'cv_download', 'Descarrega', 'Download', 'Descarga',
  # modes explanation
  "current_mode_explanation", "Dades d’interpolació dels darrers 365 dies (any natural). Totes les interpolacions es fan amb una resolució d’1 km, excepte els fitxers que contenen punts individuals, en què la interpolació es realitza a 30 m de resolució.", "Interpolation data for the last 365 days (natural year). All interpolations are done in a 1km resolution, except for files containing individual points, in which the interpolation is made at 30m resolution.", "Datos de interpolación de los últimos 365 días (año natural). Todas las interpolaciones se realizan con una resolución de 1 km, excepto los archivos que contienen puntos individuales, en los que la interpolación se realiza con una resolución de 30 m.",
  "historic_mode_explanation", "Dades d’interpolació de dates històriques (des del 1976). Totes les interpolacions, inclosos fitxers que contenen punts individuals, es fan a una resolució d'1 km.", "Interpolation data for historic dates (since 1976). All interpolations, included file containing individual points, are made at 1km resolution.", "Datos de interpolación para fechas históricas (desde 1976). Todas las interpolaciones, incluidos los archivos que contienen puntos individuales, se realizan a una resolución de 1 km.",

  # poly_id_var_check
  "poly_id_missing_title", "No s'ha trobat cap variable anomenada 'poly_id' al fitxer", "Not 'poly_id' variable found in file", "No se ha encontrado ninguna variable llamada 'poly_id' en el archivo",
  "poly_id_missing_message", "S'ha fet servir la primera variable del fitxer com a poly_id", "First variable found in file used as poly_id", "Se ha usado la primera variable del archivo como poly_id"
)

# internal data for package
usethis::use_data(
  # app_translations
  app_translations,

  internal = TRUE, overwrite = TRUE
)
