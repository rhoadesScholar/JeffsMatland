#include <mex.h>
#include "dxAviHelper.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[]){
	dxAviHelper * avi_helper;
	avi_helper = (dxAviHelper*)mxGetPr(prhs[0]);
	delete avi_helper;
}
