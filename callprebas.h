#ifndef CALLBREBAS_H
#define CALLBREBAS_H
#include <stdlib.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <Rembedded.h>
#include <string.h>
///Invokes the R command source(rfile), e.g. source("coefficients.r")
extern void source(const char *name);
///Invokes the R command library(rfile), e.g. source("Rprebasso")
extern void library(const char *name);
///\brief Call dGrowthPrebas and return coeffients for Height, Diameter and Volume growths
///\param site_info Vector of length 10 for values describing one site
///\param length Length of the site_info vector (10 for a single site).
///\param init_var Matrix for values describing model trees in Motti
///\param rows Number of rows, i.e. variables describing model trees, in init_var (should be 7)
///\param cols Number of columns, i.e. number of model trees, in init_var
///\param climate_model Climate change model to be chosen
///\param climID Climate reagion to be chosen
///\param[out] dH_result Matrix (5 year rows x Number of model tree columns) containing coefficients for Height growth
///\param|out] dD_result Matrix (5 year rows x Number of model tree columns) containing coefficients for Diameter growth
///\param[out] dV_result Matrix (5 year rows x Number of model tree columns) containg coefficients for Volume growth
///\param verbose If verbose > 0 print print \p site_info and \p init_var contents 
///\todo climate_model: For the real climate data decide how to express Climate scenario wanted
///\todo climID: For the real climate data decide how to express the geographic location wanted  
extern void callprebas(double site_info[],int length, double* init_var,long rows,long cols,
		       char* climate_model,int climID,double* dH_result,double* dD_result,
		       double* dV_result,int verbose);
#endif
