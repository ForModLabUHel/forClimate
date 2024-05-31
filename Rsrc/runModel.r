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
####for new parameter sets
initPrebas_newCal$ClCut[thinnedSites] <- 1
initPrebas_newCal$inDclct[thinnedSites] <- 9999
initPrebas_newCal$inAclct[thinnedSites] <- 9999
initPrebas2_newCal$ClCut[thinnedSites] <- 1
initPrebas2_newCal$inDclct[thinnedSites] <- 9999
initPrebas2_newCal$inAclct[thinnedSites] <- 9999
initPrebas2_newCal$mortMod <- initPrebas_newCal$mortMod <- c(1,2)


###Run PREBAS and process output (start)
test <- multiPrebas(initPrebas)
test$multiOut[,,c(13,17,30),,2] <- test$multiOut[,,c(13,17,30),,1] + test$multiOut[,,c(13,17,30),,2]

test2 <- multiPrebas(initPrebas2)
test2$multiOut[,,c(13,17,30),,2] <- test2$multiOut[,,c(13,17,30),,1] + 
  test2$multiOut[,,c(13,17,30),,2]


testNewPar <- multiPrebas(initPrebas_newCal)
testNewPar$multiOut[,,c(13,17,30),,2] <- testNewPar$multiOut[,,c(13,17,30),,1] + test$multiOut[,,c(13,17,30),,2]

testNewPar2 <- multiPrebas(initPrebas2_newCal)
testNewPar2$multiOut[,,c(13,17,30),,2] <- testNewPar2$multiOut[,,c(13,17,30),,1] + 
  testNewPar2$multiOut[,,c(13,17,30),,2]

####processng the outputs (start)
varX=11
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
simXnewpar <- testNewPar$multiOut[indX]
dataX[yearSim>0, Hsim:= simX]
dataX[yearSim>0, Hsim_newCal:=simXnewpar]
simX <- test2$multiOut[indX]
simXnewpar <- testNewPar2$multiOut[indX]
dataX[yearSim>0, Hsim2:= simX]
dataX[yearSim>0, Hsim2_newCal:= simXnewpar]
varX=12
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
simXnewpar <- testNewPar$multiOut[indX]
dataX[yearSim>0, Dsim:= simX]
dataX[yearSim>0, Dsim_newCal:=simXnewpar]
simX <- test2$multiOut[indX]
simXnewpar <- testNewPar2$multiOut[indX]
dataX[yearSim>0, Dsim2:= simX]
dataX[yearSim>0, Dsim2_newCal:= simXnewpar]
varX=13
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
simXnewpar <- testNewPar$multiOut[indX]
dataX[yearSim>0, Gsim:= simX]
dataX[yearSim>0, Gsim_newCal:=simXnewpar]
simX <- test2$multiOut[indX]
simXnewpar <- testNewPar2$multiOut[indX]
dataX[yearSim>0, Gsim2:= simX]
dataX[yearSim>0, Gsim2_newCal:= simXnewpar]
varX=17
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
simXnewpar <- testNewPar$multiOut[indX]
dataX[yearSim>0, Nsim:= simX]
dataX[yearSim>0, Nsim_newCal:=simXnewpar]
simX <- test2$multiOut[indX]
simXnewpar <- testNewPar2$multiOut[indX]
dataX[yearSim>0, Nsim2:= simX]
dataX[yearSim>0, Nsim2_newCal:= simXnewpar]
varX=30
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
simXnewpar <- testNewPar$multiOut[indX]
dataX[yearSim>0, Vsim:= simX]
dataX[yearSim>0, Vsim_newCal:=simXnewpar]
simX <- test2$multiOut[indX]
simXnewpar <- testNewPar2$multiOut[indX]
dataX[yearSim>0, Vsim2:= simX]
dataX[yearSim>0, Vsim2_newCal:= simXnewpar]
dataX$speciesID <- as.factor(dataX$speciesID)
####processng the outputs (start)
###Run PREBAS and process output (end)


####produce plots by site and variables
siteX <- 5 #(35,33,5,3)   ####vary this between 1 and 35 to see other sites
varX=11
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',ylim=range(dataX[siteID==siteX & compnt==2,.(Hsim,HW)],test$multiOut[siteX,,varX,1,1],na.rm=T))
dataX[siteID==siteX & compnt==2,points(yearSim,Hsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Hsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,HW,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,HW,col=2,pch=4)]
lines(testNewPar$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
dataX[siteID==siteX & compnt==2,points(yearSim,Hsim_newCal,col=3,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Hsim_newCal,col=3,pch=3)]
varX=30
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',ylim=range(dataX[siteID==siteX & compnt==2,.(Vsim,V)],test$multiOut[siteX,,varX,1,1],na.rm=T))
dataX[siteID==siteX & compnt==2,points(yearSim,Vsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Vsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,V,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,V,col=2,pch=4)]
lines(test2$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
dataX[siteID==siteX & compnt==2,points(yearSim,Vsim2,col=3,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Vsim2,col=3,pch=3)]
varX=13
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',ylim=range(dataX[siteID==siteX & compnt==2,.(Gsim,G)],test$multiOut[siteX,,varX,1,1],na.rm=T))
dataX[siteID==siteX & compnt==2,points(yearSim,Gsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Gsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,G,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,G,col=2,pch=4)]
lines(testNewPar$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
dataX[siteID==siteX & compnt==2,points(yearSim,Gsim_newCal,col=3,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Gsim_newCal,col=3,pch=3)]
varX=12
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',ylim=range(dataX[siteID==siteX & compnt==2,.(Dsim,DW)],test$multiOut[siteX,,varX,1,1],na.rm=T))
dataX[siteID==siteX & compnt==2,points(yearSim,Dsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Dsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,DW,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,DW,col=2,pch=4)]
lines(testNewPar$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
dataX[siteID==siteX & compnt==2,points(yearSim,Dsim_newCal,col=3,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Dsim_newCal,col=3,pch=3)]
varX=17
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',ylim=range(dataX[siteID==siteX & compnt==2,.(Nsim,N)],test$multiOut[siteX,,varX,1,1],na.rm=T))
dataX[siteID==siteX & compnt==2,points(yearSim,Nsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Nsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,N,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,N,col=2,pch=4)]
lines(testNewPar$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
dataX[siteID==siteX & compnt==2,points(yearSim,Nsim_newCal,col=3,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Nsim2_newCal,col=3,pch=3)]

#####scatter plots with all data
vlim <- range(dataX[,.(Vsim,V,Vsim_newCal,Vsim2,Vsim2_newCal)],na.rm=T)
pV <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Vsim,y=V,shape=speciesID),col=2) + 
  geom_point(aes(x=Vsim_newCal,y=V,shape=speciesID),col=3) +
  geom_abline(intercept = 0,slope = 1) + ylim(vlim)
pVpine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Vsim,y=V),col=2) + 
  geom_point(aes(x=Vsim_newCal,y=V),col=3) +
  geom_abline(intercept = 0,slope = 1) + ylim(vlim)
pVspruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Vsim,y=V),col=2) + 
  geom_point(aes(x=Vsim_newCal,y=V),col=3) +
  geom_abline(intercept = 0,slope = 1)

pBA <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Gsim,y=G,shape=speciesID),col=2) + 
  geom_point(aes(x=Gsim_newCal,y=G,shape=speciesID),col=3) +
  geom_abline(intercept = 0,slope = 1)
pBApine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Gsim,y=G),col=2) + 
  geom_point(aes(x=Gsim_newCal,y=G),col=3) +
  geom_abline(intercept = 0,slope = 1)
pBAspruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Gsim,y=G),col=2) + 
  geom_point(aes(x=Gsim_newCal,y=G),col=3) +
  geom_abline(intercept = 0,slope = 1)

pDW <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Dsim,y=DW,shape=speciesID),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=DW,shape=speciesID),col=3) +
  geom_abline(intercept = 0,slope = 1)
pDWpine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Dsim,y=DW),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=DW),col=3) +
  geom_abline(intercept = 0,slope = 1)
pDWspruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Dsim,y=DW),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=DW),col=3) +
  geom_abline(intercept = 0,slope = 1)

pDmean <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Dsim,y=Dmean,shape=speciesID),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=Dmean,shape=speciesID),col=3) +
  geom_abline(intercept = 0,slope = 1)
pDmeanPine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Dsim,y=Dmean),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=Dmean),col=3) +
  geom_abline(intercept = 0,slope = 1)
pDmeanSpruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Dsim,y=Dmean),col=2) + 
  geom_point(aes(x=Dsim_newCal,y=Dmean),col=3) +
  geom_abline(intercept = 0,slope = 1)

pH <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Hsim,y=HW,shape=speciesID),col=2) + 
  geom_point(aes(x=Hsim_newCal,y=HW,shape=speciesID),col=3) +
  geom_abline(intercept = 0,slope = 1)
pHpine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Hsim,y=HW),col=2) + 
  geom_point(aes(x=Hsim_newCal,y=HW),col=3) +
  geom_abline(intercept = 0,slope = 1)
pHspruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Hsim,y=HW),col=2) + 
  geom_point(aes(x=Hsim_newCal,y=HW),col=3) +
  geom_abline(intercept = 0,slope = 1)

pN <- ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Nsim,y=N,shape=speciesID),col=2) + 
  geom_point(aes(x=Nsim_newCal,y=N,shape=speciesID),col=3) +
  geom_abline(intercept = 0,slope = 1)
pNpine <- ggplot(dataX[yearSim>0 & speciesID==1]) + 
  geom_point(aes(x=Nsim,y=N),col=2) + 
  geom_point(aes(x=Nsim_newCal,y=N),col=3) +
  geom_abline(intercept = 0,slope = 1)
pNspruce <- ggplot(dataX[yearSim>0 & speciesID==2]) + 
  geom_point(aes(x=Nsim,y=N),col=2) + 
  geom_point(aes(x=Nsim_newCal,y=N),col=3) +
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
