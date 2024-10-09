#ifndef CALLBREBAS_H
#define CALLBREBAS_H
#include <stdlib.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <Rembedded.h>
#include <string.h>
extern void print_vector(double v[],int length);
extern void print_matrix(double* m,int rows,int cols);
///Invokes the R command source(rfile), e.g. source("coefficients.r")
extern void source(const char *name,int verbose);
///Invokes the R command library(rfile), e.g. source("Rprebasso")
extern void library(const char *name,int verbose);
///\brief Call dGrowthPrebas and return coeffients for Height, Diameter and Volume growths
///\param site_info Vector of length 10 for values describing one site
///\param length Length of the site_info vector (10 for a single site).
///\param init_var Matrix for values describing model trees in Motti
///\param rows Number of rows, i.e. variables describing model trees, in init_var (should be 7)
///\param cols Number of columns, i.e. number of model trees, in init_var
///\param site_coord Vector of 2 for the (x,y) coordinates of the site
///\param start_5_year Start calendar year for the 5 year simulation period
///\param[out] dH_result Matrix (5 year rows x Number of model tree columns) containing coefficients for Height growth
///\param|out] dD_result Matrix (5 year rows x Number of model tree columns) containing coefficients for Diameter growth
///\param[out] dV_result Matrix (5 year rows x Number of model tree columns) containing coefficients for Volume growth
///\param verbose If verbose == 1 print print debugging information during the simulation
///\pre The result matrices must have memory space for the results. 
extern void callprebas(double site_info[], int length, double* init_var, long rows, long cols,
		       double site_coord[], int start_5_year,
		       double* dH_result, double* dD_result, double* dV_result, int verbose);
#endif
