/*****************************************************************************
**
**  Copyright (c) 2015 Texas Instruments Incorporated.
**
******************************************************************************
**
**  DLP Spectrum Library
**
*****************************************************************************/

#ifndef VERSION_H_
#define VERSION_H_

// Version format: MAJOR.MINOR.BUILD
#define DLPSPEC_VERSION_MAJOR 1
#define DLPSPEC_VERSION_MINOR 1
#define DLPSPEC_VERSION_BUILD 4

/* Version History
1.1.4
Fixed a deserialization error checking issue when loading data on targets which 
pack the associated struct more tightly than the source system that seralized
the data

1.1.3
Added workaround for DLP NIRscan Nano Tiva firmware ≤ 1.1.7 BLE transfer
bug which was overwriting the first few bytes of the reference calibration
matrix and scan reference calibration coefficients. Workaround can be disabled
by #undef NANO_PRE_1_1_8_BLE_WORKAROUND

1.1.2
Changed MAX_PATTERNS_PER_SCAN to 624
Fixed klocworks reported issues
Added scanData version check before interpreting data

1.1
Increased error reporting and input checking
Column scan pattern generation increased to parity with Hadamard scans

1.0
Initial release

0.9
Bugfixes in Hadamard in genPatDef, requiring both Tiva and host to match

0.8
Hadamard support added

*/

#define DLPSPEC_CALIB_VER 1
#define DLPSPEC_REFCAL_VER 3
#define DLPSPEC_CFG_VER 1

#endif /* VERSION_H_ */
