#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include "mex.h"
#include "matrix.h"
#include "uc480.h"

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if (nlhs != 1)
        mexErrMsgTxt("One output the image.");
    if (nrhs != 3)
        mexErrMsgTxt("There must be three inputs: hCam Width Height");

    HCAM phCam = 0;
    INT result;

    INT32_T* rhd = (INT32_T*)mxGetData(prhs[0]);
    phCam = (HCAM)rhd[0];
    rhd = (INT32_T*)mxGetData(prhs[1]);
    int width = (int)rhd[0];
    rhd = (INT32_T*)mxGetData(prhs[2]);
    int height = (int)rhd[0];

    char* pImage = NULL;
    int imgID = 0;
    char errbuffer[50];

    pImage = (char*)mxCalloc(width * height + 1, sizeof(char*));

    if (pImage == NULL)
    {
        is_ExitCamera(phCam);
        mexErrMsgTxt("Failed to mxCalloc Mem.");
        return;
    }

    // start live video

    result = is_CaptureVideo(phCam, IS_WAIT);
    printf("sucess\n");
    
    if (result != IS_SUCCESS)
    {
        mxFree(pImage);
        is_ExitCamera(phCam);
        sprintf(errbuffer, "Failed to Set Alloc Mem: r = %i", result);
        mexErrMsgTxt(errbuffer);
        return;
    }
}