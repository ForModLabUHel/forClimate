library(data.table)
library("readxl")
library(Rprebasso)

# setwd("C:/Users/minunno/Documents/research/ForClimate/data/")

dataX <- data.table(read_excel("data/Daesung_stand for PREBAS.xlsx", sheet = "KPL_stand PREBAS"))
thinX <- data.table(read_excel("data/Daesung_thin for PREBAS.xlsx", sheet = "KPL_thin"))
# siteX <- data.table(read_excel("Daten_JR_Projekt_ESA_22022023.xls", sheet = "Jahre und Koordinaten"))

dataX$Dmean <- sqrt(dataX$G/dataX$N /pi *10000) *2

nSites <- nrow(unique(dataX[,.(stand,plot)]))
dataX[,startYear := min(year),by=.(stand,plot)]
dataX[,yearSim := year-startYear]
# dataX[year==startYear & stand==14526 &plot==1]
species <- unique(dataX$SP)
nLayers <- 1
# specCodes <- c("Fi","Ki","Nh","Lh")
spID <- 1:2

siteTypeTab <- data.table(codes=c("VT","OMT","MT","CT"),siteType=c(4,2,3,5))

setnames(dataX,"SP", "speciesID")
setkey(dataX,"stand","plot")
setkey(thinX,"stand","plot")
dataX[, siteID := .GRP, by = .(stand,plot)]

#assign index to extract remaining and harvested trees from PREBAS
dataX[,statusInd:= compnt-1]
dataX[statusInd==0,statusInd:= 2]

# thinX[, siteID := .GRP, by = .(stand,plot)]
setkey(dataX,siteID,stand,plot)
setkey(thinX,stand,plot)
initData <- dataX[year==startYear & compnt==2]

toMerge <- unique(dataX[,.(siteID,stand,plot,startYear)])
toMerge <- toMerge[!is.na(startYear)]
thinX <- merge(thinX,toMerge,all.x=T)
thinX <- thinX[year!=startYear]
thinX[,yearSim := year-startYear]
thinX[,layer:=1]
thinX[,H:=1.05]
thinX[,D:=1.1]
thinX[,B:=(100-thin.Gr)/100]
thinX[,Hc:=0.9]
thinX[,frac:=1]
thinX[,N:=-999]
thinX[,sapwood:=-999]
thinX <- thinX[B!=1]

thinX2 <- thinX
for(i in 1:nrow(thinX2)){
  Hratio <- dataX[siteID==thinX2[i]$siteID & yearSim==thinX2[i]$yearSim & compnt==2]$HW/
    dataX[siteID==thinX2[i]$siteID & yearSim==thinX2[i]$yearSim & compnt==1]$HW
  thinX2[i]$H <- Hratio
  Dratio <- dataX[siteID==thinX2[i]$siteID & yearSim==thinX2[i]$yearSim & compnt==2]$DW/
    dataX[siteID==thinX2[i]$siteID & yearSim==thinX2[i]$yearSim & compnt==1]$DW
  thinX2[i]$D <- Dratio
}


thinnings <- as.matrix(thinX[,.(yearSim,siteID,layer,
                                H,D,B,Hc,frac,N,sapwood)])

thinnings2 <- as.matrix(thinX2[,.(yearSim,siteID,layer,
                                H,D,B,Hc,frac,N,sapwood)])

nThinning <- thinX[,.N,by=siteID]
multiNThin <- rep(0,nSites)
multiNThin[nThinning$siteID] <- nThinning$N
thinnings <- thinnings2 <- array(0, dim=c(nSites,max(multiNThin),10))
for(i in 1:length(nThinning$siteID)){
  siteSel <- nThinning$siteID[i]
  thinnings[siteSel,1:nThinning$N[i],] <- as.matrix(thinX[siteID==siteSel,.(yearSim,siteID,layer,
                                                                            H,D,B,Hc,frac,N,sapwood)])
  thinnings2[siteSel,1:nThinning$N[i],] <- as.matrix(thinX2[siteID==siteSel,.(yearSim,siteID,layer,
                                                                            H,D,B,Hc,frac,N,sapwood)])
}

initVars <- array(NA, dim=c(nSites, 7,nLayers),dimnames = 
                    list(NULL, c("speciesID","age","h","dbh","ba","hc","Ac"),NULL))

for(i in 1:nLayers){
  initVars[,1,i] <- initData$speciesID
  initVars[,2,i] <- initData$age
  initVars[,3,i] <- initData$HW
  initVars[,4,i] <- initData$Dmean
  initVars[,5,i] <- initData$G
  ###Hc negative Lc = 15% of H
  # initVars[,6,i] <- pmin(dataX[speciesID==spID[i]]$AVG_KRONHO5/10,dataX[speciesID==spID[i]]$AVG_HOEHE5/10*0.85)
}
siteX <- data.frame(read_excel("data/Daesung_meta for PREBAS.xlsx", sheet = "KPL_meta"))

if(TRUE){
  ###extract weather (start)
    library (rgdal)
    library(sf)
    
    # CRS Lambert Azimuthal Equal-Area projection
    
    load("C:/Users/minunno/Documents/research/weather/CurrClim.rdata")
    coordAll <-fread("C:/Users/minunno/Documents/research/weather/grid_coords")
    
    nStands <- nrow(siteX)
    climID <- rep(0,nStands)
    
    for(i in 1:nStands){
      euclDist <- sqrt((siteX$east[i] - coordAll$longitude)^2 +
                         (siteX$north[i] - coordAll$latitude)^2)
      climID[i] <- which.min(euclDist)
    } 
    plot(coordAll$longitude,coordAll$latitude)
    points(siteX$east,siteX$north,pch=20,col=2)
    points(coordAll$longitude[climID],coordAll$latitude[climID],
           pch=20,col=3)
    
    climIDx <- unique(climID)
    weatherX <- dat[id %in% climIDx]
    setkey(weatherX,id,rday)
    weatherX$doy <- rep(1:365,nrow(weatherX)/365)
    weatherX[,year:=rep(1971:2013,each=365),by=.(id)]
    climIDx <- unique(weatherX$id)
    nClimIDs <- length(climID)
    yearsRun <- dataX[,.(start=min(year),end=max(year)),by=.(stand)] 
    
    totNyears <- max(yearsRun$end) - min(yearsRun$start) + 1
    maxYear <- max(yearsRun$start) + totNyears
    minYear <- min(yearsRun$start)
    nYearsDown <- 1971 - minYear
    nYearsUp <- maxYear - 2013
    
    set.seed(12)
    yearsDown <- sample(1971:2013,nYearsDown)
    yearsUp <- sample(1971:2013,nYearsUp)
    yearSeqDown <- 1962:1970
    yearSeqUp <- 2014:maxYear
    weatherDown <- weatherX[year %in% yearsDown]
    weatherUp <- weatherX[year %in% yearsUp]
    weatherDown$year <- yearSeqDown[match(weatherDown$year,yearsDown)]
    weatherUp$year <- yearSeqUp[match(weatherUp$year,yearsUp)]
    weatherX <- rbind(weatherX,weatherDown)
    weatherX <- rbind(weatherX,weatherUp)
    setkey(weatherX,id,year,doy)
    weatherX$rday= rep(1:((1+maxYear-minYear)*365),length(unique(weatherX$id)))
    nDays <- (totNyears+1)*365
    
    VPD <- TAir <- Precip <- CO2 <- PAR <- matrix(NA,nClimIDs,nDays)
    
    climIDs <- rep(NA,1,nSites)
    
    for(i in 1:nStands){
      climIDs[which(initData$stand ==siteX$stand[i])] <- i
      yearStart <- min(dataX[stand==siteX$stand[i]]$year)
      seqYears <- yearStart: (yearStart +totNyears)
    PAR[i,] <- weatherX[id==climID[i] & year %in% seqYears]$PAR
    TAir[i,] <- weatherX[id==climID[i] & year %in% seqYears]$TAir
    Precip[i,] <- weatherX[id==climID[i] & year %in% seqYears]$Precip
    VPD[i,] <- weatherX[id==climID[i] & year %in% seqYears]$VPD
    CO2[i,] <- weatherX[id==climID[i] & year %in% seqYears]$CO2
    }
    
    siteX$climIDfin <- climID
    siteX$climIDrun <- match(siteX$climIDfin,climIDx)
    
    # save(PAR,TAir,Precip,VPD,CO2,file="weather.rdata")
  ###extract weather (end)
  
  siteX$siteType <- siteTypeTab$siteType[match(siteX$site,siteTypeTab$codes)]
  siteTypes <- siteX$siteType[match(initData$stand,siteX$stand)]
  
  
  siteInfo <- matrix(c(NA, NA, NA, 160, 0, 0, 20, nLayers, nLayers, 413, 
                       0.45, 0.118), nSites, 12, byrow = T)
  
  siteInfo[,2] <- climIDs
  siteInfo[,3] <- siteTypes
  siteInfo[,1] <- initData$siteID
  
  # load("weather.rdata")
  # initVars[which(is.na(initVars))] <- 0
  

  initPrebas <- InitMultiSite(nYearsMS=rep(60,nSites),
                              siteInfo = siteInfo,
                              multiInitVar = initVars,
                              PAR = PAR, TAir = TAir,
                              VPD = VPD, CO2 = CO2, 
                              Precip = Precip,defaultThin = 0,
                              ClCut = 0,
                              multiNthin = multiNThin,
                              multiThin = as.matrix(thinnings))
  
  initPrebas2 <- InitMultiSite(nYearsMS=rep(60,nSites),
                              siteInfo = siteInfo,
                              multiInitVar = initVars,
                              PAR = PAR, TAir = TAir,
                              VPD = VPD, CO2 = CO2, 
                              Precip = Precip,defaultThin = 0,
                              ClCut = 0,
                              multiNthin = multiNThin,
                              multiThin = as.matrix(thinnings2))

  save(initPrebas,file = "data/initPrebas.rdata")
  save(initPrebas2,file = "data/initPrebas2.rdata")
  save(dataX,file="data/dataX.rdata")
}

