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
#ifndef _DLPSPEC_SCAN_H
#define _DLPSPEC_SCAN_H


// Includes
#include <stdint.h>
#include <stddef.h>
#include "dlpspec_setup.h"
#include "dlpspec_types.h"

/**
 * @addtogroup group_scan
 *
 * @{
 */

/** Version number for future compatibility if changes are required */
#define CUR_SCANDATA_VERSION 1

/** Supported scan types */
typedef enum
{
// Library scan types: 0-127 reserved for future library expansion
    COLUMN_TYPE     = 0,
    HADAMARD_TYPE   = 1,
// User extended scan types: 128-255 reserved for customer expansion
}SCAN_TYPES;


/** 
 * @name Definitions for scanConfig
 * 
 * These values determine the DMD row (Y axis) locations and height for the 
 * partial height top, middle, and bottom scans. These three scans are used 
 * during calibration to map out the curvature and wavelength positions of the 
 * DMD.
 */
/// @{

#define SCAN_CFG_FILENAME_LEN 40
#define NANO_SER_NUM_LEN 8
#define SCAN_CONFIG_HEAD \
    uint8_t     scan_type; /**< must be defined in #SCAN_TYPES */ \
    uint16_t    scanConfigIndex; /**< Unique ID per spectrometer which is modified when the config is changed. Can be used to determine whether a cached version of the config is valid per spectrometer SN. */ \
    char        ScanConfig_serial_number[NANO_SER_NUM_LEN];  /**< Serial number of the spectrometer */\
    char        config_name[SCAN_CFG_FILENAME_LEN]; /**< User friendly scan configuration name for display */
#define SCAN_CONFIG_HEAD_FORMAT "cvc#c#"

#define SCAN_CONFIG_STUB         \
    uint16_t    wavelength_start_nm; /**< Minimum wavelength to start the scan from, in nm. */ \
    uint16_t    wavelength_end_nm;  /**< Maximum wavelength to end the scan at, in nm. */ \
    uint8_t     width_px;  /**< Pixel width of the patterns. Increasing this will increase SNR, but reduce resolution. */ \
    uint16_t    num_patterns; /**< Number of desired points in the spectrum. */ \
    uint16_t    num_repeats; /**< Number of times to repeat the scan on the spectromter before averaging the scans together and returning the results. This can be used to increase integration time. */
#define SCAN_CFG_STUB_FORMAT "vvcvv"

/**
 * @brief Describes a scan configuration.
 */
typedef struct
{
    SCAN_CONFIG_HEAD
    SCAN_CONFIG_STUB
}scanConfig;

/**
 * TPL format string for #scanConfig
 */
#define SCAN_CFG_FORMAT SCAN_CONFIG_HEAD_FORMAT SCAN_CFG_STUB_FORMAT

/// @}

/** 
 * @name Definitions for #scanData
 * 
 * These values determine the DMD row (Y axis) locations and height for the 
 * partial height top, middle, and bottom scans. These three scans are used 
 * during calibration to map out the curvature and wavelength positions of the 
 * DMD.
 */
/// @{
#define SCAN_DATA_VERSION \
    uint32_t    header_version; /**< Version number for future backward compatibility in the case that this structure changes. */
#define SCAN_DATA_VERSION_FORMAT  "u"

#define DATE_TIME_STRUCT \
    uint8_t     year; /**< years since 2000 */ \
    uint8_t     month; /**< months since January [0-11] */ \
    uint8_t     day; /**< day of the month [1-31] */ \
    uint8_t     day_of_week; /**< days since Sunday [0-6] */ \
    uint8_t     hour; /**< hours since midnight [0-23] */ \
    uint8_t     minute; /**< minutes after the hour [0-59] */ \
    uint8_t     second; /**< seconds after the minute [0-60] */
#define DATE_TIME_FORMAT "ccccccc"

#define SCAN_NAME_LEN 20
#define SCAN_DATA_HEAD_NAME                                     \
    char                scan_name[SCAN_NAME_LEN]; /**< User friendly scan name */ \

#define SCAN_DATA_HEAD_BODY                                     \
    int16_t             system_temp_hundredths; /**< System temperature in hundredths of a degree Celsius: 123 = 1.23 degC */ \
    int16_t             detector_temp_hundredths; /**< Detector temperature in hundredths of a degree Celsius: 123 = 1.23 degC */ \
    uint16_t            humidity_hundredths; /**< Relative humidity in hundredths of a percent: 123 = 1.23% relative humidity */ \
    uint16_t            lamp_pd; /**< Lamp monitor photodiode value */ \
    uint32_t            scanDataIndex; /**< Unique index for scan. Can be used to determine whether a scan has already been downloaded from a particular spectrometer SN. */ \
    calibCoeffs 	    calibration_coeffs; /**< Calibration coefficients for the spectrometer this scan was taken with */ \
    char                serial_number[NANO_SER_NUM_LEN]; /**< Serial number of the spectrometer this scan was taken with */ \
    uint16_t            adc_data_length; /**< Number of ADC samples in adc_data array */ \
    uint8_t             black_pattern_first; /**< First occurrence of an all-off DMD pattern during the scan, zero indexed. */ \
    uint8_t             black_pattern_period; /**< Period of black pattern recurrence */ \
    uint8_t				pga; /**< PGA gain used during this scan */

#define SCAN_DATA_HEAD SCAN_DATA_HEAD_NAME DATE_TIME_STRUCT SCAN_DATA_HEAD_BODY

#define SCAN_DATA_HEAD_FORMAT "c#" DATE_TIME_FORMAT "jjvvu" "$(" CALIB_COEFFS_FORMAT ")" "c#vccc"


/** 
 * Could be reduced to `MAX_PATTERNS_PER_SCAN + ((MAX_PATTERNS_PER_SCAN + 23)/24)`.
 * Kept at 864 for legacy reasons even though it's longer than necessary
 */ 
#define ADC_DATA_LEN 864

/**
 * @brief Data output of a scan.
 * 
 * Contains all necessary information to interpret into an intensity spectrum.
 */
typedef struct
{
    SCAN_DATA_VERSION
    SCAN_DATA_HEAD_NAME
    DATE_TIME_STRUCT
    SCAN_DATA_HEAD_BODY
    SCAN_CONFIG_HEAD
    SCAN_CONFIG_STUB
    int32_t             adc_data[ADC_DATA_LEN];
} scanData;

#define ADC_DATA_FORMAT "i#"

/**
 * TPL format string for #scanData
 */
#define SCAN_DATA_FORMAT SCAN_DATA_VERSION_FORMAT SCAN_DATA_HEAD_FORMAT SCAN_CFG_FORMAT ADC_DATA_FORMAT

/**
 * Safe length for a serialized #scanData blob
 */
#define SCAN_DATA_BLOB_SIZE (sizeof(scanData)+100)

/// @}

/**
 * @brief Scan results, which is generated when interpreting data from #scanData.
 */
typedef struct
{
    SCAN_DATA_VERSION
    SCAN_DATA_HEAD_NAME
    DATE_TIME_STRUCT
    SCAN_DATA_HEAD_BODY
    scanConfig      	cfg; /**< Scan configuration used to take this scan */
    double              wavelength[ADC_DATA_LEN]; /**< Computed wavelength center in nm for each corresponding intensity value */
    int                 intensity[ADC_DATA_LEN]; /**< Computed intensity for each corresponding wavelength center */
    int                 length; /**< number of valid elements in the wavelength and intensity arrays */
} scanResults;


#ifdef __cplusplus
extern "C" {
#endif

DLPSPEC_ERR_CODE dlpspec_scan_read_configuration(void *pBuf, const size_t bufSize);
DLPSPEC_ERR_CODE dlpspec_scan_write_configuration(const scanConfig *pCfg, void *pBuf, const size_t bufSize);
DLPSPEC_ERR_CODE dlpspec_scan_interpret(const void *pBuf, const size_t bufSize, scanResults *pResults);
DLPSPEC_ERR_CODE dlpspec_scan_write_data(const scanData *pData, void *pBuf, const size_t bufSize);
DLPSPEC_ERR_CODE dlpspec_scan_interpReference(const void *pRefCal, size_t calSize, const void *pMatrix, size_t matrixSize, const scanResults *pScanResults, scanResults *pRefResults);
int32_t dlpspec_scan_genPatterns(const scanConfig* pCfg, const calibCoeffs *pCoeffs, const FrameBufferDescriptor *pFB);
DLPSPEC_ERR_CODE dlpspec_scan_bendPatterns(const FrameBufferDescriptor *pFB , const calibCoeffs* calCoeff, const int32_t numPatterns);

#ifdef __cplusplus      /* matches __cplusplus construct above */
}
#endif

/** @} // group group_scan
 *
 */

#endif //_DLPSPEC_SCAN_H
