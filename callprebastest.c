#include "callprebas.h"

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
  source("prebascoefficients.r",verbose);
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
    callprebas(site_info_v,site_info_length,&tree_info_m[0][0],r,c,coord,start_5_year,&dH[0][0],&dD[0][0],&dV[0][0],verbose);
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

