# Framework to run PREBAS and Motti under changing climate
>[!NOTE]
>The framework, put together in the main `mottprebas.py` script, can be used with single site Motti initialization files.
  
## Installation
The following software must be present. Python, R/RStudio and RTools are available from Luke Software Center:
+ Python: Tested with Python 3.10 but any "close enough" Python 3.x should do.
+ R/RStudio: Tested with Rstudio Version 2023.09.0+463 (2023.09.0+463) but any "close enough" R distribution should do.
+ Rtools: Compilers to build Fortran and C source files in PREBAS.
+ [Rprebasso](https://github.com/ForModLabUHel/Rprebasso): Download from GitHub. Use the instructions in the GitHub README
  file to install the latest development version in R.
   - forClimate requires that Rprebasso package (i.e. PREBAS) is installed in R.
   - To install Rprebasso from the local download directory:
      - install.packages('path\to\Rprebasso',repos=NULL,type='source')
+ forClimate: This project. Download from GitHub.
+ Motti workbench `mottiwb`.

### Python virtual environment
Create Python virtual environment (e.g. with the name *mottiprebas*):

	python -m venv mottiprebas 
 
 Activate the virtual environment in Unix like operating system
	
  	source mottiprebas/bin/activate
 
  Activate the virtual environment in Windows operating system
  
  	mottiprebas/Scripts/activate

Update pip (Python package installation tool):

	python -m pip install --upgrade pip
    
Install Python package tools *setuptools* and *wheel*. Install *numpy, pyarrow, pandas, openpyxl* and *rpy2* packages:

  	pip install setuptools wheel
	pip install numpy pyarrow pandas openpyxl rpy2 

>[!IMPORTANT]
>On Windows install *numpy, pyarrow, pandas, openpyxl* and *rpy2* packages one by one, in the order of appearance.
>You will encounter errors if trying to install all of them at the same time.

>[!IMPORTANT]
>Keep *Rprebasso* installation up to date. The project is regularly updated.

### mottiprebas.py

First, find `mottiprebas.py` in forClimate and locate the four lines in the beginning of the file for 
RHOME, MOTTI_INST_PATH, MOTTIWB and DECIMALMARKER:

```python
#R_HOME for R for Windows (comment out for Mac and Linux)
RHOME='/Program Files/R/R-4.3.2/'
os.environ['R_HOME'] = RHOME
# MottiWB RUNTIME LOCATION including all necessary shared libraries
# Change as needed using '/' for directory path also  in Windows
MOTTI_INST_PATH=pathlib.Path("/dev/MyPrograms/MottiWorkBench/Debug/")
#Motti workbench
MOTTIWB='mottiwb.exe'
#Decimal point used in mottiwb depends on locale. 
DECIMALMARKER='.'
```
Edit the path strings for RHOME and MOTTI_INST_PATH according to `R` and Motti workbench installation locations respectively.
MOTTIWB is the name of the Motti workbench binary. The binary (default `mottiwb.exe`) uses decimal marker
according to locale in use.  Change the default decimal separator in DECIMALMARKER if needed.

To check `mottiprebas.py` and its runtime environment start the Python virtual environment, 
go to *forClimate* directory and type `python mottiprebas.py -h` for command line help:
```python

python mottiprebas.py -h
usage: mottiprebas.py [-h] -y int [-i int] -d str [-m str] -s str -t str -c str -r {1,2,3,4,5,6,7} -w
                      {1,2,3,4} [-e int] [-f int]

Run Motti under climate change with Prebas

options:
  -h, --help            show this help message and exit
  -y int, --years int   Total simulation years
  -i int, --interval int
                        Prebas simulation years / Motti time step, default 5 years
  -d str, --initdata str
                        Motti initial data file(s), regular expression (Motti input, full path)
  -m str, --result_directory str
                        Simulation results main directory, default MottiPrebasSimulations
  -s str, --stand str   Motti stand file (Motti output, Prebas input, full path)
  -t str, --model_trees str
                        Motti model tree file (Motti output, Prebas input, full path)
  -c str, --coeff str   Prebas coefficients file (Prebas output, Motti input, full path)
  -r {1,2,3,4,5,6,7}, --climate_region {1,2,3,4,5,6,7}
                        Climatic region in Finland
  -w {1,2,3,4}, --climate_scenario {1,2,3,4}
                        Climate scenario (see climatedata.py for scenario names)
  -e int, --climate_scenario_data_start int
                        Climate scenario data start year, default 2025
  -f int, --climate_scenario_start int
                        Climate scenario start year in simulations, default 2025

Available climate scenarios: 1: data/tranCanESM2.rcp45.rda 2: data/tranCanESM2.rcp85.rda
3: data/tranCNRM.rcp45.rda 4: data/tranCNRM.rcp85.rda
```

## Simulations with mottiprebas.py
`mottiprebas.py` runs Motti workbench and PREABAS interchangeably and lets PREABAS to produce a set of coefficients 
for Motti to take the warming climate into account in simulations. PREBAS simulates forest stand growth
with current climate and with a given climate scenario in short 5 year time intervals. The ratio or difference 
of the two runs gives coefficients that Motti will use to adjust the stand growth under climate change.

To run Motti-Prebas simulations type for example (or copy-paste from the icon):
```python
	python mottiprebas.py -y 20 -i 5 -m MottiPrebasSimulations -d initmotti/prebasTest*.txt -s mottistand/Stand.txt -t mottimodeltree/ModelTrees.txt -c prebascoeff/PrebasCoefficient -r 2 -w 1 -e 2025 -f 2025
```
Scroll to the right to see the full command line.

>[!IMPORTANT]
>The mottiprebas.py script must be executed in *forClimate* directory. It will use weather and climate scenario
>databases installed in *forClimate* project.

The option *-y 20* is the simulation time. The last growth step is from 15 to 20, i.e the growth step
is 5 years (default value for the *-i* option). The main directory for results is given with *-m MottiPrebasSimulations*.
Simulation results will appear in subdirectories, one for each Motti initialization file. 
Motti initialization files are given with the *initmotti/prebasTest*.txt. Note the possibility to use regular expression
to match multiple initialization files for a single simulation session.

>[!NOTE]
>Currently each Motti initialization file can have one site only.

Simulation results based on template file names given for Motti stand data (the option *-s*), 
Motti model trees (the option *-t*) and Prebas coefficients (the option *-c*) will appear 
in their respective directories and named after simulation steps. For example *prebascoeff/PrebasCoeff_5-10.txt* 
contains coefficients for Motti for the simulation step 5 to 10. Directory hierarchy for the simulation results
starting from the main directory will be created programatically.

The option *-r 2* defines region in Finland (7 in total) and the option *-w 1* selects the climate scenario (4 in total).
The *-e 2025* option is the start year in the climate scenario data base and the *-f 2025* option is the start year
when climate scenario is used.

>[!NOTE]
>Current weather for each 5 year simulation period will be randomly selected for the simulation step out of 20 years available
>in the database for the current climate. Climate scenario is deterministic beginning from a given start year.
>There are 120 years of scenario data available in total in each 4 climate scenarios.
>In other  words the current weather tries to model natural variability in the annual weather with randomness
>but the climate scenarios have calendar time.

>[!WARNING]
>Directory hierarchy will be reused if the main directory for results exists. It is up to the user not to override
>previous results by accident.


