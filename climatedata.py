import os
import subprocess
import pathlib
import argparse
import numpy as np
import pandas as pd
import climateconfig
import sampling as samp
#R_HOME for R, uncomment for Mac and Linux
RHOME='/Program Files/R/R-4.3.2/'
os.environ['R_HOME'] = RHOME
# MottiWB RUNTIME LOCATION including all necessary shared libraries
# Change as needed using '/' for directory path also  in Windows
MOTTI_LOCATION=pathlib.Path("/Apps/MottiPrebas/MottiPrebas/")

# rpy2 is the glue between Python and R
import rpy2
# r is the handler to R interface
from rpy2.robjects import r
# Create R like objects from Python and vice versa.
# It seems that after `activate` the "Python magic" happens behind the screen.
from rpy2.robjects import numpy2ri
numpy2ri.activate()

# Load and source necessary files.
###
# inputDataDeltaexample.rda contains sample input data for PREBAS.
# Most notably it has current weather data for climatic regions in Finland
r.load("data/inputDataDeltaexample.rda")
### future weather - load the data for the selected climate scenario
# Available values: "data/tranCanESM2.rcp45.rda", "data/tranCanESM2.rcp85.rda",
#"data/tranCNRM.rcp45.rda" and "data/tranCNRM.rcp85.rda"
r.load(climateconfig.climate_scenarios[climateconfig.scenarioid-1]) 

# The PREBAS package must be installed in R to run dGrowthPrebas
r.library("Rprebasso")
# Function to run PREBAS twice to produce deltas of certain forest characteristics of interest
# dGrowthPrebas is in forClimate project
r.source("Rsrc/dGrowthPrebas.r")

#Data variables available for Prebas after 'r.load() above'
initVar = r['initVar']
siteInfo = r['siteInfo']
#Current climate weather
PARtran = r['PARtran']
CO2tran = r['CO2tran']
TAirtran = r['TAirtran']
VPDtran = r['VPDtran']
Preciptran = r['Preciptran']
#Climate change
PARx = r['PARx']
CO2x = r['CO2x']
TAirx = r['TAirx']
VPDx = r['VPDx']
Precipx = r['Precipx']

def convert_to_floatmatrix(obj):
    (rows,cols)=np.shape(obj) 
    return rpy2.robjects.r.matrix(obj,nrow=rows,ncol=cols)

def convert_to_floatvector(obj):
    return  rpy2.robjects.vectors.FloatVector(obj)

#Single site selection for Prebas example data.
#Motti will provide its own site data.
siteX=3
#Select climatic region in Finland
climID=climateconfig.climateid

#Prebas site data. Motti will use its own site data
#siteInfo numpy array -> Python indexing
siteInfo_siteX=siteInfo[siteX-1,:]
siteInfo_siteX_r = convert_to_floatvector(siteInfo_siteX)
#3D array
initVar_siteX=initVar[siteX-1,:,:]
initVar_siteX_r=convert_to_floatmatrix(initVar_siteX)

#Weather data and selected climate scenario 
#PAR
PAR_siteX = PARtran[climID-1,:]
PAR_siteX_r =  convert_to_floatvector(PAR_siteX)
newPAR_siteX = PARx[climID-1,:]
newPAR_siteX_r =  convert_to_floatvector(newPAR_siteX)
#Precip
Precip_siteX = Preciptran[climID-1,:]
Precip_siteX_r =  convert_to_floatvector(Precip_siteX)
newPrecip_siteX = Precipx[climID-1,:]
newPrecip_siteX_r =  convert_to_floatvector(newPrecip_siteX)
#TAir
TAir_siteX = TAirtran[climID-1,:]
TAir_siteX_r =  convert_to_floatvector(TAir_siteX)
newTAir_siteX = TAirx[climID-1,:]
newTAir_siteX_r =  convert_to_floatvector(newTAir_siteX)
#VPD
VPD_siteX = VPDtran[climID-1,:]
VPD_siteX_r = convert_to_floatvector(VPD_siteX)
newVPD_siteX = VPDx[climID-1,:]
newVPD_siteX_r = convert_to_floatvector(newVPD_siteX)
#Slicing via rx -> R indexing
CO2_siteX_r = CO2tran.rx(climID,True)
newCO2_siteX = CO2x[climID-1,:]
newCO2_siteX_r = convert_to_floatvector(newCO2_siteX)
