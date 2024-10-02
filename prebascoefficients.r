library(Rprebasso)
library(data.table)
library(prodlim)
library(tidyverse)
library(sf)

# setwd("C:/Daesung_R/ForClimate/prebas") # Set your working directory
# getwd()

# rm(list = ls())
# rm(list = setdiff(ls(), c("currClim_dataBase", "climateChange_dataBase_rcp85")))


# load dGrowthPrebas function ---------------------------------------------
devtools::source_url("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/Rsrc/dGrowthPrebas.r")

# load coordinate ID table --------------------------------------------------------
coordFin <- fread("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/data/coordinates.dat")

# load current climate Rdata -----------------------------------------------
load("C:/Daesung_R/ForClimate/Motti_C/climate rcp database/CurrClim.rdata") # load the current climate database (0.98 GB)
currClim_dataBase <- dat

# load future climate rcp85 Rdata -----------------------------------------------
load("C:/Daesung_R/ForClimate/Motti_C/climate rcp database/CanESM2.rcp85.rdata") # load the future climate rcp85 database (3.66 GB)
climateChange_dataBase_rcp85 <- dat

# sample site coordinate ---------------------------------------------------------
coord_datapuu <- fread("C:/Daesung_R/ForClimate/prebas/data/arp_14586_1_34.txt") # load your inital input motti file in txt
# coord_datapuu <- fread("C:/Daesung_R/ForClimate/prebas/data/har_14081_1_41.txt")

site_coord_txt <- as.numeric(coord_datapuu[V1 %in% c(1, 2), METSIKKO])
site_coord_3067 <- data.frame(x = site_coord_txt[2]*1000, y = site_coord_txt[1]*1000)

# transformed coordinates
siteCoords_4326 <- st_coordinates(st_transform(st_as_sf(site_coord_3067, coords = c("x", "y"), crs = 3067), crs = 4326))

coordFin_x <- unique(as.numeric(coordFin[, x]))
coordFin_y <- unique(as.numeric(coordFin[, y]))

siteCoords <- siteCoords_4326
siteCoords[1] <- coordFin_x[which.min(abs(coordFin_x - siteCoords_4326[1]))]
siteCoords[2] <- coordFin_y[which.min(abs(coordFin_y - siteCoords_4326[2]))]

# sample siteInfo_siteX -------------------------------------------------------------
TestSiteInfo <- read.csv("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/data/TestSiteInfo.csv",sep=" ")[c(1:7,10:12)]
siteInfo_siteX <- setNames(as.numeric(TestSiteInfo), colnames(TestSiteInfo))

# sample initVar_siteX ------------------------------------------------------------------
treedata <- read.csv("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/data/TestTreeInfo.csv", sep=" ")
treedata_t <- t(treedata[, -1])  
colnames(treedata_t) <- treedata$variable 
rownames(treedata_t) <- paste("layer", 1:nrow(treedata_t), sep=" ")
initVar_siteX <- t(as.matrix(treedata_t))
dimnames(initVar_siteX) <- list(variable = treedata$variable, layer = paste("layer", 1:nrow(treedata_t), sep=" "))

# prebascoefficients function ------------------------------------------------------
prebascoefficients <- function(siteInfo_siteX,initVar_siteX,siteCoords){
  
  # Daesung: if needed, I think we can add some more factors in this function such as startYear, startYear2, startYearDataBase, and etc.
  
  startYear <- 1950
  DataBaseFormat <- TRUE
  currClimData <- extractWeatherPrebas(siteCoords,startYear,coordFin,
                                       DataBaseFormat,currClim_dataBase,sourceData="currClim")$dataBase
  
  startYear2 <- 1980
  DataBaseFormat <- FALSE
  climateChangeData_rcp85 <- extractWeatherPrebas(siteCoords,startYear2,coordFin,
                                                  DataBaseFormat,climateChange_dataBase_rcp85,sourceData="climChange")
  
  
  
  typicalSample <- sampleTypicalYears(currClimData)
  
  PAR_sample　<- as.numeric(typicalSample$PAR)
  Precip_sample　<- as.numeric(typicalSample$Precip)
  TAir_sample　<- as.numeric(typicalSample$TAir)
  VPD_sample　<- as.numeric(typicalSample$VPD)
  CO2_sample　<- as.numeric(typicalSample$CO2)
  
  
  # set years of simulations, define climatechange starting year of database and simulations
  nYears_sim <- 5 # number of year of simulations
  startYearDataBase <- 2025 # starting year in the data base
  # startYear <- 2041 # start year in the simulations
  
  # extract climate from climate change database
  startYearSim <- startYear - startYearDataBase
  yearsSim <- startYearSim+1:nYears_sim  
  day_climateChange <- rep((yearsSim-1)*365,each=365) + 1:365
  
  PAR_clChange <- climateChangeData_rcp85$PAR[,day_climateChange]
  Precip_clChange <- climateChangeData_rcp85$Precip[,day_climateChange]
  TAir_clChange <- climateChangeData_rcp85$TAir[,day_climateChange]
  VPD_clChange <- climateChangeData_rcp85$VPD[,day_climateChange]
  CO2_clChange <- climateChangeData_rcp85$CO2[,day_climateChange]
  
  
  PAR_siteX <- PAR_sample
  newPAR_siteX <- PAR_clChange
  Precip_siteX <- Precip_sample
  newPrecip_siteX <- Precip_clChange
  TAir_siteX <- TAir_sample
  newTAir_siteX <- TAir_clChange
  VPD_siteX <- VPD_sample
  newVPD_siteX <- VPD_clChange
  CO2_siteX <- CO2_sample
  newCO2_siteX <- CO2_clChange
  
  
  dGrowthExample_siteX <- dGrowthPrebas(5,siteInfo_siteX,initVar_siteX,
                                        currPAR=PAR_siteX,newPAR=newPAR_siteX,
                                        currTAir=TAir_siteX,newTAir=newTAir_siteX,
                                        currPrecip=Precip_siteX,newPrecip=newPrecip_siteX,
                                        currVPD=VPD_siteX,newVPD=newVPD_siteX,
                                        currCO2=CO2_siteX,newCO2=newCO2_siteX)
  return(dGrowthExample_siteX)
}

# example running ---------------------------------------------------------
prebascoefficients(siteInfo_siteX,initVar_siteX,siteCoords)
