library(data.table)
library("readxl")
library(Rprebasso)
library(ggplot2)

###load data and model inputs
load("../data/dataX.rdata")
load("../data/initPrebas.rdata")
load("../data/initPrebas2.rdata")

###Run PREBAS and process output (start)
test <- multiPrebas(initPrebas)
test$multiOut[,,c(13,17,30),,2] <- test$multiOut[,,c(13,17,30),,1] + test$multiOut[,,c(13,17,30),,2]

test2 <- multiPrebas(initPrebas2)
test2$multiOut[,,c(13,17,30),,2] <- test2$multiOut[,,c(13,17,30),,1] + 
  test2$multiOut[,,c(13,17,30),,2]

varX=11
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
dataX[yearSim>0, Hsim:= simX]
simX <- test2$multiOut[indX]
dataX[yearSim>0, Hsim2:= simX]
varX=12
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
dataX[yearSim>0, Dsim:= simX]
simX <- test2$multiOut[indX]
dataX[yearSim>0, Dsim2:= simX]
varX=13
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
dataX[yearSim>0, Gsim:= simX]
simX <- test2$multiOut[indX]
dataX[yearSim>0, Gsim2:= simX]
varX=17
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
dataX[yearSim>0, Nsim:= simX]
simX <- test2$multiOut[indX]
dataX[yearSim>0, Nsim2:= simX]
varX=30
indX <- as.matrix(dataX[yearSim>0,.(siteID,yearSim,variable=varX,layer=1,statusInd)])
simX <- test$multiOut[indX]
dataX[yearSim>0, Vsim:= simX]
simX <- test2$multiOut[indX]
dataX[yearSim>0, Vsim2:= simX]
###Run PREBAS and process output (end)


####produce plots by site and variables
siteX <- 1   ####vary this between 1 and 35 to see other sites
varX=11
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l')
dataX[siteID==siteX & compnt==2,points(yearSim,Hsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Hsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,HW,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,HW,col=2,pch=4)]
lines(test2$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
dataX[siteID==siteX & compnt==2,points(yearSim,Hsim2,col=3,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Hsim2,col=3,pch=3)]
varX=30
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l')
dataX[siteID==siteX & compnt==2,points(yearSim,Vsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Vsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,V,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,V,col=2,pch=4)]
lines(test2$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
dataX[siteID==siteX & compnt==2,points(yearSim,Vsim2,col=3,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Vsim2,col=3,pch=3)]
varX=13
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l')
dataX[siteID==siteX & compnt==2,points(yearSim,Gsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Gsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,G,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,G,col=2,pch=4)]
lines(test2$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
dataX[siteID==siteX & compnt==2,points(yearSim,Gsim2,col=3,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Gsim2,col=3,pch=3)]
varX=12
plot(test$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l')
dataX[siteID==siteX & compnt==2,points(yearSim,Dsim,col=1,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Dsim,col=1,pch=3)]
dataX[siteID==siteX & compnt==2,points(yearSim,DW,col=2,pch=20)]
dataX[siteID==siteX & compnt==1,points(yearSim,DW,col=2,pch=4)]
lines(test2$multiOut[siteX,,varX,1,1],ylab = varNames[varX],xlab="year",type='l',col=3)
dataX[siteID==siteX & compnt==2,points(yearSim,Dsim2,col=3,pch=1)]
dataX[siteID==siteX & compnt==1,points(yearSim,Dsim2,col=3,pch=3)]

#####scatter plots with all data
ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Vsim,y=V),col=2) + 
  geom_point(aes(x=Vsim2,y=V),col=3) +
  geom_abline(intercept = 0,slope = 1)

ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Gsim,y=G),col=2) + 
  geom_point(aes(x=Gsim2,y=G),col=3) +
  geom_abline(intercept = 0,slope = 1)

ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Dsim,y=DW),col=2) + 
  geom_point(aes(x=Dsim2,y=DW),col=3) +
  geom_abline(intercept = 0,slope = 1)

ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Hsim,y=HW),col=2) + 
  geom_point(aes(x=Hsim2,y=HW),col=3) +
  geom_abline(intercept = 0,slope = 1)

ggplot(dataX[yearSim>0]) + 
  geom_point(aes(x=Nsim,y=N),col=2) + 
  geom_point(aes(x=Nsim2,y=N),col=3) +
  geom_abline(intercept = 0,slope = 1)

