library(Rprebasso)
library(data.table)
source('Rsrc/dGrowthPrebas.r')
siteinfo<-function(fname){
    siteInfo <- as.numeric(read.csv("data/TestSiteInfo.csv",sep=" ")[c(1:7,10:12)])
    print(siteInfo)
    return (siteInfo)
}

initvar<-function(fname){
    initVar <- as.matrix(read.csv("data/TestTreeInfo.csv",sep=" ")[,2:27])
    return (initVar)
}

climate<-function(climateModel){
    load(paste0("data/tran",climateModel,".","rcp45",".rda"))
}

###Call dGrowthPrebas with site and model tree information, given climate scenario
###and geographic location. The climate set-up must be reimplemented for the
###real climate scenario data.
###TODO: decide how to express climate scenario and geographic location. Implement
###the climate data set-up.
prebascoefficients<-function(siteInfo_siteX,initVar_siteX,climateModel,climID){
    ###BEGIN reimplement climate data set-up for dGrowthPrebas
    load("data/inputDataDeltaexample.rda")
    load(paste0("data/tran",climateModel,".","rcp45",".rda"))
    #### set years of simulations, define climatechange starting year of database and simulations
    nYears_sim <- 5 # number of year of simulations
    startYearDataBase <- 2025 ###starting year in the data base
    startYear <- 2041 #start year in the simulations
    
    ####process weather data
    nYears_CurrClim <- ncol(PARtran)/365   ###number of available years in current climate

    year_sample <- sample(1:nYears_CurrClim,nYears_sim) ###sample 5 years randomly 
    day_sample <- rep((year_sample-1)*365,each=365) + 1:365 ###corresponding days for the sampled years

    ### prepare weather inputs for the current climate
    PAR_sample <- PARtran[,day_sample]
    Precip_sample <- Preciptran[,day_sample]
    TAir_sample <- TAirtran[,day_sample]
    VPD_sample <- VPDtran[,day_sample]
    CO2_sample <- CO2tran[,day_sample]
    ### calculate mean climate inputs
    PAR_average <- averageWeather(PARtran,nYears_sim)
    Precip_average <- averageWeather(Preciptran,nYears_sim)
    TAir_average <- averageWeather(TAirtran,nYears_sim)
    VPD_average <- averageWeather(VPDtran,nYears_sim)
    CO2_average <- averageWeather(CO2tran,nYears_sim)

    ####extract climate from climate change database
    startYearSim <- startYear - startYearDataBase
    yearsSim <- startYearSim+1:nYears_sim  
    day_climateChange <- rep((yearsSim-1)*365,each=365) + 1:365

    PAR_clChange <- PARx[,day_climateChange]
    Precip_clChange <- Precipx[,day_climateChange]
    TAir_clChange <- TAirx[,day_climateChange]
    VPD_clChange <- VPDx[,day_climateChange]
    CO2_clChange <- CO2x[,day_climateChange]

    PAR_siteX <- PAR_sample[climID,]
    newPAR_siteX <- PAR_clChange[climID,]
    Precip_siteX <- Precip_sample[climID,]
    newPrecip_siteX <- Precip_clChange[climID,]
    TAir_siteX <- TAir_sample[climID,]
    newTAir_siteX <- TAir_clChange[climID,]
    VPD_siteX <- VPD_sample[climID,]
    newVPD_siteX <- VPD_clChange[climID,]
    CO2_siteX <- CO2_sample[climID,]
    newCO2_siteX <- CO2_clChange[climID,]
    ###siteInfo <- as.numeric(read.csv("data/TestSiteInfo.csv",sep=" ")[c(1:7,10:12)])
    ###initVar <- as.matrix(read.csv("data/TestTreeInfo.csv",sep=" ")[,2:27])
    ###siteInfo_siteX <- siteInfo#siteInfo[siteX,c(1:7,10:12)]
    ###initVar_siteX <- initVar#initVar[siteX,,]
    ###print("HERE")
    ###END Reimplement climate scenario data set-up for dGrowthPrebas
    dGrowthExample_siteX <- dGrowthPrebas(5,siteInfo_siteX,initVar_siteX,
                                          currPAR=PAR_siteX,newPAR=newPAR_siteX,
                                          currTAir=TAir_siteX,newTAir=newTAir_siteX,
                                          currPrecip=Precip_siteX,newPrecip=newPrecip_siteX,
                                          currVPD=VPD_siteX,newVPD=newVPD_siteX,
                                          currCO2=CO2_siteX,newCO2=newCO2_siteX)
    ###print(dGrowthExample_siteX)
    return (dGrowthExample_siteX)
}
