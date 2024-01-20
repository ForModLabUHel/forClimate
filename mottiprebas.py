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
##    -# Install with `pip` rpy2, numpy, openpyxl and pandas packages:
##    -# pip install numpy pandas openpyxl rpy2
##
## \par Run mottiprebas.py
## Start the Python virtual environment, go to forClimate directory and type `python mottiprebas.py`
## Currently mottiprebas.py repeats the demonstration in *exampleFunctionDelta.r*
## and saves the results in RData file.

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

# Motti Growth coefficients (i.e. the results to Motti)  
# Data frame column names
# Site Info Table
# Default values [1,1,3, 160, 0, 0, 20, 413.,0.45, 0.118] or c(NA,NA,3,160,0,0,20,nLayers,3,413,0.45,0.118)
site_info_cols = ["SiteID","climID","SiteType", "SWinit (initial soil water)", "CWinit (initial crown water)", "SOGinit (initial snow on ground)",\
                  "Sinit (initial temperature acclimation state)", "NLayers", "NSpecies", "SoilDepth", "Effective field capacity",\
                  "Permanent wilthing point"]
# Initial Variables (descriptive)
# (nSite x 7 x nLayer array)
# SpeciesID (a number corresponding to the species parameter values of pPRELES columns), Age (years), average height of the layer (H, m),
# average diameter at breast height of the layer (D, cm), basal area of the layer (BA, m2 ha-1), average height of the crown base of the layer (Hc, m).
# 8th column is updated automatically to Ac
init_var_cols = ["SpeciesID","Age(years)","H(m)","D(cm)","BA(m2ha-1)","Hc(m)","Ac(prebas_ex_officio)"]
# Motti results, coefficients from the results
motti_coeffient_cols = ["dGrowth_5YearMean","dH_5YearMean","dD_5YearMean"]
layers = "Layers/ModelTrees"
#Site type index in Motti stand file
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
Preciptran = r['Preciptran']

def create_output_file_name(file_name:str,year:int):
    """
    Create new output file name by appending current simualtion year to original file name
    @param file_name Full path of the original output file name
    @param year Current simulation years
    @return New file name with 'year' appended to the stem of the 'file_name'
    @retval new_file_name New file name as string
    """
    p=pathlib.Path(file_name)
    stem=p.stem
    parent=p.parent
    suffix=p.suffix
    new_file_name = parent.joinpath(pathlib.Path(stem+'_'+str(year))).joinpath(pathlib.Path(suffix))
    return str(new_file_name)

def motti_init(motti_init:str,stand_data_out:str,prebas_out:str):
    """
    The first MOTTI initialization run before simulation
    @param motti_init the PREINIT file for MOTTI
    @param stand_data_out The stand data output file and input data for Prebas
    @param prebas_out The output tree level data and input data for Prebas
    """
    print("INIT BEGIN")
    subprocess.run([str(MOTTI_LOCATION.joinpath('mottiwb.exe')),'PREBAS','INISTATE',
                    '-in',motti_init,'-out',stand_data_out,'-outprbs',prebas_out],
                    capture_output=True,text=True)
    print("INIT DONE")
 
def test_motti_growth_command_line():
    #Motti growth
    print("GROWTH BEGIN")
    subprocess.run([str(motti_location.joinpath('mottiwb.exe')),'PREBAS','-simulate','5',
                    '-in',str(pathlib.Path('prebasSimu/stand0.txt')),
                    '-out',str(pathlib.Path('prebasSimu/stand1.txt')),
                    '-outprbs',str(pathlib.Path('prebasSimu/prebasPara1.txt'))],
                    cwd=str(motti_location),capture_output=True,text=True)
    print("GROWTH DONE")

def test_mottiprebas(site_info,init_var):
    res = mottiprebas(5,site_info,init_var)
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
    dfmotti.to_csv("MottiCoefficients.txt",sep=" ")
    dfmotti.to_excel("MottiCoefficients.xlsx")
    #For testing purposes save initVar (first site) and SiteInfo
    dfemptyrow = pd.DataFrame([])
    dfInitVar = pd.DataFrame(initVar[0].T)
    dfInitVar.columns = init_var_cols
    dfInitVar.index.name = layers
    dfSiteInfo = pd.DataFrame(siteInfo)
    dfSiteInfo.columns = site_info_cols
    dfmotticoeff = pd.concat([dfInitVar,dfSiteInfo,dfmotti],keys=['InitVar','SiteInfo','MottiCoeff'])
    dfmotticoeff.to_excel("MottPrebas.xlsx")  
    print("DONE")

def read_motti_site_type(f:str)->float:
    """
    Read Motti stand file and return site type.
    @note Currently for one site only
    @param f Site file
    @return Site type
    @retval stype Site type as float 
    """
    df = pd.read_csv(f,engine='python',sep='\s+',nrows=30,decimal=',',names=['Index','Value'],header=0)
    stype = df[df['Index']==SITE_TYPE_INDEX].iloc[0,1]
    return stype

def read_motti_model_tree_info(f:str):
    """
    Read Motti model tree/respresentetive trees info and return dataframe of model tree data for Prebas
    @note Currently assuming one stand and one tree species
    @param f Motti model tree info file
    @return Data frame of model tree info, Number of model trees, number of tree species
    """
    df = pd.read_csv(f,engine='python',sep='\s+',nrows=30,decimal=',',names=['INDEX1','INDEX2','INDEX3','VALUE'])
    dfg = df.groupby(['INDEX3'])
    ngroups = dfg.ngroups
    lss = []
    for n in range(1,ngroups+1):
        g = dfg.get_group(n)
        g.reset_index()
        s = list(g['VALUE'])
        lss.append(s)
    print(lss[0])
    df_tree_info = pd.DataFrame(lss)
    df_tree_info['Ac'] = 0.0
    df_tree_info.columns = init_var_cols
    nspecies = len(set(df_tree_info['SpeciesID']))
    return (df_tree_info,ngroups,nspecies)

def prebas_input(site_info:str,model_tree_info:str):
    """
    Create Prebas input data from Motti output files
    @param site_info Motti stand level output file
    @param model_tree_info Motti tree level output file
    @return Prebas dataframes for Site info and tree/layer level Initial variables
    """
    site_type =  read_motti_site_type(site_info)
    print(site_type)
    (df_tree_info,n_model_trees,nspecies) =  read_motti_model_tree_info(model_tree_info)
    df_site_info = pd.DataFrame(data=0,index=[0],columns=site_info_cols)
    df_site_info['SiteType'] = site_type
    df_site_info['NLayers'] = n_model_trees
    df_site_info['NSpecies'] = nspecies
    return (df_site_info,df_tree_info)

def dgrowthprebas(year,siteInfo,initVar):
    print("BEGIN")
    # Call dGrowthPrebas
    print("SITEINFO")
    print(siteInfo)
    print("INITVAR")
    print(initVar)
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
    parser = argparse.ArgumentParser()
    parser.add_argument("-y","--years",dest="y",type=int,required=True,help="Total simulation years")
    parser.add_argument("-i","--interval",dest="i",type=int,default=5,help="Prebas simulation years (interval), default 5 years")
    parser.add_argument("-d","--initdata",dest="d",type=str,required=True,help="Read Motti initial data file")
    parser.add_argument("-s","--stand",dest="s", type=str,required=True,help="Motti stand output file (full path)")
    parser.add_argument("-p","--prebas",dest="p",type=str,required=True,help="Prebas data file (full path)")
    args = parser.parse_args()
    
    motti_init(args.d,args.s,args.p)

    current_stand_file = args.s
    current_prebas_file = args.p
    for year in range(args.i,args.y+args.i,args.i):
        (df_site_info,df_tree_info)= prebas_input(current_stand_file,current_prebas_file)
        print(df_site_info)
        print(df_tree_info)
        site_info_array = df_site_info.to_numpy()
        #R and python have different views to matrices
        #Transposse Python matrix to get R matrix
        tree_info_array = df_tree_info.T.to_numpy()
        #Run dGrowthPrebas
        #res = dgrowthprebas(args.i,site_info_array,tree_info_array)
        #Write the results 'res' to Prebas coeffients file
        #Update 'current_stand_file' and 'current_prebas_file'  
        #Run MOTTI and repeat
        #Prebas testing purposes
        print("DGROWTH ALL SITES")
        res = dgrowthprebas(5,siteInfo,initVar)
        print("DGROWTH ONE SITE")
        res1 = dgrowthprebas(5,siteInfo[0],initVar[0])
        print("DONE")
