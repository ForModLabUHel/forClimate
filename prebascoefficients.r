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

base::setwd("C:/Daesung_R/ForClimate/prebas") # Set your working directory
base::getwd()

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
currClim_dataBase <- dat

# load future climate rcp85 Rdata -----------------------------------------------
base::load("C:/Daesung_R/ForClimate/Motti_C/climate rcp database/CanESM2.rcp85.rdata") # load the future climate rcp85 database (3.66 GB) from your local drive
climateChange_dataBase_rcp85 <- dat

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
