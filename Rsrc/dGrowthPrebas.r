library(Rprebasso)
##Load sample data
##load("data/inputDataDeltaexample.rda")

 
# ####create new weather
##PARx <- PARtran + 20
##CO2x <- CO2tran + 50
##TAirx <- TAirtran + 7
##VPDx <- VPDtran #+ 20
##Precipx <- Preciptran #+ 20



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
                    currPar,newPAR,
                    currTAir,newTAir,
                    currPrecip,newPrecip,
                    currVPD,newVPD,
                    currCO2,newCO2
                    ){
  nSites <- nrow(siteInfo)
  
  initCurr <- InitMultiSite(nYearsMS = rep(nYears,nSites),
                      PAR = currPar,
                      VPD = currVPD,
                      CO2 = currCO2,
                      TAir = currTAir,
                      Precip = currPrecip,
                      siteInfo = siteInfo,
                      multiInitVar = initVar)
  modOutCurr <- multiPrebas(initCurr)
  
  initNew <- InitMultiSite(nYearsMS = rep(nYears,nSites),
                            PAR = newPAR,
                            VPD = newVPD,
                            CO2 = newCO2,
                            TAir = newTAir,
                            Precip = newPrecip,
                            siteInfo = siteInfo,
                            multiInitVar = initVar)
  modOutNew <- multiPrebas(initNew)
  dGrowth <-modOutNew$multiOut[,,43,,1]/modOutCurr$multiOut[,,43,,1]
  dH <-modOutNew$multiOut[,,11,,1]/modOutCurr$multiOut[,,11,,1]
  dD <-modOutNew$multiOut[,,12,,1]/modOutCurr$multiOut[,,12,,1]
  return(list(dGrowth=dGrowth,dH=dH,dD=dD))
}
