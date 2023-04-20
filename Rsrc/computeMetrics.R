library(Metrics)
source("https://raw.github.com/ForModLabUHel/utilStuff/master/ErrorDecomposition/ErrorDecomposition.R")
met <-2 #select the MSE decomp method to be applied
source("Normalized_RMSE.R")

## First create a variable with the data to compute the statistics
dataFstats <- dataX[dataX$yearSim>0]

nPlaces <- unique(dataFstats$siteID)
outputStats <- list()
for (i in 1:length(nPlaces)) {
  dataFstats.i <- dataFstats[dataFstats$siteID==nPlaces[i]]
  
  MSEdHsim1 <- MSEdec("H",dataFstats.i$HW,dataFstats.i$Hsim,method = met)
  MSEdHsim2 <- MSEdec("H",dataFstats.i$HW,dataFstats.i$Hsim2,method = met)
  MSEdDsim1 <- MSEdec("D",dataFstats.i$DW,dataFstats.i$Dsim,method = met)
  MSEdDsim2 <- MSEdec("D",dataFstats.i$DW,dataFstats.i$Dsim2,method = met)
  MSEdGsim1 <- MSEdec("G",dataFstats.i$G,dataFstats.i$Gsim,method = met) 
  MSEdGsim2 <- MSEdec("G",dataFstats.i$G,dataFstats.i$Gsim2,method = met) 
  MSEdNsim1 <- MSEdec("N",dataFstats.i$N,dataFstats.i$Nsim,method = met) 
  MSEdNsim2 <- MSEdec("N",dataFstats.i$N,dataFstats.i$Nsim2,method = met) 
  MSEdVsim1 <- MSEdec("V",dataFstats.i$V,dataFstats.i$Vsim,method = met)
  MSEdVsim2 <- MSEdec("V",dataFstats.i$V,dataFstats.i$Vsim2,method = met)
  
  coefDetH1 <- summary(lm(dataFstats.i$HW~dataFstats.i$Hsim))$r.squared #"R^2"
  coefDetH2 <- summary(lm(dataFstats.i$HW~dataFstats.i$Hsim2))$r.squared #"R^2"
  coefDetD1 <- summary(lm(dataFstats.i$DW~dataFstats.i$Dsim))$r.squared #"R^2"
  coefDetD2 <- summary(lm(dataFstats.i$DW~dataFstats.i$Dsim2))$r.squared #"R^2"
  coefDetG1 <- summary(lm(dataFstats.i$G~dataFstats.i$Gsim))$r.squared #"R^2"
  coefDetG2 <- summary(lm(dataFstats.i$G~dataFstats.i$Gsim2))$r.squared #"R^2"
  coefDetN1 <- summary(lm(dataFstats.i$N~dataFstats.i$Nsim))$r.squared #"R^2"
  coefDetN2 <- summary(lm(dataFstats.i$N~dataFstats.i$Nsim2))$r.squared #"R^2"
  coefDetV1 <- summary(lm(dataFstats.i$V~dataFstats.i$Vsim))$r.squared #"R^2"
  coefDetV2 <- summary(lm(dataFstats.i$V~dataFstats.i$Vsim2))$r.squared #"R^2"
  
  cRMSEH1 <- sqrt(mean(resid(lm(dataFstats.i$HW~dataFstats.i$Hsim))^2,na.rm=TRUE))#custom RMSE 
  cRMSEH2 <- sqrt(mean(resid(lm(dataFstats.i$HW~dataFstats.i$Hsim2))^2,na.rm=TRUE))#custom RMSE
  cRMSED1 <- sqrt(mean(resid(lm(dataFstats.i$DW~dataFstats.i$Dsim))^2,na.rm=TRUE))#custom RMSE
  cRMSED2 <- sqrt(mean(resid(lm(dataFstats.i$DW~dataFstats.i$Dsim2))^2,na.rm=TRUE))#custom RMSE
  cRMSEG1 <- sqrt(mean(resid(lm(dataFstats.i$G~dataFstats.i$Gsim))^2,na.rm=TRUE))#custom RMSE
  cRMSEG2 <- sqrt(mean(resid(lm(dataFstats.i$G~dataFstats.i$Gsim2))^2,na.rm=TRUE))#custom RMSE
  cRMSEN1 <- sqrt(mean(resid(lm(dataFstats.i$N~dataFstats.i$Nsim))^2,na.rm=TRUE))#custom RMSE
  cRMSEN2 <- sqrt(mean(resid(lm(dataFstats.i$N~dataFstats.i$Nsim2))^2,na.rm=TRUE))#custom RMSE
  cRMSEV1 <- sqrt(mean(resid(lm(dataFstats.i$V~dataFstats.i$Vsim))^2,na.rm=TRUE))#custom RMSE
  cRMSEV2 <- sqrt(mean(resid(lm(dataFstats.i$V~dataFstats.i$Vsim2))^2,na.rm=TRUE))#custom RMSE
  
  rRMSEH1 <- (cRMSEH1/mean(dataFstats.i$HW))*100 #rRMSE relative RMSE (%)
  rRMSEH2 <- (cRMSEH2/mean(dataFstats.i$HW))*100 #rRMSE relative RMSE (%)
  rRMSED1 <- (cRMSED1/mean(dataFstats.i$DW))*100 #rRMSE relative RMSE (%)
  rRMSED2 <- (cRMSED2/mean(dataFstats.i$DW))*100 #rRMSE relative RMSE (%)
  rRMSEG1 <- (cRMSEG1/mean(dataFstats.i$G))*100 #rRMSE relative RMSE (%)
  rRMSEG2 <- (cRMSEG2/mean(dataFstats.i$G))*100 #rRMSE relative RMSE (%)
  rRMSEN1 <- (cRMSEN1/mean(dataFstats.i$N))*100 #rRMSE relative RMSE (%)
  rRMSEN2 <- (cRMSEN2/mean(dataFstats.i$N))*100 #rRMSE relative RMSE (%)
  rRMSEV1 <- (cRMSEV1/mean(dataFstats.i$V))*100 #rRMSE relative RMSE (%)
  rRMSEV2 <- (cRMSEV2/mean(dataFstats.i$V))*100 #rRMSE relative RMSE (%)
  
  nRMSEH1 <- nrmse_func2(dataFstats.i$HW,dataFstats.i$Hsim,"sd") #there is four methods to normalize (sd,mean,maxmin=max-min,iq=interquartile range)
  nRMSEH2 <- nrmse_func2(dataFstats.i$HW,dataFstats.i$Hsim2,"sd")
  nRMSED1 <- nrmse_func2(dataFstats.i$DW,dataFstats.i$Dsim,"sd")
  nRMSED2 <- nrmse_func2(dataFstats.i$DW,dataFstats.i$Dsim2,"sd")
  nRMSEG1 <- nrmse_func2(dataFstats.i$G,dataFstats.i$Gsim,"sd")
  nRMSEG2 <- nrmse_func2(dataFstats.i$G,dataFstats.i$Gsim2,"sd")
  nRMSEN1 <- nrmse_func2(dataFstats.i$N,dataFstats.i$Nsim,"sd")
  nRMSEN2 <- nrmse_func2(dataFstats.i$N,dataFstats.i$Nsim2,"sd")
  nRMSEV1 <- nrmse_func2(dataFstats.i$V,dataFstats.i$Vsim,"sd")
  nRMSEV2 <- nrmse_func2(dataFstats.i$V,dataFstats.i$Vsim2,"sd")
  
  pBIASH1 <- percent_bias(dataFstats.i$HW,dataFstats.i$Hsim) # BIAS(%)
  pBIASH2 <- percent_bias(dataFstats.i$HW,dataFstats.i$Hsim2) # BIAS(%)
  pBIASD1 <- percent_bias(dataFstats.i$DW,dataFstats.i$Dsim) # BIAS(%)
  pBIASD2 <- percent_bias(dataFstats.i$DW,dataFstats.i$Dsim2) # BIAS(%)
  pBIASG1 <- percent_bias(dataFstats.i$G,dataFstats.i$Gsim) # BIAS(%)
  pBIASG2 <- percent_bias(dataFstats.i$G,dataFstats.i$Gsim2) # BIAS(%)
  pBIASN1 <- percent_bias(dataFstats.i$N,dataFstats.i$Nsim) # BIAS(%)
  pBIASN2 <- percent_bias(dataFstats.i$N,dataFstats.i$Nsim2) # BIAS(%)
  pBIASV1 <- percent_bias(dataFstats.i$V,dataFstats.i$Vsim) # BIAS(%)
  pBIASV2 <- percent_bias(dataFstats.i$V,dataFstats.i$Vsim2) # BIAS(%)
  
  outputStats[[i]] = as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],stand=dataFstats.i$stand[1],plot=dataFstats.i$plot[1],MSEdH1=MSEdHsim1$mse,MSEdH2=MSEdHsim2$mse,MSEdD1=MSEdDsim1$mse,MSEdD2=MSEdDsim2$mse,MSEdG1=MSEdGsim1$mse,MSEdG2=MSEdGsim2$mse,MSEdN1=MSEdNsim1$mse,MSEdN2=MSEdNsim2$mse,MSEdV1=MSEdVsim1$mse,MSEdV2=MSEdVsim2$mse,coefDetH1,coefDetH2,coefDetD1,coefDetD2,coefDetG1,coefDetG2,coefDetN1,coefDetN2,coefDetV1,coefDetV2,cRMSEH1,cRMSEH2,cRMSED1,cRMSED2,cRMSEG1,cRMSEG2,cRMSEN1,cRMSEN2,cRMSEV1,cRMSEV2,rRMSEH1,rRMSEH2,rRMSED1,rRMSED2,rRMSEG1,rRMSEG2,rRMSEN1,rRMSEN2,rRMSEV1,rRMSEV2,nRMSEH1,nRMSEH2,nRMSED1,nRMSED2,nRMSEG1,nRMSEG2,nRMSEN1,nRMSEN2,nRMSEV1,nRMSEV2,pBIASH1,pBIASH2,pBIASD1,pBIASD2,pBIASG1,pBIASG2,pBIASN1,pBIASN2,pBIASV1,pBIASV2))
  
  rm(MSEdHsim1,MSEdHsim2,MSEdDsim1,MSEdDsim2,MSEdGsim1,MSEdGsim2,MSEdNsim1,MSEdNsim2,MSEdVsim1,MSEdVsim2) 
  rm(coefDetH1,coefDetH2,coefDetD1,coefDetD2,coefDetG1,coefDetG2,coefDetN1,coefDetN2,coefDetV1,coefDetV2,cRMSEH1)
  rm(cRMSEH2,cRMSED1,cRMSED2,cRMSEG1,cRMSEG2,cRMSEN1,cRMSEN2,cRMSEV1,cRMSEV2)
  rm(rRMSEH1,rRMSEH2,rRMSED1,rRMSED2,rRMSEG1,rRMSEG2,rRMSEN1,rRMSEN2,rRMSEV1,rRMSEV2)
  rm(nRMSEH1,nRMSEH2,nRMSED1,nRMSED2,nRMSEG1,nRMSEG2,nRMSEN1,nRMSEN2,nRMSEV1,nRMSEV2)
  rm(pBIASH1,pBIASH2,pBIASD1,pBIASD2,pBIASG1,pBIASG2,pBIASN1,pBIASN2,pBIASV1,pBIASV2)
  rm(dataFstats.i)
}

rm(met,dataFstats,nPlaces)
outputStats <- rbindlist(outputStats)
write.csv(outputStats,file = 'statistics.csv')
