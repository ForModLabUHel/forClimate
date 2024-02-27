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
import re
import subprocess
import pathlib
import argparse
import numpy as np
import pandas as pd

#R_HOME for R for Windows (comment out for Mac and Linux)
RHOME='/Program Files/R/R-4.3.2/'
os.environ['R_HOME'] = RHOME
#MottiWB RUNTIME LOCATION including all necessary shared libraries
#Change as needed using '/' for directory path also  in Windows
MOTTI_LOCATION=pathlib.Path("/Apps/MottiPrebas/MottiPrebas/")
#Motti workbench executable name
MOTTIWB='mottiwb.exe'
#Decimal point used in mottiwb depends on locale. 
DECIMALMARKER='.'

# rpy2 is the glue between Python and R
import rpy2
# r is the handler to R interface
from rpy2.robjects import r
# Create R like objects from Python and vice versa.
from rpy2.robjects import numpy2ri
numpy2ri.activate()

# The PREBAS package must be installed in R.
r.library("Rprebasso")
# Function to run PREBAS twice to produce deltas of certain forest characteristics of interest
# dGrowthPrebas is in forClimate project
r.source("Rsrc/dGrowthPrebas.r")
# Load and source necessary weather data files.
# Replace sample data with real data.
import demodata as dd

#Convert dataframes to vectors or 2D arrays
from rfunc import convert_r

# Data frame column names
# Site Info Table
# Default values c(1,2,3,160,0,0,20,nLayers,3,413,0.45,0.118)
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


def create_new_file_name(file_name:str,year):
    """
    Create new output file name by appending current simualtion year to original file name
    @param file_name Full path of the original output file name
    @param year Current simulation years or some other description 
    @return New file name with 'year' appended to the stem of the 'file_name'
    @retval new_file_name New file name as string
    """
    p=pathlib.Path(file_name)
    stem=p.stem
    parent=p.parent
    suffix=p.suffix
    new_file_name = parent.joinpath(pathlib.Path(stem+'_'+str(year)+str(suffix)))
    return str(new_file_name)

def motti_coefficients_mean(res):
    """
    Write the mean of dGrowthPrebas values to file for Motti
    @param res dGrowthPrebas coeffients 
    @retval dfmotti DataFrame of the means of coefficients in `res`.
    """
    dG = res[0]
    dH = res[1]
    dD = res[2]
    dGmean = np.mean(dG.T,axis=1)
    dHmean = np.mean(dH.T,axis=1)
    dDmean = np.mean(dD.T,axis=1)
    dfdGmean = pd.DataFrame(dGmean)
    dfHmean = pd.DataFrame(dHmean)
    dfDmean = pd.DataFrame(dDmean)
    dfmotti = pd.concat([dfdGmean,dfHmean,dfDmean],axis=1,ignore_index=True)
    dfmotti.columns = motti_coeffient_cols
    dfmotti.index.name=layers
    return dfmotti

def write_prebas_coefficients_single_site(res,file_name:str):
    """
    Write the means of dGrowthPrebas values to file for Motti
    @param res dGrowthPrebas coeffients 
    @param file_name Output file name
    @return Write to file the mean of coefficients in `res`.
    """
    dfmotti = motti_coefficients_mean(res)
    dfmotti.to_csv(file_name,sep=" ")
    
def write_prebas_coefficients(res,file_name:str):
    """
    Write the mean of dGrowthPrebas values to file for Motti
    @param res dGrowthPrebas coeffients 
    @param file_name Output file name
    @return Write to file the mean of coefficients in `res`.
    """
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
    dfmotti.to_csv(file_name,sep=" ")
    
def motti_init(motti_init_file:str,motti_stand_file:str,prebas_model_tree_file:str):
    """
    The first MOTTI initialization run before simulation
    @param motti_init_file the PREINIT file for MOTTI
    @param stand_data_file The stand data output file and input data for Prebas
    @param prebas_model_tree_file The output model tree data and for Prebas
    """
    print("INIT BEGIN")
    print("INPUT:",motti_init_file,"OUTPUT:",motti_stand_file,prebas_model_tree_file)
    subprocess.run([str(MOTTI_LOCATION.joinpath(MOTTIWB)),'PREBAS','INISTATE',
                        '-in',motti_init_file,'-out',motti_stand_file,'-outprbs',prebas_model_tree_file],
                       capture_output=True,text=True)
    print("INIT DONE")
    
def motti_growth(years,motti_input_stand_file:str,motti_output_stand_file:str,prebas_model_tree_file:str,prebas_coeff_file:str):
    """
    Motti growth
    @param years Simulation years
    @param motti_input_stand_file  Motti stand file
    @param motti_output_stand_file Motti stand file after simulation
    @param prebas_model_tree_file Motti model tree file for Prebas
    @param prebas_coeff_file Coefficients from Prebas to be used in Motti
    """
    print("MOTTI GROWTH BEGIN")
    subprocess.run([str(MOTTI_LOCATION.joinpath(MOTTIWB)),'PREBAS','-simulate',str(years),
                    '-in',motti_input_stand_file,'-out',motti_output_stand_file,
                    '-outprbs',prebas_model_tree_file,'-prebascoeff',prebas_coeff_file],
                   capture_output=True,text=True)
    print("MOTTI GROWTH DONE")

def read_motti_site_type(f:str)->float:
    """
    Read Motti stand file and return site type.
    @note Currently for one site only
    @param f Site file
    @return Site type
    @retval stype Site type as float 
    """
    df = pd.read_csv(f,engine='python',sep=re.compile(r'\s+'),nrows=30,decimal=DECIMALMARKER,names=['Index','Value'],header=0)
    stype = df[df['Index']==SITE_TYPE_INDEX].iloc[0,1]
    return stype

def read_motti_model_tree_info(f:str):
    """
    Read Motti model tree/respresentetive trees info and return dataframe of model tree data for Prebas
    @note Currently assuming one stand and one tree species
    @param f Motti model tree info file
    @return Data frame of model tree info, Number of model trees, number of tree species
    """
    df = pd.read_csv(f,engine='python',sep=re.compile(r'\s+'),decimal=DECIMALMARKER,names=['INDEX0','INDEX1','INDEX2','VALUE'])
    dfg = df.groupby(['INDEX2'])
    ngroups = dfg.ngroups
    lss = []
    for n in range(1,ngroups+1):
        g = dfg.get_group((n,))
        g.reset_index()
        s = list(g['VALUE'])
        lss.append(s)
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
    (df_tree_info,n_model_trees,nspecies) =  read_motti_model_tree_info(model_tree_info)
    df_site_info = pd.DataFrame(data=0,index=[0],columns=site_info_cols)
    df_site_info['SiteID'] = 1
    df_site_info['climID'] = 2
    df_site_info['SiteType'] = site_type
    df_site_info['SWinit (initial soil water)'] = 160.0
    df_site_info['Sinit (initial temperature acclimation state)'] = 20.0
    df_site_info['NLayers'] = n_model_trees
    df_site_info['NSpecies'] = nspecies
    df_site_info['SoilDepth'] = 413.0
    df_site_info["Effective field capacity"] = 45.0
    df_site_info["Permanent wilthing point"] = 0.118
    
    return (df_site_info,df_tree_info)

def dgrowthprebas(years,siteInfo,initVar,PARtran,New_PARtran,TAirtran,New_TAirtran,
                  Preciptran,New_Preciptran,VPDtran,New_VPDtran,CO2tran,New_CO2tran):
    """
    Call to dGrowthPrebas
    @param years Number of years to simulate
    @param siteInfo Site data from Motti plus Prebas default values
    @param initVar Model tree data from Motti
    \note PARtran - New_CO2tran weather data for Prebas
    """
    print("DGROWTHPREBAS BEGIN")
    # Call dGrowthPrebas
    res = r['dGrowthPrebas'](years,siteInfo,initVar,
        PARtran,New_PARtran,
        TAirtran,New_TAirtran,
        Preciptran,New_Preciptran,
        VPDtran,New_VPDtran,
        CO2tran,New_CO2tran)
    #To see the same in python matrix transposes T are needed
    print("DGROWTH PREBAS END")
    return res

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-y","--years",dest="y",type=int,required=True,help="Total simulation years")
    parser.add_argument("-i","--interval",dest="i",type=int,default=5,help="Prebas simulation years (interval), default 5 years")
    parser.add_argument("-d","--initdata",dest="d",type=str,required=True,help="Motti initial data file (full path)")
    parser.add_argument("-s","--stand",dest="s", type=str,required=True,help="Motti stand  file (full path)")
    parser.add_argument("-t","--model_trees",dest="t",type=str,required=True,help="Motti model tree file (full path)")
    parser.add_argument("-c","--coeff",dest="c",type=str,required=True,help="Prebas coefficients")
    parser.add_argument("-x","--excel_file",dest="x",type=str,default=None,help="Motti coefficients excel file")
    args = parser.parse_args()

    
    orig_stand_file = current_stand_file = args.s
    orig_model_tree_file = current_model_tree_file = args.t
    orig_coeff_file = current_coeff_file = args.c
    initial_data_file = args.d
    simulation_time = args.y 
    simulation_step = args.i
    motti_init(initial_data_file,current_stand_file,current_model_tree_file)

    df_ls=[]
    year_ls=[]
    for year in range(0,simulation_time,simulation_step):
        print("YEAR",year)
        (df_site_info,df_tree_info)= prebas_input(current_stand_file,current_model_tree_file)
        new_stand_file = create_new_file_name(orig_stand_file,str(year)+'-'+str(year+simulation_step))
        new_model_tree_file = create_new_file_name(orig_model_tree_file,str(year)+'-'+str(year+simulation_step))
        current_coeff_file = create_new_file_name(orig_coeff_file,str(year)+'-'+str(year+simulation_step))
        #Site info is data frame but Prebas reuires data array 
        #Tree info is N trees x 7 data frame but Prebas requires 7 x N trees matrix (2D data array)
        (site_info_r,tree_info_r) = convert_r(df_site_info,df_tree_info.T)
        #Using Francesco data max 20 years
        #Slice vectors to start at the right point 
        res = dgrowthprebas(simulation_step,site_info_r,tree_info_r,
                             dd.PAR_siteX_r[365*year:],dd.newPAR_siteX_r[365*year:],
                             dd.TAir_siteX_r[365*year:],dd.newTAir_siteX_r[365*year:],
                             dd.Precip_siteX_r[365*year:],dd.newPrecip_siteX_r[365*year:],
                             dd.VPD_siteX_r[365*year:],dd.newVPD_siteX_r[365*year:],
                             dd.CO2_siteX[365*year:],dd.newCO2_siteX[365*year:])
        write_prebas_coefficients_single_site(res,current_coeff_file)
        df = motti_coefficients_mean(res)
        df_ls.append(df)
        year_ls.append(year)
        motti_growth(simulation_step,current_stand_file,new_stand_file,new_model_tree_file,current_coeff_file)
        current_stand_file = new_stand_file
        current_model_tree_file = new_model_tree_file

    #As extra write coeffients to excel file
    if args.x:
        excel_writer = pd.ExcelWriter(args.x, engine='openpyxl')
        for (df,year) in zip(df_ls,year_ls):
            df.to_excel(excel_writer,sheet_name="Year "+str(year)+'-'+str(year+simulation_step))
        excel_writer.close()
