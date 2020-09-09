---
title: "Technical specifications"
output: html_document
---

### Introduction

**Meteoland App** tries to give daily meteorology estimations for all Catalonia
in the 1976-present time period. It is based on the data provided by the
[Agencia Estatal de Meteorologia (AEMET)](http://www.aemet.es) and the
[Servei Meteorologic de Catalunya (SMC)](http://www.meteo.cat). This service
is designed to provide support forestry studies in need of daily climatic data,
making it an accesory to the raw data provided by the mentioned institutions.
Is important to remember that data provided includes interpolations and calculations
based on models, so the data can be substantially different from real measurements.

### Data sources

Offered interpolations are performed based on measurements obtained at the
meteorological stations from the
[Agencia Estatal de Meteorologia (AEMET)](http://www.aemet.es) and the
[Servei Meteorologic de Catalunya (SMC)](http://www.meteo.cat). AEMET data includes
the 1976-present period, while SMC data belongs to the automatic stations network
(XEMA), progessively developed since 1988. In order to use the data provided by
the **Meteoland App** is mandatory to cite in the resulting documents (articles
or reports) both data sources.

### Metodology of meteorological variables estimation

There are numerous aproximations to the estimation and interpolation of
meteorological data. **Meteoland App** is based on the
[R package of the same name (De Cáceres *et al.* 2018)](https://cran.r-project.org/package=meteoland). This package implements
the interpolation and estimation algorithms developed for the DAYMET dataset
in the USA (Thornton *et al.* 1997; Thornton & Running 1999), with slight
modifications. Here we offer a summary of the metodology. This approach is based
on the establishment of weights for the meteorological stations as a decreasing
function of their distance to the target interpolation point. A negative
exponential function is used, depending on two parameters (Thornton *et al.* 1997):
parameter $\alpha$ modulates the function shape, changing the steepness, and the
parameter $N$ indicates a mean number of stations to include in the interpolation.
Based on the station density and $N$ the algorithm determines a cuttoff distance.
All stations beyond this distance are removed from the calculation.

For the specific variables calculated, there are differences in the metodology:

+ *Temperature* - Temperature interpolation includes a correction for the
  elevation differences between the meteorological stations and the target point.
  A weighted regression is used to find out the relationship between the differences
  in elevation in the stations and their temperature differences. This relationship,
  as well as the elevation difference with the target point is used to correct
  the temperature estimation, using the same procedure for Mean, Min and Max
  temperature values.
+ *Relative humidity* - Humidity interpolation is based on the Dew temperature
  (without any correction by elevation) and the previous temperature estimations
  to calculate the Mean, MAX and Min relative humidity.
+ *Rainfall* - Rainfall interpolation is more complex given the necessity of predict
  both the ocurrence and the quantity of the precipitation. In order to do this
  a binomial predictor is created in the first place for the precipitation
  ocurrence based on the stations ocurrence. In those target points that have
  ocurrence, the amount of precipitation is calculated in a similar way that the
  temperature data, including the elevation correction.
+ *Wind* - Wind interpolation is performed in two different ways, based on the
  availability of data. If only daily mean wind velocity is available, but
  no info about the direction is found, interpolation is made following the
  general metodology. If wind direction info is available, polar means are
  calculated using the weight method previously explained.

Not all variables calculated came from interpolation, some are calculated
*a posteriori* from the interpolated variables:

+ *Radiation* - Daily incident solar radiation is calculated in two steps. First
  the potential solar radiation is calculated based on solar declination as well
  as the latitude, aspect and slope of the target point (Granier & Ohmura 1968),
  integrating the instant radiation between dawn and sunset. Next, the daily
  incident solar radiation is estimated correcting the potential radiation by the
  atmosphere transmitance, following Thornton & Running (1999).
+ *Potential evapotranspiration* - Once we have all the previously mentioned
  variables, potential evapotranspiration is calculated using Penman (1948).

### Parameters and evaluation

As explained previously, interpolation method need to establish $\alpha$ and
$N$ parameters for each variable (two pairs in the case of precipitation).
These parameters has been estimated using calibrations for each year of the
historical series, choosing the parameters values which minimize the estimation
error in the same meteorological stations. For the actual year interpolation
last year parameters are used.

For the historical series, an evaluation of the prediction capacity of the
meteorological variables has been performed, using the optim interpolation
parameters. Both the mean absolute error (*MAE*) and *Bias* were estimated:

1. For the whole data.
2. For each station, using all days with available data
3. For each day, using all stations with data on that day.

The results by station and by day allow to inspect the variabiity on the
estimation quality by geographic location or year day.

### Bibliography

+ De Caceres M, Martin-StPaul N, Turco M, Cabon A, Granda V (2018) Estimating daily meteorological data and downscaling climate models over landscapes. Environmental Modelling and Software 108: 186-196.
+ Garnier, B.J., Ohmura, A., 1968. A method of calculating the direct shortwave radiation income of slopes. J. Appl. Meteorol. 7, 796–800.
+ Penman, H.L., 1948. Natural evaporation from open water, bare soil and grass. Proc. R. Soc. London. Ser. A. Math. Phys. Sci. 193, 129–145.
+ Thornton, P.E., Running, S.W., 1999. An improved algorithm for estimating incident daily solar radiation from measurements of temperature, humidity, and precipitation. Agric. For. Meteorol. 93, 211–228. https://doi.org/10.1016/S0168-1923(98) 00126-9.
+ Thornton, P.E., Running, S.W., White, M. A., 1997. Generating surfaces of daily meteorological variables over large regions of complex terrain. J. Hydrol. 190, 214–251. https://doi.org/10.1016/S0022-1694(96)03128-9.

