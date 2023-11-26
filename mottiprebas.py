## \file mottiprebas.py
## \brief Framwork to run PREBAS and Motti under changing climate.
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
## -# PREBAS: Download from GitHub and use the instructions for GitHub installation in R.
##    -# mottiprebas.py requires that Rprebasso package (i.e. PREBAS) is installed in R.
## -# forClimate: Download from GitHub.
## -# Python: Tested with Python 3.10 but any "close by version" should do.
## -# Create Python virtual environment:
##    -# Install with `pip` rpy2, numpy and pandas packages.
##    -# pip install numpy pandas rpy2
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
# Function to run PREBAS twice to produce deltas of ceratin forest characteristcs
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

print("BEGIN")
# Call dGrowthPrebas
res = r['dGrowthPrebas'](20,siteInfo,initVar,
                         PARtran,PARx,
                         TAirtran,TAirx,
                         Preciptran,Preciptran,
                         VPDtran,VPDtran,
                         CO2tran,CO2x)
#Print with  R  print
print("PRINT AS R")
r.print(res[0][0][:,0])
print("PRINTED R")
#To see the same in python matrix transposes T are need 
resT = res[0].T
resTT = [x.T for x in resT]
print("PRINT PYTHON")
print(resTT[0][0])
print("PRINTED PYTHON")
#Save results to R data file
r.assign("PrebasRes",res)
r.save("PrebasRes",file='PrebasRes.RData')
print("DONE")
