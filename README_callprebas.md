# Embedded R interface between Motti and dGrowthPrebas

## callprebas
The link function between *MottiWB* and *dGrowthPrebas* implemented with C/Embedded R:

```C
///\brief Call dGrowthPrebas and return coeffients for Height, Diameter and Volume growths
///\param site_info Vector of length 10 for values describing one site
///\param length Length of the site_info vector (10 for a single site).
///\param init_var Matrix for values describing model trees in Motti
///\param rows Number of rows, i.e. variables describing model trees, in init_var (should be 7)
///\param cols Number of columns used, i.e. number of model trees, in init_var
///\param site_coord Vecor of length 2 for (x,y) coordinates of the location. Check the coordinate system
///\param start_5_year Start calendar year for the 5 year simuolation period
///\param[out] dH_result Matrix (5 year rows x Number of model trees columns) containing coefficients for Height growth
///\param|out] dD_result Matrix (5 year rows x Number of model trees columns) containing coefficients for Diameter growth
///\param[out] dV_result Matrix (5 year rows x Number of model trees columns) containg coefficients for Volume growth
///\param verbose If verbose == 1 print debugging output fro paramters and result values
///\pre The result matrices must have memory space for the results. 
void callprebas(double site_info[],int length, double* init_var,long rows,long cols,double site_coord[],
                int start_5_year,double* dH_result,double* dD_result,double* dV_result,int verbose)
		
```
The *site_info* vector length is known to be 10 but for consistency its length is explicitely given. 
The *init_var* matrix is designed to have statically in the order of 1000 model trees, but for the 
*dGrowthPrebas* we need to know the number of model trees (Prebas layers) so that we can pass the proper 
slice of it to *dGrowthPrebas*. Both the number of rows (7, variables describing the model trees) 
and the number of colums (i.e. the number of model trees) is needed. 

The size of the result matrices for *dH*, *dD* and *dV* are implicitely known (5 rows for 5 year simulation period 
and the number of columns is the number of model trees) but the memory space must be reserved
before the call to *callprebas*. The *verbose* parameter allows to print the debugging putput during the simaulation. 

Note that the model trees are the matrix *columns* both in *init_var* and in the result matrices..

See the files *callprebas.h* and *callprebas.c*.

## prebascoefficients

The R function *prebascoefficients* (called by *callprebas*) with the given input
selects the climate scenario as well as  the geographic region and
calls *dGrowthPrebas*. Returns the coefficients for *dH*, *dD* and *dV*.
The *prebascoefficients* function is implemented in *prebascoefficients.r*.

The current climate and the climate scenario are loaded once and maintained in memory for subsequent
calls to *prebascoecffients.

```R
###Call dGrowthPrebas with site and model tree information, given climate scenario
###and geographic location. The climate set-up must be reimplemented for the
###real climate scenario data.
###the climate data set-up.
prebascoefficients<-function(siteInfo_siteX,initVar_siteX,siteCoords,startYear_of_simulation,verbose)
```
>[!NOTE]
>Currently *prebascoefficients* uses the *data/CurrClim.rdata* and *data/CanESM2.rcp45.rdata*
>as the current climate and climate scenario respectively. These two files are of considerable size
>and not in GitHub. See *prebascoefficients.r* for details.

>[!NOTE]
>Make sure the right coordinate system is used.

## TASKS
Present-day status: The test program `callprebas` compiles and runs on Windows 10.
To complete the link between MottiWB and dGrowthPrebas:
- [ ] Remove all network based file retrievals from *prebascoefficients.r*
- [ ] Remove unnecessary calls to data retrievals from *prebascoefficients.r*
- [X] Compile and run on Windows (Mika, Hannu)
- [X] Create shared library on Windows (Mika, Hannu)
- [X] prebascoefficients.r file: replace demo climate data with Francesco's real current climate 
     and the real climate scenario in *prebascoefficients* for *dGrowthPrebas* (Daesung)
	- See Francesco's instructions to use climate data in *Rsrc/extractWeather_example.r*
  	- The part needed to be replaced is marked in *prebascoefficients* with BEGIN and END
  	- Use parameters for *dGrowthPrebas* from the real climate and climate scenario (PAR, CO2, VPD etc.)
  	- The function *prebascoefficients* can be tested independently in R for example using demo Site and Layers data available in
  	  forClimate.	
- [X] Implement the two-way link MottiWB &harr; callprebas &harr; prebascoefficients &harr; dGrowthPrebas (Mika, Hannu, Daesung, Jari)   
	- Determine additional parameters needed in *prebascoefficients* to run simulations from Motti
 		- For example: calendar year for the beginning of the 5 year simulation period, (x,y) coordinates for geograpich location.
  	- Note the *R Extensions* package allows up to five parameters in R function calls from C.
- [X] Check Francesco if *dGrowthPrebas* coefficients for *dV* indeed are for volume growth (*dV* is gross growth). 
- [X] Check Francesco if a particular version of R is needed for Rprebasso (No need).
- [X] Sensitivity tests for *dGrowthPrebas*.

## Compilation
*Rprebasso*, *reshape2*, *data.table*, *prodlim* and *sf* packages must be installed in R.

### Linux
To compile and run `callprebas` in forClimate directory. The *R_HOME* points to R installation directory:

	export R_HOME=/usr/lib64/R/
	gcc -DMAIN -o callprebas -g -I/usr/include/R -L$R_HOME/lib -lR -lRblas callprebas.c
	./callprebas

The working directory must be *forClimate* in order to find the climate data files.

The *-DMAIN* includes the C *main* function that implements the `callprebas` test program. To create the *callprebas.so* shared library:
	
	gcc -fPIC -c -I/usr/include/R  callprebas.c -o callprebas.o
	gcc -shared callprebas.o -o callprebas.so

### Windows 10
Set-up *R_HOME* and *Path* environment variables with [Control Panel](https://learn.microsoft.com/en-us/windows/win32/shell/user-environment-variables):

+ Set *R_HOME*: C:\<path to R installation directory\>
	+ For example: C:\dev\MyPrograms\R\R-4.3.3 
+ Add to *Path*: C:\<path to R installation directory\>\bin\x64
	+ For example:  C:\dev\MyPrograms\R\R-4.3.3\bin\x64
   
The *Path* variable is also a search path for shared libraries. 

Install Cygwin and from the Cygwin installation window the `x86_64-w64-mingw32-gcc` compiler. To build and run `callprebas.exe` 
is an interplay with Cygwin and Windows. Open *Cygwin terminal*, go to forClimate directory and build `callprebas.exe`:

	x86_64-w64-mingw32-gcc.exe -DMAIN -o callprebas.exe -g -I"$R_HOME"/include -L"$R_HOME"/bin/x64 -lR -lRblas callprebas.c

To build the *callprebas.dll* shared library in *Cygwin terminal*:

	x86_64-w64-mingw32-gcc.exe -g -c -I"$R_HOME"/include -L"$R_HOME"/bin/x64 -lR -lRblas callprebas.c	
 	x86_64-w64-mingw32-gcc.exe -shared -o callprebas.dll callprebas.o -g -I"$R_HOME"/include -L"$R_HOME"/bin/x64 -lR -lRblas

To run the `callprebas.exe` test program open *Windows Command Prompt[^cmd]*, go to forClimate directory and run the test program.  

### Linking Delphi and C
The shared library *callprebas.dll* has the functions *initialize_R*, *source* and *callprebas*. 
The *initialize_R* function initializes the embedded R environment. The *source* function can be used 
to source the necessary R files. These must be called before any calls to *callprebas* in the main program. 
See the beginning of the *main* function in *callprebas.c* as an example.

```C
int main()
{
  printf("Testing callprebas\n");
  printf("------------------\n");
  printf("Initializing Embedded R\n");
  //Initialize the embedded R environment. 
  initialize_R();
  //Sourcing R files
  printf("Sourcing R files\n");
  source("prebascoefficients.r");
  source("Rsrc/dGrowthPrebas.r");
  .....
}
```

Note the *callprebas* function signature for Delphi/MottiWB , i.e. the parameters and the return values for the 
three growth coefficients:

```C
void callprebas(double site_info[],int length, double* init_var,long rows,long cols,double site_coord[],
                int start_5_year,double* dH_result,double* dD_result,double* dV_result,int verbose)
```

The growth coefficients are returned in *dH_result*, *dD_result* and *dV_result*. There sizes are implicitly known and
proper memory must have been allocated for them.

## Reading
[Cygwin manual](https://cygwin.com/cygwin-ug-net/dll.html).

[^cmd]: Also known as `cmd.exe` or `cmd`.
