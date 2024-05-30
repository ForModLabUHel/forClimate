library(data.table)
currClimIDs <- fread("C:/Users/minunno/Documents/research/weather/grid_coords")
setnames(currClimIDs,c("long_deg","lat_deg"),c("x","y"))
currclimIDs_tran <- c(200,500,700, 1385,2305,2805,3422)
exampleCoords <- as.matrix(currClimIDs[currclimIDs_tran,.(x,y)])
exampleCoords[3,] <- c(27.1,64.44)

load("C:/Users/minunno/Documents/research/weather/CurrClim.rdata")

coords <- exampleCoords
startYear <- 1981
outDataBase <- TRUE

climateIn <- extractWeatherPrebas(exampleCoords,1991,TRUE)$dataBase

oo <- sampleTypicalYears(climateIn)



currClimIDs
RCPsIDs
coords <- exampleCoords

xx <- coords[1,]
x <- xx[1] - currClimIDs$long_deg
y <- xx[2] - currClimIDs$lat_deg
hip = sqrt(x^2 + y^2)
which.min(hip)
hip[200]
