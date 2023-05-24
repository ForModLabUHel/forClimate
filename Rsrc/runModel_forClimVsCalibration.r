library("patchwork")
library(ggpubr)
library(data.table)
library("readxl")
library(Rprebasso)
library(ggplot2)
###load data and model inputs
load("data/dataX.rdata")
load("data/initPrebas.rdata")
load("data/initPrebas2.rdata")
load("data/initPrebas_newCal.rdata")
load("data/initPrebas2_newCal.rdata")
load("data/init_set2.rdata")
load("data/init_set3.rdata")
load("data/cal_pPRELES.rdata")
load("data/cal_pCROBAS.rdata")

####set mortality model for managed and unmaneged forests
thinnedSites <- which(initPrebas$nThinning>0)
unmanFor <- which(initPrebas$nThinning==0)
# change the settings of clearcut so cleacut doesn't take place but the mortality model is for managed forests
initPrebas$ClCut[thinnedSites] <- 1
initPrebas$inDclct[thinnedSites] <- 9999
initPrebas$inAclct[thinnedSites] <- 9999
initPrebas2$ClCut[thinnedSites] <- 1
initPrebas2$inDclct[thinnedSites] <- 9999
initPrebas2$inAclct[thinnedSites] <- 9999
initPrebas2$mortMod <- initPrebas$mortMod <- c(1,2)
###for new parameter sets
initPrebas_newCal$ClCut[thinnedSites] <- 1
initPrebas_newCal$inDclct[thinnedSites] <- 9999
initPrebas_newCal$inAclct[thinnedSites] <- 9999
initPrebas2_newCal$ClCut[thinnedSites] <- 1
initPrebas2_newCal$inDclct[thinnedSites] <- 9999
initPrebas2_newCal$inAclct[thinnedSites] <- 9999
###Run PREBAS and process output (start)
test <- multiPrebas(initPrebas) # initPrebas and original parameters - test in the legend
test$multiOut[,,c(13,17,30),,2] <- test$multiOut[,,c(13,17,30),,1] + test$multiOut[,,c(13,17,30),,2]

test2 <- multiPrebas(initPrebas2)
test2$multiOut[,,c(13,17,30),,2] <- test2$multiOut[,,c(13,17,30),,1] +
  test2$multiOut[,,c(13,17,30),,2]

testNewPar <- multiPrebas(initPrebas_newCal)
testNewPar$multiOut[,,c(13,17,30),,2] <- testNewPar$multiOut[,,c(13,17,30),,1] + testNewPar$multiOut[,,c(13,17,30),,2]

testNewPar2 <- multiPrebas(initPrebas2_newCal)
testNewPar2$multiOut[,,c(13,17,30),,2] <- testNewPar2$multiOut[,,c(13,17,30),,1] +
  testNewPar2$multiOut[,,c(13,17,30),,2]


# initPrebas and calibrated parameters - testCal in the legend
initPrebasCheck<-initPrebas
initPrebasCheck$pCROBAS<-cal_pCROBAS
initPrebasCheck$pPRELES<-cal_pPRELES
testNewParCheck <- multiPrebas(initPrebasCheck)
testNewParCheck$multiOut[,,c(13,17,30),,2] <- testNewParCheck$multiOut[,,c(13,17,30),,1] + testNewParCheck$multiOut[,,c(13,17,30),,2]

### original parameters - init_set2 and init_set3 with BA weighted D - modOut in the legend
modOut2 <- multiPrebas(init_set2)
modOut3 <- multiPrebas(init_set3)

### original parameters - init_set2 and init_set3 with changed initVar DBH to quadratic mean DHB- modOutinitD in the legend
init_set2D<-init_set2
init_set2D$multiInitVar[162,4,]<-12.06781
init_set3D<-init_set3
init_set3D$multiInitVar[181,4,1]<-11.92192451
modOut2D <- multiPrebas(init_set2D)
modOut3D <- multiPrebas(init_set3D)

### calibrated parameters - init_set2 and init_set3 with BA weighted D - modOutCal in the legend
init_set2Cal<-init_set2
init_set2Cal$pPRELES<-cal_pPRELES
init_set2Cal$pCROBAS<-cal_pCROBAS
init_set3Cal<-init_set3
init_set3Cal$pPRELES<-cal_pPRELES
init_set3Cal$pCROBAS<-cal_pCROBAS
modOut2Cal <- multiPrebas(init_set2Cal)
modOut3Cal <- multiPrebas(init_set3Cal)

### calibrated parameters - init_set2 and init_set3 with changed initVar DBH to quadratic mean DHB - modOutCalD in the legend
init_set2D$pPRELES<-cal_pPRELES
init_set2D$pCROBAS<-cal_pCROBAS
init_set3D$pPRELES<-cal_pPRELES
init_set3D$pCROBAS<-cal_pCROBAS
modOut2CalD <- multiPrebas(init_set2D)
modOut3CalD <- multiPrebas(init_set3D)

# par(mfrow = c(2, 2), mar=c(10, 4, 4, 4), xpd=TRUE)
# plot(initPrebas$weather[4,1,1:365,1],ylim=c(0,60))
# points(init_set2$weather[24,1,1:365,1], pch=20, col=2)
# plot(initPrebas$weather[4,1,1:365,2],ylim=c(-30,30))
# points(init_set2$weather[24,1,1:365,2], pch=20, col=2)
# plot(initPrebas$weather[4,1,1:365,3],ylim=c(0,1.5))
# points(init_set2$weather[24,1,1:365,3], pch=20, col=2)
# plot(initPrebas$weather[4,1,1:365,4])
# points(init_set2$weather[24,1,1:365,4], pch=20, col=2)
# legend('bottom', legend = c('ForClimate initPrebas', 'Calibration Init_set'), title = 'site 35',
#        pch = c(1,20), col = c(1,2), cex=1, horiz = T, inset = c(0, -1), bty = "n", xpd = TRUE)
# 
# plot(initPrebas$weather[1,1,1:365,1],ylim=c(0,60))
# points(init_set3$weather[18,1,1:365,1], pch=20, col=3)
# plot(initPrebas$weather[1,1,1:365,2],ylim=c(-30,30))
# points(init_set3$weather[18,1,1:365,2], pch=20, col=3)
# plot(initPrebas$weather[1,1,1:365,3],ylim=c(0,1.5))
# points(init_set3$weather[18,1,1:365,3], pch=20, col=3)
# plot(initPrebas$weather[1,1,1:365,4])
# points(init_set3$weather[18,1,1:365,4], pch=20, col=3)
# legend('bottom', legend = c('ForClimate initPrebas', 'Calibration Init_set'), title = 'site 5',
#        pch = c(1,20), col = c(1,3), cex=1, horiz = T, inset = c(0, -1), bty = "n", xpd = TRUE)

varX=11
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
simXnewpar <- testNewPar$multiOut[indX]
simXnewparCheck <- testNewParCheck$multiOut[indX]
dataX[yearSim>0, Hsim:= simX]
dataX[yearSim>0, Hsim_newCal:=simXnewpar]
dataX[yearSim>0, Hsim_newCalCheck:=simXnewparCheck]
simX <- test2$multiOut[indX]
simXnewpar <- testNewPar2$multiOut[indX]
dataX[yearSim>0, Hsim2:= simX]
dataX[yearSim>0, Hsim2_newCal:= simXnewpar]
varX=12
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
simXnewpar <- testNewPar$multiOut[indX]
simXnewparCheck <- testNewParCheck$multiOut[indX]
dataX[yearSim>0, Dsim:= simX]
dataX[yearSim>0, Dsim_newCal:=simXnewpar]
dataX[yearSim>0, Dsim_newCalCheck:=simXnewparCheck]
simX <- test2$multiOut[indX]
simXnewpar <- testNewPar2$multiOut[indX]
dataX[yearSim>0, Dsim2:= simX]
dataX[yearSim>0, Dsim2_newCal:= simXnewpar]
varX=13
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
simXnewpar <- testNewPar$multiOut[indX]
simXnewparCheck <- testNewParCheck$multiOut[indX]
dataX[yearSim>0, Gsim:= simX]
dataX[yearSim>0, Gsim_newCal:=simXnewpar]
dataX[yearSim>0, Gsim_newCalCheck:=simXnewparCheck]
simX <- test2$multiOut[indX]
simXnewpar <- testNewPar2$multiOut[indX]
dataX[yearSim>0, Gsim2:= simX]
dataX[yearSim>0, Gsim2_newCal:= simXnewpar]
varX=17
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
simXnewpar <- testNewPar$multiOut[indX]
simXnewparCheck <- testNewParCheck$multiOut[indX]
dataX[yearSim>0, Nsim:= simX]
dataX[yearSim>0, Nsim_newCal:=simXnewpar]
dataX[yearSim>0, Nsim_newCalCheck:=simXnewparCheck]
simX <- test2$multiOut[indX]
simXnewpar <- testNewPar2$multiOut[indX]
dataX[yearSim>0, Nsim2:= simX]
dataX[yearSim>0, Nsim2_newCal:= simXnewpar]
varX=30
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
simXnewpar <- testNewPar$multiOut[indX]
simXnewparCheck <- testNewParCheck$multiOut[indX]
dataX[yearSim>0, Vsim:= simX]
dataX[yearSim>0, Vsim_newCal:=simXnewpar]
dataX[yearSim>0, Vsim_newCalCheck:=simXnewparCheck]
simX <- test2$multiOut[indX]
simXnewpar <- testNewPar2$multiOut[indX]
dataX[yearSim>0, Vsim2:= simX]
dataX[yearSim>0, Vsim2_newCal:= simXnewpar]
dataX$speciesID <- as.factor(dataX$speciesID)
###Run PREBAS and process output (end)

####produce plots by site and variables
siteX <- 35 #(35,33,5,3)   ####vary this between 1 and 35 to see other sites ### check sites 5 and 35
siteYp <- 162
siteYs <- 181
varX=11
par(mar=c(10, 4, 4, 4), xpd=TRUE)
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',ylim=range(dataX[siteID==siteX & compnt==2,.(Hsim,HW)],test$multiOut[siteX,,varX,1,1],modOut2$multiOut[siteYp,1:44,varX,1,1],na.rm=T))
dataX[siteID==siteX & compnt==2,points(yearSim,Hsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Hsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,HW,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,HW,col=2,pch=4)]
# lines(testNewPar$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type=http://127.0.0.1:24063/graphics/plot_zoom_png?width=1174&height=900'l',col=3)
# dataX[siteID==siteX & compnt==2,points(yearSim,Hsim_newCal,col=3,pch=1)]
# dataX[siteID==siteX & compnt==1,points(yearSim,Hsim_newCal,col=3,pch=3)]
lines(testNewParCheck$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=4)
dataX[siteID==siteX & compnt==2,points(yearSim,Hsim_newCalCheck,col=4,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Hsim_newCalCheck,col=4,pch=3)]
### calset pine
lines(modOut2$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=3)
points(c(1,7,18,31,38,43), modOut2$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=3)
lines(modOut2Cal$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=6)
points(c(1,7,18,31,38,43), modOut2Cal$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=6)
lines(modOut2D$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=7)
points(c(1,7,18,31,38,43), modOut2D$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=7)
lines(modOut2CalD$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=8)
points(c(1,7,18,31,38,43), modOut2CalD$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=8)
points(Hdata_s2$outData[which(Hdata_s2$outData[,1]==siteYp),2],Hdata_s2$obs[which(Hdata_s2$outData[,1]==siteYp)],col=6,pch=20)
### calset spruce
lines(modOut3$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=3)
points(c(1,6,12,17,23,32), modOut3$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=3)
lines(modOut3Cal$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=6)
points(c(1,6,12,17,23,32), modOut3Cal$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=6)
lines(modOut3D$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=7)
points(c(1,6,12,17,23,32), modOut3D$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=7)
lines(modOut3CalD$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=8)
points(c(1,6,12,17,23,32), modOut3CalD$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=8)
points(Hdata_s3$outData[which(Hdata_s3$outData[,1]==siteYs),2],Hdata_s3$obs[which(Hdata_s3$outData[,1]==siteYs)],col=3,pch=20)
###legend
legend('bottom', legend = c('test', 'testCal', 'modOut', 'modOutinitD', 'modOutCal', 'modOutCalD'),title = paste0('site',siteX),
       lwd = 1, col = c(1,4,3,7,6,8), cex=1, ncol = 3, inset = c(0, -0.275), bty = "n", xpd = TRUE) 
legend('bottom', legend = c('simulated', 'observed'),
       pch = c(1,20), col = c(1,1), cex=1, horiz = T, inset = c(0, -0.31), bty = "n", xpd = TRUE)

varX=30
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',ylim=range(dataX[siteID==siteX & compnt==2,.(Vsim,V)],test$multiOut[siteX,,varX,1,1],modOut2$multiOut[siteYp,1:44,varX,1,1],na.rm=T))
dataX[siteID==siteX & compnt==2,points(yearSim,Vsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Vsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,V,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,V,col=2,pch=4)]
# lines(test2$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
# dataX[siteID==siteX & compnt==2,points(yearSim,Vsim2,col=3,pch=1)]
# dataX[siteID==siteX & compnt==1,points(yearSim,Vsim2,col=3,pch=3)]
lines(testNewParCheck$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=4)
dataX[siteID==siteX & compnt==2,points(yearSim,Vsim_newCalCheck,col=4,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Vsim_newCalCheck,col=4,pch=3)]
### calset pine
lines(modOut2$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=3)
points(c(1,7,18,31,38,43), modOut2$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=3)
lines(modOut2Cal$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=6)
points(c(1,7,18,31,38,43), modOut2Cal$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=6)
lines(modOut2D$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=7)
points(c(1,7,18,31,38,43), modOut2D$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=7)
lines(modOut2CalD$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=8)
points(c(1,7,18,31,38,43), modOut2CalD$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=8)
points(Vdata_s2$outData[which(Vdata_s2$outData[,1]==siteYp),2],Vdata_s2$obs[which(Vdata_s2$outData[,1]==siteYp)],col=3,pch=20)
### calset spruce
lines(modOut3$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=3)
points(c(1,6,12,17,23,32), modOut3$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=3)
lines(modOut3Cal$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=6)
points(c(1,6,12,17,23,32), modOut3Cal$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=6)
lines(modOut3D$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=7)
points(c(1,6,12,17,23,32), modOut3D$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=7)
lines(modOut3CalD$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=8)
points(c(1,6,12,17,23,32), modOut3CalD$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=8)
points(Vdata_s3$outData[which(Vdata_s3$outData[,1]==siteYs),2],Vdata_s3$obs[which(Vdata_s3$outData[,1]==siteYs)],col=3,pch=20)
###legend
legend('bottom', legend = c('test', 'testCal', 'modOut', 'modOutinitD', 'modOutCal', 'modOutCalD'),title = paste0('site',siteX),
       lwd = 1, col = c(1,4,3,7,6,8), cex=1, ncol = 3, inset = c(0, -0.275), bty = "n", xpd = TRUE) 
legend('bottom', legend = c('simulated', 'observed'),
       pch = c(1,20), col = c(1,1), cex=1, horiz = T, inset = c(0, -0.31), bty = "n", xpd = TRUE)

varX=13
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',ylim=range(dataX[siteID==siteX & compnt==2,.(Gsim,G)],test$multiOut[siteX,,varX,1,1],modOut2$multiOut[siteYp,1:44,varX,1,1],na.rm=T))
dataX[siteID==siteX & compnt==2,points(yearSim,Gsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Gsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,G,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,G,col=2,pch=4)]
# lines(testNewPar$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
# dataX[siteID==siteX & compnt==2,points(yearSim,Gsim_newCal,col=3,pch=1)]
# dataX[siteID==siteX & compnt==1,points(yearSim,Gsim_newCal,col=3,pch=3)]
lines(testNewParCheck$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=4)
dataX[siteID==siteX & compnt==2,points(yearSim,Gsim_newCalCheck,col=4,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Gsim_newCalCheck,col=4,pch=3)]
### calset pine
lines(modOut2$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=3)
points(c(1,7,18,31,38,43), modOut2$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=3)
lines(modOut2Cal$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=6)
points(c(1,7,18,31,38,43), modOut2Cal$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=6)
lines(modOut2D$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=7)
points(c(1,7,18,31,38,43), modOut2D$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=7)
lines(modOut2CalD$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=8)
points(c(1,7,18,31,38,43), modOut2CalD$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=8)
points(Bdata_s2$outData[which(Bdata_s2$outData[,1]==siteYp),2],Bdata_s2$obs[which(Bdata_s2$outData[,1]==siteYp)],col=3,pch=20)
### calset spruce
lines(modOut3$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=3)
points(c(1,6,12,17,23,32), modOut3$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=3)
lines(modOut3Cal$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=6)
points(c(1,6,12,17,23,32), modOut3Cal$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=6)
lines(modOut3D$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=7)
points(c(1,6,12,17,23,32), modOut3D$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=7)
lines(modOut3CalD$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=8)
points(c(1,6,12,17,23,32), modOut3CalD$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=8)
points(Bdata_s3$outData[which(Bdata_s3$outData[,1]==siteYs),2],Bdata_s3$obs[which(Bdata_s3$outData[,1]==siteYs)],col=3,pch=20)
###legend
legend('bottom', legend = c('test', 'testCal', 'modOut', 'modOutinitD', 'modOutCal', 'modOutCalD'),title = paste0('site',siteX),
       lwd = 1, col = c(1,4,3,7,6,8), cex=1, ncol = 3, inset = c(0, -0.275), bty = "n", xpd = TRUE) 
legend('bottom', legend = c('simulated', 'observed'),
       pch = c(1,20), col = c(1,1), cex=1, horiz = T, inset = c(0, -0.31), bty = "n", xpd = TRUE)

varX=12
par(mar=c(10, 4, 4, 4), xpd=TRUE)
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',ylim=range(dataX[siteID==siteX & compnt==2,.(Dsim,DW)],test$multiOut[siteX,,varX,1,1],modOut2$multiOut[siteYp,1:44,varX,1,1],na.rm=T))
dataX[siteID==siteX & compnt==2,points(yearSim,Dsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Dsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,DW,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,DW,col=2,pch=4)]
# lines(testNewPar$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
# dataX[siteID==siteX & compnt==2,points(yearSim,Dsim_newCal,col=3,pch=1)]
# dataX[siteID==siteX & compnt==1,points(yearSim,Dsim_newCal,col=3,pch=3)]
lines(testNewParCheck$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=4)
dataX[siteID==siteX & compnt==2,points(yearSim,Dsim_newCalCheck,col=4,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Dsim_newCalCheck,col=4,pch=3)]
### calset pine
lines(modOut2$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=3)
points(c(1,7,18,31,38,43), modOut2$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=3)
lines(modOut2Cal$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=6)
points(c(1,7,18,31,38,43), modOut2Cal$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=6)
lines(modOut2D$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=7)
points(c(1,7,18,31,38,43), modOut2D$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=7)
lines(modOut2CalD$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=8)
points(c(1,7,18,31,38,43), modOut2CalD$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=8)
points(Ddata_s2$outData[which(Ddata_s2$outData[,1]==siteYp),2],Ddata_s2$obs[which(Ddata_s2$outData[,1]==siteYp)],col=3,pch=20)
### calset spruce
lines(modOut3$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=3)
points(c(1,6,12,17,23,32), modOut3$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=3)
lines(modOut3Cal$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=6)
points(c(1,6,12,17,23,32), modOut3Cal$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=6)
lines(modOut3D$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=7)
points(c(1,6,12,17,23,32), modOut3D$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=7)
lines(modOut3CalD$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=8)
points(c(1,6,12,17,23,32), modOut3CalD$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=8)
points(Ddata_s3$outData[which(Ddata_s3$outData[,1]==siteYs),2],Ddata_s3$obs[which(Ddata_s3$outData[,1]==siteYs)],col=3,pch=20)
###legend
legend('bottom', legend = c('test', 'testCal', 'modOut', 'modOutinitD', 'modOutCal', 'modOutCalD'),title = paste0('site',siteX),
       lwd = 1, col = c(1,4,3,7,6,8), cex=1, ncol = 3, inset = c(0, -0.275), bty = "n", xpd = TRUE) 
legend('bottom', legend = c('simulated', 'observed'),
       pch = c(1,20), col = c(1,1), cex=1, horiz = T, inset = c(0, -0.31), bty = "n", xpd = TRUE)

varX=17
par(mar=c(10, 4, 4, 4), xpd=TRUE)
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',ylim=range(dataX[siteID==siteX & compnt==2,.(Nsim,N)],test$multiOut[siteX,,varX,1,1],modOut2$multiOut[siteYp,1:44,varX,1,1],modOut2Cal$multiOut[siteYp,1:44,varX,1,1],na.rm=T))
dataX[siteID==siteX & compnt==2,points(yearSim,Nsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Nsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,N,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,N,col=2,pch=4)]
# lines(testNewPar$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
# dataX[siteID==siteX & compnt==2,points(yearSim,Nsim_newCal,col=3,pch=1)]
# dataX[siteID==siteX & compnt==1,points(yearSim,Nsim2_newCal,col=3,pch=3)]
lines(testNewParCheck$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=4)
dataX[siteID==siteX & compnt==2,points(yearSim,Nsim_newCalCheck,col=4,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Nsim_newCalCheck,col=4,pch=3)]
### calset pine
lines(modOut2$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=3)
points(c(1,7,18,31,38,43), modOut2$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=3)
lines(modOut2Cal$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=6)
points(c(1,7,18,31,38,43), modOut2Cal$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=6)
lines(modOut2D$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=7)
points(c(1,7,18,31,38,43), modOut2D$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=7)
lines(modOut2CalD$multiOut[siteYp,1:44,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=8)
points(c(1,7,18,31,38,43), modOut2CalD$multiOut[siteYp,c(1,7,18,31,38,43),varX,1,1], pch=1, col=8)
### calset spruce
lines(modOut3$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=3)
points(c(1,6,12,17,23,32), modOut3$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=3)
lines(modOut3Cal$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=6)
points(c(1,6,12,17,23,32), modOut3Cal$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=6)
lines(modOut3D$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=7)
points(c(1,6,12,17,23,32), modOut3D$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=7)
# lines(modOut3CalD$multiOut[siteYs,1:33,varX,1,1], ylab = varNames[varX],xlab="year",type='l',col=8)
# points(c(1,6,12,17,23,32), modOut3CalD$multiOut[siteYs,c(1,6,12,17,23,32),varX,1,1], pch=1, col=8)
###legend
legend('bottom', legend = c('test', 'testCal', 'modOut', 'modOutinitD', 'modOutCal', 'modOutCalD'),title = paste0('site',siteX),
       lwd = 1, col = c(1,4,3,7,6,8), cex=1, ncol = 3, inset = c(0, -0.275), bty = "n", xpd = TRUE) 
legend('bottom', legend = c('simulated', 'observed'),
       pch = c(1,20), col = c(1,1), cex=1, horiz = T, inset = c(0, -0.31), bty = "n", xpd = TRUE)

#####scatter plots with all data
vlim <- range(dataX[,.(Vsim,V,Vsim_newCal,Vsim2,Vsim2_newCal,Vsim_newCalCheck)],na.rm=T)
pV <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Vsim,y=V,shape=speciesID),col=2) + 
  geom_point(aes(x=Vsim_newCal,y=V,shape=speciesID),col=3) +
  geom_point(aes(x=Vsim_newCalCheck,y=V,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1) + ylim(vlim)
pVpine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Vsim,y=V),col=2) + 
  geom_point(aes(x=Vsim_newCal,y=V),col=3) +
  geom_point(aes(x=Vsim_newCalCheck,y=V),col=4) +
  geom_abline(intercept = 0,slope = 1) + ylim(vlim)
pVspruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Vsim,y=V),col=2) + 
  geom_point(aes(x=Vsim_newCal,y=V),col=3) +
  geom_point(aes(x=Vsim_newCalCheck,y=V),col=4) +
  geom_abline(intercept = 0,slope = 1)

pBA <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Gsim,y=G,shape=speciesID),col=2) + 
  geom_point(aes(x=Gsim_newCal,y=G,shape=speciesID),col=3) +
  geom_point(aes(x=Gsim_newCalCheck,y=G,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)
pBApine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Gsim,y=G),col=2) + 
  geom_point(aes(x=Gsim_newCal,y=G),col=3) +
  geom_point(aes(x=Gsim_newCalCheck,y=G,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)
pBAspruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Gsim,y=G),col=2) + 
  geom_point(aes(x=Gsim_newCal,y=G),col=3) +
  geom_point(aes(x=Gsim_newCalCheck,y=G,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)

pDW <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Dsim,y=DW,shape=speciesID),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=DW,shape=speciesID),col=3) +
  geom_point(aes(x=Dsim_newCalCheck,y=DW,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)
pDWpine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Dsim,y=DW),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=DW),col=3) +
  geom_point(aes(x=Dsim_newCalCheck,y=DW,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)
pDWspruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Dsim,y=DW),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=DW),col=3) +
  geom_point(aes(x=Dsim_newCalCheck,y=DW,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)

pDmean <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Dsim,y=Dmean,shape=speciesID),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=Dmean,shape=speciesID),col=3) +
  geom_point(aes(x=Dsim_newCalCheck,y=Dmean,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)
pDmeanPine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Dsim,y=Dmean),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=Dmean),col=3) +
  geom_point(aes(x=Dsim_newCalCheck,y=Dmean,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)
pDmeanSpruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Dsim,y=Dmean),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=Dmean),col=3) +
  geom_point(aes(x=Dsim_newCalCheck,y=Dmean,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)

pH <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Hsim,y=HW,shape=speciesID),col=2) + 
  geom_point(aes(x=Hsim_newCal,y=HW,shape=speciesID),col=3) +
  geom_point(aes(x=Hsim_newCalCheck,y=HW,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)
pHpine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Hsim,y=HW),col=2) + 
  geom_point(aes(x=Hsim_newCal,y=HW),col=3) +
  geom_point(aes(x=Hsim_newCalCheck,y=HW,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)
pHspruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Hsim,y=HW),col=2) + 
  geom_point(aes(x=Hsim_newCal,y=HW),col=3) +
  geom_point(aes(x=Hsim_newCalCheck,y=HW,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)

pN <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Nsim,y=N,shape=speciesID),col=2) + 
  geom_point(aes(x=Nsim_newCal,y=N,shape=speciesID),col=3) +
  geom_point(aes(x=Nsim_newCalCheck,y=N,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)
pNpine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Nsim,y=N),col=2) + 
  geom_point(aes(x=Nsim_newCal,y=N),col=3) +
  geom_point(aes(x=Nsim_newCalCheck,y=N,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)
pNspruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Nsim,y=N),col=2) + 
  geom_point(aes(x=Nsim_newCal,y=N),col=3) +
  geom_point(aes(x=Nsim_newCalCheck,y=N,shape=speciesID),col=4) +
  geom_abline(intercept = 0,slope = 1)


obsVars <- rep(NA,54)
varIDs <- c(11:13,17,30)
obsVars[varIDs] <- c("HW","Dmean","G","N","V")

nSites <- max(dataX$siteID)
plots <-  list()[1:nSites]

# siteX=3
# varX=11
for(siteX in 1:nSites){
  for(varX in varIDs){
    message(siteX)
    message(varX)
    plots[[siteX]][[varNames[varX]]] <- local({
      siteX <- siteX
      varX <- varX
      
      simX1 <- test$multiOut[siteX,,varX,1,1]
      simX2 <- test2$multiOut[siteX,,varX,1,1]
      simYears <- 1:length(simX2)
      prebOut <- data.table(sim1=simX1,sim2=simX2,simYears=simYears)
      colorX <- initPrebas$multiInitVar[siteX,1,1] + 1
      print(
        ggplot(dataX[siteID==siteX]) +
          geom_line(data=prebOut,mapping=aes(x=simYears,y=simX1),col=3) + 
          geom_line(data=prebOut,mapping=aes(x=simYears,y=simX2),col=4) + 
          geom_point(aes(x=yearSim, y=get(obsVars[varX])),col=colorX) + 
          ylab(NULL) + xlab("simulation year") +
          ggtitle(varNames[varX]))
    })
  }
}

save(plots,file="plots/prebasPlots.rdata")

pdf(file="plots/selectedSites.pdf")
siteX=5
ggp_all <- (plots[[siteX]]$BA + plots[[siteX]]$V) / (plots[[siteX]]$D + plots[[siteX]]$H + plots[[siteX]]$N) +    # Create grid of plots with title
  plot_annotation(title = paste0("site ",siteX)) & 
  theme(plot.title = element_text(hjust = 0.5))
print(ggp_all)

siteX=3
ggp_all <- (plots[[siteX]]$BA + plots[[siteX]]$V) / (plots[[siteX]]$D + plots[[siteX]]$H + plots[[siteX]]$N) +    # Create grid of plots with title
  plot_annotation(title = paste0("site ",siteX)) & 
  theme(plot.title = element_text(hjust = 0.5))
print(ggp_all)

siteX=35
ggp_all <- (plots[[siteX]]$BA + plots[[siteX]]$V) / (plots[[siteX]]$D + plots[[siteX]]$H + plots[[siteX]]$N) +    # Create grid of plots with title
  plot_annotation(title = paste0("site ",siteX)) & 
  theme(plot.title = element_text(hjust = 0.5))
print(ggp_all)
siteX=33
ggp_all <- (plots[[siteX]]$BA + plots[[siteX]]$V) / (plots[[siteX]]$D + plots[[siteX]]$H + plots[[siteX]]$N) +    # Create grid of plots with title
  plot_annotation(title = paste0("site ",siteX)) & 
  theme(plot.title = element_text(hjust = 0.5))
print(ggp_all)
dev.off()




pdf(file="plots/allSites.pdf")
ggp_all <- (pBA + pV) / (pDmean + pH + pN) +    # Create grid of plots with title
  plot_annotation(title = "allData") & 
  theme(plot.title = element_text(hjust = 0.5))
print(ggp_all)
ggp_all <- (pBApine + pVpine) / (pDmeanPine + pHpine + pNpine) +    # Create grid of plots with title
  plot_annotation(title = "pine") & 
  theme(plot.title = element_text(hjust = 0.5))
print(ggp_all)
ggp_all <- (pBAspruce + pVspruce) / (pDmeanSpruce + pHspruce + pNspruce) +    # Create grid of plots with title
  plot_annotation(title = "spruce") & 
  theme(plot.title = element_text(hjust = 0.5))
print(ggp_all)
for(siteX in 1:35){
  ggp_all <- (plots[[siteX]]$BA + plots[[siteX]]$V) / (plots[[siteX]]$D + plots[[siteX]]$H + plots[[siteX]]$N) +    # Create grid of plots with title
    plot_annotation(title = paste0("site ",siteX)) & 
    theme(plot.title = element_text(hjust = 0.5))
  print(ggp_all)
}
dev.off()



pdf(file="plots/UnmanagedForests.pdf")
for(siteX in unmanFor){
  ggp_all <- (plots[[siteX]]$BA + plots[[siteX]]$V) / (plots[[siteX]]$D + plots[[siteX]]$H + plots[[siteX]]$N) +    # Create grid of plots with title
    plot_annotation(title = paste0("site ",siteX)) & 
    theme(plot.title = element_text(hjust = 0.5))
  print(ggp_all)
}
dev.off()

pdf(file="plots/managedForests.pdf")
for(siteX in thinnedSites){
  ggp_all <- (plots[[siteX]]$BA + plots[[siteX]]$V) / (plots[[siteX]]$D + plots[[siteX]]$H + plots[[siteX]]$N) +    # Create grid of plots with title
    plot_annotation(title = paste0("site ",siteX)) & 
    theme(plot.title = element_text(hjust = 0.5))
  print(ggp_all)
}
dev.off()
