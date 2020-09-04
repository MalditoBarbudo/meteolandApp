---
title: "Especificacions tècniques"
output: html_document
---



### Introducció

L'aplicació **Meteoland App** intenta proporcionar estimacions de meteorologia diària per a tot Catalunya, cobrint el periode entre 1976 i l'actualitat, basant-se en dades proporcionades per l'[Agencia Estatal de Meteorologia (AEMET)](http://www.aemet.es) i el [Servei Meteorologic de Catalunya (SMC)](http://www.meteo.cat). Aquest servei està pensat per donar suport d'estudis en l'àmbit forestal que requereixin informació climàtica diària, complementant les dades que puguin oferir les institucions esmentades. És important recordar que les dades proporcionades inclouen interpolacions i càlculs basats en models, pel que els valors resultants poden contenir diferències notables respecte a mesuraments.

### Fonts de dades

Les interpolacions ofertes en aquesta aplicació es realitzen a partir de mesuraments obtinguts en estacions meteorològiques de l'[Agencia Estatal de Meteorologia (AEMET)](http://www.aemet.es) i el [Servei Meteorologic de Catalunya (SMC)](http://www.meteo.cat). Les dades de l'AEMET inclouen el periode comprès entre 1976 i l'actualitat, mentre que les del SMC corresponen a la xarxa d'estacions automàtiques (XEMA) desenvolupat progressivament a partir de l'any 1988. Per a utilitzar les dades proporcionades per l'aplicació és necessari fer constar en els documents resultants (articles o informes) aquestes dues fonts de dades.

### Metodologia d'estimació de variables meteorològiques

Existeixen nombroses aproximacions per a l'interpolació i estimació de dades meteorològiques. L'aplicació **Meteoland App** es basa en el paquet d'R del mateix nom (De Cáceres et al. 2018), que implementa amb unes poques modificacions els algoritmes d'interpolacio i estimació desenvolupats als EEUU per al dataset DAYMET (Thornton et al. 1997; Thornton & Running 1999). Oferim aquí una descripció abreujada de la metodologia. Aquesta aproximació es basa en establir pesos per a les estacions en funció decreixent de la seva distancia al punt d'interpolació objectiu. La funció utilitzada és una exponencial negativa que depèn de dos paràmetres (Thornton et al. 1997): un paràmetre $\alpha$ que modula la forma de la funció, fent-la més o menys abrupte, i un paràmetre $N$ que indica un nombre mitja d'estacions a incloure en les dades utilitzades per a la interpolació. Segons la densitat d'estacions i el paràmetre $N$, l'algoritme determina una distància de truncament que fa que aquelles estacions que es trobin a distancies més grans no siguin tingudes en compte.

A partir de la aproximació general, cal tenir en compte les diferències metodològiques per variables concretes:

+ *Temperatura* - La interpolació de la temperatura inclou una correcció per les diferències d'elevació entre les estacions meteorològiques i el punt objectiu. Especificament, s'empra una regresió ponderada per esbrinar la relació entre les diferències d'elevació entre les estacions utilitzades i les seves diferències de temperatura. Aquesta relació i les diferències d'elevació entre el punt objectiu i les estacions s'utilitzen després per corregir l'estimació de temperatura per al punt objectiu. El mateix procediment s'utilitza per a la temperatura màxima, mínima i mitjana.
+ *Humitat relativa* - La interpolació de la humitat es realitza sobre la temperatura de rosada (sense tenir en compte cap correció per diferències d'elevació) i després es calculen les humitats relatives mitjana, mínima i màxima a partir de l'estimació de temperatura.
+ *Precipitació* - La interpolació de la precipitació és més complexa, donada la necessitat de predir tant la ocurrència de precipitació com la quantitat. Per a fer-ho, es defineix primer un predictor binomial de la ocurrència de precipitació a partir de la ocurrència en les estacions. Per a aquells punts objectiu on es determina que hi ha precipitació, la rutina d'interpolació prediu la quantitat de precipitació de manera semblant a la temperatura, és a dir tenint en compte la diferència d'elevació entre les estacions i cada punt objectiu.
+ *Vent* - La interpolació del vent es realitza de dues maneres segons la informació disponible. Si només es disposa de velocitats mitjanes diàries, però no de direccions, la interpolació es realitza mitjançant el procediment general, però si es disposa de direccions es calculen promitjos polars fent servir els pesos esmentats.

És important tenir en compte que hi ha variables que no són interpolades, sinó que són calculades *a posteriori* a partir de les interpolacions de les variables anteriors:

+ *Radiació* - La radiació solar incident diària es calcula en dos passos. En primer lloc es determina una radiació solar potencial tenint en compte la declinació solar així com la latitut, orientació i pendent del punt objectiu (Granier & Ohmura 1968), integrant la radiació  instantània entre l'alba i la posta de sol. A continuació, s'estima la radiació solar incident corregint la radiació potencial segons la transmitància de l'atmosfera, seguint l'aproximació de Thornton & Running (1999).
+ *Evapotranspiració potencial* - Un cop totes les variables esmentades anteriorment estan disponibles, es calcula l'evapotranspiració potencial de referència diària per al punt objectiu segons l'aproximació de Penman (1948)


### Estimació a partir de dades històriques

L'aplicació **Meteoland App** ofereix estimacions històriques de meteorologia diària a Catalunya per al periode comprès entre 1976 i l'any anterior a l'any en curs. En el cas de consultes en mode ràster o per àrees seleccionades, les dades han estat interpolades/calculades prèviament i es proporcionen a una resolució espacial d'1km. Aquestes consultes estan limitades a un periode de 30 dies. Per a consultes sobre punts, els càlculs es realitzen en el moment de la consulta i utilitzen una base topogràfica amb resolució de 30 m, pel que és possible obtenir estimacions més fines pel que fa a variables meteorològiques afectades per la topografia.

### Estimació per a l'any en curs

L'aplicació **Meteoland App** també ofereix la possibilitat d'estimar dades de meteorologia per a dies de l'any en curs fins a la data d'ahir. La interpolació/càlcul de dades de l'any en curs es realitza a partir de dades obtingudes diàriament del l'AEMET i SMC mitjançant els serveis *OpenData* oferts per ambdues institucions. Aquest fet implica que les dades de les estacions no han passat tots els controls de qualitat pertinents i poden contenir errors. S'apliquen aquí les mateixes consideracions respecte a les consultes en ràster, poligons o punts esmentades a l'apartat d'estimació de dades històriques.

### Paràmetrització i evaluació

Tal i com s'ha esmentat anteriorment, la metodologia d'interpolació necessita especificar els paràmetres $\alpha$ i $N$ per a cada variable a interpolar (en el cas de la precipitació són dos parells). Aquests paràmetres han estat estimats mitjançant calibracions per a cada any de les dades històriques, determinant aquells paràmetres que minimitzaven l'error d'estimació sobre les mateixes estacions de base. En el cas de la interpolació per a dades de l'any en curs, s'utilitzen els paràmetres determinats per a l'any anterior.

Per als anys històrics s'ha realitzat una evaluació de la capacitat de predicció de les diferents variables meteorològiques, un cop establerts els paràmetres d'interpolació òptims. En concret s'ha estimat l'error absolut mitjà (*MAE*) i el biaix mitjà (*Bias*), calculats per:

1. El conjunt de les dades disponibles.
2. Per cada estació, tenint en compte tots els dies de l'any amb dades disponibles. 
3. Per cada dia, tenint en compte les estacions amb dades per a aquell dia.

Els resultats per estació i per dia permeten veure la variabilitat de la qualitat de les estimacions segons la localització geogràfica o el moment de l'any.


### Bibliografia

+ De Caceres M, Martin-StPaul N, Turco M, Cabon A, Granda V (2018) Estimating daily meteorological data and downscaling climate models over landscapes. Environmental Modelling and Software 108: 186-196.
+ Garnier, B.J., Ohmura, A., 1968. A method of calculating the direct shortwave radiation income of slopes. J. Appl. Meteorol. 7, 796–800.
+ Penman, H.L., 1948. Natural evaporation from open water, bare soil and grass. Proc. R. Soc. London. Ser. A. Math. Phys. Sci. 193, 129–145.
+ Thornton, P.E., Running, S.W., 1999. An improved algorithm for estimating incident daily solar radiation from measurements of temperature, humidity, and precipitation. Agric. For. Meteorol. 93, 211–228. https://doi.org/10.1016/S0168-1923(98) 00126-9.
+ Thornton, P.E., Running, S.W., White, M. A., 1997. Generating surfaces of daily meteorological variables over large regions of complex terrain. J. Hydrol. 190, 214–251. https://doi.org/10.1016/S0022-1694(96)03128-9.
