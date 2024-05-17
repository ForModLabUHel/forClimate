###function for delta growth calculation
#' dGrowthPrebas
#'
#' @param nYears number of year for the simulations
#' @param siteInfo site information table. (rows=nSites x column=12 Matrix) Matrix of site info: SiteID, climID, siteType, SWinit (initial soil water), CWinit (initial crown water), SOGinit (initial snow on ground), Sinit (initial temperature acclimation state), nLayers, nSpecies, soildepth, effective field capacity, permanent wilthing point. Default = c(1,1,3, 160, 0, 0, 20, 413.,0.45, 0.118), i.e. siteType = 3. Give for homogeneous sites as siteInfo <- matrix(c(NA,NA,3,160,0,0,20,nLayers,3,413,0.45,0.118),nSites,12,byrow = T) # Set site index values to siteInfo columns 1-2 siteInfos[,2] <- siteInfos[,1] <- 1:nSites
#' @param initVar 	(nSite x 7 x nLayer array) Array with initial stand values for all the tree strata in each site. Third dimension corresponds to the layers in the stand. Initial information needed are: SpeciesID (a number corresponding to the species parameter values of pPRELES columns), Age (years), average height of the layer (H, m), average diameter at breast height of the layer (D, cm), basal area of the layer (BA, m2 ha-1), average height of the crown base of the layer (Hc, m). 8th column is updated automatically to Ac. If initVar is not provided the model is initialized from plantation using default planting parameters (see initClearcut) and assuming that Pine, Spruce and Birch are equally present at plantation.
#' @param currPar 	PAR for current weather (nSites x nYears*365 matrix) A numeric matrix of daily sums of photosynthetically active radiation, mmol/m2, for each site.
#' @param newPAR    PAR for new weather (nSites x nYears*365 matrix) A numeric matrix of daily sums of photosynthetically active radiation, mmol/m2, for each site.
#' @param currTAir air temperature for current weather (nSites x nYears*365 matrix) A numeric matrix of daily mean temperature, degrees C, for each site.
#' @param newTAir air temperature for new weather (nSites x nYears*365 matrix) A numeric matrix of daily mean temperature, degrees C, for each site.
#' @param currPrecip Precipitation for current weather (nSites x nYears*365 matrix) A numeric matrix of daily rainfall, mm, for each site.
#' @param newPrecip Precipitation for new weather (nSites x nYears*365 matrix) A numeric matrix of daily rainfall, mm, for each site.
#' @param currVPD VPD for current weather (nSites x nYears*365 matrix) A numeric matrix of daily mean vapour pressure deficits, kPa, for each site.
#' @param newVPD VPD for new weather (nSites x nYears*365 matrix) A numeric matrix of daily mean vapour pressure deficits, kPa, for each site.
#' @param currCO2 CO2 for current weather (nSites x nYears*365 matrix) A numeric matrix of air CO2, ppm, for each site.
#' @param newCO2 CO2for new weather (nSites x nYears*365 matrix) A numeric matrix of air CO2, ppm, for each site.
#'
#' @return a list of 3 3-dimensional array (nSites x nYears x nLayers) of deltas for gross growth (dGrowth), Height (dH) and dbh (dD)
#' 
#' @export
#'
#' @examples
#' # define the number of years for the simulation and run the function for 7 sites using the example weather data
#' nYears=20
#' dGrowthExample <- dGrowthPrebas(nYears,siteInfo,initVar,currPar=PARtran,newPAR=PARx,currTAir=TAirtran,newTAir=TAirx,currPrecip=Preciptran,newPrecip=Precipx,currVPD=VPDtran,newVPD=VPDx,currCO2=CO2tran,newCO2=CO2x)

dGrowthPrebas <- function(nYears,siteInfo,initVar,
                    currPAR,newPAR,
                    currTAir,newTAir,
                    currPrecip,newPrecip,
                    currVPD,newVPD,
                    currCO2,newCO2,
                    ClCut = 0,
                    defaultThin = 0
                    ){
  if(length(siteInfo)<=12){
    nSites <- 1
  }else{
    nSites <- nrow(siteInfo)  
  }
  
  if(nSites>1){
    initCurr <- InitMultiSite(nYearsMS = rep(nYears,nSites),
                              PAR = currPAR,
                              VPD = currVPD,
                              CO2 = currCO2,
                              TAir = currTAir,
                              Precip = currPrecip,
                              siteInfo = siteInfo,
                              multiInitVar = initVar,
                              ClCut = ClCut,
                              defaultThin = defaultThin)
    modOutCurr <- multiPrebas(initCurr)
    
    initNew <- InitMultiSite(nYearsMS = rep(nYears,nSites),
                             PAR = newPAR,
                             VPD = newVPD,
                             CO2 = newCO2,
                             TAir = newTAir,
                             Precip = newPrecip,
                             siteInfo = siteInfo,
                             multiInitVar = initVar,
                             ClCut = ClCut,
                             defaultThin = defaultThin)
    modOutNew <- multiPrebas(initNew)
    if(dim(modOutNew$multiInitVar)[3]>1){
      dimX <- dim(modOutNew$multiOut[,,11,,1]);dimX[2] <- nYears +1
      xx <- array(NA,dim = dimX)
      if (length(dimX)>2){
        xx[,2:(nYears+1),] <- modOutNew$multiOut[,,11,,1]
        xx[,1,] <- modOutNew$multiInitVar[,3,]
        dGrowthH <- xx[,2:(nYears+1),] - xx[,2:(nYears+1),]
        
      }
    }
    growthCurr <- dGrowthVars(modOutCurr)
    growthNew <- dGrowthVars(modOutNew)

    dH <-growthNew$dGrowthH/growthCurr$dGrowthH
    dD <-growthNew$dGrowthD/growthCurr$dGrowthD
    # dN <-growthNew$dGrowthN/growthCurr$dGrowthN
    # dB <-growthNew$dGrowthB/growthCurr$dGrowthB
    dV <-modOutNew$multiOut[,,43,,1]/modOutCurr$multiOut[,,43,,1]
  }else{
    modOutCurr <- prebas(nYears = nYears,
                              PAR = currPAR,
                              VPD = currVPD,
                              CO2 = currCO2,
                              TAir = currTAir,
                              Precip = currPrecip,
                              siteInfo = siteInfo,
                              initVar = initVar,
                              ClCut = ClCut,
                              defaultThin = defaultThin)
    
    modOutNew <- prebas(nYears = nYears,
                             PAR = newPAR,
                             VPD = newVPD,
                             CO2 = newCO2,
                             TAir = newTAir,
                             Precip = newPrecip,
                             siteInfo = siteInfo,
                             initVar = initVar,
                             ClCut = ClCut,
                             defaultThin = defaultThin)
    
    growthCurr <- dGrowthVars(modOutCurr)
    growthNew <- dGrowthVars(modOutNew)
    
    dH <-growthNew$dGrowthH/growthCurr$dGrowthH
    dD <-growthNew$dGrowthD/growthCurr$dGrowthD
    # dN <-growthNew$dGrowthN/growthCurr$dGrowthN
    # dB <-growthNew$dGrowthB/growthCurr$dGrowthB
    dV <-modOutNew$output[,43,,1]/modOutCurr$output[,43,,1]
  }
# ###filter data
#   dH[which(is.na(dH) | dH<0)] <- 1
#   dD[which(is.na(dD) | dD<0)] <- 1
#   dV[which(is.na(dV) | dV<0)] <- 1
  
  return(list(dH=dH,dD=dD,dV=dV)) #,dB=dB,dN=dN
}

dGrowthVars <- function(modOut){
  if(class(modOut)=="multiPrebas"){
    nYears <- modOut$maxYears
    dimX <- dim(modOut$multiOut[,,11,,1]);dimX[2] <- nYears +1
    xx <- array(NA,dim = dimX)
    if(length(dimX)>2){
# H
      xx[,2:(nYears+1),] <- modOut$multiOut[,,11,,1]
      xx[,1,] <- modOut$multiInitVar[,3,]
      dGrowthH <- xx[,2:(nYears+1),] - xx[,1:nYears,]
# D      
      xx[,2:(nYears+1),] <- modOut$multiOut[,,12,,1]
      xx[,1,] <- modOut$multiInitVar[,4,]
      dGrowthD <- xx[,2:(nYears+1),] - xx[,1:nYears,]
# B
      xx[,2:(nYears+1),] <- modOut$multiOut[,,13,,1]
      xx[,1,] <- modOut$multiInitVar[,5,]
      dGrowthB <- xx[,2:(nYears+1),] - xx[,1:nYears,]
# N
      xx[,2:(nYears+1),] <- modOut$multiOut[,,17,,1]
      xx[,1,] <- modOut$multiInitVar[,5,]/(pi*(modOut$multiInitVar[,4,]/200)^2)
      dGrowthN <- xx[,2:(nYears+1),] - xx[,1:nYears,]
    }else{
        # H
      xx[,2:(nYears+1)] <- modOut$multiOut[,1:20,11,,1]
      xx[,1] <- modOut$multiInitVar[,3,]
      dGrowthH <- xx[,2:(nYears+1)] - xx[,1:nYears]
      # D      
      xx[,2:(nYears+1)] <- modOut$multiOut[,,12,,1]
      xx[,1] <- modOut$multiInitVar[,4,]
      dGrowthD <- xx[,2:(nYears+1)] - xx[,1:nYears]
      # B
      xx[,2:(nYears+1)] <- modOut$multiOut[,,13,,1]
      xx[,1] <- modOut$multiInitVar[,5,]
      dGrowthB <- xx[,2:(nYears+1)] - xx[,1:nYears]
      # N
      xx[,2:(nYears+1)] <- modOut$multiOut[,,17,,1]
      xx[,1] <- modOut$multiInitVar[,5,]/(pi*(modOut$multiInitVar[,4,]/200)^2)
      dGrowthN <- xx[,2:(nYears+1)] - xx[,1:nYears]
    }
  }else{####for single site runs
    nYears <- modOut$nYears
    if(modOut$nLayers>1){
      # H
      xx <- rbind(modOut$initVar[3,],modOut$output[,11,,1])
      dGrowthH <- xx[2:(nYears+1),] - xx[1:nYears,]
      # D      
      xx <- rbind(modOut$initVar[4,],modOut$output[,12,,1])
      dGrowthD <- xx[2:(nYears+1),] - xx[1:nYears,]
      # B
      xx <- rbind(modOut$initVar[5,],modOut$output[,13,,1])
      dGrowthB <- xx[2:(nYears+1),] - xx[1:nYears,]
      # N
      xx <- rbind(modOut$initVar[5,],modOut$output[,17,,1])
      xx[1,] <- modOut$initVar[5,]/(pi*(modOut$initVar[4,]/200)^2)
      dGrowthN <- xx[2:(nYears+1),] - xx[1:nYears,]
    }else{
      # H
      xx <- c(modOut$initVar[3],modOut$output[,11,1,1])
      dGrowthH <- xx[2:(nYears+1)] - xx[1:nYears]
      # D      
      xx <- c(modOut$initVar[4],modOut$output[,12,1,1])
      dGrowthD <- xx[2:(nYears+1)] - xx[1:nYears]
      # B
      xx <- c(modOut$initVar[5],modOut$output[,13,1,1])
      dGrowthB <- xx[2:(nYears+1)] - xx[1:nYears]
      # N
      xx <- c(modOut$initVar[5],modOut$output[,17,1,1])
      xx[1] <- modOut$initVar[5]/(pi*(modOut$initVar[4]/200)^2)
      dGrowthN <- xx[2:(nYears+1)] - xx[1:nYears]
    }
  }
  return(list(dGrowthH=dGrowthH,dGrowthD=dGrowthD,dGrowthB=dGrowthB,dGrowthN=dGrowthN))
}




averageWeather <- function(inputX,nYearsRun){
  require(data.table)
  nYearsX <- ncol(inputX)/365
  xx <- data.table(t(inputX))
  xx$doy <- rep(1:365,nYearsX)
  ciao <- data.table(reshape2::melt(xx,id.vars = "doy"))
  averageX <- ciao[,mean(value),by=c("doy","variable")]
  yy <- data.matrix(reshape(averageX, idvar = "variable", timevar = "doy", direction = "wide"))[,2:366]
  # yy <- as.numeric(yy)
  yy2 = yy[, rep(1:365, nYearsRun)]
  
  return(yy2)
}


extractIDs <- function(coords,dataBase){
  x <- coords[1] - dataBase$x
  y <- coords[2] - dataBase$y
  hip = sqrt(x^2 + y^2)
  IDx <- which.min(hip)
  return(IDx)
}
  
extractWeatherPrebas <- function(coords,startYear,outDataBase){
  IDs <- apply(exampleCoords,1,extractIDs,currClimIDs)
  climateX <- dat[id %in% unique(IDs)]
  newIDs <- 1:length(unique(IDs))
  newIDsSites <- newIDs[match(IDs,unique(IDs))]
  climateX$idNew <- newIDs[match(climateX$id,unique(IDs))]
  
  
  nYears <- max(climateX$rday)/365
  climateX[,year:=rep(1:nYears,each=365),by="id"]
  climateX[,doy:=1:365,by=c("id","year")]
  climateX$actualYear <- climateX$year + 1980 
  climateX <- climateX[actualYear >= startYear]
  if(outDataBase==TRUE){
    return(list(dataBase=climateX,climIDs = newIDsSites))
  }else{
    nIDs <- length(unique(climateX$idNew))
    nDays <- nrow(climateX[idNew==1])
    PAR <- VPD <- CO2 <- Precip <- TAir <- matrix(NA,nIDs,nDays)
    for(i in 1:nIDs){
      PAR[i,] = climateX[idNew==i]$PAR
      VPD[i,] = climateX[idNew==i]$VPD
      TAir[i,] = climateX[idNew==i]$TAir
      Precip[i,] = climateX[idNew==i]$Precip
      CO2[i,] = climateX[idNew==i]$CO2
    }
    return(list(PAR=PAR,VPD=VPD,TAir=TAir,Precip=Precip,CO2=CO2,climIDs = newIDsSites))
  }
}

sampleTypicalYears <- function(climateIn,nYears=5){
  Tseason <- climateIn[doy %in% 150:250,mean(TAir),by=c("year","id")]
  setnames(Tseason,"V1","Tair")
  Tseason[,quant40:= quantile(Tair,0.25),by="id"]
  Tseason[,quant60:= quantile(Tair,0.75),by="id"]
  Tseason[,typical_T:=ifelse(Tair > quant40 & Tair<quant60,1,0)]
  
  RainSeason <- climateIn[doy < 200,sum(Precip),by=c("year","id")]
  setnames(RainSeason,"V1","Rain")
  RainSeason[,quant40:= quantile(Rain,0.25),by="id"]
  RainSeason[,quant60:= quantile(Rain,0.75),by="id"]
  RainSeason[,typical_R:=ifelse(Rain > quant40 & Rain<quant60,1,0)]
  
  seasonX <- merge(Tseason,RainSeason,by=c("year","id"))
  seasonX[,typical_year:= ifelse(typical_R==1 & typical_T==1,1,0)]
  climateIn <- merge(seasonX[,.(typical_year,id,year)],climateIn,by = c("id","year"))
  
  nIDs <- length(unique(climateIn$idNew))
  PAR <- VPD <- CO2 <- Precip <- TAir <- matrix(NA,nIDs,nYears*365)
  for(i in 1:nIDs){
    sampleYears <- sample(unique(ciao[idNew==i&typical_year==1]$year),5)
    oo <- ciao[idNew==i & year %in% sampleYears]
    PAR[i,] = oo$PAR
    VPD[i,] = oo$VPD
    TAir[i,] = oo$TAir
    Precip[i,] = oo$Precip
    CO2[i,] = oo$CO2
  }
  return(list(PAR=PAR,VPD=VPD,TAir=TAir,Precip=Precip,CO2=CO2))
}
