library(data.table)
library(prodlim)
source("Rsrc/dGrowthPrebas.r")
coordFin <- fread("data/coordinates.dat") 

currclimIDs_tran <- c(200,500,700, 1385,2305,2805,3422)
siteCoords <- as.matrix(coordFin[currclimIDs_tran,.(x,y)])
# siteCoords[3,] <- c(27.1,64.44)

load("C:/Users/checc/Documents/research/weather/CurrClim.rdata")
currClim_dataBase = dat

startYear <- 1980
DataBaseFormat <- TRUE

currClimData <- extractWeatherPrebas(siteCoords,startYear,coordFin,
                    DataBaseFormat,currClim_dataBase,sourceData="currClim")$dataBase

load("C:/Users/checc/Downloads/CanESM2.rcp85.rdata")
climateChange_dataBase = dat
startYear2 <- 2022
DataBaseFormat <- FALSE
climateChangeData <- extractWeatherPrebas(siteCoords,startYear2,coordFin,
                      DataBaseFormat,climateChange_dataBase,sourceData="climChange")

typicalSample <- sampleTypicalYears(currClimData)



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



