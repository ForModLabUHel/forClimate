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
                  "Sinit (initial temperature acclimation state)", "NLayers", "NSpecies", "SoilDepth", "Effective field capacity", "Permanent wilthing point"]
# Initial Variables (descriptive)
# (nSite x 7 x nLayer array)
# SpeciesID (a number corresponding to the species parameter values of pPRELES columns), Age (years), average height of the layer (H, m),
# average diameter at breast height of the layer (D, cm), basal area of the layer (BA, m2 ha-1), average height of the crown base of the layer (Hc, m).
# 8th column is updated automatically to Ac
init_var_cols = ["SpeciesID","Age(years)","H(m)","D(cm)","BA(m2ha-1)","Hc(m)","Ac(prebas_ex_officio)"]
# Motti results, coefficients from the results
motti_coeffient_cols = ["dGrowth_5YearMean","dH_5YearMean","dD_5YearMean"]
layers = "Layers/ModelTrees"
#SIte type index in Motti stand file
SITE_TYPE_INDEX = 22
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

def read_motti_site_info(f:str)->float:
    """
    Read Motti stand file and return site type.
    Currently for one site only
    @param f Site file
    @return Site type
    @retval stype Site type as float 
    """
    df = pd.read_csv(f,engine='python',sep='\s+',nrows=30,names=['Index','Value'],header=0)
    stype = df[df['Index']==SITE_TYPE_INDEX].iloc[0,1]
    return stype

def read_motti_model_tree_info(f:str):
    """
    Read Motti model tree info and return dataframe of model tree data for Prebas
    @param f Motti model tree info file
    @return Data frame of model tree info, Number of model trees, number of tree species
    """
    df = pd.read_csv(f,engine='python',sep='\s+',nrows=30,names=['INDEX1','INDEX2','INDEX3','VALUE'])
    dfg = df.groupby(['INDEX3'])
    ngroups = dfg.ngroups
    lss = []
    for n in range(1,ngroups+1):
        g = dfg.get_group(n)
        g.reset_index()
        s = list(g['VALUE'])
        lss.append(s)
    df_tree_info = pd.DataFrame(lss)
    #Hc to  be fixed when available 
    df_tree_info['Hc'] = 0.0
    df_tree_info['Ac'] = 0.0
    df_tree_info.columns = init_var_cols
    nspecies = len(set(df_tree_info['SpeciesID']))
    return (df_tree_info,ngroups,nspecies)

def prebas_input(site_info:str,model_tree_info:str):
    """
    Create Prebas input data from Motti output files
    @param site_finfo Motti stand level output file
    @param model_tree_info Motti tree level output file
    @return Prebas dataframes for Site info and tree/layer level Initial variables
    """
    site_type =  read_motti_site_info(site_info)
    (df_tree_info,n_model_trees,nspecies) =  read_motti_model_tree_info(model_tree_info)
    df_site_info = pd.DataFrame(data=0,index=[0],columns=site_info_cols)
    df_site_info['SiteType'] = site_type
    df_site_info['NLayers'] = n_model_trees
    df_site_info['NSpecies'] = nspecies
    return (df_site_info,df_tree_info)

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
    #For testing purposes save initVar (first site) and SiteInfo
    dfemptyrow = pd.DataFrame([])
    dfInitVar = pd.DataFrame(initVar[0].T)
    dfInitVar.columns = init_var_cols
    dfInitVar.index.name = layers
    dfSiteInfo = pd.DataFrame(siteInfo)
    dfSiteInfo.columns = site_info_cols
    dfmotticoeff = pd.concat([dfInitVar,dfSiteInfo,dfmotti],keys=['InitVar','SiteInfo','MottiCoeff'])
    dfmotticoeff.to_excel("MottiCoefficients.xlsx")
    dfmotticoeff.to_csv("MottiCoefficients.txt",sep=" ")
    print("DONE")
