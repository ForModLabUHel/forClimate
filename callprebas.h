#ifndef CALLBREBAS_H
#define CALLBREBAS_H
#include <stdlib.h>
#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <Rembedded.h>
#include <string.h>
#include <windows.h>
#include <stdio.h>
#include <fcntl.h>
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
///\brief Read the Site info file for testing purposes
extern SEXP prebassiteinfo();
///\brief Read the model tree (Prebas layers) file for testing purposes
extern SEXP prebasinitvar();
///\brief Initialize the Embedded R environment
///\param verbose Print the status of the initialization
///\important The mandatory call in the beginning of a program using the Embedded R.
///\pre Initialize The Embedded R if the static variable \p init is 0.
///\post The static variable \p init is set to 1 (the Embedded R is initialized only once).
void initialize_R(int verbose);
///\brief Call dGrowthPrebas and return coeffients for Height, Diameter and Volume growths
///\param[in] site_info Vector of length 10 for values describing one site
///\param[in] length Length of the site_info vector (10 for a single site).
///\param[in] init_var Row first matrix for values describing model trees in Motti
///\param[in] rows Number of rows, i.e. variables describing model trees, in init_var (should be 7)
///\param[in] cols Number of columns, i.e. number of model trees, in init_var
///\param[in] site_coord Vector of 2 for the (x,y) coordinates of the site
///\param[in] start_5_year Start calendar year for the 5 year simulation period
///\param[out] dH_result Row first matrix (5 year rows x Number of model tree columns) containing coefficients for Height growth
///\param|out] dD_result Row first matrix (5 year rows x Number of model tree columns) containing coefficients for Diameter growth
///\param[out] dV_result Row first matrix (5 year rows x Number of model tree columns) containing coefficients for Volume growth
///\param]in] verbose If verbose == 1 print print debugging information during the simulation
///\pre The result matrices must have memory space allocated for the results. 
//void callprebas(double site_info[10], double init_var[7000], int numtrees, int treeproperties, double site_coord[2], int start_5_year, double dH_result[1000], double dD_result[1000], double dV_result[1000], int verbose);

void callprebas(int iround, double site_info[10], double init_var[7000], int cols, int rows, double site_coord[2], int start_5_year, double dH_result[1000], double dD_result[1000], double dV_result[1000], int verbose);
void callprebas2(double site_info[], int length, double* init_var, long rows, long cols,double site_coord[], int start_5_year,double* dH_result, double* dD_result, double* dV_result, int verbose);
void callprebase(int iround);

#endif
