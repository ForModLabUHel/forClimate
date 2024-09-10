library(Rprebasso)
library(data.table)

avWeather = TRUE

load("data/inputDataDeltaexample.rda")
# siteInfo <- read.csv("data/TestSiteInfo.csv",sep=" ")
# initVar <- read.csv("data/TestTreeInfo.csv",sep=" ")[,2:26]

### future weather - load the data for selected model and scenario
climateModel <- "CanESM2"       # "CanESM2" or "CNRM"
rcp <- "rcp45"                  # "rcp45" or "rcp85"

load(paste0("data/tran",climateModel,".",rcp,".rda"))

#load functions
devtools::source_url("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/Rsrc/dGrowthPrebas.r")
 
#### set years of simulations, define climatechange starting year of database and simulations
nYears_sim <- 5 # number of year of simulations
startYearDataBase <- 2025 ###starting year in the data base
startYear <- 2031 #start year in the simulations

####process weather data
nYears_CurrClim <- ncol(PARtran)/365   ###number of available years in current climate

if(avWeather){
  ### calculate mean climate inputs
  PAR_currClim <- averageWeather(PARtran,nYears_sim)
  Precip_currClim <- averageWeather(Preciptran,nYears_sim)
  TAir_currClim <- averageWeather(TAirtran,nYears_sim)
  VPD_currClim <- averageWeather(VPDtran,nYears_sim)
  CO2_currClim <- averageWeather(CO2tran,nYears_sim)
}else{
  ### prepare weather inputs for the current climate sampling years from historical data
  year_sample <- sample(1:nYears_CurrClim,nYears_sim) ###sample 5 years randomly 
  day_sample <- rep((year_sample-1)*365,each=365) + 1:365 ###corresponding days for the sampled years
  PAR_currClim <- PARtran[,day_sample]
  Precip_currClim <- Preciptran[,day_sample]
  TAir_currClim <- TAirtran[,day_sample]
  VPD_currClim <- VPDtran[,day_sample]
  CO2_currClim <- CO2tran[,day_sample]
}

####extract climate from climate change database
startYearSim <- startYear - startYearDataBase
yearsSim <- startYearSim+1:nYears_sim  
day_climateChange <- rep((yearsSim-1)*365,each=365) + 1:365

PAR_clChange <- PARx[,day_climateChange]
Precip_clChange <- Precipx[,day_climateChange]
TAir_clChange <- TAirx[,day_climateChange]
VPD_clChange <- VPDx[,day_climateChange]
CO2_clChange <- CO2x[,day_climateChange]



###multiite example
dGrowthExample <- dGrowthPrebas(nYears_sim,siteInfo,initVar,
             currPAR=PAR_currClim,newPAR=PAR_clChange,
             currTAir=TAir_currClim,newTAir=TAir_clChange,
             currPrecip=Precip_currClim,newPrecip=Precip_clChange,
             currVPD=VPD_currClim,newVPD=VPD_clChange,
             currCO2=CO2_currClim,newCO2=CO2_clChange)


#plot results for GrossGrowth
  dim(dGrowthExample$dV)
  plot(dGrowthExample$dV[1,,1])
  points(dGrowthExample$dV[1,,2],col=2)
  points(dGrowthExample$dV[1,,3],col=3)
hist(dGrowthExample$dV)
dVstand <- apply(dGrowthExample$dV,1:2,sum)
hist(dVstand)


#plot results for dH
dim(dGrowthExample$dH)
plot(dGrowthExample$dH[1,,1])
points(dGrowthExample$dH[1,,2],col=2)
points(dGrowthExample$dH[1,,3],col=3)
hist(dGrowthExample$dH)
dHStand <- apply(dGrowthExample$dH,1:2,sum)
hist(dHStand)


#plot results for dD
dim(dGrowthExample$dD)
plot(dGrowthExample$dD[1,,1])
points(dGrowthExample$dD[1,,2],col=2)
points(dGrowthExample$dD[1,,3],col=3)
hist(dGrowthExample$dD)
dDStand <- apply(dGrowthExample$dD,1:2,sum)
hist(dDStand)

###single Site example
siteX = 3 #select a site (from 1 to 7 from the previous dataset)
climID = 2 #select a climate (from 1 to 7 from the previous dataset)

siteInfo_siteX <- siteInfo[siteX,c(1:7,10:12)]
initVar_siteX <- initVar[siteX,,]

PAR_siteX <- PAR_currClim[climID,]
newPAR_siteX <- PAR_clChange[climID,]
Precip_siteX <- Precip_currClim[climID,]
newPrecip_siteX <- Precip_clChange[climID,]
TAir_siteX <- TAir_currClim[climID,]
newTAir_siteX <- TAir_clChange[climID,]
VPD_siteX <- VPD_currClim[climID,]
newVPD_siteX <- VPD_clChange[climID,]
CO2_siteX <- CO2_currClim[climID,]
newCO2_siteX <- CO2_clChange[climID,]

dGrowthExample_siteX <- dGrowthPrebas(nYears_sim,siteInfo_siteX,initVar_siteX,
                                currPAR=PAR_siteX,newPAR=newPAR_siteX,
                                currTAir=TAir_siteX,newTAir=newTAir_siteX,
                                currPrecip=Precip_siteX,newPrecip=newPrecip_siteX,
                                currVPD=VPD_siteX,newVPD=newVPD_siteX,
                                currCO2=CO2_siteX,newCO2=newCO2_siteX)


#plot results for GrossGrowth
dim(dGrowthExample_siteX$dV)
plot(dGrowthExample_siteX$dV[,1])
points(dGrowthExample_siteX$dV[,2],col=2)
points(dGrowthExample_siteX$dV[,3],col=3)
hist(dGrowthExample_siteX$dV)
dVstand <- apply(dGrowthExample_siteX$dV,1,sum)
hist(dVstand)

#plot results for dH
dim(dGrowthExample_siteX$dH)
plot(dGrowthExample_siteX$dH[,1])
points(dGrowthExample_siteX$dH[,2],col=2)
points(dGrowthExample_siteX$dH[,3],col=3)
hist(dGrowthExample_siteX$dH)
dHStand <- apply(dGrowthExample_siteX$dH,1,sum)
hist(dHStand)


#plot results for dD
dim(dGrowthExample_siteX$dD)
plot(dGrowthExample_siteX$dD[,1])
points(dGrowthExample_siteX$dD[,2],col=2)
points(dGrowthExample_siteX$dD[,3],col=3)
hist(dGrowthExample_siteX$dD)
dDStand <- apply(dGrowthExample_siteX$dD,1,sum)
hist(dDStand)

