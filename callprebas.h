#ifndef CALLBREBAS_H
#define CALLBREBAS_H
#include <stdlib.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <Rembedded.h>
#include <string.h>
///\brief Print the vector content
///\param v The vector
///\param length The vector length
extern void print_vector(double v[],int length);
///\brief Print the 2D matrix content
///\param m The 2D matrix
///\param rows The number of rows in the matrix \p m
///\param cols The number of columns in the matrix \p m
extern void print_matrix(double* m,int rows,int cols);
///\brief Execute the `source` R command
///\param name The R file name
///\param verbose Print the file \p name on standard out
extern void source(const char *name,int verbose);
///\brief Execute the R `library` command
///\param name The R file name
///\param verbose Print the file \p name on standard out
extern void library(const char *name,int verbose);
///\brief Initialize the Embedded R environment
///\param verbose Print the status of the initialization
///\important The mandatory call in the beginning of a program using the Embedded R.
///\pre Initialize The Embedded R if the static variable \p init is 0.
///\post The static variable \p init is set to 1 (the Embedded R is initialized only once).
void initialize_R(int verbose);
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
///\pre The result matrices must have memory space allocated for the results. 
extern void callprebas(double site_info[], int length, double* init_var, long rows, long cols,
		       double site_coord[], int start_5_year,
		       double* dH_result, double* dD_result, double* dV_result, int verbose);
#endif
