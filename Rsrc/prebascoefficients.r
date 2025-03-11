# install.packages("devtools")
# library(devtools)
# devtools::install_github("ForModLabUHel/Rprebasso")  # install the package if it's not ready in your R

# install.packages("data.table")  # install the package if it's not ready in your R
# install.packages("prodlim")     # install the package if it's not ready in your R
# install.packages("sf")          # install the package if it's not ready in your R

# base::setwd("C:/GitHub/forClimate") # Set your working directory

#cat("sourcing prebascoefficients starts\n", file = "coeff_log.txt", append=TRUE)

print_matrix<-function(m){
  rows=NROW(m)
  cols=NCOL(m)
  cat("Rows",rows,"Cols",cols,"\n")
  for (i in 1:rows){
    for (j in 1:cols){  
      cat(m[i,j]," ")
    }
    cat("\n")
  }
  cat("\n")
}

###siteinfo<-function(fname){
###    siteInfo <- as.numeric(read.csv("data/TestSiteInfo.csv",sep=" ")[c(1:7,10:12)])
###    #print(siteInfo)
###    return (siteInfo)
###}

###initvar<-function(fname){
###    initVar <- as.matrix(read.csv("data/TestTreeInfo.csv",sep=" ")[,2:27])
###    return (initVar)
###}

library <- function (...) {
  packages <- as.character(match.call(expand.dots = FALSE)[[2]])
  suppressWarnings(suppressMessages(lapply(packages, base::library, character.only = TRUE)))
  return(invisible())
}

library(Rprebasso)
library(data.table)
library(prodlim)
library(sf)

# load dGrowthPrebas function ---------------------------------------------
#writeLines(c("load dGrowthPrebas"), "coeff_log.txt")
#cat("source Rsrc/dGrowthPrebas\n", file = "coeff_log.txt", append=TRUE)
#source("Rsrc/dGrowthPrebas.r")

# load coordinate ID table --------------------------------------------------------
#if ( exists("coordFin) ) writeLines(c("coordFin already loaded"), "coeff_log.txt") else
#	coordFin <- data.table::fread("data/coordinates.dat")

coordFin <- data.table::fread("data/coordinates.dat")
# load current climate Rdata -----------------------------------------------
# base::load("C:/GitHub/rcp_database/CurrClim.rdata") # load the current climate database (0.98 GB) from your local drive
base::load("data/CurrClim.rdata")
currClim_dataBase <- dat

# load future climate rcp45 Rdata -----------------------------------------------
# base::load("C:/GitHub/rcp_database/CanESM2.rcp45.rdata") # load the future climate rcp45 database (3.66 GB) from your local drive
base::load("data/CanESM2.rcp45.rdata")
climateChange_dataBase <- dat

# sample site coordinate ---------------------------------------------------------
#coord_datapuu <- data.table::fread("data/arp_14586_1_34.txt") # load your inital input motti file in txt

#site_coord_txt <- base::as.numeric(coord_datapuu[V1 %in% c(1, 2), METSIKKO])
#site_coord_3067 <- base::data.frame(x = 238.70000*1000, y = 6657.60010*1000)
#site_coord_3067 <- base::data.frame(x = site_coord_txt[1]*1000, y = site_coord_txt[2]*1000)

# transformed coordinates
#siteCoords_4326 <- sf::st_coordinates(st_transform(st_as_sf(site_coord_3067, coords = c("x", "y"), crs = 3067), crs = 4326))

#coordFin_x <- base::unique(base::as.numeric(coordFin[, x]))
#coordFin_y <- base::unique(base::as.numeric(coordFin[, y]))

#siteCoords <- siteCoords_4326
#siteCoords[1] <- coordFin_x[base::which.min(base::abs(coordFin_x - siteCoords_4326[1]))]
#siteCoords[2] <- coordFin_y[base::which.min(base::abs(coordFin_y - siteCoords_4326[2]))]

# sample siteInfo_siteX -------------------------------------------------------------
###TestSiteInfo <- read.csv("data/TestSiteInfo.csv",sep=" ")[c(1:7,10:12)]

###siteInfo_siteX <- stats::setNames(base::as.numeric(TestSiteInfo), base::colnames(TestSiteInfo))

# sample initVar_siteX ------------------------------------------------------------------
###treedata <- read.csv("data/TestTreeInfo.csv", sep=" ")

###treedata_t <- base::t(treedata[, -1])  
###base::colnames(treedata_t) <- treedata$variable 
###base::rownames(treedata_t) <- base::paste("layer", 1:nrow(treedata_t), sep=" ")
###initVar_siteX <- base::t(base::as.matrix(treedata_t))
###base::dimnames(initVar_siteX) <- base::list(variable = treedata$variable, layer = paste("layer", 1:nrow(treedata_t), sep=" "))

# sample startYear_of_simulation input ------------------------------------
###startYear_of_simulation <- 2025 # This must be updated each time during the Motti simulation.

# prebascoefficients function ------------------------------------------------------
#writeLines(c("define function prebascoefficients"), "coeff_log.txt")
#cat("define function prebascoefficients\n", file = "coeff_log.txt", append=TRUE)
prebascoefficients <- function(siteInfo_siteX,
                               initVar_siteX,
                               siteCoords,
                               startYear_of_simulation,
                               verbose){

  ###Site coordinates must be dim(1,2) matrix
  if (is.vector(siteCoords)){
    ### The vector comes from 'callprebas'
    siteCoords<-t(as.matrix(siteCoords))
  }

  # transform EPSG:3067 -coordinates into EPSG: 4326
  if (siteCoords[1] > 100 ){
      # library sf is supposed to be loaded at this point --> is it necessary to check it at all?
      if(! "dplyr" %in% tolower((.packages()))){
        library("sf")
        (.packages())
      }
      #library(sf)
    site_coord_3067 <- base::data.frame(x = siteCoords[1]*1000, y = siteCoords[2]*1000)
    siteCoords_4326 <- sf::st_coordinates(st_transform(st_as_sf(site_coord_3067, coords = c("x", "y"), crs = 3067), crs = 4326))
    siteCoords <- siteCoords_4326
  }
  
  if (verbose == 1){
    cat("-----------------------------------\n",  file= "coeff_log.txt", append=TRUE)
    cat(paste("startYear_of_simulation",startYear_of_simulation,"\n"),  file= "coeff_log.txt", append=TRUE)
    cat(paste("SiteInfo",siteInfo_siteX,"\n"),  file= "coeff_log.txt", append=TRUE)
    #cat("TreeInfo\n",  file= "coeff_log.txt", append=TRUE)
    #cat(paste("TreeInfo","Is matrix",is.matrix(initVar_siteX),"Dimensions",dim(initVar_siteX),"Trees",initVar_siteX,"\n"),  file= "coeff_log.txt", append=TRUE)
    #print_matrix(initVar_siteX)
    cat(paste("Site coordinates","Is matrix",is.matrix(siteCoords),"Dimensions",dim(siteCoords),"Coordinates",siteCoords,"\n"),  file= "coeff_log.txt", append=TRUE)
    cat("-----------------------------------\n",  file= "coeff_log.txt", append=TRUE)
    #cat(paste(coordFin),"\n",  file= "coeff_log.txt", append=TRUE)
    #cat("-----------------------------------\n",  file= "coeff_log.txt", append=TRUE)
    if(startYear_of_simulation < 2022){
      print("Error: startYear_of_simulation MUST be equal to or greater than 2022, which is currently the start year of the equipped future climate change database")
      return(NULL)
    }
  }
  
  
  # extract currClimData from currClim_dataBase
  startYear_currClim <- 1980 # the start year of currClim_dataBase is 1980. If the database is changed, this argument must be updated accordingly.
  DataBaseFormat_currClim <- TRUE
  currClimData <- extractWeatherPrebas(coords = siteCoords,
                                       startYear = startYear_currClim,
                                       coordFin = coordFin,
                                       DataBaseFormat = DataBaseFormat_currClim,
                                       dat = currClim_dataBase,
                                       sourceData = "currClim")$dataBase
  
  # extract climateChangeData from climateChange_dataBase
  startYear_climateChange <- 2022 # the start year of climateChange_dataBase_rcp45 is 2022. If the database is changed, this argument must be updated accordingly.
  DataBaseFormat_climateChange <- FALSE
  climateChangeData <- extractWeatherPrebas(coords = siteCoords,
                                            startYear = startYear_climateChange,
                                            coordFin = coordFin,
                                            DataBaseFormat = DataBaseFormat_climateChange,
                                            dat = climateChange_dataBase,
                                            sourceData="climChange")
  
  
  # extract typicalSample for current climate data
  typicalSample <- sampleTypicalYears(currClimData)
  PAR_sample<-as.numeric(typicalSample$PAR)
  Precip_sample<-as.numeric(typicalSample$Precip)
  TAir_sample<-as.numeric(typicalSample$TAir)
  VPD_sample<-as.numeric(typicalSample$VPD)
  CO2_sample<-as.numeric(typicalSample$CO2)
  
  
  # extract climate from climate change database
  # startYear_of_simulation MUST be equal to or greater than the start year of the future climate change database (it is currently 2022)
  # StartYearSim must be always a positive number.
  
  nYears_sim <- 5 # nYears_sim can be always 5 for dGrowthPrebas(). MottiWB can select the required number of years between 1 and 5 to simulate in Motti.
  startYearSim <- startYear_of_simulation - startYear_climateChange 
    if (verbose==1){
    cat("startYearSim",startYearSim,"\n")
    }
  yearsSim <- startYearSim+1:nYears_sim  
  if (verbose==1){
    cat("yearsSim",yearsSim,"\n")
  }
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
  
  if (verbose==1){
    cat("dGrowthExample_siteX <- dGrowthPrebas\n",  file= "coeff_log.txt", append=TRUE)
    cat(paste("Site coordinates","Is matrix",is.matrix(siteCoords),"Dimensions",dim(siteCoords),"Coordinates",siteCoords,"\n"),  file= "coeff_log.txt", append=TRUE)
    cat("-----------------------------------\n",  file= "coeff_log.txt", append=TRUE)

  }  
  dGrowthExample_siteX <- dGrowthPrebas(nYears_sim,siteInfo_siteX,initVar_siteX,
                                        currPAR=PAR_siteX,newPAR=newPAR_siteX,
                                        currTAir=TAir_siteX,newTAir=newTAir_siteX,
                                        currPrecip=Precip_siteX,newPrecip=newPrecip_siteX,
                                        currVPD=VPD_siteX,newVPD=newVPD_siteX,
                                        currCO2=CO2_siteX,newCO2=newCO2_siteX)
  
  if (verbose==1){
    print("In R prebascoefficients return values")
    print("-------------------------------------")
    print("dH")
    print("--")
    print(dGrowthExample_siteX[1])
    print("dD")
    print("--")
    print(dGrowthExample_siteX[2])
    print("dV")
    print("--")
    print(dGrowthExample_siteX[3])
  #sink()
  }
  return(dGrowthExample_siteX)
}
#"writeLines(c("prebascoefficients ends"), "coeff_log.txt")
#print("Before call to prebascoefficients")
#print("---------------------------------")
#print("SiteInfo")
#print(siteInfo_siteX)
#print("TreeInfo")
#print(initVar_siteX)
#print("Local Coordinates")
#print(siteCoords)
#print("Coord FIN")
#print(coordFin)

#dGrowthCoeff <- prebascoefficients(siteInfo_siteX,initVar_siteX,siteCoords,2026,1)
#print("Prebas coefficients after call to prebascoefficients")
#print(dGrowthCoeff)