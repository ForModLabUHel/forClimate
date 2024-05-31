library(data.table)
currClimIDs <- fread("C:/Users/checc/Documents/research/weather/grid_coords")
setnames(currClimIDs,c("long_deg","lat_deg"),c("x","y"))
currclimIDs_tran <- c(200,500,700, 1385,2305,2805,3422)
exampleCoords <- as.matrix(currClimIDs[currclimIDs_tran,.(x,y)])
exampleCoords[3,] <- c(27.1,64.44)

load("C:/Users/checc/Documents/research/weather/CurrClim.rdata")

coords <- exampleCoords
startYear <- 1981
DataBaseFormat <- TRUE

currClimData <- extractWeatherPrebas(exampleCoords,startYear,
                                     DataBaseFormat,currClim_dataBase)$dataBase

startYear2 <- 2022
DataBaseFormat <- FALSE
climateChangeData <- extractWeatherPrebas(exampleCoords,startYear2,
                                          DataBaseFormat,climateChange_dataBase)

typicalSample <- sampleTypicalYears(currClimData)

dim(oo$PAR)



1. load the databases
2. process the data (extract the sites using the coordinates and the years used in the simulations)
point two needs to be done for climate change scenario and the Current Climate
2.1 currentClimate database (line 10 to 14)
2.2 climate change data extraction (lines 17 to 20)
2.3 update the climateIds in siteInfo
siteInfo[,2] <- climateChangeData$climIDs

3. run simulations:
  3.1 sample 5 typical years: typicalSample <- sampleTypicalYears(currClimData)
3.2 extract the correct years from the climateChangeData database !!!!!!every year has 365 days



