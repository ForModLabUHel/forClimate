#include "callprebas.h"

SEXP what_sexp_is_this(SEXP x) {
  Rprintf("SEXPTYPE: %i = %s \n", TYPEOF(x), type2char(TYPEOF(x)));
  printf("type of SEXP = %d\n", TYPEOF(x));
  printf("description of SEXP type = %s\n",type2char(TYPEOF(x)));
  printf("lenght of SEXP = %d \n",length(x));
  
  return R_NilValue;
}

SEXP call_r_from_c_with_lang1(void) {

  SEXP my_call = PROTECT(lang1(
    PROTECT(Rf_install("getwd"))
  ));

  SEXP my_result = PROTECT(eval(my_call, R_GlobalEnv)); 
  what_sexp_is_this(my_result);
  UNPROTECT(3);
  return my_result;
}

void print_vector(double v[],int length)
{
  printf("Vector length %d items ",length);
  for (int i=0; i < length;i++){
    printf("%0.5f ",v[i]);
  }
  printf("\n");
}

void print_matrix(double* m,int rows,int cols)
{
  printf("Matrix rows %d columns %d\n",rows,cols);
  for (int i=0; i < rows; i++){
     for (int j=0; j < cols; j++){
       //Row first data.
       //(https://en.wikipedia.org/wiki/Row-_and_column-major_order)
       printf("%0.5f ",m[i*cols+j]);
     }
     printf("\n"); 
    }
}

void source(const char *name,int verbose)
{
  SEXP e;
  if (verbose==1){
    printf("Sourcing file %s for R\n",name);
  }
  int errorOccurred;
  PROTECT(e = lang2(install("source"), mkString(name)));
  R_tryEval(e, R_GlobalEnv, &errorOccurred);

  if (verbose==1){
    printf(" erroroccured %d\n", errorOccurred);
  }

  UNPROTECT(1);
}

void library(const char *name, int verbose)
{
  SEXP e;
  if (verbose == 1){
    printf("R library call for file %s\n",name);
  }
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

///\brief Read the model tree (Prebas layers) file for testing purposes
SEXP prebasinitvar()
{
  SEXP initvar_call;
  initvar_call =  PROTECT(lang2(install("initvar"),mkString("data/TestTreeInfo.csv")));
  int errorOccurred;
  SEXP retval_treeinfo = R_tryEval(initvar_call, R_GlobalEnv, &errorOccurred);
  UNPROTECT(1);
  return retval_treeinfo;
}

void initialize_R(int verbose)
{
  static int init=0;
  if (!init){
    if (verbose == 1){
      printf("Initializing R environment with  Rf_initEmbeddedR\n");
    }
    //Initialize R
    //Initialize the embedded R environment. The initialization must be relocated
    //in the main program to the context of 'callprebas' when linking together MottiWB and and dGrowthPrebas 
    int r_argc = 2;
    char* r_argv[] = { "R", "--silent" };
    Rf_initEmbeddedR(r_argc, r_argv);
    init=1;
  }
  else{
    if (verbose==1){
      printf("The R environment already initialized (no initialization)\n");
    }
  }
}

void callprebas(int iround,double site_info[10], double init_var[7000], int cols, int rows, double site_coord[2], int start_5_year, double dH_result[1000], double dD_result[1000], double dV_result[1000], int verbose)

{
   FILE *fout1 = freopen("CONIN$", "r", stdin);
   FILE *fout2 = freopen("CONOUT$", "w", stderr);
   FILE *fout3 = freopen("CONOUT$", "w", stdout);
    HANDLE hStdout = CreateFile("CONOUT$",  GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE,
                                NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);   
   
   int length = 10;
   
   if (verbose){
    printf("Testing callprebas, call number %d\n", iround);
    printf("In C callprebas\n");
    printf("siteifno-length %d\n",length);
    printf("simyear %d\n",start_5_year);
    printf("init_var rows %d\n",rows);
    printf("init_var cols %d\n",cols);
    printf("verbose %d\n",verbose);
    printf("---------------\n");
    printf("initializing R\n");
  }
   if (iround == 1 )
  {
    initialize_R(verbose);
    source("Rsrc/dGrowthPrebas.r",verbose);
    source("Rsrc/prebascoefficients.r",verbose);
  }
	
  //if (length != 10){
  //  printf("Site Info vector must be 10 long instead of %d \n",length);
  //  exit(0);
 // }
  if (verbose){
    printf("SiteInfo\n");
    print_vector(site_info,length);
    printf("TreeInfo\n");
    print_matrix(init_var,rows,cols);
    printf("Cooordinates\n");
    print_vector(site_coord,2);
    printf("---------------\n");
    printf("Copy Site Info data to R vector\n");  
  }
  //Copy Site Info data to R vector
  SEXP site_info_r = PROTECT(allocVector(REALSXP,length));
  //Note SEXP internals are hidden but the function REAL
  //provides access to the vector data
    memcpy(REAL(site_info_r),site_info,length*sizeof(double));
  
//  if (verbose){
//    what_sexp_is_this(site_info_r);
//  }
  //Copy InitVar (Motti model trees, Prebas layers) data to R matrix  
  if (verbose){
    printf("Copy InitVar (Motti model trees, Prebas layers) data to R matrix\n");  
  }
   SEXP init_var_r = PROTECT(allocMatrix(REALSXP,rows,cols));
  //REAL provides access to matrix data as double* vector.
  double* init_var_v = REAL(init_var_r);
  for (int i=0; i < rows; i++){
     for (int j=0; j < cols; j++){
       //Transfering from row first data to R column first.
       //(https://en.wikipedia.org/wiki/Row-_and_column-major_order)
       init_var_v[i+rows*j]=init_var[i*cols+j];
     }
  }
  //Copy coordinates to R vector
   if (verbose){
   printf("Copy coordinates to R vector\n");  
   }
  SEXP site_coord_r = PROTECT(allocVector(REALSXP,2));
  memcpy(REAL(site_coord_r),site_coord,2*sizeof(double));
  //Copy start of 5 year period to R integer
  SEXP start_5_year_r = ScalarInteger(start_5_year);
  //Copy verbose to R integer
  SEXP verbose_r = ScalarInteger(verbose);  
  //Set-up the call to prebascoeffients in R (see coeffiecients.r)
 if (verbose){
     printf("Set-up the call to prebascoeffients in R\n");  
 }
  
//  SEXP funfun=Rf_install("prebascoefficients");
//  printf("Rf_install over\n");  
//  if(!isFunction(funfun)) error("'funfun' must be a function");
//  if(isFunction(funfun)) printf("'funfun' is a function");
 if (verbose){
   printf("Calling prebascoefficients, start 5 period from %d\n",start_5_year);
   printf("coeff_call initiated\n");  
 }
//  SEXP coeff_call = PROTECT(lang6(funfun,site_info_r,init_var_r,site_coord_r,start_5_year_r,verbose_r));
SEXP coeff_call;
coeff_call = PROTECT(lang6(install("prebascoefficients"),site_info_r,init_var_r,site_coord_r,start_5_year_r,verbose_r));
int errorOccurred;
  //Return value is a list for dH, dD and dV, coeffients for heigth, diameter and volume growth. 
 if (verbose){
     printf("R_tryEval\n");  
 }
  SEXP prebascoeff = R_tryEval(coeff_call, R_GlobalEnv, &errorOccurred);
  //Retrieve dH,dD,dV from the prbascoeff vector
 if (verbose){
     printf(" erroroccured %d\n", errorOccurred);
    printf("Retrieve dH,dD,dV from the prbascoeff vector\n");  
 }
  int l = XLENGTH(prebascoeff);
 if (verbose){
     printf("First dH\n");  
 }
  SEXP dH = VECTOR_ELT(prebascoeff,0);
 if (verbose){
     printf("Then dD\n");  
 }
  SEXP dD = VECTOR_ELT(prebascoeff,1);
 if (verbose){
     printf("And finally dV\n");  
 }
  SEXP dV = VECTOR_ELT(prebascoeff,2);
  //Retrieve the C vectors 
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
  if (verbose){
    printf("In C callprebas return values\n");
    printf("-----------------------------\n");
    printf("dH\n");
    print_matrix(dH_result,5,cols);
    printf("dD\n");
    print_matrix(dD_result,5,cols);
    printf("dV\n");
    print_matrix(dV_result,5,cols);
    printf("------------------------------\n");
  }
  UNPROTECT(4);

  if (verbose){
    printf("exit callprebas, return to mainprog\n");
  }

fclose(fout1);
fclose(fout2);
fclose(fout3);
return;

}


void callprebas2(double site_info[], int length, double* init_var, long rows, long cols,
		double site_coord[], int start_5_year,
		double* dH_result, double* dD_result, double* dV_result, int verbose)
{
  if (length != 10){
    printf("Site Info vector must be 10 long instead of %d \n",length);
    exit(0);
  }
  if (verbose){
    printf("In C callprebas\n");
    printf("---------------\n");
    printf("SiteInfo\n");
    printf("---------------\n");
    print_vector(site_info,length);
    printf("---------------\n");
    printf("TreeInfo\n");
    printf("---------------\n");
    print_matrix(init_var,rows,cols);
    printf("---------------\n");
    printf("Cooordinates\n");
    print_vector(site_coord,2);
    printf("---------------\n");
    printf("Calling prebascoefficients, start 5 period from %d\n",start_5_year);
    printf("---------------\n");
  }
  //Copy Site Info data to R vector
  SEXP site_info_r = PROTECT(allocVector(REALSXP,length));
  //Note SEXP internals are hidden but the function REAL
  //provides access to the vector data
  memcpy(REAL(site_info_r),site_info,10*sizeof(double));
  //Copy InitVar (Motti model trees, Prebas layers) data to R matrix  
  SEXP init_var_r = PROTECT(allocMatrix(REALSXP,rows,cols));
  //REAL provides access to matrix data as double* vector.
  double* init_var_v = REAL(init_var_r);
  for (int i=0; i < rows; i++){
     for (int j=0; j < cols; j++){
       //Transfering from row first data to R column first.
       //(https://en.wikipedia.org/wiki/Row-_and_column-major_order)
       init_var_v[i+rows*j]=init_var[i*cols+j];
     }
  }
  //Copy coordinates to R vector
  SEXP site_coord_r = PROTECT(allocVector(REALSXP,2));
  memcpy(REAL(site_coord_r),site_coord,2*sizeof(double));
  //Copy start of 5 year period to R integer
  SEXP start_5_year_r = ScalarInteger(start_5_year);
  //Copy verbose to R integer
  SEXP verbose_r = ScalarInteger(verbose);  
  //Set-up the call to prebascoeffients in R (see coeffiecients.r)
  SEXP coeff_call;
  coeff_call = PROTECT(lang6(install("prebascoefficients"),site_info_r,init_var_r,site_coord_r,start_5_year_r,verbose_r));
  int errorOccurred;
  //Return value is a list for dH, dD and dV, coeffients for heigth, diameter and volume growth. 
  SEXP prebascoeff = R_tryEval(coeff_call, R_GlobalEnv, &errorOccurred);
  //Retrieve dH,dD,dV from the prbascoeff vector
  int l = XLENGTH(prebascoeff);
  SEXP dH = VECTOR_ELT(prebascoeff,0);
  SEXP dD = VECTOR_ELT(prebascoeff,1);
  SEXP dV = VECTOR_ELT(prebascoeff,2);
  //Retrieve the C vectors 
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
  if (verbose){
    printf("In C callprebas return values\n");
    printf("-----------------------------\n");
    printf("dH\n");
    print_matrix(dH_result,5,cols);
    printf("dD\n");
    print_matrix(dD_result,5,cols);
    printf("dV\n");
    print_matrix(dV_result,5,cols);
    printf("------------------------------\n");
  }
  UNPROTECT(4);
}

#ifdef MAIN

int main()
{
  //Verbose argument for the test program passed on to various functions including callprebas
  int verbose = 1;
  printf("Testing callprebas\n");
  printf("------------------\n");
  printf("Initializing Embedded R\n");
  //Initialize the embedded R environment. 
  initialize_R(verbose);
  printf("Sourcing R files\n");
  source("Rsrc/dGrowthPrebas.r",verbose);
  source("Rsrc/prebascoefficients.r",verbose);
  printf("Test loop begins\n");
  printf("---------------------\n");
  //Test the call in a loop. Create initial data each time 
  for (int i=0; i < 5; i++){
    //Sample site info
    SEXP siteinfo = prebassiteinfo();
    double* site_info_v = REAL(siteinfo);
    int site_info_length =  LENGTH(siteinfo);
    //Sample model trees (prebas Layers)
    SEXP treeinfo = prebasinitvar();
    SEXP dims = GET_DIM(treeinfo);
    int r = INTEGER(dims)[0];
    int c = INTEGER(dims)[1];
    //Sample coordinate
    double coord[2];
    coord[0]=22.8;
    coord[1]=62.2;
    //Sample start for 5 year period
    int start_5_year = 2025;
    //Return values
    double dH[5][c];
    double dD[5][c];
    double dV[5][c];
    //Transfer R column first matrix to C row first
    double* tree_info_v = REAL(treeinfo);
    double tree_info_m[r][c];
    for (int i=0; i < r; i++){
      for (int j=0; j < c; j++){
	tree_info_m[i][j] = tree_info_v[i+r*j];
      }
    }
    
    printf("Call number %d to callprebas\n",i+1);
    callprebas2(site_info_v,site_info_length,&tree_info_m[0][0],r,c,coord,start_5_year,&dH[0][0],&dD[0][0],&dV[0][0],verbose);
    printf("dH from Prebas coeffients\n");
    print_matrix(&dH[0][0],5,c);
    printf("dD from Prebas coeffients\n");
    print_matrix(&dD[0][0],5,c);
    printf("dV from Prebas coefficients\n");
    print_matrix(&dV[0][0],5,c);
    printf("%d call(s) to callprebas done\n\n",i+1);
  }
  printf("All done\n");
  printf("----------------------\n");
}


#endif

void callprebase(int iround)
{
  //Verbose argument for the test program passed on to various functions including callprebas
   freopen("CONIN$", "r", stdin);
   freopen("CONOUT$", "w", stderr);
   freopen("CONOUT$", "w", stdout);int length = 10;
    HANDLE hStdout = CreateFile("CONOUT$",  GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE,
                                NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);   
  int verbose = 1;
  printf("Testing callprebas %d \n", iround);
  printf("------------------\n");
  if (iround == 1 )
  {
  printf("Initializing Embedded R\n");
  //Initialize the embedded R environment. 
  initialize_R(verbose);
  printf("Sourcing R files\n");
  source("Rsrc/dGrowthPrebas.r",verbose);
  source("prebascoefficients.r",verbose);
  }
  printf("Test loop begins\n");
  printf("---------------------\n");
  //Test the call in a loop. Create initial data each time 
  for (int i=0; i < 5; i++){
    //Sample site info
    SEXP siteinfo = prebassiteinfo();
    double* site_info_v = REAL(siteinfo);
    int site_info_length =  LENGTH(siteinfo);
    //Sample model trees (prebas Layers)
    SEXP treeinfo = prebasinitvar();
    SEXP dims = GET_DIM(treeinfo);
    int r = INTEGER(dims)[0];
    int c = INTEGER(dims)[1];
    //Sample coordinate
    double coord[2];
    coord[0]=22.8;
    coord[1]=62.2;
    //Sample start for 5 year period
    int start_5_year = 2025;
    //Return values
    double dH[5][c];
    double dD[5][c];
    double dV[5][c];
    //Transfer R column first matrix to C row first
    double* tree_info_v = REAL(treeinfo);
    double tree_info_m[r][c];
    for (int i=0; i < r; i++){
      for (int j=0; j < c; j++){
	tree_info_m[i][j] = tree_info_v[i+r*j];
      }
    }
    
    printf("Call number %d to callprebas\n",i+1);
    callprebas2(site_info_v,site_info_length,&tree_info_m[0][0],r,c,coord,start_5_year,&dH[0][0],&dD[0][0],&dV[0][0],verbose);
    printf("dH from Prebas coeffients\n");
    print_matrix(&dH[0][0],5,c);
    printf("dD from Prebas coeffients\n");
    print_matrix(&dD[0][0],5,c);
    printf("dV from Prebas coefficients\n");
    print_matrix(&dV[0][0],5,c);
    printf("%d call(s) to callprebas done\n\n",i+1);
  }
  printf("All done\n");
  printf("----------------------\n");
}
