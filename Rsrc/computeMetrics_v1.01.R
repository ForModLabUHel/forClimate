
library(Metrics)
source("https://raw.github.com/ForModLabUHel/utilStuff/master/ErrorDecomposition/ErrorDecomposition.R")
met <-1 #select the MSE decomp method to be applied
source("Normalized_RMSE.R")

## First create a variable with the data to compute the statistics
dataFstats <- dataX[dataX$yearSim>0]

#### 1. Compute the metrics

nPlaces <- unique(dataFstats$stand)#unique(dataFstats$siteID)
outputStats <- list()
MSEdecomp <- list()
a<-1
b<-1
for (i in 1:length(nPlaces)) {#I can select the data in this easy way because there is only one specie for each stand
  dataFstats.i <- dataFstats[dataFstats$stand==nPlaces[i]]#dataFstats[dataFstats$siteID==nPlaces[i]]
  
  MSEdHsim1 <- MSEdec("H1",dataFstats.i$HW,dataFstats.i$Hsim,method = met)
  MSEdHsim2 <- MSEdec("H2",dataFstats.i$HW,dataFstats.i$Hsim2,method = met)
  MSEdDsim1 <- MSEdec("D1",dataFstats.i$DW,dataFstats.i$Dsim,method = met)
  MSEdDsim2 <- MSEdec("D2",dataFstats.i$DW,dataFstats.i$Dsim2,method = met)
  MSEdGsim1 <- MSEdec("G1",dataFstats.i$G,dataFstats.i$Gsim,method = met) 
  MSEdGsim2 <- MSEdec("G2",dataFstats.i$G,dataFstats.i$Gsim2,method = met) 
  MSEdNsim1 <- MSEdec("N1",dataFstats.i$N,dataFstats.i$Nsim,method = met) 
  MSEdNsim2 <- MSEdec("N2",dataFstats.i$N,dataFstats.i$Nsim2,method = met) 
  MSEdVsim1 <- MSEdec("V1",dataFstats.i$V,dataFstats.i$Vsim,method = met)
  MSEdVsim2 <- MSEdec("V2",dataFstats.i$V,dataFstats.i$Vsim2,method = met)
  
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
  
  outputStats[[a]]   <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='H1',MSE=MSEdHsim1$mse,r2=coefDetH1,RMSE=cRMSEH1,rRMSE=rRMSEH1,nRMSE=nRMSEH1,pBIAS=pBIASH1))
  outputStats[[a+1]] <- as.data.frame(cbind(dataFstats.i$HarriF[1],dataFstats.i$town[1],dataFstats.i$speciesID[1],dataFstats.i$stand[1],'H2',MSEdHsim2$mse,coefDetH2,cRMSEH2,rRMSEH2,nRMSEH2,pBIASH2))
  outputStats[[a+2]] <- as.data.frame(cbind(dataFstats.i$HarriF[1],dataFstats.i$town[1],dataFstats.i$speciesID[1],dataFstats.i$stand[1],'D1',MSEdDsim1$mse,coefDetD1,cRMSED1,rRMSED1,nRMSED1,pBIASD1))
  outputStats[[a+3]] <- as.data.frame(cbind(dataFstats.i$HarriF[1],dataFstats.i$town[1],dataFstats.i$speciesID[1],dataFstats.i$stand[1],'D2',MSEdDsim2$mse,coefDetD2,cRMSED2,rRMSED2,nRMSED2,pBIASD2))
  outputStats[[a+4]] <- as.data.frame(cbind(dataFstats.i$HarriF[1],dataFstats.i$town[1],dataFstats.i$speciesID[1],dataFstats.i$stand[1],'G1',MSEdGsim1$mse,coefDetG1,cRMSEG1,rRMSEG1,nRMSEG1,pBIASG1))
  outputStats[[a+5]] <- as.data.frame(cbind(dataFstats.i$HarriF[1],dataFstats.i$town[1],dataFstats.i$speciesID[1],dataFstats.i$stand[1],'G2',MSEdGsim2$mse,coefDetG2,cRMSEG2,rRMSEG2,nRMSEG2,pBIASG2))
  outputStats[[a+6]] <- as.data.frame(cbind(dataFstats.i$HarriF[1],dataFstats.i$town[1],dataFstats.i$speciesID[1],dataFstats.i$stand[1],'N1',MSEdNsim1$mse,coefDetN1,cRMSEN1,rRMSEN1,nRMSEN1,pBIASN1))
  outputStats[[a+7]] <- as.data.frame(cbind(dataFstats.i$HarriF[1],dataFstats.i$town[1],dataFstats.i$speciesID[1],dataFstats.i$stand[1],'N2',MSEdNsim2$mse,coefDetN2,cRMSEN2,rRMSEN2,nRMSEN2,pBIASN2))
  outputStats[[a+8]] <- as.data.frame(cbind(dataFstats.i$HarriF[1],dataFstats.i$town[1],dataFstats.i$speciesID[1],dataFstats.i$stand[1],'V1',MSEdVsim1$mse,coefDetV1,cRMSEV1,rRMSEV1,nRMSEV1,pBIASV1))
  outputStats[[a+9]] <- as.data.frame(cbind(dataFstats.i$HarriF[1],dataFstats.i$town[1],dataFstats.i$speciesID[1],dataFstats.i$stand[1],'V2',MSEdVsim2$mse,coefDetV2,cRMSEV2,rRMSEV2,nRMSEV2,pBIASV2))
  a<-a+10
  
  MSEdecomp[[b]]    <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='H1',comp='lc',val=MSEdHsim1$lc))
  MSEdecomp[[b+1]]  <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='H1',comp='sb',val=MSEdHsim1$sb))
  MSEdecomp[[b+2]]  <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='H1',comp='sdsd',val=MSEdHsim1$sdsd))
  MSEdecomp[[b+3]]  <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='H2',comp='lc',val=MSEdHsim2$lc))
  MSEdecomp[[b+4]]  <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='H2',comp='sb',val=MSEdHsim2$sb))
  MSEdecomp[[b+5]]  <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='H2',comp='sdsd',val=MSEdHsim2$sdsd))
  MSEdecomp[[b+6]]  <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='D1',comp='lc',val=MSEdDsim1$lc))
  MSEdecomp[[b+7]]  <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='D1',comp='sb',val=MSEdDsim1$sb))
  MSEdecomp[[b+8]]  <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='D1',comp='sdsd',val=MSEdDsim1$sdsd))
  MSEdecomp[[b+9]]  <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='D2',comp='lc',val=MSEdDsim2$lc))
  MSEdecomp[[b+10]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='D2',comp='sb',val=MSEdDsim2$sb))
  MSEdecomp[[b+11]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='D2',comp='sdsd',val=MSEdDsim2$sdsd))
  MSEdecomp[[b+12]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='G1',comp='lc',val=MSEdGsim1$lc))
  MSEdecomp[[b+13]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='G1',comp='sb',val=MSEdGsim1$sb))
  MSEdecomp[[b+14]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='G1',comp='sdsd',val=MSEdGsim1$sdsd))
  MSEdecomp[[b+15]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='G2',comp='lc',val=MSEdGsim2$lc))
  MSEdecomp[[b+16]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='G2',comp='sb',val=MSEdGsim2$sb))
  MSEdecomp[[b+17]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='G2',comp='sdsd',val=MSEdGsim2$sdsd))
  MSEdecomp[[b+18]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='N1',comp='lc',val=MSEdNsim1$lc))
  MSEdecomp[[b+19]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='N1',comp='sb',val=MSEdNsim1$sb))
  MSEdecomp[[b+20]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='N1',comp='sdsd',val=MSEdNsim1$sdsd))
  MSEdecomp[[b+21]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='N2',comp='lc',val=MSEdNsim2$lc))
  MSEdecomp[[b+22]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='N2',comp='sb',val=MSEdNsim2$sb))
  MSEdecomp[[b+23]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='N2',comp='sdsd',val=MSEdNsim2$sdsd))
  MSEdecomp[[b+24]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='V1',comp='lc',val=MSEdVsim1$lc))
  MSEdecomp[[b+25]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='V1',comp='sb',val=MSEdVsim1$sb))
  MSEdecomp[[b+26]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='V1',comp='sdsd',val=MSEdVsim1$sdsd))
  MSEdecomp[[b+27]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='V2',comp='lc',val=MSEdVsim2$lc))
  MSEdecomp[[b+28]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='V2',comp='sb',val=MSEdVsim2$sb))
  MSEdecomp[[b+29]] <- as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],Town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],Stand=dataFstats.i$stand[1],var='V2',comp='sdsd',val=MSEdVsim2$sdsd))
  b<-b+30
  
  #outputStats[[i]] = as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],stand=dataFstats.i$stand[1],plot=dataFstats.i$plot[1],MSEdH1=MSEdHsim1$mse,MSEdH2=MSEdHsim2$mse,MSEdD1=MSEdDsim1$mse,MSEdD2=MSEdDsim2$mse,MSEdG1=MSEdGsim1$mse,MSEdG2=MSEdGsim2$mse,MSEdN1=MSEdNsim1$mse,MSEdN2=MSEdNsim2$mse,MSEdV1=MSEdVsim1$mse,MSEdV2=MSEdVsim2$mse,coefDetH1,coefDetH2,coefDetD1,coefDetD2,coefDetG1,coefDetG2,coefDetN1,coefDetN2,coefDetV1,coefDetV2,cRMSEH1,cRMSEH2,cRMSED1,cRMSED2,cRMSEG1,cRMSEG2,cRMSEN1,cRMSEN2,cRMSEV1,cRMSEV2,rRMSEH1,rRMSEH2,rRMSED1,rRMSED2,rRMSEG1,rRMSEG2,rRMSEN1,rRMSEN2,rRMSEV1,rRMSEV2,nRMSEH1,nRMSEH2,nRMSED1,nRMSED2,nRMSEG1,nRMSEG2,nRMSEN1,nRMSEN2,nRMSEV1,nRMSEV2,pBIASH1,pBIASH2,pBIASD1,pBIASD2,pBIASG1,pBIASG2,pBIASN1,pBIASN2,pBIASV1,pBIASV2))
  #MSEdecomp[[i]] = as.data.frame(cbind(HarriF=dataFstats.i$HarriF[1],town=dataFstats.i$town[1],speciesID=dataFstats.i$speciesID[1],stand=dataFstats.i$stand[1],MSEdH1lc=MSEdHsim1$lc,MSEdH2lc=MSEdHsim2$lc,MSEdD1lc=MSEdDsim1$lc,MSEdD2lc=MSEdDsim2$lc,MSEdG1lc=MSEdGsim1$lc,MSEdG2lc=MSEdGsim2$lc,MSEdN1lc=MSEdNsim1$lc,MSEdN2lc=MSEdNsim2$lc,MSEdV1lc=MSEdVsim1$lc,MSEdV2lc=MSEdVsim2$lc,MSEdH1sb=MSEdHsim1$sb,MSEdH2sb=MSEdHsim2$sb,MSEdD1sb=MSEdDsim1$sb,MSEdD2sb=MSEdDsim2$sb,MSEdG1sb=MSEdGsim1$sb,MSEdG2sb=MSEdGsim2$sb,MSEdN1sb=MSEdNsim1$sb,MSEdN2sb=MSEdNsim2$sb,MSEdV1sb=MSEdVsim1$sb,MSEdV2sb=MSEdVsim2$sb,MSEdH1sdsd=MSEdHsim1$sdsd,MSEdH2sdsd=MSEdHsim2$sdsd,MSEdD1sdsd=MSEdDsim1$sdsd,MSEdD2sdsd=MSEdDsim2$sdsd,MSEdG1sdsd=MSEdGsim1$sdsd,MSEdG2sdsd=MSEdGsim2$sdsd,MSEdN1sdsd=MSEdNsim1$sdsd,MSEdN2sdsd=MSEdNsim2$sdsd,MSEdV1sdsd=MSEdVsim1$sdsd,MSEdV2sdsd=MSEdVsim2$sdsd))
  
  rm(MSEdHsim1,MSEdHsim2,MSEdDsim1,MSEdDsim2,MSEdGsim1,MSEdGsim2,MSEdNsim1,MSEdNsim2,MSEdVsim1,MSEdVsim2) 
  rm(coefDetH1,coefDetH2,coefDetD1,coefDetD2,coefDetG1,coefDetG2,coefDetN1,coefDetN2,coefDetV1,coefDetV2,cRMSEH1)
  rm(cRMSEH2,cRMSED1,cRMSED2,cRMSEG1,cRMSEG2,cRMSEN1,cRMSEN2,cRMSEV1,cRMSEV2)
  rm(rRMSEH1,rRMSEH2,rRMSED1,rRMSED2,rRMSEG1,rRMSEG2,rRMSEN1,rRMSEN2,rRMSEV1,rRMSEV2)
  rm(nRMSEH1,nRMSEH2,nRMSED1,nRMSED2,nRMSEG1,nRMSEG2,nRMSEN1,nRMSEN2,nRMSEV1,nRMSEV2)
  rm(pBIASH1,pBIASH2,pBIASD1,pBIASD2,pBIASG1,pBIASG2,pBIASN1,pBIASN2,pBIASV1,pBIASV2)
  rm(dataFstats.i)
}

rm(met,dataFstats,nPlaces,a,b)
outputStats <- rbindlist(outputStats, use.names=FALSE)
MSEdecomp <- rbindlist(MSEdecomp, use.names = FALSE)

write.csv(outputStats,file = 'statistics.csv')  #uncoment this two lines to save the csv file
write.csv(MSEdecomp, file = 'MSEdecomp.csv' )

##### 2 Graphs for MSE decomposition

rm(list = ls())

library(ggplot2)
library(data.table)
library(ggpubr)

MSEdecomp <- read.csv('MSEdecomp.csv')

for (i in 1:length(unique(MSEdecomp$Stand))) {
  stand.i <- MSEdecomp[MSEdecomp$Stand==unique(MSEdecomp$Stand)[i],]
  stand.i <- as.data.table(stand.i)
  
  g_N <-stand.i[stand.i$var=='N1'|stand.i$var=='N2']
  g_V <-stand.i[stand.i$var=='V1'|stand.i$var=='V2']
  g_R <-stand.i[stand.i$var!='N1'&stand.i$var!='N2'&stand.i$var!='V1'&stand.i$var!='V2']
  
  plot.g_N <- ggplot(g_N)+
    geom_col(aes(fill=comp, y=val, x=var))+
    theme(axis.title.x = element_blank(),axis.title.y = element_blank())
  plot.g_V <- ggplot(g_V)+
    geom_col(aes(fill=comp, y=val, x=var))+
    theme(axis.title.x = element_blank(),axis.title.y = element_blank())
  plot.g_R <- ggplot(g_R)+
    geom_col(aes(fill=comp, y=val, x=var))+
    theme(axis.title.x = element_blank(),axis.title.y = element_blank())
  
  p1 <- ggarrange(plot.g_N,plot.g_V, ncol = 2, nrow = 1, legend = "none", common.legend = F)
  p2 <- ggarrange(plot.g_R,p1, ncol = 1, nrow = 2, legend = "bottom", common.legend = T)
  plot.p1_p2<-annotate_figure(p2, top = text_grob(c(paste('MSE decomposition;', 'stand = ', stand.i$Stand), sep = " "),
                                                  size = 12))
  print(plot.p1_p2)
  ggsave(c(paste('MSE_decomp',stand.i$Stand[1],'.jpg')),plot = plot.p1_p2) #uncomment this line to save the Figures
  rm(g_N,g_V,g_R,p1,p2,plot.p1_p2,plot.g_N,plot.g_V,plot.g_R)
}

##### 3 Graphs for the rest of statistics

rm(list = ls())

library(ggplot2)
library(data.table)
library(ggpubr)

Statistics <- read.csv('statistics.csv')

for (i in 1:length(unique(Statistics$Stand))) {
  stand.i <- Statistics[Statistics$Stand==unique(Statistics$Stand)[i],]
  stand.i <- as.data.table(stand.i)
  
  #make plot for r2, rRMSE, nRMSE (normalized by SD), and BIAS in %
  plot.r2 <- ggplot(stand.i)+
    geom_col(aes(y=r2, x=var))+
    xlab(expression(paste('r'^2)))+
    theme(axis.title.y = element_blank())
  plot.rRMSE <- ggplot(stand.i)+
    geom_col(aes(y=rRMSE, x=var))+
    xlab(expression(paste('rRMSE (%)')))+
    theme(axis.title.y = element_blank())
  plot.nRMSE <- ggplot(stand.i)+
    geom_col(aes(y=nRMSE, x=var))+
    xlab(expression(paste('nRMSE (by sd)')))+
    theme(axis.title.y = element_blank())
  plot.pBIAS <- ggplot(stand.i)+
    geom_col(aes(y=pBIAS, x=var))+
    xlab(expression(paste('pBIAS (%))')))+
    theme(axis.title.y = element_blank())

  ### graph for RMSE, since there is two different scales, ,we need to separate in two (N,V) and (D,G,H)
  g_N <-stand.i[stand.i$var=='N1'|stand.i$var=='N2']
  g_V <-stand.i[stand.i$var=='V1'|stand.i$var=='V2']
  g_R <-stand.i[stand.i$var!='N1'&stand.i$var!='N2'&stand.i$var!='V1'&stand.i$var!='V2']
  
  plot.g_N.RMSE <- ggplot(g_N)+
    geom_col(aes(y=RMSE, x=var))+
    xlab(expression(paste('RMSE')))+
    theme(axis.title.y = element_blank())
  plot.g_V.RMSE <- ggplot(g_V)+
    geom_col(aes(y=RMSE, x=var))+
    xlab(expression(paste('RMSE')))+
    theme(axis.title.y = element_blank())
  plot.g_R.RMSE <- ggplot(g_R)+
    geom_col(aes(y=RMSE, x=var))+
    xlab(expression(paste('RMSE')))+
    theme(axis.title.y = element_blank())
  
  p1.RMSE <- ggarrange(plot.g_N.RMSE,plot.g_V.RMSE, ncol = 2, nrow = 1, legend = "none", common.legend = F)
  p2.RMSE <- ggarrange(plot.g_R.RMSE,p1.RMSE, ncol = 1, nrow = 2, legend = "bottom", common.legend = T)
  
  plot.g_N.MSE <- ggplot(g_N)+
    geom_col(aes(y=MSE, x=var))+
    xlab(expression(paste('MSE')))+
    theme(axis.title.y = element_blank())
  plot.g_V.MSE <- ggplot(g_V)+
    geom_col(aes(y=MSE, x=var))+
    xlab(expression(paste('MSE')))+
    theme(axis.title.y = element_blank())
  plot.g_R.MSE <- ggplot(g_R)+
    geom_col(aes(y=MSE, x=var))+
    xlab(expression(paste('MSE')))+
    theme(axis.title.y = element_blank())
  
  p1.MSE <- ggarrange(plot.g_N.MSE,plot.g_V.MSE, ncol = 2, nrow = 1, legend = "none", common.legend = F)
  p2.MSE <- ggarrange(plot.g_R.MSE,p1.MSE, ncol = 1, nrow = 2, legend = "bottom", common.legend = T)
  
  
  p.Final <- ggarrange(plot.r2,plot.pBIAS,plot.rRMSE,plot.nRMSE,p2.MSE,p2.RMSE, ncol = 2, nrow = 3, legend = "bottom", common.legend = T)
  
  plot.Final<-annotate_figure(p.Final, top = text_grob(c(paste('Statistics;', 'stand = ', stand.i$Stand), sep = " "),
                                                  size = 12))
  print(plot.Final)
 
  ggsave(c(paste('Statistics',stand.i$Stand[1],'.jpg')),plot = plot.Final) #uncomment this line to save the Figures
  rm(g_N.RMSE,g_V.RMSE,g_R.RMSE,g_N.MSE,g_V.MSE,g_R.MSE,plot.Final,p.Final,p1.RMSE,p2.RMSE,p1.MSE,p2.MSE,plot.r2,plot.rRMSE,plot.nRMSE,plot.pBIAS)
}

