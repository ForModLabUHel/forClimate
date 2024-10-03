# install.packages("devtools")
# devtools::install_github("ForModLabUHel/Rprebasso")  # install the package if it's not ready in your R

# install.packages("data.table")  # install the package if it's not ready in your R
# install.packages("prodlim")     # install the package if it's not ready in your R
# install.packages("tidyverse")   # install the package if it's not ready in your R
# install.packages("sf")          # install the package if it's not ready in your R

library(Rprebasso)
library(data.table)
library(prodlim)
# library(tidyverse)
library(sf)

# base::setwd("C:/Daesung_R/ForClimate/prebas") # Set your working directory
# base::getwd()

# base::rm(list = ls())
# base::rm(list = setdiff(ls(), c("currClim_dataBase", "climateChange_dataBase_rcp85")))


# load dGrowthPrebas function ---------------------------------------------
# source("C:/Daesung_R/ForClimate/prebas/Rsrc/dGrowthPrebas.r")
devtools::source_url("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/Rsrc/dGrowthPrebas.r")

# load coordinate ID table --------------------------------------------------------
# coordFin <- fread("C:/Daesung_R/ForClimate/Motti_C/coordinates.dat") 
coordFin <- data.table::fread("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/data/coordinates.dat")

# load current climate Rdata -----------------------------------------------
base::load("C:/Daesung_R/ForClimate/Motti_C/climate rcp database/CurrClim.rdata") # load the current climate database (0.98 GB) from your local drive
currClim_dataBase_1 <- dat

# load future climate rcp85 Rdata -----------------------------------------------
base::load("C:/Daesung_R/ForClimate/Motti_C/climate rcp database/CanESM2.rcp85.rdata") # load the future climate rcp85 database (3.66 GB) from your local drive
climateChange_dataBase_rcp85 <- dat

# load future climate rcp45 Rdata -----------------------------------------------
base::load("C:/Daesung_R/ForClimate/Motti_C/climate rcp database/CanESM2.rcp45.rdata") # load the future climate rcp45 database (3.66 GB) from your local drive
climateChange_dataBase_rcp45 <- dat

# load future climate rcp26 Rdata -----------------------------------------------
base::load("C:/Daesung_R/ForClimate/Motti_C/climate rcp database/CanESM2.rcp26.rdata") # load the future climate rcp26 database (2.93 GB) from your local drive
climateChange_dataBase_rcp26 <- dat

# sample site coordinate ---------------------------------------------------------
coord_datapuu <- data.table::fread("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/data/arp_14586_1_34.txt") # load your inital input motti file in txt
# coord_datapuu <- fread("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/data/har_14081_1_41.txt")

site_coord_txt <- base::as.numeric(coord_datapuu[V1 %in% c(1, 2), METSIKKO])
site_coord_3067 <- base::data.frame(x = site_coord_txt[2]*1000, y = site_coord_txt[1]*1000)

# transformed coordinates
siteCoords_4326 <- sf::st_coordinates(st_transform(st_as_sf(site_coord_3067, coords = c("x", "y"), crs = 3067), crs = 4326))

coordFin_x <- base::unique(base::as.numeric(coordFin[, x]))
coordFin_y <- base::unique(base::as.numeric(coordFin[, y]))

siteCoords <- siteCoords_4326
siteCoords[1] <- coordFin_x[base::which.min(base::abs(coordFin_x - siteCoords_4326[1]))]
siteCoords[2] <- coordFin_y[base::which.min(base::abs(coordFin_y - siteCoords_4326[2]))]

# sample siteInfo_siteX -------------------------------------------------------------
# TestSiteInfo <- read.csv("data/TestSiteInfo.csv",sep=" ")[c(1:7,10:12)]
TestSiteInfo <- utils::read.csv("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/data/TestSiteInfo.csv",sep=" ")[c(1:7,10:12)]
siteInfo_siteX <- stats::setNames(base::as.numeric(TestSiteInfo), base::colnames(TestSiteInfo))

# sample initVar_siteX ------------------------------------------------------------------
# treedata <- read.csv("data/TestTreeInfo.csv", sep=" ")
treedata <- utils::read.csv("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/data/TestTreeInfo.csv", sep=" ")
treedata_t <- base::t(treedata[, -1])  
base::colnames(treedata_t) <- treedata$variable 
base::rownames(treedata_t) <- base::paste("layer", 1:nrow(treedata_t), sep=" ")
initVar_siteX <- base::t(base::as.matrix(treedata_t))
base::dimnames(initVar_siteX) <- base::list(variable = treedata$variable, layer = paste("layer", 1:nrow(treedata_t), sep=" "))

# prebascoefficients function ------------------------------------------------------
prebascoefficients <- function(siteInfo_siteX = siteInfo_siteX,
                               initVar_siteX = initVar_siteX,
                               siteCoords = siteCoords,
                               startYear_currClim = 1980,
                               currClim_dataBase_Mapping = 1,
                               startYear_climateChange = 2022,
                               climateChange_dataBase_Mapping = 1,
                               startYear_of_simulation = 2025,
                               nYears_sim = 5){
  
  if(startYear_climateChange > startYear_of_simulation){
    print("Error: startYear_of_simulation MUST be equal to or greater than startYear_climateChange")
    return(NULL)
  }
  
  # Select the current climate database based on the input
  selected_currClim_dataBase <- if(currClim_dataBase_Mapping == 1) {
    currClim_dataBase_1 # currently, we have only currClim_dataBase_1.
  } else if (currClim_dataBase_Mapping == 2) {
    currClim_dataBase_2
  } else if (currClim_dataBase_Mapping == 3) {
    currClim_dataBase_3
  }
  
  # To print the selected current climate database based on the input
  selected_currClim_dataBase_message <- if(currClim_dataBase_Mapping == 1) {
    "currClim_dataBase_1" # currently, we have only currClim_dataBase_1.
  } else if (currClim_dataBase_Mapping == 2) {
    "currClim_dataBase_2"
  } else if (currClim_dataBase_Mapping == 3) {
    "currClim_dataBase_3"
  }
  
  # Check if the provided currClim_dataBase is valid
  if(!currClim_dataBase_Mapping %in% 1:3) {
    stop("Invalid currClim_dataBase: Please provide a number between 1 and 3.")
  }
  
  # Print the selected database for verification
  print(paste("Selected current climate database:", selected_currClim_dataBase_message))
  
  
  
  # Select the future change climate database based on the input
  selected_climateChange_dataBase <- if(climateChange_dataBase_Mapping == 1) {
    climateChange_dataBase_rcp85
  } else if (climateChange_dataBase_Mapping == 2) {
    climateChange_dataBase_rcp45
  } else if (climateChange_dataBase_Mapping == 3) {
    climateChange_dataBase_rcp26
  }
  
  # To print the future change climate database based on the input
  selected_climateChange_dataBase_message <- if(climateChange_dataBase_Mapping == 1) {
    "climateChange_dataBase_rcp85"
  } else if (climateChange_dataBase_Mapping == 2) {
    "climateChange_dataBase_rcp45"
  } else if (climateChange_dataBase_Mapping == 3) {
    "climateChange_dataBase_rcp26"
  }
  
  # Check if the provided currClim_dataBase is valid
  if (!climateChange_dataBase_Mapping %in% 1:3) {
    stop("Invalid climateChange_dataBase: Please provide a number between 1 and 3.")
  }
  
  # Print the selected database for verification
  print(paste("Selected future climate change database:", selected_climateChange_dataBase_message))
  
  # extract currClimData from selected_currClim_dataBase
  DataBaseFormat_currClim <- TRUE
  currClimData <- extractWeatherPrebas(coords = siteCoords,
                                       startYear = startYear_currClim,
                                       coordFin = coordFin,
                                       DataBaseFormat = DataBaseFormat_currClim,
                                       dat = selected_currClim_dataBase,
                                       sourceData = "currClim")$dataBase
  
  # extract climateChangeData from selected_climateChange_dataBase
  DataBaseFormat_climateChange <- FALSE
  climateChangeData <- extractWeatherPrebas(coords = siteCoords,
                                            startYear = startYear_climateChange,
                                            coordFin = coordFin,
                                            DataBaseFormat = DataBaseFormat_climateChange,
                                            dat = selected_climateChange_dataBase,
                                            sourceData="climChange")
  
  
  # extract typicalSample for current climate data
  typicalSample <- sampleTypicalYears(currClimData)
  
  PAR_sample　<- as.numeric(typicalSample$PAR)
  Precip_sample　<- as.numeric(typicalSample$Precip)
  TAir_sample　<- as.numeric(typicalSample$TAir)
  VPD_sample　<- as.numeric(typicalSample$VPD)
  CO2_sample　<- as.numeric(typicalSample$CO2)
  
  
  # extract climate from climate change database
  # startYear_of_simulation MUST be equal to or greater than startYear_climateChange. Thus, startYearSim is always a positive number.
  startYearSim <- startYear_of_simulation - startYear_climateChange 
  yearsSim <- startYearSim+1:nYears_sim  
  day_climateChange <- rep((yearsSim-1)*365,each=365) + 1:365
  
  PAR_clChange <- climateChangeData$PAR[,day_climateChange]
  Precip_clChange <- climateChangeData$Precip[,day_climateChange]
  TAir_clChange <- climateChangeData$TAir[,day_climateChange]
  VPD_clChange <- climateChangeData$VPD[,day_climateChange]
  CO2_clChange <- climateChangeData$CO2[,day_climateChange]
  
  # current climate data for dGrowthPrebas function
  PAR_siteX <- PAR_sample
  Precip_siteX <- Precip_sample
  TAir_siteX <- TAir_sample
  VPD_siteX <- VPD_sample
  CO2_siteX <- CO2_sample
  
  # future change climate data for dGrowthPrebas function
  newPAR_siteX <- PAR_clChange
  newPrecip_siteX <- Precip_clChange
  newTAir_siteX <- TAir_clChange
  newVPD_siteX <- VPD_clChange
  newCO2_siteX <- CO2_clChange
  
  
  dGrowthExample_siteX <- dGrowthPrebas(nYears_sim,siteInfo_siteX,initVar_siteX,
                                        currPAR=PAR_siteX,newPAR=newPAR_siteX,
                                        currTAir=TAir_siteX,newTAir=newTAir_siteX,
                                        currPrecip=Precip_siteX,newPrecip=newPrecip_siteX,
                                        currVPD=VPD_siteX,newVPD=newVPD_siteX,
                                        currCO2=CO2_siteX,newCO2=newCO2_siteX)
  
  return(dGrowthExample_siteX)
}

# prebascoefficients output -----------------------------------------------------------
prebascoefficients_output <- prebascoefficients(siteInfo_siteX = siteInfo_siteX,
                                                initVar_siteX = initVar_siteX,
                                                siteCoords = siteCoords,
                                                startYear_currClim = 1980,
                                                currClim_dataBase_Mapping = 1,
                                                startYear_climateChange = 2022,
                                                climateChange_dataBase_Mapping = 1,
                                                startYear_of_simulation = 2030,
                                                nYears_sim = 5
)

prebascoefficients_output$dD[1:5,1:10]
prebascoefficients_output$dH[1:5,1:10]
prebascoefficients_output$dV[1:5,1:10]

# prebascoefficients running example ------------------------------------------------------
prebascoefficients.rcp85 <- prebascoefficients(siteInfo_siteX,
                                               initVar_siteX,
                                               siteCoords,
                                               startYear_currClim = 1980,
                                               currClim_dataBase_Mapping = 1,
                                               startYear_climateChange = 2022,
                                               climateChange_dataBase_Mapping = 1,
                                               startYear_of_simulation = 2030
)

prebascoefficients.rcp45 <- prebascoefficients(siteInfo_siteX,
                                               initVar_siteX,
                                               siteCoords,
                                               startYear_currClim = 1980,
                                               currClim_dataBase_Mapping = 1,
                                               startYear_climateChange = 2022,
                                               climateChange_dataBase_Mapping = 2,
                                               startYear_of_simulation = 2030
)


prebascoefficients.rcp26 <- prebascoefficients(siteInfo_siteX,
                                               initVar_siteX,
                                               siteCoords,
                                               startYear_currClim = 1980,
                                               currClim_dataBase_Mapping = 1,
                                               startYear_climateChange = 2022,
                                               climateChange_dataBase_Mapping = 3,
                                               startYear_of_simulation = 2030
)

prebascoefficients.rcp85$dD[1:5,1:10]
prebascoefficients.rcp45$dD[1:5,1:10]
prebascoefficients.rcp26$dD[1:5,1:10]

prebascoefficients.rcp85$dH[1:5,1:10]
prebascoefficients.rcp45$dH[1:5,1:10]
prebascoefficients.rcp26$dH[1:5,1:10]

prebascoefficients.rcp85$dV[1:5,1:10]
prebascoefficients.rcp45$dV[1:5,1:10]
prebascoefficients.rcp26$dV[1:5,1:10]

prebascoefficients(siteInfo_siteX = siteInfo_siteX,
                   initVar_siteX = initVar_siteX,
                   siteCoords = siteCoords,
                   startYear_currClim = 1980,
                   currClim_dataBase_Mapping = 1,
                   startYear_climateChange = 2022,
                   climateChange_dataBase_Mapping = 3,
                   startYear_of_simulation = 2030
)

prebascoefficients(siteInfo_siteX = siteInfo_siteX,
                   initVar_siteX = initVar_siteX,
                   siteCoords = siteCoords)


prebascoefficients(siteInfo_siteX,
                   initVar_siteX,
                   siteCoords)

prebascoefficients(siteInfo_siteX = siteInfo_siteX,
                   initVar_siteX = initVar_siteX,
                   siteCoords = siteCoords,
                   startYear_currClim = 1980,
                   currClim_dataBase_Mapping = 1,
                   startYear_climateChange = 2022,
                   climateChange_dataBase_Mapping = 3,
                   startYear_of_simulation = 2022,
                   nYears_sim = 5
)


prebascoefficients(siteInfo_siteX = siteInfo_siteX,
                   initVar_siteX = initVar_siteX,
                   siteCoords = siteCoords,
                   startYear_currClim = 1980,
                   currClim_dataBase_Mapping = 1,
                   startYear_climateChange = 2022,
                   climateChange_dataBase_Mapping = 3,
                   startYear_of_simulation = 2020,
                   nYears_sim = 5
)

