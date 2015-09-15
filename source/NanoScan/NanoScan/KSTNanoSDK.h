//
//  KSTNanoSDK.h
//  NanoScan
//
//  Created by Robert Kressin on 1/1/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <KSTSpectrumLibrary/KSTSpectrumLibrary.h>

#pragma mark - NIRScan Nano Services
extern NSString *const kNanoServiceGeneralInformationUUIDString;
extern NSString *const kNanoServiceCommandUUIDString;
extern NSString *const kNanoServiceCurrentTimeUUIDString;
extern NSString *const kNanoServiceCalibrationUUIDString;
extern NSString *const kNanoServiceConfigurationUUIDString;
extern NSString *const kNanoServiceScanDataUUIDString;

#pragma mark General Information Service Characteristics
extern NSString *const kNanoCharacteristicTemperatureMeasurementUUIDString;
extern NSString *const kNanoCharacteristicHumidityMeasurementUUIDString;
extern NSString *const kNanoCharacteristicDeviceStatusUUIDString;
extern NSString *const kNanoCharacteristicErrorStatusUUIDString;
extern NSString *const kNanoCharacteristicTemperatureThresholdUUIDString;
extern NSString *const kNanoCharacteristicHumidityThresholdUUIDString;
extern NSString *const kNanoCharacteristicNumberOfUsageHoursUUIDString;
extern NSString *const kNanoCharacteristicNumberOfBatteryRechargeCyclesUUIDString;
extern NSString *const kNanoCharacteristicTotalLampHoursUUIDString;
extern NSString *const kNanoCharacteristicErrorLogUUIDString;

#pragma mark Command Service
extern NSString *const kNanoCharacteristicInternalCommandUUIDString;

#pragma mark Current Time Service
extern NSString *const kNanoCharacteristicCurrentTimeUUIDString;

#pragma mark Calibration Service
extern NSString *const kNanoCharacteristicSpectrumCalCoefficientsUUIDString;
extern NSString *const kNanoCharacteristicReadReferenceCalCoefficientsUUIDString;
extern NSString *const kNanoCharacteristicReturnReferenceCalCoefficientsUUIDString;

#pragma mark Configuration Service
extern NSString *const kNanoCharacteristicNumberOfStoredConfigurationsUUIDString;
extern NSString *const kNanoCharacteristicReadStoredConfigurationsListUUIDString;
extern NSString *const kNanoCharacteristicReturnStoredConfigurationsListUUIDString;
extern NSString *const kNanoCharacteristicReadScanConfigurationDataUUIDString;
extern NSString *const kNanoCharacteristicReturnScanConfigurationDataUUIDString;

#pragma mark Scan Service
extern NSString *const kNanoCharacteristicNumberOfStoredScansUUIDString;
extern NSString *const kNanoCharacteristicRequestStoredScanIndicesListUUIDString;
extern NSString *const kNanoCharacteristicGetStoredScanIndicesListUUIDString;
extern NSString *const kNanoCharacteristicSetScanNameStubUUIDString;
extern NSString *const kNanoCharacteristicStartScanUUIDString;
extern NSString *const kNanoCharacteristicClearScanUUIDString;
extern NSString *const kNanoCharacteristicGetScanNameUUIDString;
extern NSString *const kNanoCharacteristicReturnScanNameUUIDString;
extern NSString *const kNanoCharacteristicGetScanTypeUUIDString;
extern NSString *const kNanoCharacteristicReturnScanTypeUUIDString;
extern NSString *const kNanoCharacteristicGetScanTimestampUUIDString;
extern NSString *const kNanoCharacteristicReturnScanTimestampUUIDString;
extern NSString *const kNanoCharacteristicGetScanBlobVersionUUIDString;
extern NSString *const kNanoCharacteristicReturnScanBlobVersionUUIDString;
extern NSString *const kNanoCharacteristicGetScanDataUUIDString;
extern NSString *const kNanoCharacteristicReturnScanDataUUIDString;

#pragma mark - State Notifications
static NSString *kKSTNanoSDKStateChanged                    = @"kKSTNanoSDKStateChanged";
static NSString *kKSTNanoSDKBusy                            = @"kKSTNanoSDKBusy";
static NSString *kKSTNanoSDKDownloadingRefCalCoefficients   = @"kKSTNanoSDKDownloadingRefCalCoefficients";
static NSString *kKSTNanoSDKDownloadingRefMatrixCoefficients = @"kKSTNanoSDKDownloadingRefMatrixCoefficients";
static NSString *kKSTNanoSDKDownloadingData                 = @"kKSTNanoSDKDownloadingData";
static NSString *kKSTNanoSDKReady                           = @"kKSTNanoSDKReady";
static NSString *kKSTNanoSDKDisconnected                    = @"kKSTNanoSDKDisconnected";
static NSString *kKSTNanoSDKIncompatibleFirmware            = @"kKSTNanoSDKIncompatibleFirmware";

#pragma mark - Threshold Notifications
extern NSString *const kKSTNanoSDKTemperatureThresholdExceeded;
extern NSString *const kKSTNanoSDKHumidityThresholdExceeded;
extern NSString *const kKSTNanoSDKScanCompleted;
extern NSString *const kKSTNanoSDKUpdatedVisiblePeripherals;

#pragma mark - Keys for Device Info and Device Status Dictionaries
extern NSString *kKSTNanoSDKKeyManufacturerName;
extern NSString *kKSTNanoSDKKeyModelNumber;
extern NSString *kKSTNanoSDKKeySerialNumber;
extern NSString *kKSTNanoSDKKeyHardwareRev;
extern NSString *kKSTNanoSDKKeyTivaRev;
extern NSString *kKSTNanoSDKKeySpectrumRev;

extern NSString *kKSTNanoSDKKeyBattery;
extern NSString *kKSTNanoSDKKeyTemperature;
extern NSString *kKSTNanoSDKKeyHumidity;
extern NSString *kKSTNanoSDKKeyDeviceStatus;
extern NSString *kKSTNanoSDKKeyErrorStatus;
extern NSString *kKSTNanoSDKKeyTemperatureThreshold;
extern NSString *kKSTNanoSDKKeyHumidityThreshold;
extern NSString *kKSTNanoSDKKeyUsageHours;
extern NSString *kKSTNanoSDKKeyBatteryRechargeCycles;
extern NSString *kKSTNanoSDKKeyTotalLampHours;
extern NSString *kKSTNanoSDKKeyErrorLog;

#pragma mark - Delegate Methods
@protocol KSTNanoSDKDelegate <NSObject>
@end

#pragma mark - Interface
@interface KSTNanoSDK : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

#pragma mark - Class Methods
+ (id)manager;

#pragma mark - Instance Methods
/**
 Changes the Central Manager to begin the scan process
 */
-(void)KSTNanoSDKConnect;    

/**
 Forces a disconnect from the currently-connected Nano
 */
-(void)KSTNanoSDKDisconnect;

/**
 Provides a string representative of the current place in the primary State Machine
 */
-(NSString *)KSTNanoSDKGetCurrentState;

/**
 Sets a temperature threshold; when exceeded, a temperature alert is fired.
 @param temperatureThreshold
 Temperature, as integer, and in degrees Celsius from 0degC to 100degC.
 
 */
-(void)KSTNanoSDKSetTemperatureThreshold:(NSNumber *)temperatureThreshold;

/**
 Sets a humidity threshold; when exceeded, a humidity alert is fired.
 @param humidity
 Humidity, as integer, and in percent relative humidity from 0% RH to 100% RH.
 
 */
-(void)KSTNanoSDKSetHumidityThreshold:(NSNumber *)humidityThreshold;

#pragma mark - Diagnostic Commands
/**
 Turns the Tiva Controller PCB Yellow LED on or off.
 @param on
 Set to @YES for on or @NO for off.
 
 */
-(void)KSTNanoSDKSetYellowLEDOn:(NSNumber *)on;

/**
 Sets a fake battery value, for diagnostics only.
 @param battery
 Battery remaining, as integer, and in percentage from 0% to 100%.
 
 */
-(void)KSTNanoSDKSetDiagnosticBattery:(NSNumber *)battery;

/**
 Sets a fake temperature value, for diagnostics only.
 @param temperature
 Temperature, as integer, and in degrees Celsius from 0degC to 100degC.
 
 */
-(void)KSTNanoSDKSetDiagnosticTemperature:(NSNumber *)temperature;

/**
 Sets a fake humidity value, for diagnostics only.
 @param temperature
 Humidity, as integer, and in degrees Celsius from 0%RH to 100%RH.
 
 */
-(void)KSTNanoSDKSetDiagnosticHumidity:(NSNumber *)humidity;

/**
 Sets a fake usage hours value, for diagnostics only.
 @param usageHours
 Usage Hours, as integer.
 
 */
-(void)KSTNanoSDKSetDiagnosticHoursOfUse:(NSNumber *)usageHours;

/**
 Sets a fake number of battery recharge cycles, for diagnostics only.
 @param usageHours
 Usage Hours, as integer.
 
 */
-(void)KSTNanoSDKSetDiagnosticBattCycles:(NSNumber *)battCycles;

/**
 Sets a fake number of lamp hours, for diagnostics only.
 @param lampHours
 Lamp Hours, as integer.
 
 */
-(void)KSTNanoSDKSetDiagnosticLampHours:(NSNumber *)lampHours;

/**
 Requests that the Nano respond with the set of Spectrum Cal Coefficients.
 
 */
-(void)KSTNanoSDKReadSpectrumCalCoefficients;

/**
 Requests that the Nano respond with the set of Reference Cal Coefficients.
 
 */
-(void)KSTNanoSDKReadReferenceCalCoefficients;

/**
 Sets the Nano's clock to the current iOS device time.
 
 */
-(void)KSTNanoSDKSetCurrentTime;

/**
 Refreshes the KSTNanoSDKdeviceStatus dictionary.
 
 */
-(void)KSTNanoSDKRefreshDeviceStatus;

/**
 Controls the Central's scanner without having to nil the object
 
 */
-(void)KSTNanoSDKShouldActivelyScanForNano:(NSNumber *)shouldScan;

#pragma mark - Properties
@property(readwrite, unsafe_unretained) id <KSTNanoSDKDelegate> delegate;

/**
 The minimum RSSI required to establish a connection; -95dBm by default
 
 */
@property(nonatomic, readwrite) NSNumber *KSTNanoSDKminimumRSSIThreshold;

/**
 A dictionary containing key:value pairs of static Nano parameters
 
 */
@property(nonatomic, strong) NSMutableDictionary *KSTNanoSDKdeviceInfo;

/**
 A dictionary containing key:value pairs of dyanmic Nano parameters
 
 */
@property(nonatomic, strong) NSMutableDictionary *KSTNanoSDKdeviceStatus;

/**
 The Nano you'd like to connect to; perfect for using the retrieve: method in case the device is already connected to iOS when the app launches
 
 */
@property(readwrite) NSMutableString *KSTNanoSDKmyNanoUUIDString;

/**
 An array of currently visible Nano's organized into dictionaries
 
 */
@property(nonatomic, strong) NSMutableArray *KSTNanoSDKvisiblePeripherals;

/**
 The prefix string for all stored data files
 
 */
@property(nonatomic, strong) NSString *stubName;

/**
 If @YES, a completed scan is stored to iOS device locally.
 
 */
@property( nonatomic, strong ) NSNumber *KSTNanoSDKshouldSaveToiOSDevice;

/**
 Manually set the log's filename
 
 */
@property(nonatomic, strong) NSString *logFilename;

/**
 A simple property that allows the app to quickly check connection status
 
 */
@property(nonatomic, strong) NSNumber *isConnected;

#pragma mark - Methods
/**
 Sets a stub name (or prefix) for data stored on the NIRScan Nano
 @param stubName
 The stub name for data files stored in SD Card
 
 */
-(void)KSTNanoSDKSetStubName:(NSString *)stubName;

/**
 Request the number of stored scans; forces an update to the KSTDataManager array
 
 */
-(void)KSTNanoSDKRequestNumberOfStoredScans;

/**
 Request the number of stored scan configurations; forces an update to the KSTDataManager array
 
 */
-(void)KSTNanoSDKRequestNumberOfStoredScanConfigurations;

/**
 Request the number of stored scan indices; forces an update to the KSTDataManager array
 
 */
-(void)KSTNanoSDKRequestStoredScanIndicesList;

/**
 Request the number of stored scan configuration indices; forces an update to the KSTDataManager array
 
 */
-(void)KSTNanoSDKRequestStoredScanConfigurationIndicesList;

/**
 Retrieves the Scan Configuration Blob by presented index
 @param scanConfigurationIndexData
 The index of the Scan Configuration being retrieved
 
 */
-(void)KSTNanoSDKGetScanConfigurationDataForIndex:(NSData *)scanConfigurationIndexData;

/**
 Retrieves the Scan Name by presented index
 @param scanIndexData
 The index of the Scan being retrieved
 
 */
-(void)KSTNanoSDKGetScanNameForIndex:(NSData *)scanIndexData;

/**
 Retrieves the Scan Type by presented index
 @param scanIndexData
 The index of the Scan being retrieved
 
 */
-(void)KSTNanoSDKGetScanTypeForIndex:(NSData *)scanIndexData;

/**
 Retrieves the Scan Raw Blob data by presented index
 @param scanIndexData
 The index of the Scan being retrieved
 
 */
-(void)KSTNanoSDKGetScanBlobDataForIndex:(NSData *)scanIndexData;

/**
 Retrieves the Scan Timestamp data by presented index
 @param scanIndexData
 The index of the Scan being retrieved
 
 */
-(void)KSTNanoSDKGetScanTimestampForIndex:(NSData *)scanIndexData;

/**
 Retrieves the Scan Blob Version by presented index
 @param scanIndexData
 The index of the Scan being retrieved
 
 */
-(void)KSTNanoSDKGetScanBlobVersionForIndex:(NSData *)scanIndexData;

/**
 Sets the active scan configuration by index
 @param scanConfigurationIndexData
 The index of the Scan being retrieved
 
 */
-(void)KSTNanoSDKSetActiveScanConfigurationToIndex:(NSData *)scanConfigurationIndexData;

/**
 Deletes a scan blob by index
 @param scanIndexData
 The index of the Scan being retrieved
 
 */
-(void)KSTNanoSDKClearScanAtIndex:(NSData *)scanIndexData;

/**
 Set this before a scan to dump a scan blob to SD Card
 @param shouldSave
 The index of the Scan being retrieved
 
 */
-(void)KSTNanoSDKStartScanWithSDCardSave:(BOOL)shouldSave;

/**
 Force Refresh SD Card Contents
 
 */
-(void)KSTNanoSDKRefreshSDCardStatus;

/**
 Force Refresh Scan Configurations
 
 */
-(void)KSTNanoSDKRefreshScanConfigStatus;

@end