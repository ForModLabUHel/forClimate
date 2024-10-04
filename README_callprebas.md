# Embedded R interface between Motti and dGrowthPrebas

## callprebas
The link function between *MottiWB* and *dGrowthPrebas* implemented in C/Embedded R:

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
///\param verbose If verbose > 0 print site_info and init_var contents 
///\pre The result matrices must have memory space for tne results. 
///\todo climate_model: For the real climate data decide how to express Climate scenario wanted
///\todo climID: For the real climate data decide how to express the geographic location wanted 
void callprebas(double site_info[],int length, double* init_var,long rows,long cols,
		char* climate_model,int climID,double* dH_result,double* dD_result,
		double* dV_result,int verbose)
		
```
The *site_info* vector length is known to be 10 but for consistency its length is explicitely given. 
The *init_var* matrix is designed to have statically in the order of 1000 model trees, but for the 
*dGrowthPrebas* we need to know the number of model trees (Prebas layers) so that we can pass the proper 
slice of it to *dGrowthPrebas*. Both the number of rows (7, variables describing the model trees) 
and the number of colums (i.e. the number of model trees) is needed. 

The size of the result matrices for *dH*, *dD* and *dV* are implicitely known (5 rows for 5 year simulation period 
and the number of columns is the number of model trees) but the memory space must be reserved
before the call to *callprebas*. The *verbose* parameter allows to print the contents of *site_info* and *init_var* for
debugging purposes.

Note that the model trees are the matrix *columns* both in *init_var* and in the result matrices.

The function signature needs to be finalized with information required for *dGrowthPrebas*. 
For example: the selected geographic region and calendar year for the beginning of the 5 year period.

See the files *callprebas.h* and *callprebas.c*.

> [!IMPORTANT]
> The function signature (number of parameters, their types and the return value) is due to change.
>   
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
See *prebascoefficients.r* for details. Climate data and climate scenario files are big (in the order of gigabytes).
Consider loading climate data once, not each time in *prebascoefficients* calls.

## TASKS
Present-day status: Compiles and runs on Linux. To complete the link between MottiWB and dGrowthPrebas:

- [X] Compile and run on Windows (Mika, Hannu)
- [X] Create shared library on Windows (Mika, Hannu)
- [] prebascoefficients.r file: replace demo climate data with Francesco's real current climate 
     and the real climate scenario in *prebascoefficients* for *dGrowthPrebas* (Daesung)
	- See Francesco's instructions to use climate data in *Rsrc/extractWeather_example.r*
  	- The part needed to be replaced is marked in *prebascoefficients* with BEGIN and END
  	- Use parameters for *dGrowthPrebas* from the real climate and climate scenario (PAR, CO2, VPD etc.)
  	- The function *prebascoefficients* can be tested independently in R for example using demo Site and Layers data available in
  	  forClimate.	
- [] Implement the two-way link MottiWB &harr; callprebas &harr; prebascoefficients &harr; dGrowthPrebas (Mika, Hannu, Daesung, Jari)   
	- Determine additional parameters needed in *prebascoefficients* to run simulations from Motti
 		- For example: calendar year for the beginning of the 5 year simulation period, (x,y) coordinates for geograpich location.
  	- Note the *R Extensions* package allows up to five parameters in R function calls from C.
- [X] Check Francesco if *dGrowthPrebas* coefficients for *dV* indeed are for volume growth (*dV* is gross growth). 
- [X] Check Francesco if a particular version of R is needed for Rprebasso (No need).
- [X] Sensitivity tests for *dGrowthPrebas*.

## Compilation
### Linux
Rprebasso and reshape2 packages must be installed in R. To compile and run `callprebas` in forClimate directory:

	export R_HOME=/usr/lib64/R/
	gcc -DMAIN -o callprebas -g -I/usr/include/R -L$R_HOME/lib -lR -lRblas callprebas.c
	./callprebas

The *-DMAIN* includes the C *main* function that implements the `callprebas` test program. To create the *callprebas.so* shared library:
	
	gcc -fPIC -c -I/usr/include/R  callprebas.c -o callprebas.o
	gcc -shared callprebas.o -o callprebas.so

### Windows 10
Rprebasso and reshape2 packages must be installed in R. Set-up *R_HOME* and *Path* environment variables with [Control Panel](https://learn.microsoft.com/en-us/windows/win32/shell/user-environment-variables):

+ Set *R_HOME*: C:\<path to R installation directory\>
	+ For example: C:\dev\MyPrograms\R\R.4.3.3 
+ Add to *Path*: C:\<path to R installation directory\>\bin\x64
	+ For exampe:  C:\dev\MyPrograms\R\R.4.3.3\bin\x64
   
The *Path* variable is also a search path for shared libraries. 

Install Cygwin and from Cygwin the `x86_64-w64-mingw32-gcc` compiler. To build and run `callprebas.exe` 
is an interplay with Cygwin and Windows. Open *Cygwin terminal*, go to forClimate directory and build `callprebas.exe`:

	x86_64-w64-mingw32-gcc.exe -DMAIN -o callprebass.exe -g -I"$R_HOME"/include -L"$R_HOME"/bin/x64 -lR -lRblas callprebas.c

To build the *callprebas.dll* shared library in *Cygwin terminal*:

	x86_64-w64-mingw32-gcc.exe -g -c -I"$R_HOME"/include -L"$R_HOME"/bin/x64 -lR -lRblas callprebas.c	
 	x86_64-w64-mingw32-gcc.exe -shared -o callprebas.dll callprebas.o -g -I"$R_HOME"/include -L"$R_HOME"/bin/x64 -lR -lRblas

To run the `callprebas.exe` test program open *Windows Command Prompt[^cmd]*, go to forClimate directory and run the test program.  

### Linking Delphi and C
The shared library *callprebas.dll* has the functions *initialize_R*, *source* and *callprebas*. 
The *initialize_R* function initializes the embedded R environment. The *source* function can be used 
to source the necessary R files. These must be called before any calls to *callprebas* in the main program. 
See the beginning of the *main* function in *callprebas.c* as an example.

Note the *callprebas* function signature for Delphi/MottiWB , i.e. the parameters and the return values for the 
three growth coefficients:
```C
void callprebas(double site_info[],int length, double* init_var,long rows,long cols,
		char* climate_model,int climID,double* dH_result,double* dD_result,
		double* dV_result,int verbose)
```
The growth coefficients are returned in *dH_result*, *dD_result* and *dV_result*. There sizes are implicitly known and
proper memory must have been allocated for them.

## Reading
[Cygwin manual](https://cygwin.com/cygwin-ug-net/dll.html).

[^cmd]: Also known as `cmd.exe` or `cmd`.
