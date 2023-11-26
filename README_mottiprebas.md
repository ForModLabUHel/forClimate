# Framework to run PREBAS and Motti under changing climate
One idea is to use Python as a glue to run PREBAS (i.e. R)
and Motti (i.e. Pascal binary or shared library) interchangeably.
The data exchange can be with files and Motti command line parameters.

Examples how to call Motti as binary with python can be found
for example in some customer projects. Using Pascal shared libraries
is certainly trickier with no prior experience.

## Installation
The following software must be present:

+ Rprebasso: Download from GitHub and use the instructions in GitHub to install in R.
  - mottiprebas.py requires that Rprebasso package (i.e. PREBAS) is installed in R.
+ forClimate: Download from GitHub.
+ Python: Tested with Python 3.10 but any "close enough" of Python 3.x should do.
+ R: Tested with Rstudio Version 2023.09.0+463 (2023.09.0+463) but any "close enough" R distribition should do
	
Create Python virtual environment (e.g. *mottiprebas*) and install rpy2, numpy and pandas packages:

	#Unix like operating system
	python -m venv mottiprebas 
	source mottiprebas/bin/activate
	pip install --upgrade pip
	pip install numpy pandas rpy2
	
	#Windows
	python -m venv mottiprebas 
	mottiprebas/Scripts/activate
	pip install --upgrade pip
	pip install numpy pandas rpy2
	
## Run mottiprebas.py
Start the Python virtual environment, go to *forClimate* directory and type 

	python mottiprebas.py
	
Currently mottiprebas.py repeats the demonstration in *exampleFunctionDelta.r*
and saves the results in *PrebasRes.RData* file that appears in forClimate directory.
