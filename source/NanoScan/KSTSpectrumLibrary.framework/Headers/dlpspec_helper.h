
/*****************************************************************************
**
**  Copyright (c) 2015 Texas Instruments Incorporated.
**
******************************************************************************
**
**  DLP Spectrum Library
**
*****************************************************************************/

// Inclusion Guard
#ifndef _DLPSPEC_HELPER_H
#define _DLPSPEC_HELPER_H

#include <stdbool.h>
#include <stdint.h>
#include "dlpspec_scan.h"
#include "dlpspec_types.h"

/**
 * @brief Describes a rectangle for drawing into the frame buffer
 * 
 * Contains information related to a rectangle for drawing including its
 * origin, dimensions, and pixel value.
 */
typedef struct
{
	uint32_t startX; /**< starting pixel column */
	uint32_t startY; /**< starting pixel row */
	uint32_t width; /**< rectangle width */
	uint32_t height; /**< rectangle height */
	uint32_t pixelVal; /**< rectangle color */
}RectangleDescriptor;


#ifdef __cplusplus
extern "C" {
#endif

void DrawRectangle(const RectangleDescriptor *r, const FrameBufferDescriptor *fb, const bool overwrite_pixel);
void dlpspec_copy_scanData_hdr_to_scanResults(const scanData *pScanData, scanResults *pResults);
DLPSPEC_ERR_CODE dlpspec_deserialize(void* struct_p, const size_t buffer_size, const BLOB_TYPES data_type);
DLPSPEC_ERR_CODE dlpspec_serialize(const void* struct_p, void *pBuffer, const size_t buffer_size, const BLOB_TYPES data_type);
void dlpspec_subtract_remove_dc_level(const scanData *pScanData, scanResults *pResults);
DLPSPEC_ERR_CODE dlpspec_interpolate_int_wavelengths(const double *desired_nm, double *reference_nm, int *reference_int, const int num_entries);
DLPSPEC_ERR_CODE dlpspec_interpolate_double_wavelengths(const double *desired_nm, double *reference_nm, double *reference_int, const int num_entries);
DLPSPEC_ERR_CODE dlpspec_matrix_mult(const double *a, const double*b, double*res, int p, int q, int r);
DLPSPEC_ERR_CODE dlpspec_matrix_transpose(double*a, double*res, int row,int col);
DLPSPEC_ERR_CODE dlpspec_compute_from_references(int ref_in1, int ref_in2, int ref_out1, int ref_out2, int in, int *out);

#ifdef __cplusplus      /* matches __cplusplus construct above */
}
#endif
#endif //_DLPSPEC_HELPER_H
