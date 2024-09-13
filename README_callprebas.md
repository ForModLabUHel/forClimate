# C function interface between Motti and dGrowthPrebas

## callprebas
The link function between *MottiWB* and *dGrowthPrebas* implemented in C:

```C
///\brief Call dGrowthPrebas and return coeffients for Height, Diameter and Volume growths
///\param site_info Vector of length 10 for values describing one site
///\param length Length of the site_info vector (10 for a single site).
///\param init_var Matrix for values describing model trees in Motti
///\param rows Number of rows, i.e. variables describing model trees, in init_var (should be 7)
///\param cols Number of columns used, i.e. number of model trees, in init_var
///\param climate_model Climate change model to be chosen
///\param climID Climate reagion to be chosen
///\param[out] dH_result Matrix (5 year rows x Number of model trees columns) containing coefficients for Height growth
///\param|out] dD_result Matrix (5 year rows x Number of model trees columns) containing coefficients for Diameter growth
///\param[out] dV_result Matrix (5 year rows x Number of model trees columns) containg coefficients for Volume growth
///\pre The result vectors must have memory space for tne results. 
///\todo climate_model: For the real climate data decide how to express Climate scenario wanted
///\todo climID: For the real climate data decide how to express the geographic location wanted 
void callprebas(double site_info[],int length, double* init_var,long rows,long cols,
		char* climate_model,int climID,double* dH_result,double* dD_result,
		double* dV_result)
		
```
The *site_info* vector length is known to be 10 but for consistency its length is explicitely given. 
The *init_var* matrix is designed to have statically in the order of 1000 model trees, but for the 
*dGrowthPrebas* we need to know the number of model trees (Prebas layers) so that we can pass the proper 
slice of it to *dGrowthPrebas*. Both the number of rows (7) and the number of colums (i.e. the number of model trees) is needed. 

The size of the result matrices for *dH*, *dD* and *dV* are implicitely known but the memory space must be reserved
before the call to *callprebas*.

Note that the model trees are the matrix *columns* both in *init_var* and in the result matrices.

The function signature needs to include the choice of Climate scenario and the selected geographic region.

See the files *callprebas.h* and *callprebas.c*.

## prebascoefficients

The R function called by *callprebas* that with given input selects the climate scenario as well as  
the geographic region and calls *dGrowthPrebas*. Returns the coefficients for *dH*, *dD* and *dV*:

```R
###Call dGrowthPrebas with site and model tree information, given climate scenario
###and geographic location. The climate set-up must be reimplemented for the
###real climate scenario data.
###TODO: decide how to express climate scenario and geographic location. Implement
###the climate data set-up.
prebascoefficients<-function(siteInfo_siteX,initVar_siteX,climateModel,climID)
```

Currently *prebascoefficients* uses the demonstration climate data that needs to be changed to real climate scenarios.
See *prebascoefficients.r* for details.

## TASKS
Present-day status: Compiles and runs on Linux. To complete the link between MottiWB and dGrowthPrebas:

- [] Compile and run on Windows (Mika, Hannu)
- [] Create shared library on Windows (Mika, Hannu)
- [] Implement real climate scenario selection in *prebascoefficients* for *dGrowthPrebas* (Daesung)
	- See Francesco's instructions in *Rsrc/extractWeather_example.r*
 	- The implementation can be started on Linux and tested with demonstration site and model tree (Prebas layers) data.
  	- The part needed to be replaced is marked in *prebascoefficients* 	
- [] Put together the two-way link MottiWB &harr; callprebas &harr; dGrowthPrebas (Mika, Hannu, Daesung, Jari if needed)
  	- Check if *dGrowthPrebas* coefficients for *dV* indeed are for volume growth (Francesco)
  	- The *R Extensions* package allows up to five parameters in R function calls from C. That is the constraint
  	  for *prebascoefficients*.
  	- Check if a particular version of R is needed for Rprebasso (Francesco).
- [] Sensitivity tests for *dGrowthPrebas*.

## Compilation
### Linux
To compile and run on Linux (Rprebasso must be installed in R):

	export R_HOME=/usr/lib64/R/
	gcc -DMAIN -o callprebas -g -I/usr/include/R -L$R_HOME/lib -lR -lRblas callprebas.c
	./callprebas

Note that the call `callprebas` must executed in the  *forClimate* directory. 
To create shared library on Linux:
	
	gcc -fPIC -c -I/usr/include/R  callprebas.c -o callprebas.o
	gcc -shared callprebas.o -o callprebas.so

### Windows 10
For Windows install Cygwin and the `x86_64-w64-mingw32-gcc` compiler. The build process *in Cygwin terminal* is similar to Linux.
To build the simple test program (Rprebasso must be installed in R):

	x86_64-w64-mingw32-gcc.exe -DMAIN -o /cygdrive/c/dev/Cygwin64/home/03081263/callprebass.exe -g -I"$R_HOME"/include -L"$R_HOME"/bin/x64 -lR -lRblas /cygdrive/c/dev/MyGit/forClimate/callprebas.c

To build the shared library in Cygwin:

	x86_64-w64-mingw32-gcc.exe -g -c -I"$R_HOME"/include -L"$R_HOME"/bin/x64 -lR -lRblas /cygdrive/c/dev/MyGit/forClimate/callprebas.c	
 	x86_64-w64-mingw32-gcc.exe -shared -o callprebas.dll callprebas.o -g -I"$R_HOME"/include -L"$R_HOME"/bin/x64 -lR -lRblas

To run the `callprebas` test program set-up first R_HOME and other required environment variables. 
Open *Windows terminal*, go to forClimate installation directory and run the test program.  

### Linking Delphi and C
The shared library *callprebas.dll* has the functions *initialize_R* and *callprebas*. The former initilizes the embedded R environment
and must be called before *callprebas* in the main program.

## Reading
[Cygwin manual](https://cygwin.com/cygwin-ug-net/dll.html).

