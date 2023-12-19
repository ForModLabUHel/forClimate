## \file mottiprebas.py
## \brief Framework to run PREBAS and Motti under changing climate.
##
## One idea is to use Python as a glue to run PREBAS (i.e. R)
## and Motti (i.e. Pascal binary or shared library) interchangeably.
## The data exchange can be with files and Motti command line parameters.
##
## Examples how to call Motti as binary with python can be found
## for example in some customer projects. Using Pascal shared libraries
## is certainly trickier with no prior experience.
##
## \par Installation
## The following software must be present:
## -# Rprebasso: Download from GitHub and use the instructions in GitHub to install in R.
##    -# mottiprebas.py requires that Rprebasso package (i.e. PREBAS) is installed in R.
## -# forClimate: Download from GitHub.
## -# Python: Tested with Python 3.10 but any "close enough" version of Python 3.x should do.
## -# R: Tested with Rstudio Version 2023.09.0+463 (2023.09.0+463) but any "close enough" R distribition should do
## -# Create Python virtual environment:
##    -# Install with `pip` rpy2, numpy and pandas packages.
##    -# pip install numpy pandas rpy2
##
## \par Run mottiprebas.py
## Start the Python virtual environment, go to forClimate directory and type `python mottiprebas.py`
## Currently mottiprebas.py repeats the demonstration in *exampleFunctionDelta.r*
## and saves the results in RData file.
import numpy as np
import pandas as pd
# rpy2 is the glue between Python and R
import rpy2
# r is the handler to R interface
from rpy2.robjects import r
# Create R like objects from Python and vice versa.
# It seems that after `activate` the "Python magic" happens behind the screen.
from rpy2.robjects import numpy2ri
numpy2ri.activate()
# Motti Growth coefficients (i.e. the results to Motti)  
# Data frame column names
# Site Info Table
# Default values [1,1,3, 160, 0, 0, 20, 413.,0.45, 0.118] or c(NA,NA,3,160,0,0,20,nLayers,3,413,0.45,0.118)
site_info_cols = ["SiteID","climID","SiteType", "SWinit (initial soil water)", "CWinit (initial crown water)", "SOGinit (initial snow on ground)",\
                  "Sinit (initial temperature acclimation state)", "Nlayers", "Nspecies", "SoilDepth", "Effective field capacity", "Permanent wilthing point"]
# Initial Variables (descriptive)
# (nSite x 7 x nLayer array)
# SpeciesID (a number corresponding to the species parameter values of pPRELES columns), Age (years), average height of the layer (H, m),
# average diameter at breast height of the layer (D, cm), basal area of the layer (BA, m2 ha-1), average height of the crown base of the layer (Hc, m).
# 8th column is updated automatically to Ac
init_var_cols = ["SpeciesID","Age(years)","H(m)","D(cm)","BA(m2ha-1)","Hc(m)","Ac(prebas_ex_officio)"]
# Motti results, coefficients from the results
motti_coeffient_cols = ["dGrowth5Mean","dH5Mean","dD5Mean"]
layers = "Layers"
# Load and source necessary files. dGrowthPrebas.r contains
# the PREBAS function dGrowthPrebas that will compute the deltas
# of interesting forest characteristics (biomass, dominant height etc).
# inputDataDeltaexample.rda contains sample input data for PREBAS.
# Replace sample data with real data.
r.load("data/inputDataDeltaexample.rda")
# The PREBAS package must be installed in R.
r.library("Rprebasso")
# Function to run PREBAS twice to produce deltas of certain forest characteristics of interest
r.source("Rsrc/dGrowthPrebas.r")

initVar = r['initVar']
siteInfo = r['siteInfo']
PARtran = r['PARtran']
PARx = r['PARtran'] + 20
CO2tran = r['CO2tran']
#Note the R and Pythonic addition with matrices
CO2x = r['CO2tran'].ro + 50
TAirtran = r['TAirtran']
TAirx = r['TAirtran'] + 7
VPDtran = r['VPDtran']
Preciptran = r['Preciptran']

def mottiprebas(year,siteInfo,initVar):
    print("BEGIN")
    # Call dGrowthPrebas
    res = r['dGrowthPrebas'](year,siteInfo,initVar,
        PARtran,PARx,
        TAirtran,TAirx,
        Preciptran,Preciptran,
        VPDtran,VPDtran,
        CO2tran,CO2x)
    #Print with  R  print
    print("PRINT R, FIRST ITEM")
    print("SHAPE", r.dim(res[0]))
    r.print(res[0][0][:,0])
    print("PRINTED R")
    #To see the same in python matrix transposes T are needed
    resT = res[0].T
    resTT = [x.T for x in resT]
    print("PRINT PYTHON, FIRST ITEM")
    print("SHAPE",np.shape(res[0]),'-->',np.shape(resT))
    print(resTT[0][0])
    print("PRINTED PYTHON")
    return res

if __name__ == "__main__":
    res = mottiprebas(5,siteInfo,initVar)
    #Save results to R data file
    #Assign `res`to R environment
    r.assign("PrebasRes",res)
    #Then save data
    print("SAVE RESULTS")
    #All results as RData file 
    r.save("PrebasRes",file='PrebasRes.RData')
    #For testing purposes save initVar (first site) and SiteInfo
    dfInitVar = pd.DataFrame(initVar[0].T)
    dfInitVar.columns = init_var_cols
    dfInitVar.index.name = layers
    dfInitVar.to_excel('PrebasInitVar.xlsx')
    dfSiteInfo = pd.DataFrame(siteInfo)
    dfSiteInfo.columns = site_info_cols
    dfSiteInfo.to_excel('PrebasSiteInfo.xlsx')
    #Motti input data, coefficients from results
    dG = res[0]
    dH = res[1]
    dD = res[2]
    dG0 = dG[0]
    dH0 = dH[0]
    dD0 = dD[0]
    dGmean = np.mean(dG0.T,axis=1)
    dHmean = np.mean(dH0.T,axis=1)
    dDmean = np.mean(dD0.T,axis=1)
    dfdGmean = pd.DataFrame(dGmean)
    dfHmean = pd.DataFrame(dHmean)
    dfDmean = pd.DataFrame(dDmean)
    dfmotti = pd.concat([dfdGmean,dfHmean,dfDmean],axis=1,ignore_index=True)
    dfmotti.columns = motti_coeffient_cols
    dfmotti.index.name=layers
    dfmotti.to_excel("MottiCoeffients.xlsx")
    print("DONE")
