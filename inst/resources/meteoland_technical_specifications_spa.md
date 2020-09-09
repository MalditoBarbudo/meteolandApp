---
title: "Especificaciones técnicas"
output: html_document
---

### Introducción

La aplicación **Meteoland App** intenta proporcionar estimaciones de meteorología
diaria para toda Cataluña, en el período comprendido entre 1976 y la actualidad,
basándose en datos proporcionados por la
[Agencia Estatal de Meteorología (AEMET)](http://www.aemet.es) y el
[Servei Meteorologic de Catalunya (SMC)](http://www.meteo.cat).
Este servicio esta pensado para dar soporte a estudios en el ámbito forestal que
requieren información climática diaria, complementando los datos que pueden
ofrecer las instituciones citadas. Es importante recordar que los datos
proporcionados incluyen interpolaciones y cálculos basados en modelos, por lo que
los valores resultantes pueden contener diferencias notables respecto a medidas
reales.

### Orígenes de los datos

Las interpolaciones ofrecidas en esta aplicación se realizan a partir de las
medidas obtenidas en estaciones meteorológicas de la
[Agencia Estatal de Meteorología (AEMET)](http://www.aemet.es) y el
[Servei Meteorologic de Catalunya (SMC)](http://www.meteo.cat). Los datos de la
AEMET incluyen el período comprendido entre 1976 y la actualidad, mientras que
los datos del SMC corresponden a la red de estaciones automáticas (XEMA)
desarrollada progresivamente a partir del año 1988. Para utilizar los datos
proporcionados por la aplicación es necesario hacer constar en los documentos
resultantes (articulos o informes) éstos dos orígines de los datos.

### Metodología de estimación de variables meteorológicas

Existen numerosas aproximaciones para la interpolación y estimación de datos
meteorológicos. La aplicación **Meteoland App** se basa en el
[paquete de R del mismo nombre (De Cáceres *et al.* 2018)](https://cran.r-project.org/package=meteoland),
que implementa con unas pocas modificaciones los algoritmos de interpolación y
estimacuón desarrollados en EEUU para el dataset DAYMET
(Thornton *et al.* 1997; Thornton & Running 1999). Ofrecemos aquí una descripción
abreviada de la metodología. Esta aproximación se basa en establecer pesos para
las estaciones en función decreciente de su distancia al punto de interpolación
objetivo. La función utilizada es una exponencial negativa que depende de dos
parámetros (Thornton *et al.* 1997): un parámetro $\alpha$ que modula la forma
de la función, haciéndola más o menos abrupta, y un parámetro $N$ que indica un
número medio de estaciones a incluir en los datos utilizados por la interpolación.
Según la densidad de estaciones y el parámetro $N$, el algoritmo determina una
distancia de truncado que hace que aquellas estaciones que se encuentren a
distancias más grandes no sean tenidas en cuenta.

A partir de la aproximación general, conviene tener en cuenta las diferencias
metodológicas para las variables concretas:

+ *Temperatura* - La interpolación de la temperatura incluye una corrección para
  las diferencias de elevación entre las estaciones meteorológicas y el punto
  objectivo. Específicamente, se emplea una regresión ponderada para encontrar
  la relación entre las diferencias de elevación entre las estaciones utilizadas
  y sus diferencias de temperatura. Esta relación y las diferencias de elevación
  entre el punto objetivo y las estaciones se utilizan después para corregir la
  estimación de temperatura para el punto objetivo. EL mismo procedimiento se
  utiliza para la temperatura máxima, mínima y media.
+ *Humedad relativa* - La interpolación de la humedad se realiza sobre la
  temperatura de rocio (sin tener en cuenta ninguna correción por las diferencias
  en elevación) y después se calculan las humedades relativas media, mínima y
  máxima a partir de la estimación de temperatura.
+ *Precipitación* - La interpolación de la precipitación es más compleja, dada
  la necesidad de predecir tanto la ocurrencia de precipitación como la cantidad.
  Para hacerlo, se define primero un predictor binomial de la ocurrencia de
  precipitación a partir de la ocurrencia en las estaciones. Para aquellos
  puntos objetivo donde se determina que hay precipitación, la rutina de
  interpolación predice la cantidad de precipitación de manera similar a la
  temperatura, es decir, teniendo en cuenta la diferencia de elevación entre las
  estaciones y cada punto objectivo.
+ *Viento* - La interpolación del viento se realiza de dos maneras, según la
  información disponible. Si solamente se dispone de velocidades medias diarias,
  pero no de direcciones, la interpolación se realiza mediante el procedimiento
  general, pero si se dispone de direcciones se calculan los promedios polares
  utilizando los pesos mencionados.

Es importante tener en cuenta que hay variables que no son interpoladas, si no
que son calculadas *a posteriori* a partir de las interpolaciones de las
variables anteriores:

+ *Radiación* - La radiación solar incidente diaria se calcula en dos pasos. En
  primer lugar se determina una radiación solar potencial teniendo en cuenta la
  declinación solar así como la latitud, orientación y pendiente del punto
  objetivo (Granier & Ohmura 1968), integrando la radiación instantánea entre
  el amanecer y la puesta de sol. A continuación, se estima la radiación solar
  incidente corrigiendo la radiación potencial según la transmitancia de la
  atmósfera, siguiendo la aproximación de Thornton & Running (1999).
+ *Evapotranspiración potencial* - Una vez todas las variables mencionadas
  anteriormente están disponibles, se calcula la evapotranspiración potencial
  de referencia diaria para el punto objetivo según la aproximiación de
  Penman (1984).
  
### Parámetros y evaluación

Tal y como se ha comentado anteriormente, la metodología de interpolación
necesita especificar los parámetros $\alpha$ y $N$ para cada variable a interpolar
(en el caso de la precipitación serían dos parejas de variables). Éstos
parámetros han sido estimados mediante calibraciones para cada año de los
datos históricos, determinando aquellos parámetros que minimizaban el error de
estimación sobre las mismas estaciones de base. En el caso de la interpolación
para los datos del año en curso, se utilizan los parámetros determinados para el
año anterior.

Para los datos históricos se ha realizado una evaluación de la capacidad de
predicción de las diferentes variables meteorológicas, una vez establecidos los
parámetros de interpolación óptimos. En concreto se ha estimado el error
absoluto medio (*MAE*) y el sesgo mediano (*Bias*), calculados para:

1. El conjuto de datos disponibles.
2. Para cada estación, teniendo en cuenta todos los días del año con datos
  disponibles.
3. Para cada día, teniendo en cuenta las estaciones con datos para ese día.

Los resultados por estación y por día permiten ver la variabilidad de la calidad
de las estimaciones según la localización geográfica o el momento del año.

### Bibliografía

+ De Caceres M, Martin-StPaul N, Turco M, Cabon A, Granda V (2018) Estimating daily meteorological data and downscaling climate models over landscapes. Environmental Modelling and Software 108: 186-196.
+ Garnier, B.J., Ohmura, A., 1968. A method of calculating the direct shortwave radiation income of slopes. J. Appl. Meteorol. 7, 796–800.
+ Penman, H.L., 1948. Natural evaporation from open water, bare soil and grass. Proc. R. Soc. London. Ser. A. Math. Phys. Sci. 193, 129–145.
+ Thornton, P.E., Running, S.W., 1999. An improved algorithm for estimating incident daily solar radiation from measurements of temperature, humidity, and precipitation. Agric. For. Meteorol. 93, 211–228. https://doi.org/10.1016/S0168-1923(98) 00126-9.
+ Thornton, P.E., Running, S.W., White, M. A., 1997. Generating surfaces of daily meteorological variables over large regions of complex terrain. J. Hydrol. 190, 214–251. https://doi.org/10.1016/S0022-1694(96)03128-9.
