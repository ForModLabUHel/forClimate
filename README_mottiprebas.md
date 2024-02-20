# Framework to run PREBAS and Motti under changing climate
One idea is to use Python as a glue to run PREBAS (i.e. R)
and Motti (i.e. Pascal binary or shared library) interchangeably.
The data exchange can be with files and Motti command line parameters.

Examples how to call Motti as binary with python can be found
for example in some customer projects. Using Pascal shared libraries
is certainly trickier with no prior experience.

## Installation
The following software must be present:
+ Python: Tested with Python 3.10 but any "close enough" Python 3.x should do.
+ R/RStudio: Tested with Rstudio Version 2023.09.0+463 (2023.09.0+463) but any "close enough" R distribution should do.
   - Rtools: Compilers to build Fortran and C source files in PREBAS. Download from [CRAN/R for Windows](https://cran.r-project.org).
+ [Rprebasso](https://github.com/ForModLabUHel/Rprebasso): Download from GitHub. Use the instructions in the GitHub README
  file to install in R.
   - forClimate requires that Rprebasso package (i.e. PREBAS) is installed in R.
   - To install from the local download directory:
      - install.packages('Rprebasso',repos=NULL,type='sources')
+ forClimate: This project. Download from GitHub.


	
Create Python virtual environment (e.g. with the name *mottiprebas*):

	python -m venv mottiprebas 
 
 Activate the virtual environment in Unix like operating system
	
  	source mottiprebas/bin/activate
 
  Activate the virtual environment in Windows operating system
  
  	mottiprebas/Scripts/activate

Update pip (Python package installation tool):

	python -m pip install --upgrade pip
    
Install Python package tools and install rpy2, numpy, openpyxl and pandas packages:

  	pip install setuptools wheel
	pip install numpy pandas openpyxl rpy2
	
## mottiprebas.py
`mottiprebas.py` runs Motti workbench and PREABAS interchangeably and lets PREABAS to produce a set of coefficients 
for Motti to take the warming climate into account in simulations.

First, find `mottiprebas.py` in forClimate and locate the three lines in the beginning of the file for 
RHOME, MOTTI_LOCATION and MOTTIWB:

```python
#R_HOME for R for Windows (comment out for Mac and Linux)
RHOME='/Program Files/R/R-4.3.2/'
os.environ['R_HOME'] = RHOME
# MottiWB RUNTIME LOCATION including all necessary shared libraries
# Change as needed using '/' for directory path also  in Windows
MOTTI_LOCATION=pathlib.Path("/Apps/MottiPrebas/MottiPrebas/")
#Motti workbench
MOTTIWB='mottiwb.exe'
```
Edit the path strings for RHOME and MOTTI_LOCATION according to `R` and `mottiwb` installation locations respectively.
MOTTIWB is the name of the Motti workbench binary.

To check `mottiprebas.py` and its runtime environment start the Python virtual environment, 
go to *forClimate* directory and type for command line help:
	
 	python mottiprebas.py -h

To run Motti-Prebas simulations type for example:

	python mottiprebas.py -y 20 -d initmotti/prebasTest.txt -s mottistand/Stand.txt -t mottimodeltree/ModelTrees.txt -c prebascoeff/PrebasCoefficient.txt -x prebascoeff/PrebasCoefficient.xlsx

 **Note** that the directories for data files must exist before simulation. The number 20 is the simulation time (years). 
 The last growth step is from 15 to 20, i.e the growth step  is 5 by default.  *prebasTest.txt* is used with the Motti initialization 
 run (the file must exist with reasonable content). *Stand.txt* is is the first Motti stand level data file and 
 *ModelTrees.txt* is the first model tree data file after the initialization run. They also provide name templates 
 for files to be created during simulation. *PrebasCoefficient.txt* is the name template for PREBAS coeffient files. 
 *PrebasCoefficient.xlsx* collects generated Prebas coefficients in a single Excel file (optional).

 Data files will appear in their respective directories and named using simulation steps. For example *PrebasCoeff_5-10.txt* contains 
 coefficients for the simulation step 5 to 10. **Note** there is currently 20 years of weather data to demonstrate 
 the linking between Motti and PREBAS.	

