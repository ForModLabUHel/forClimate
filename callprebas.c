#include "callprebas.h"

void source(const char *name)
{
  SEXP e;
 
  PROTECT(e = lang2(install("source"), mkString(name)));
  R_tryEval(e, R_GlobalEnv, NULL);
  UNPROTECT(1);
}

void library(const char *name)
{
  SEXP e;
 
  PROTECT(e = lang2(install("library"), mkString(name)));
  R_tryEval(e, R_GlobalEnv, NULL);
  UNPROTECT(1);
}

SEXP prebassiteinfo()
{
  SEXP siteinfo_call;
  siteinfo_call = PROTECT(lang2(install("siteinfo"),mkString("data/TestSiteInfo.csv")));
  int errorOccurred;
  SEXP retval_siteinfo = R_tryEval(siteinfo_call, R_GlobalEnv, &errorOccurred);
  UNPROTECT(1);
  return retval_siteinfo;
}

SEXP prebasinitvar()
{
  SEXP initvar_call;
  initvar_call =  PROTECT(lang2(install("initvar"),mkString("data/TestTreeInfo.csv")));
  int errorOccurred;
  SEXP retval_treeinfo = R_tryEval(initvar_call, R_GlobalEnv, &errorOccurred);
  UNPROTECT(1);
  return retval_treeinfo;
}


void callprebas(double site_info[],int length, double* init_var,long rows,long cols,
		char* climate_model,int climID,double* dH_result,double* dD_result,
		double* dV_result)
{
   SEXP site_info_v = PROTECT(allocVector(REALSXP,length));
  //Note SEXP internals are hidden but the function REAL
  //provides access to the vector data
  memcpy(REAL(site_info_v),site_info,10 * sizeof(double));
  SEXP init_var_m = PROTECT(allocMatrix(REALSXP,rows,cols));
  double* init_var_v = REAL(init_var_m);
  for (int i=0; i < rows; i++){
     for (int j=0; j < cols; j++){
       //REAL provides access to r_arg matrix data as double* vector crm.
       //Transfering from row first data to R column first.
       //(https://en.wikipedia.org/wiki/Row-_and_column-major_order)
       init_var_v[i+rows*j]=init_var[i*cols+j];
     }
   }
  //Set-up the call to prebascoeffients in R (see coeffiecients.r)
  SEXP coeff_call;
  SEXP climid_sexp = ScalarInteger(climID);
  coeff_call = PROTECT(lang5(install("prebascoefficients"),site_info_v,init_var_m,mkString(climate_model),climid_sexp));
  int errorOccurred;
  //Return value is a list for dH, dD and dV, coeffients for heigth, diameter and volume growth. 
  SEXP prebascoeff = R_tryEval(coeff_call, R_GlobalEnv, &errorOccurred);
  //Retrieve marix values
  int l = XLENGTH(prebascoeff);
  SEXP dH = VECTOR_ELT(prebascoeff,0);
  SEXP dD = VECTOR_ELT(prebascoeff,1);
  SEXP dV = VECTOR_ELT(prebascoeff,2);
  double* dH_c = REAL(dH);
  double* dD_c = REAL(dD);
  double* dV_c = REAL(dV);
  SEXP dims1 = GET_DIM(dV);
  long r1 = INTEGER(dims1)[0];
  long c1 = INTEGER(dims1)[1];
  //Transfer data from R column first to C row first in result matrices
  for (int i = 0; i < r1; i++){
    for (int j = 0; j < c1; j++){
      dH_result[i*c1+j] = dH_c[i+r1*j];
    }
  }
  for (int i = 0; i < r1; i++){
    for (int j = 0; j < c1; j++){
      dD_result[i*c1+j] = dD_c[i+r1*j];
    }
  }
  for (int i = 0; i < r1; i++){
    for (int j = 0; j < c1; j++){
      dV_result[i*c1+j] = dV_c[i+r1*j];
    }
  }
}

#ifdef MAIN
int main()
{
  //Initialize the embedded R environment. The initialization must be relocated
  //to the context of 'callprebas' when linking together MottiWB and and dGrowthPrebas 
  int r_argc = 2;
  char* r_argv[] = { "R", "--silent" };
  Rf_initEmbeddedR(r_argc, r_argv);

  //These two calls sourcing R files needed may need to be relocated
  //to the context of 'callprebas'  when linking together MottiWB and and dGrowthPrebas 
  source("prebascoefficients.r");
  source("Rsrc/dGrowthPrebas.r");
  
  SEXP siteinfo = prebassiteinfo();
  double* site_info_val = REAL(siteinfo);
  int length_v =  LENGTH(siteinfo);
  if (isVector(siteinfo)){
    printf("Site info vector\n");
    for (int i = 0; i < LENGTH(siteinfo); i++){
       printf("%0.4f ", site_info_val[i]);
     }
    printf("\n");
  }
  SEXP treeinfo = prebasinitvar();
  SEXP dims = GET_DIM(treeinfo);
  printf("Tree info matrix dimensions %ld\n",LENGTH(dims));
  long r = INTEGER(dims)[0];
  long c = INTEGER(dims)[1];
  double* tree_info_v = REAL(treeinfo);
  double tree_info_m[r][c];
  printf("Rows %ld Columns %ld\n",r,c);
  for (int i=0; i < r; i++){
    for (int j=0; j < c; j++){
      printf("%0.5f ", tree_info_v[i+r*j]);
      tree_info_m[i][j] = tree_info_v[i+r*j];
    }
    printf("\n");
  }
  double dH[5][c];
  double dD[5][c];
  double dV[5][c];
  callprebas(site_info_val,length_v,&tree_info_m[0][0],r,c,"CanESM2",2,&dH[0][0],&dD[0][0],&dV[0][0]);
  printf("dH from Prebas coeffients\n");
  for (int i = 0; i < 5; i++){
    for (int j = 0; j < c; j++){
      printf("%0.7f ",dH[i][j]);
    }
    printf("\n");
  }
  printf("dD from Prebas coeffients\n");
  for (int i = 0; i < 5; i++){
    for (int j = 0; j < c; j++){
      printf("%0.7f ",dD[i][j]);
    }
    printf("\n");
  }
  printf("dV from Prebas coefficients\n");
  for (int i = 0; i < 5; i++){
    for (int j = 0; j < c; j++){
      printf("%0.7f ",dV[i][j]);
    }
    printf("\n");
  }
  printf("Done\n");
  return 0;
}
#endif
