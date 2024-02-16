import os
import subprocess
import pathlib
import argparse
import numpy as np
import pandas as pd
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

# Load and source necessary files. dGrowthPrebas.r contains
# the PREBAS function dGrowthPrebas that will compute the deltas
# of interesting forest characteristics (biomass, dominant height etc).
# inputDataDeltaexample.rda contains sample input data for PREBAS.
# Replace sample data with real data.
r.load("data/inputDataDeltaexample.rda")
# The PREBAS package must be installed in R.
r.library("Rprebasso")
# Function to run PREBAS twice to produce deltas of certain forest characteristics of interest
# dGrowthPrebas is in forClimate project
r.source("Rsrc/dGrowthPrebas.r")

#Data variables available for Prebas after 'r.load() above'
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
VPDx = r['VPDtran']
Preciptran = r['Preciptran']
Precipx = r['Preciptran']

def convert_to_floatmatrix(obj):
    (rows,cols)=np.shape(obj) 
    return rpy2.robjects.r.matrix(obj,nrow=rows,ncol=cols)

def convert_to_floatvector(obj):
    return  rpy2.robjects.vectors.FloatVector(obj)

#Single site example data
siteX=3
climID=2

#siteInfo numpy array -> Python indexing
siteInfo_siteX=siteInfo[siteX-1,:]
siteInfo_siteX_r = convert_to_floatvector(siteInfo_siteX)
#3D array
initVar_siteX=initVar[siteX-1,:,:]
initVar_siteX_r=convert_to_floatmatrix(initVar_siteX)
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
CO2_siteX = CO2tran.rx(climID,True)
newCO2_siteX = CO2x.rx(climID,True)
