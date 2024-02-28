# Framework to run PREBAS and Motti under changing climate
One idea is to use Python as a glue to run PREBAS (i.e. R)
and Motti (i.e. Pascal binary or shared library) interchangeably.
The data exchange can be with files and Motti command line parameters.

Examples how to call Motti as binary with python can be found
for example in some customer projects. Using Pascal shared libraries
is certainly trickier with no prior experience.

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

>[!WARNING]
>On Windows install *numpy, pyarrow, pandas, openpyxl* and *rpy2* packages one by one, in the order of appearance.
>You will encounter errors if trying to install all of them at the same time.

## mottiprebas.py
`mottiprebas.py` runs Motti workbench and PREABAS interchangeably and lets PREABAS to produce a set of coefficients 
for Motti to take the warming climate into account in simulations.

First, find `mottiprebas.py` in forClimate and locate the four lines in the beginning of the file for 
RHOME, MOTTI_LOCATION, MOTTIWB and DECIMALMARKER:

```python
#R_HOME for R for Windows (comment out for Mac and Linux)
RHOME='/Program Files/R/R-4.3.2/'
os.environ['R_HOME'] = RHOME
# MottiWB RUNTIME LOCATION including all necessary shared libraries
# Change as needed using '/' for directory path also  in Windows
MOTTI_LOCATION=pathlib.Path("/dev/MyPrograms/MottiWorkBench/Debug/")
#Motti workbench
MOTTIWB='mottiwb.exe'
#Decimal point used in mottiwb depends on locale. 
DECIMALMARKER='.'
```
Edit the path strings for RHOME and MOTTI_LOCATION according to `R` and Motti workbench installation locations respectively.
MOTTIWB is the name of the Motti workbench binary. The binary (default `mottiwb.exe`) uses decimal marker
according to locale in use.  Change the default decimal separator in DECIMALMARKER if needed.

To check `mottiprebas.py` and its runtime environment start the Python virtual environment, 
go to *forClimate* directory and type for command line help:
	
 	python mottiprebas.py -h

To run Motti-Prebas simulations type for example:

	python mottiprebas.py -y 20 -d initmotti/prebasTest.txt -s mottistand/Stand.txt -t mottimodeltree/ModelTrees.txt -c prebascoeff/PrebasCoefficient.txt -x prebascoeff/PrebasCoefficient.xlsx

>[!NOTE]
>The data file directories (*initmotti, mottistand, mottimodeltree, prebascoeff*) must exist before simulation.
>Also the file the inital Motti file (in this case *prebasTest.txt') must exists and able to produce
>the first *Stand.txt* and *ModelTrees.txt* files.

The number 20 is the simulation time (years). The last growth step is from 15 to 20, i.e the growth step  is 5 by default. 
*prebasTest.txt* is used with the Motti initialization run (the file must exist with reasonable content). 
*Stand.txt* is is the first Motti stand level data file and *ModelTrees.txt* is the first model tree data
file after the initialization run. They also provide name templates for files to be created during simulation. 
*PrebasCoefficient.txt* is the name template for PREBAS coeffient files. *PrebasCoefficient.xlsx* collects generated Prebas
coefficients in a single Excel file (optional).

 Data files will appear in their respective directories and named using simulation steps. For example *PrebasCoeff_5-10.txt* contains 
 coefficients for the simulation step 5 to 10. **Note** there is currently 20 years of weather data to demonstrate 
 the linking between Motti and PREBAS.	

