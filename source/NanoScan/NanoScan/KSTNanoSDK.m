//
//  KSTNanoSDK.m
//  NanoScan
//
//  Created by Robert Kressin on 1/1/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import "KSTNanoSDK.h"
#import "KSTDataManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <KSTSpectrumLibrary/KSTSpectrumLibrary.h>

#pragma mark TODO Store the Cal Coefficients and Matrix by Nano S/N

// NLog displays output if the NOTICE flag is defined in the Preprocessor Macros section of Build Settings
#ifdef NOTICE
#   define NLog(fmt, ...) NSLog((@"[KSTNanoSDK:%d] " fmt), __LINE__, ##__VA_ARGS__)
#else
#   define NLog(...)
#endif

// WLog displays output if the WARNING flag is defined in the Preprocessor Macros section of Build Settings
#ifdef WARNING
#   define WLog(fmt, ...) NSLog((@"[KSTNanoSDK-WARNING:%d] " fmt), __LINE__, ##__VA_ARGS__)
#else
#   define WLog(...)
#endif

// ELog displays output if the ERROR flag is defined in the Preprocessor Macros section of Build Settings
#ifdef ERROR
#   define ELog(fmt, ...) NSLog((@"[KSTNanoSDK-ERROR:%d] " fmt), __LINE__, ##__VA_ARGS__)
#else
#   define ELog(...)
#endif

// This is used for internal documentation only
#define VERSION_MAJOR   1
#define VERSION_MINOR   0
#define VERSION_SUB     0

// This is used for checking firmware version on the NIRScan Nano
#define FW_VERSION_MAJOR_MINIMUM    1
#define FW_VERSION_MINOR_MINIMUM    1
#define FW_VERSION_SUB_MINIMUM      0

#define WRITE_DELAY     0.01
#define DEVICE_NAME     @"NIRScanNano"

#pragma mark - NIRScan Nano Services
NSString *const kNanoServiceGeneralInformationUUIDString    = @"53455201-444C-5020-4E49-52204E616E6F";
NSString *const kNanoServiceCommandUUIDString               = @"53455202-444C-5020-4E49-52204E616E6F";
NSString *const kNanoServiceCurrentTimeUUIDString           = @"53455203-444C-5020-4E49-52204E616E6F";
NSString *const kNanoServiceCalibrationUUIDString           = @"53455204-444C-5020-4E49-52204E616E6F";
NSString *const kNanoServiceConfigurationUUIDString         = @"53455205-444C-5020-4E49-52204E616E6F";
NSString *const kNanoServiceScanDataUUIDString              = @"53455206-444C-5020-4E49-52204E616E6F";

#pragma mark - General Information Service Characteristics
NSString *const kNanoCharacteristicTemperatureMeasurementUUIDString             = @"43484101-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicHumidityMeasurementUUIDString                = @"43484102-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicDeviceStatusUUIDString                       = @"43484103-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicErrorStatusUUIDString                        = @"43484104-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicTemperatureThresholdUUIDString               = @"43484105-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicHumidityThresholdUUIDString                  = @"43484106-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicNumberOfUsageHoursUUIDString                 = @"43484107-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicNumberOfBatteryRechargeCyclesUUIDString      = @"43484108-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicTotalLampHoursUUIDString                     = @"43484109-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicErrorLogUUIDString                           = @"4348410A-444C-5020-4E49-52204E616E6F";

#pragma mark - Command Service
NSString *const kNanoCharacteristicInternalCommandUUIDString                    = @"4348410B-444C-5020-4E49-52204E616E6F";

#pragma mark - Current Time Service
NSString *const kNanoCharacteristicCurrentTimeUUIDString                        = @"4348410C-444C-5020-4E49-52204E616E6F";

#pragma mark - Calibration Service
NSString *const kNanoCharacteristicReadSpectrumCalCoefficients                  = @"4348410D-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReturnSpectrumCalCoefficients                = @"4348410E-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReadReferenceCalCoefficients                 = @"4348410F-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReturnReferenceCalCoefficients               = @"43484110-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReadReferenceCalMatrix                       = @"43484111-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReturnReferenceCalMatrix                     = @"43484112-444C-5020-4E49-52204E616E6F";

#pragma mark - Configuration Service
NSString *const kNanoCharacteristicNumberOfStoredConfigurationsUUIDString       = @"43484113-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicRequestStoredConfigurationsListUUIDString    = @"43484114-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReturnStoredConfigurationsListUUIDString     = @"43484115-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReadScanConfigurationDataUUIDString          = @"43484116-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReturnScanConfigurationDataUUIDString        = @"43484117-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicActiveScanConfigurationUUIDString            = @"43484118-444C-5020-4E49-52204E616E6F";

#pragma mark - Scan Service
NSString *const kNanoCharacteristicNumberOfStoredScansUUIDString                = @"43484119-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicRequestStoredScanIndicesListUUIDString       = @"4348411A-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicGetStoredScanIndicesListUUIDString           = @"4348411B-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicSetScanNameStubUUIDString                    = @"4348411C-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicStartScanUUIDString                          = @"4348411D-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicClearScanUUIDString                          = @"4348411E-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicGetScanNameUUIDString                        = @"4348411F-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReturnScanNameUUIDString                     = @"43484120-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicGetScanTypeUUIDString                        = @"43484121-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReturnScanTypeUUIDString                     = @"43484122-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicGetScanTimestampUUIDString                   = @"43484123-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReturnScanTimestampUUIDString                = @"43484124-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicGetScanBlobVersionUUIDString                 = @"43484125-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReturnScanBlobVersionUUIDString              = @"43484126-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicGetScanDataUUIDString                        = @"43484127-444C-5020-4E49-52204E616E6F";
NSString *const kNanoCharacteristicReturnScanDataUUIDString                     = @"43484128-444C-5020-4E49-52204E616E6F";

NSString *kKSTNanoSDKKeyManufacturerName    = @"kKSTNanoSDKKeyManufacturerName";
NSString *kKSTNanoSDKKeyModelNumber         = @"kKSTNanoSDKKeyModelNumber";
NSString *kKSTNanoSDKKeySerialNumber        = @"kKSTNanoSDKKeySerialNumber";
NSString *kKSTNanoSDKKeyHardwareRev         = @"kKSTNanoSDKKeyHardwareRev";
NSString *kKSTNanoSDKKeyTivaRev             = @"kKSTNanoSDKKeyTivaRev";
NSString *kKSTNanoSDKKeySpectrumRev         = @"kKSTNanoSDKKeySpectrumRev";

NSString *const kKSTNanoSDKTemperatureThresholdExceeded     = @"kKSTNanoSDKTemperatureThresholdExceeded";
NSString *const kKSTNanoSDKHumidityThresholdExceeded        = @"kKSTNanoSDKHumidityThresholdExceeded";
NSString *const kKSTNanoSDKScanCompleted                    = @"kKSTNanoSDKScanCompleted";

NSString *const kKSTNanoSDKUpdatedVisiblePeripherals        = @"kKSTNanoSDKUpdatedVisiblePeripherals";

// These are key:value pairs to make it easier to reference throughout the source code
NSString *kKSTNanoSDKKeyBattery                             = @"kKSTNanoSDKKeyBattery";
NSString *kKSTNanoSDKKeyTemperature                         = @"kKSTNanoSDKKeyTemperature";
NSString *kKSTNanoSDKKeyHumidity                            = @"kKSTNanoSDKKeyHumidity";
NSString *kKSTNanoSDKKeyDeviceStatus                        = @"kKSTNanoSDKKeyDeviceStatus";
NSString *kKSTNanoSDKKeyErrorStatus                         = @"kKSTNanoSDKKeyErrorStatus";
NSString *kKSTNanoSDKKeyTemperatureThreshold                = @"kKSTNanoSDKKeyTemperatureThreshold";
NSString *kKSTNanoSDKKeyHumidityThreshold                   = @"kKSTNanoSDKKeyHumidityThreshold";
NSString *kKSTNanoSDKKeyUsageHours                          = @"kKSTNanoSDKKeyUsageHours";
NSString *kKSTNanoSDKKeyBatteryRechargeCycles               = @"kKSTNanoSDKKeyBatteryRechargeCycles";
NSString *kKSTNanoSDKKeyTotalLampHours                      = @"kKSTNanoSDKKeyTotalLampHours";
NSString *kKSTNanoSDKKeyErrorLog                            = @"kKSTNanoSDKKeyErrorLog";

// Central Manager, possible states
typedef enum
{
    KSTNanoSDKStateIdle,
    KSTNanoSDKStateScanning,
    KSTNanoSDKStateConnecting,
    KSTNanoSDKStateConnected,
    KSTNanoSDKStateInitializingTime,
    KSTNanoSDKStateFetchSpectrumCalCoefficients,
    KSTNanoSDKStateFetchReferenceCalCoefficients,
    KSTNanoSDKStateFetchReferenceCalMatrix,
    KSTNanoSDKStateFetchScanConfigurations,
    KSTNanoSDKStateReady,
    KSTNanoSDKStateWritingData,
    KSTNanoSDKStateDeletingData,
    KSTNanoSDKStateReadingSDCard,
    KSTNanoSDKStateReadingScanConfigurations,
    KSTNanoSDKStateTransferringData,
    KSTNanoSDKStateScanningSample,
    KSTNanoSDKStateDisconnected
} KSTNanoSDKState;

#pragma mark TODO Move this to a new KSTNano class that is a subclass of CBPeripheral instead
// Peripheral, possible states
typedef enum
{
    KSTNanoSDKDeviceStatusNominal,
    KSTNanoSDKDeviceStatusScanInProgress,
    KSTNanoSDKDeviceStatusClearingScanData,
    KSTNanoSDKDeviceStatusTivaStatus,
    KSTNanoSDKDeviceStatusErrorStatus,
    KSTNanoSDKDeviceStatusCommandBeingProcessed,
    KSTNanoSDKDeviceStatusScanComplete,
    KSTNanoSDKDeviceStatusClearComplete,
    KSTNanoSDKDeviceStatusFutureUse
} KSTNanoSDKDeviceStatus;

#pragma mark TODO At the time of posting, error status fields are not yet supported by firmware
typedef enum
{
    KSTNanoSDKErrorStatusNominal,
    KSTNanoSDKErrorStatusScanFail,
    KSTNanoSDKErrorStatusLowBattery,
    KSTNanoSDKErrorStatusOutOfMemory,
    KSTNanoSDKErrorStatusTBD3,
    KSTNanoSDKErrorStatusTBD4,
    KSTNanoSDKErrorStatusTBD5,
    KSTNanoSDKErrorStatusTBD6,
    KSTNanoSDKErrorStatusTBD7
} KSTNanoSDKErrorStatus;

#pragma mark TODO It would be better to create a "KSTNano.h/m" class that represents the CBPeripheral (future implementation detail)
#pragma mark TODO The KSTDataManager was built with good intentions but is clumsy.  Remove direct method calls.  Replace with a "data delegate".
@interface KSTNanoSDK()
{
    // Primary BLE manager
    CBCentralManager    *_nanoCentralManager;
    KSTNanoSDKState     _state;
    CBPeripheral        *peripheral;
    
    // Scan Data
    NSMutableData *_scanDataBuffer;
    uint32_t _scanDataByteCount;
    
    // Spectrum Cal Coefficients
    NSMutableData *_spectrumCalCoefficientsBuffer;
    uint32_t _spectrumCalCoefficientsByteCount;
    
    // Reference Cal Coefficients
    NSMutableData *_referenceCalCoefficientsBuffer;
    uint32_t _referenceCalCoefficientsByteCount;
    
    // Reference Matrix
    NSMutableData *_referenceCalMatrixBuffer;
    uint32_t _referenceCalMatrixByteCount;
    
    // Scan Configuration Data
    NSMutableData *_scanConfigurationBuffer;
    uint32_t _scanConfigurationByteCount;
    
    // Scan Index
    NSMutableData *_scanIndex;
    int _totalNumberOfScansOnSDCard;
    int _currentScanIndex;
    uint32_t _totalStoredScanIndicesByteCount;
    NSMutableData *_allScanIndicesData;
    NSMutableDictionary *_sdCardDataDictionary;
    
    // Scan Configurations
    int _totalNumberOfScanConfigurations;
    NSMutableData *_scanConfigurationListBuffer;
    uint32_t _scanConfigurationListByteCount;
    
    int _currentScanConfigIndex;
    NSMutableDictionary *_scanConfigDataDictionary;
    NSMutableData *_scanConfigIndex;
    uint32_t _totalScanConfigByteCount;
    
    NSMutableData *_activeScanConfigurationData;
    NSMutableDictionary *_activeScanConfigDataDictionary;
    
    bool _shouldConnect;
}

#pragma mark TODO This is temporary; the Spectrum C Library was "clobbering" these values after scans, so we temporarily cache them
@property( nonatomic, retain ) NSData *lockedDownSpectrumCalCoefficientsBuffer;
@property( nonatomic, retain ) NSData *lockedDownReferenceCalCoefficientsBuffer;
@property( nonatomic, retain ) NSData *lockedDownReferenceMatrixBuffer;

@end

@implementation KSTNanoSDK

static KSTNanoSDK *manager = nil;

// This is a bit of a force fit.  iOS does not distinguish between didUpdateValue:forCharacteristic: and true GATT notifications.
// Therefore, if I know that I'm forcing a read of temperature, humidity, etc., then I want to suppress notifications.
bool isForcingTemperatureRead = YES;
bool isForcingHumidityRead = YES;

#pragma mark - Singleton Management
+ (KSTNanoSDK *)manager
{
    if (nil != manager)
    {
        return manager;
    }
    
    // This guarantees that we always only have a single instance of the KSTNanoSDK in a given app lifecycle.
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[KSTNanoSDK alloc] init];
    });
    
    return manager;
}

#pragma mark - CBCentralManager Methods
- (BOOL)isLECapableHardware
{
    bool isBLEOperational = NO;
    
    switch ([_nanoCentralManager state])
    {
        case CBCentralManagerStateUnsupported:
        {
            isBLEOperational = NO;
        } break;
            
        case CBCentralManagerStateUnauthorized:
        {
            isBLEOperational = NO;
        } break;
            
        case CBCentralManagerStatePoweredOff:
        {
            isBLEOperational = NO;
        } break;
            
        case CBCentralManagerStatePoweredOn:
        {
            isBLEOperational = YES;
            [self changeToState:KSTNanoSDKStateScanning];
        } break;
            
        case CBCentralManagerStateUnknown:
        {
            isBLEOperational = NO;
        } break;
            
        default:
        {
            isBLEOperational = NO;
        }
            
    }
    
    if( isBLEOperational )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    // In iOS8+, be sure that the state of the Central is PoweredOn!
    if( central.state == CBCentralManagerStatePoweredOn && _state == KSTNanoSDKStateScanning )
        [self changeToState:KSTNanoSDKStateScanning];
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // If the app choses not to set the minimum RSSI Threshold Property, we do it here and are extremely conservative.  This will find Nanos that are far away.
    if(!_KSTNanoSDKminimumRSSIThreshold)
    {
        _KSTNanoSDKminimumRSSIThreshold = [NSNumber numberWithInt:-115];
    }
    
    if(!_KSTNanoSDKmyNanoUUIDString )
        _KSTNanoSDKmyNanoUUIDString = [NSMutableString string];
    
    // There are two conditions for connecting - that we see the proper name and that the Nano is within RSSI Threshold.
    if( aPeripheral.name && RSSI.intValue > _KSTNanoSDKminimumRSSIThreshold.intValue && [aPeripheral.name compare:DEVICE_NAME] == NSOrderedSame )
    {
        if( _shouldConnect == YES )
        {
            if( [_KSTNanoSDKmyNanoUUIDString compare:aPeripheral.identifier.UUIDString] || !_KSTNanoSDKmyNanoUUIDString )
            {
                if( !_KSTNanoSDKmyNanoUUIDString )
                    WLog(@"Connecting to closest device that appears to be a Nano");
                else
                    WLog(@"Connecting to User's Specific Nano");
                
                peripheral = aPeripheral;
                peripheral.delegate = self;
                
                [self changeToState:KSTNanoSDKStateConnecting];
            }
        }
        else
        {
            if( !_KSTNanoSDKvisiblePeripherals )
                _KSTNanoSDKvisiblePeripherals = [NSMutableArray array];
            
            bool newDevice = YES;
            for( NSMutableDictionary *aVisiblePeripheral in _KSTNanoSDKvisiblePeripherals )
            {
                NSString *thisUUID = aPeripheral.identifier.UUIDString;
                NSString *aVisibleUUID = aVisiblePeripheral[@"uuidString"];
                if( [thisUUID compare:aVisibleUUID] == NSOrderedSame )
                {
                    newDevice = NO;
                    [aVisiblePeripheral setObject:RSSI forKey:@"rssi"];
                }
            }
            
            if( newDevice )
            {
                NSMutableDictionary *newDevice = [@{@"uuidString":aPeripheral.identifier.UUIDString,
                                                    @"rssi":RSSI,
                                                    @"name":aPeripheral.name} mutableCopy];
                [_KSTNanoSDKvisiblePeripherals addObject:newDevice];
            }
            
            [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKUpdatedVisiblePeripherals waitUntilDone:YES];
            
            NLog(@"Scanned Peripheral: %@ (%@dBm) [%@]", aPeripheral.identifier.UUIDString, RSSI, advertisementData);
        }
    }
}

#pragma mark TODO Remove once deployment target is set to iOS8.4+ (deprecated)
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    for( CBPeripheral *aPeripheral in peripherals )
    {
        // If the Nano is already connected to another app, simply establish its connection here.
        if( [aPeripheral.name compare:DEVICE_NAME] == NSOrderedSame )
        {
            peripheral = aPeripheral;
            peripheral.delegate = self;
            [self changeToState:KSTNanoSDKStateConnecting];
        }
    }
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    // NOTE: We do not send the notification until the GATT Profile has been enumerated.
    [peripheral discoverServices:nil];
    _isConnected = @YES;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    WLog(@"Disconnected with Error %@", error.description);
    [self changeToState:KSTNanoSDKStateDisconnected];
    _isConnected = @NO;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    WLog(@"Failed Connection with Error %@", error.description);
    [self changeToState:KSTNanoSDKStateDisconnected];
}

#pragma mark - CBPeripheral delegate methods
- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        [aPeripheral discoverCharacteristics:nil forService:aService];
        
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:kNanoServiceGeneralInformationUUIDString]])
        {
            NLog(@"Found Service -> Nano General Information");
        }
        else if ([aService.UUID isEqual:[CBUUID UUIDWithString:kNanoServiceCommandUUIDString]])
        {
            NLog(@"Found Service -> Nano Command");
        }
        else if ([aService.UUID isEqual:[CBUUID UUIDWithString:kNanoServiceCurrentTimeUUIDString]])
        {
            NLog(@"Found Service -> Nano Current Time");
        }
        else if ([aService.UUID isEqual:[CBUUID UUIDWithString:kNanoServiceCalibrationUUIDString]])
        {
            NLog(@"Found Service -> Nano Calibration");
        }
        else if ([aService.UUID isEqual:[CBUUID UUIDWithString:kNanoServiceConfigurationUUIDString]])
        {
            NLog(@"Found Service -> Nano Configuration");
        }
        else if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
        {
            NLog(@"Found Service -> Device Information");
        }
        else if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180F"]])
        {
            NLog(@"Found Service -> Battery");
        }
        else if ([aService.UUID isEqual:[CBUUID UUIDWithString:kNanoServiceScanDataUUIDString]])
        {
            NLog(@"Found Service -> Nano Scan Data");
        }
        else
        {
            WLog(@"Unexpected Service -> %@", aService.UUID);
        }
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
#pragma mark TODO Update this to support iOS8.4 SDK or higher (deprecations)
    /*
    [aPeripheral readRSSI];
    NSNumber *rssi = [aPeripheral RSSI];
    */
    
    // We have found that the iOS BT Server can get unstable if you try to read values without a BLE4.0 Read property, try to set notifications without a BLE4.0 Notify property, etc.
    // So, we are very careful to make sure we enumerate the GATT Profile properly and avoid these types of mistakes.
    for (CBCharacteristic *aChar in service.characteristics)
    {
        isForcingTemperatureRead = YES;
        isForcingHumidityRead = YES;
        
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Battery");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Manufacturer Name");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A24"]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Model Number");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A25"]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Serial Number");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Hardware Revision");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Tiva Revision");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A28"]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Spectrum Revision");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A50"]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> PnP ID");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A2A"]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> IEEE Regulatory");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A23"]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> System ID");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicTemperatureMeasurementUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Temperature Measurement");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicTemperatureThresholdUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Temperature Threshold");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicHumidityMeasurementUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Humidity Measurement");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicHumidityThresholdUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Humidity Threshold");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicDeviceStatusUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Device Status");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicErrorStatusUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Error Status");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicNumberOfUsageHoursUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Number of Usage Hours");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicNumberOfBatteryRechargeCyclesUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Number of Recharge Cycles");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicTotalLampHoursUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Total Lamp Hours");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicErrorLogUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Error Log");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicInternalCommandUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Internal Command");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicCurrentTimeUUIDString]])
        {
            NLog(@"Found Characteristic -> Nano Current Time [Write Only]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReadSpectrumCalCoefficients]])
        {
            NLog(@"Found Characteristic -> Nano Spectrum Cal Coefficients [Read]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReadReferenceCalCoefficients]])
        {
            NLog(@"Found Characteristic -> Nano Read Reference Cal Coefficients [Read]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReadReferenceCalMatrix]])
        {
            NLog(@"Found Characteristic -> Nano Read Reference Cal Matrix [Read]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnSpectrumCalCoefficients]])
        {
            //[peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Spectrum Cal Coefficients [Notify]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnReferenceCalCoefficients]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Reference Cal Coefficients [Notify]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnReferenceCalMatrix]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Reference Cal Matrix [Notify]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicNumberOfStoredScansUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Number of Stored Scans");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicStartScanUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Start Scan [Notify/Write]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicClearScanUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Clear Scan [Notify/Write]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanNameUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Return Scan Name [Notify]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanTypeUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Scan Type [Notify]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanTimestampUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Scan Timestamp [Notify]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanBlobVersionUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Scan Blob Version [Notify]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanDataUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Scan Blob Data [Notify]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetStoredScanIndicesListUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Nano Scan Indices List [Notify]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnStoredConfigurationsListUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Stored Configurations List [Notify]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanConfigurationDataUUIDString]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NLog(@"Found Characteristic -> Scan Configuration Data [Notify]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicRequestStoredConfigurationsListUUIDString]])
        {
            NLog(@"Found Characteristic -> Read Stored Scan Configurations List [Write]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicNumberOfStoredConfigurationsUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Number of Stored Configurations [Read]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReadScanConfigurationDataUUIDString]])
        {
            NLog(@"Found Characteristic -> Read Scan Configuration Data [Write]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicActiveScanConfigurationUUIDString]])
        {
            [peripheral readValueForCharacteristic:aChar];
            NLog(@"Found Characteristic -> Active Scan Configuration [Read/Write]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicRequestStoredScanIndicesListUUIDString]])
        {
            NLog(@"Found Characteristic -> Request Stored Scan Indices List [Write]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicSetScanNameStubUUIDString]])
        {
            NLog(@"Found Characteristic -> Set Scan Name Stub [Write]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetScanNameUUIDString]])
        {
            NLog(@"Found Characteristic -> Get Scan Name Stub [Write]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetScanTypeUUIDString]])
        {
            NLog(@"Found Characteristic -> Get Scan Type [Write]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetScanTimestampUUIDString]])
        {
            NLog(@"Found Characteristic -> Get Scan Timestamp [Write]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetScanBlobVersionUUIDString]])
        {
            NLog(@"Found Characteristic -> Get Scan Blob Version [Write]");
        }
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetScanDataUUIDString]])
        {
            NLog(@"Found Characteristic -> Get Scan Data [Write]");
        }
        else
        {
            WLog(@"Unknown Characteristic -> %@", aChar.UUID.UUIDString);
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if( error )
        ELog(@"UUID: %@ - %@", characteristic.UUID, error.description);
    else
        if (characteristic.isNotifying)
        {
            NLog(@"Notification began on %@", characteristic.UUID);
            if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanDataUUIDString]] && _state == KSTNanoSDKStateConnecting)
            {
                // This is the last notification during the Connecting State; consider connected when you get this far
                [self changeToState:KSTNanoSDKStateConnected];
            }
        }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
    {
        NLog(@"Did Update Mfg -> %@ (%@)", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding], characteristic.value);
        NSString *mfgName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        [_KSTNanoSDKdeviceInfo setObject:mfgName forKey:kKSTNanoSDKKeyManufacturerName];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A24"]])
    {
        NLog(@"[Did Update Model -> %@ (%@)", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding], characteristic.value);
        [_KSTNanoSDKdeviceInfo setObject:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] forKey:kKSTNanoSDKKeyModelNumber];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A25"]])
    {
        if( characteristic.value.length > 0 )
        {
            NLog(@"Did Update S/N -> %@ (%@)", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding], characteristic.value);
            [_KSTNanoSDKdeviceInfo setObject:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] forKey:kKSTNanoSDKKeySerialNumber];
        }
        else
        {
            WLog(@"Nil Length Serial Number");
            [_KSTNanoSDKdeviceInfo setObject:@"Unspecified" forKey:kKSTNanoSDKKeySerialNumber];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]])
    {
        NLog(@"Did Update H/W Rev -> %@ (%@)", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding], characteristic.value);
        [_KSTNanoSDKdeviceInfo setObject:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] forKey:kKSTNanoSDKKeyHardwareRev];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]])
    {
        NSString *version = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NLog(@"Did Update Tiva Rev -> %@ (%@)", version, characteristic.value);
        NSArray *versionArray = [version componentsSeparatedByString:@"."];
        if( versionArray.count == 3 )
        {
            int versionMajor = [versionArray[0] intValue];
            int versionMinor = [versionArray[1] intValue];
            int versionSub = [versionArray[2] intValue];
            
            bool isCompatibleFirmware = YES;
            
            if( versionMajor >= FW_VERSION_MAJOR_MINIMUM )
            {
                if( versionMinor >= FW_VERSION_MINOR_MINIMUM )
                {
                    if( versionSub >= FW_VERSION_SUB_MINIMUM )
                    {
                        NSLog(@"App is compatible with this firmware");
                    }
                    else
                    {
                        isCompatibleFirmware = NO;
                    }
                }
                else
                {
                    isCompatibleFirmware = NO;
                }
            }
            else
            {
                isCompatibleFirmware = NO;
            }
            
            if( isCompatibleFirmware )
                NLog(@"App is compatible with this firmware");
            else
            {
                ELog(@"App is not compatible with this firmware");
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKIncompatibleFirmware waitUntilDone:YES];
            }
            
        }
        else
        {
            WLog(@"Firmware version does not conform to standard and cannot be checked!");
        }
        
        [_KSTNanoSDKdeviceInfo setObject:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] forKey:kKSTNanoSDKKeyTivaRev];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A28"]])
    {
        NLog(@"Did Update Spectrum Rev -> %@ (%@)", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding], characteristic.value);
        [_KSTNanoSDKdeviceInfo setObject:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] forKey:kKSTNanoSDKKeySpectrumRev];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]])
    {
        
        if( characteristic.value.length > 0 )
        {
            const uint8_t *charUint = [characteristic.value bytes];
            uint8_t batt = 0;
            batt = charUint[0];
            
            float finalBatt = (float)batt;
            
            NLog(@"Did Update Battery -> %@", [NSString stringWithFormat:@"%3.0f%%", finalBatt] );
            [_KSTNanoSDKdeviceStatus setObject:[NSString stringWithFormat:@"%3.0f%%", finalBatt] forKey:kKSTNanoSDKKeyBattery];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicTemperatureMeasurementUUIDString]])
    {
        //       uint16_t temperatureThousanths = CFSwapInt16HostToBig(*(uint16_t*)([characteristic.value bytes]));
        uint16_t temperatureHundredths = *(uint16_t*)([characteristic.value bytes]);
        float temperature = temperatureHundredths / 100.0;
        [_KSTNanoSDKdeviceStatus setObject:[NSNumber numberWithFloat:temperature] forKey:kKSTNanoSDKKeyTemperature];
        
        if( isForcingTemperatureRead )
        {
            NLog(@"[Temperature -> %@ (%@)", [NSString stringWithFormat:@"%2.2f\u00b0C", temperature], characteristic.value);
        }
        else
        {
            WLog(@"Asynchronous Temperature -> %@ (%@)", [NSString stringWithFormat:@"%2.2f\u00b0C", temperature], characteristic.value);
            [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKTemperatureThresholdExceeded waitUntilDone:YES];
        }
        isForcingTemperatureRead = NO;
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicHumidityMeasurementUUIDString]])
    {
        //        uint16_t humidityHThousanths = CFSwapInt16HostToBig(*(uint16_t*)([characteristic.value bytes]));
        uint16_t humidityHundredths = *(uint16_t*)([characteristic.value bytes]);
        float humidity = humidityHundredths / 100.0;
        
        if( isForcingHumidityRead )
        {
            NLog(@"Humidity -> %@ (%@)", [NSString stringWithFormat:@"%2.2f%%RH", humidity], characteristic.value);
            [_KSTNanoSDKdeviceStatus setObject:[NSString stringWithFormat:@"%2.2f%%RH", humidity] forKey:kKSTNanoSDKKeyHumidity];
        }
        else
        {
            WLog(@"Asynchronous Humidity -> %@ (%@)", [NSString stringWithFormat:@"%2.2f%%RH", humidity], characteristic.value);
            [_KSTNanoSDKdeviceStatus setObject:[NSString stringWithFormat:@"%2.2f%%RH", humidity] forKey:kKSTNanoSDKKeyHumidity];
            [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKHumidityThresholdExceeded waitUntilDone:YES];
        }
        isForcingHumidityRead = NO;
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicDeviceStatusUUIDString]])
    {
        const uint16_t *charUint = [characteristic.value bytes];
        uint16_t deviceStatus = 0;
        deviceStatus = charUint[0];
        
        NSString *plainText;
        
        // 7654 3210
        if( deviceStatus && 0x01)
            deviceStatus = KSTNanoSDKDeviceStatusScanInProgress;
        else if( deviceStatus & 0x02)
            deviceStatus = KSTNanoSDKDeviceStatusClearingScanData;
        else if( deviceStatus & 0x04)
            deviceStatus = KSTNanoSDKDeviceStatusTivaStatus;
        else if( deviceStatus & 0x08)
            deviceStatus = KSTNanoSDKDeviceStatusErrorStatus;
        else if( deviceStatus & 0x10)
            deviceStatus = KSTNanoSDKDeviceStatusCommandBeingProcessed;
        else if( deviceStatus & 0x20)
            deviceStatus = KSTNanoSDKDeviceStatusScanComplete;
        else if( deviceStatus & 0x40)
            deviceStatus = KSTNanoSDKDeviceStatusClearComplete;
        else if( deviceStatus & 0x80)
            deviceStatus = KSTNanoSDKDeviceStatusFutureUse;
        
        switch (deviceStatus)
        {
            case KSTNanoSDKDeviceStatusNominal:
                plainText = @"Nominal";
                break;
                
            case KSTNanoSDKDeviceStatusScanInProgress:
                plainText = @"Scan in Progress";
                break;
                
            case KSTNanoSDKDeviceStatusClearingScanData:
                plainText = @"Clearing Scan Data";
                break;
                
            case KSTNanoSDKDeviceStatusTivaStatus:
                plainText = @"Clearing Scan Data";
                break;
                
            case KSTNanoSDKDeviceStatusErrorStatus:
                plainText = @"Error";
                break;
                
            case KSTNanoSDKDeviceStatusCommandBeingProcessed:
                plainText = @"Command Being Processed";
                break;
                
            case KSTNanoSDKDeviceStatusScanComplete:
                plainText = @"Scan Complete";
                break;
                
            case KSTNanoSDKDeviceStatusClearComplete:
                plainText = @"Clearing Complete";
                break;
                
            case KSTNanoSDKDeviceStatusFutureUse:
                plainText = @"RESERVED";
                break;
                
            default:
                plainText = @"Unknown Status";
                break;
        }
        
        plainText = @"Not Supported";
        
        NLog(@"Dev Status -> %@ (%@)", plainText, characteristic.value);
        [_KSTNanoSDKdeviceStatus setObject:[NSString stringWithFormat:@"%@", plainText] forKey:kKSTNanoSDKKeyDeviceStatus];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicErrorStatusUUIDString]])
    {
        const uint16_t *charUint = [characteristic.value bytes];
        uint16_t errorStatus = 0;
        errorStatus = charUint[0];
        
        NSString *plainText;
        
        if( errorStatus && 0x01)
            errorStatus = KSTNanoSDKErrorStatusScanFail;
        else if( errorStatus & 0x02)
            errorStatus = KSTNanoSDKErrorStatusLowBattery;
        else if( errorStatus & 0x04)
            errorStatus = KSTNanoSDKErrorStatusOutOfMemory;
        
        switch (errorStatus)
        {
            case KSTNanoSDKErrorStatusNominal:
                plainText = @"Nominal";
                break;
                
            case KSTNanoSDKErrorStatusScanFail:
                plainText = @"Scan Failed";
                break;
                
            case KSTNanoSDKErrorStatusLowBattery:
                plainText = @"Low Battery";
                break;
                
            case KSTNanoSDKErrorStatusOutOfMemory:
                plainText = @"Out of Memory";
                break;
                
            default:
                plainText = @"Unknown Error";
                break;
        }
        
#pragma mark Decode this in future versions of the firmware
        plainText = @"Not Supported";
        
        NLog(@"Found Err Status -> %@ (%@, len=%lu)", plainText, characteristic.value, (unsigned long)characteristic.value.length);
        [_KSTNanoSDKdeviceStatus setObject:plainText forKey:kKSTNanoSDKKeyErrorStatus];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicTemperatureThresholdUUIDString]])
    {
        if( characteristic.value.length > 0 )
        {
            const uint8_t *charUint = [characteristic.value bytes];
            uint8_t tempThreshold = 0;
            tempThreshold = charUint[0];
            
            NLog(@"Did Update Temp Threshold -> %@ (%@)", [NSString stringWithFormat:@"%d", tempThreshold], characteristic.value);
            [_KSTNanoSDKdeviceStatus setObject:[NSString stringWithFormat:@"%d", tempThreshold] forKey:kKSTNanoSDKKeyTemperatureThreshold];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicHumidityThresholdUUIDString]])
    {
        if( characteristic.value.length > 0 )
        {
            const uint8_t *charUint = [characteristic.value bytes];
            uint8_t humidityThreshold = 0;
            humidityThreshold = charUint[0];
            
            NLog(@"Did Update Humidity Threshold -> %@ (%@)", [NSString stringWithFormat:@"%d", humidityThreshold], characteristic.value);
            [_KSTNanoSDKdeviceStatus setObject:[NSString stringWithFormat:@"%d", humidityThreshold] forKey:kKSTNanoSDKKeyHumidityThreshold];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicNumberOfUsageHoursUUIDString]])
    {
        unsigned char bytes[2];
        [characteristic.value getBytes:bytes length:2];
        NSInteger n = (int)bytes[0] << 8;
        n |= (int)bytes[1] << 0;
        
        NLog(@"Did Update Hours Used -> %ld (%@, len=%lu)", (long)n, characteristic.value, (unsigned long)characteristic.value.length);
        [_KSTNanoSDKdeviceStatus setObject:[NSString stringWithFormat:@"%ld", (long)n] forKey:kKSTNanoSDKKeyUsageHours];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicNumberOfBatteryRechargeCyclesUUIDString]])
    {
        unsigned char bytes[2];
        [characteristic.value getBytes:bytes length:2];
        NSInteger n = (int)bytes[0] << 8;
        n |= (int)bytes[1] << 0;
        
        NLog(@"Did Update Batt Cycles -> %ld (%@, len=%lu)", (long)n, characteristic.value, (unsigned long)characteristic.value.length);
        [_KSTNanoSDKdeviceStatus setObject:[NSString stringWithFormat:@"%ld", (long)n] forKey:kKSTNanoSDKKeyBatteryRechargeCycles];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicTotalLampHoursUUIDString]])
    {
        unsigned char bytes[2];
        [characteristic.value getBytes:bytes length:2];
        NSInteger n = (int)bytes[0] << 8;
        n |= (int)bytes[1] << 0;
        
        NLog(@"Did Update Lamp Hours -> %ld (%@, len=%lu)", (long)n, characteristic.value, (unsigned long)characteristic.value.length);
        [_KSTNanoSDKdeviceStatus setObject:[NSString stringWithFormat:@"%ld", (long)n] forKey:kKSTNanoSDKKeyTotalLampHours];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicErrorLogUUIDString]])
    {
        const uint16_t *charUint = [characteristic.value bytes];
        uint16_t errorLog = 0;
        errorLog = charUint[0];
        
        NLog(@"Did Update Error Log -> %@ (%@)", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding], characteristic.value);
        [_KSTNanoSDKdeviceStatus setObject:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] forKey:kKSTNanoSDKKeyErrorLog];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnSpectrumCalCoefficients]])
    {
        if( !_spectrumCalCoefficientsBuffer )
        {
            // You have to allocate the object but then snarf the byte count
            _spectrumCalCoefficientsBuffer = [NSMutableData data];
            NSData *byteCount = [characteristic.value subdataWithRange:NSMakeRange(1, 4)]; // note that i'm bypassing the packet count reference itself
            _spectrumCalCoefficientsByteCount = *(int*)([byteCount bytes]);  // the byte count is contained in the byteCount NSData object
            NLog(@"Did Update Spectrum Cal Coeff Count to %d (%@)", _spectrumCalCoefficientsByteCount, byteCount);
        }
        else
        {
            // I need to throw out the first byte
            NSMutableData *thisCharacteristicData = [NSMutableData dataWithData:characteristic.value];
            NSRange range = NSMakeRange(0, 1);
            [thisCharacteristicData replaceBytesInRange:range withBytes:NULL length:0];
            
            [_spectrumCalCoefficientsBuffer appendData:thisCharacteristicData];
            
            // only change state when you get everything
            if( _spectrumCalCoefficientsBuffer.length == 144 )
            {
                _lockedDownSpectrumCalCoefficientsBuffer = [NSData dataWithData:_spectrumCalCoefficientsBuffer];
                NLog(@"Locked Down Spectrum Cal Coefficients Size: %lu", (unsigned long)_lockedDownSpectrumCalCoefficientsBuffer.length);
                [self changeToState:KSTNanoSDKStateFetchReferenceCalCoefficients];
                
            }
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnReferenceCalCoefficients]])
    {
        if( !_referenceCalCoefficientsBuffer)
        {
            // You have to allocate the object but then snarf the byte count
            _referenceCalCoefficientsBuffer = [NSMutableData data];
            NSData *byteCount = [characteristic.value subdataWithRange:NSMakeRange(1, 4)]; // note that i'm bypassing the packet count reference itself
            _referenceCalCoefficientsByteCount = *(int*)([byteCount bytes]);
            NLog(@"Did Update Ref Cal Coeff Count to %d (%@)", _referenceCalCoefficientsByteCount, byteCount);
        }
        else
        {
            // I need to throw out the first byte
            NSMutableData *thisCharacteristicData = [NSMutableData dataWithData:characteristic.value];
            NSRange range = NSMakeRange(0, 1);
            [thisCharacteristicData replaceBytesInRange:range withBytes:NULL length:0];
            
            [_referenceCalCoefficientsBuffer appendData:thisCharacteristicData];
            
            // only change state when you get everything
            if( _referenceCalCoefficientsBuffer.length == _referenceCalCoefficientsByteCount )
            {
                _lockedDownReferenceCalCoefficientsBuffer = [NSData dataWithData:_referenceCalCoefficientsBuffer];
                [self changeToState:KSTNanoSDKStateFetchReferenceCalMatrix];
            }
            else
            {
                float completionPercentage = 100.0*((float)_referenceCalCoefficientsBuffer.length/(float)_referenceCalCoefficientsByteCount);
                
                NSDictionary *nameAndPacketDictionary = @{@"name":kKSTNanoSDKDownloadingRefCalCoefficients,
                                                          @"percentage":[NSNumber numberWithFloat:completionPercentage]};
                [self performSelectorOnMainThread:@selector(triggerNotificationWithNamePercentage:) withObject:nameAndPacketDictionary waitUntilDone:YES];
            }
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnReferenceCalMatrix]])
    {
        if( !_referenceCalMatrixBuffer)
        {
            // You have to allocate the object but then snarf the byte count
            _referenceCalMatrixBuffer = [NSMutableData data];
            NSData *byteCount = [characteristic.value subdataWithRange:NSMakeRange(1, 4)]; // note that i'm bypassing the packet count reference itself
            _referenceCalMatrixByteCount = *(int*)([byteCount bytes]);
        }
        else
        {
            // I need to throw out the first byte
            NSMutableData *thisCharacteristicData = [NSMutableData dataWithData:characteristic.value];
            NSRange range = NSMakeRange(0, 1);
            [thisCharacteristicData replaceBytesInRange:range withBytes:NULL length:0];
            
            [_referenceCalMatrixBuffer appendData:thisCharacteristicData];
            
            // only change state when you get everything
            if( _referenceCalMatrixBuffer.length == _referenceCalMatrixByteCount )
            {
                _lockedDownReferenceMatrixBuffer = [NSData dataWithData:_referenceCalMatrixBuffer];
                [self changeToState:KSTNanoSDKStateFetchScanConfigurations];
            }
            else
            {
                float completionPercentage = 100.0*((float)_referenceCalMatrixBuffer.length/(float)_referenceCalMatrixByteCount);
                NSDictionary *nameAndPacketDictionary = @{@"name":kKSTNanoSDKDownloadingRefMatrixCoefficients,
                                                          @"percentage":[NSNumber numberWithFloat:completionPercentage]};
                [self performSelectorOnMainThread:@selector(triggerNotificationWithNamePercentage:) withObject:nameAndPacketDictionary waitUntilDone:YES];
            }
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicCurrentTimeUUIDString]])
    {
        NLog(@"Did Update Current Time -> %@", characteristic.value);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetStoredScanIndicesListUUIDString]])
    {
        
        NLog(@"Did Update Scan Indices List (partial %d vs %lu) -> %@", _totalStoredScanIndicesByteCount, (unsigned long)_allScanIndicesData.length, characteristic.value);
        
        if( !_allScanIndicesData )
            _allScanIndicesData = [NSMutableData data];
        
        [_allScanIndicesData appendData:characteristic.value];
        
        if( _allScanIndicesData.length == _totalStoredScanIndicesByteCount )
        {
            NLog(@"Final Scan Data Indices List: %@", _allScanIndicesData);
            _currentScanIndex = 0;
            
            if( !_sdCardDataDictionary )
                _sdCardDataDictionary = [NSMutableDictionary dictionary];
            
            NSData *scanDataIndex = [_allScanIndicesData subdataWithRange:NSMakeRange(_currentScanIndex*4, 4)];
            
            if( !_scanIndex )
                _scanIndex = [NSMutableData data];
            else
                [_scanIndex setData:nil];
            
            [_scanIndex setData:scanDataIndex];
            _sdCardDataDictionary[kKSTDataManagerSDCard_Index] = [_scanIndex mutableCopy];
            
            NLog(@"Setting Scan Index To %@", _scanIndex);
            
            [self KSTNanoSDKGetScanNameForIndex:_scanIndex];
            
            // clear the byte count
            _totalStoredScanIndicesByteCount = 0;
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicStartScanUUIDString]])
    {
        WLog(@"Scan Update -> %@", characteristic.value);
        
        const uint8_t *charUint = [characteristic.value bytes];
        uint8_t scanStatus = charUint[0];
        
        if( scanStatus == 1 )
        {
            NLog(@"Starting Scan");
        }
        else if( scanStatus == 255 )
        {
            NSData *scanIndex = [characteristic.value subdataWithRange:NSMakeRange(1, 4)];
            
            NLog(@"Scan Complete - Index is %@", scanIndex);
            WLog(@"Scan Complete");
            
            if( !_scanIndex )
                _scanIndex = [NSMutableData data];
            else
                [_scanIndex setData:nil];
            
            [_scanIndex setData:scanIndex];
            [self KSTNanoSDKGetScanBlobDataForIndex:(NSData *)scanIndex];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicClearScanUUIDString]])
    {
        WLog(@"Did Update Clear Scan -> %@", characteristic.value);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanNameUUIDString]])
    {
        NSString *scanName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSString *trimmedScanName = [scanName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NLog(@"Scan Name -> %@", trimmedScanName);
        
        _sdCardDataDictionary[kKSTDataManagerSDCard_Name] = trimmedScanName;
        
        [self KSTNanoSDKGetScanTypeForIndex:_scanIndex];
        
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanTypeUUIDString]])
    {
        NLog(@"Did Update Scan Type -> %@", characteristic.value);
        _sdCardDataDictionary[kKSTDataManagerSDCard_Type] = characteristic.value;
        
        [self KSTNanoSDKGetScanTimestampForIndex:_scanIndex];
        
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanTimestampUUIDString]])
    {
        NSData *yearByte = [characteristic.value subdataWithRange:NSMakeRange(0, 1)];
        NSData *monthByte = [characteristic.value subdataWithRange:NSMakeRange(1, 1)];
        NSData *dayByte = [characteristic.value subdataWithRange:NSMakeRange(2, 1)];
        NSData *dayOfWeekByte = [characteristic.value subdataWithRange:NSMakeRange(3, 1)];
        NSData *hourByte = [characteristic.value subdataWithRange:NSMakeRange(4, 1)];
        NSData *minByte = [characteristic.value subdataWithRange:NSMakeRange(5, 1)];
        NSData *secByte = [characteristic.value subdataWithRange:NSMakeRange(6, 1)];
        
        uint8_t year = ((const uint8_t *)[yearByte bytes])[0];
        uint8_t month = ((const uint8_t *)[monthByte bytes])[0];
        uint8_t day = ((const uint8_t *)[dayByte bytes])[0];
        uint8_t hour = ((const uint8_t *)[hourByte bytes])[0];
        uint8_t min = ((const uint8_t *)[minByte bytes])[0];
        uint8_t sec = ((const uint8_t *)[secByte bytes])[0];
        uint8_t dayOfWeek = ((const uint8_t *)[dayOfWeekByte bytes])[0];
        
        NSString *dayString;
        
        switch (dayOfWeek) {
            case 0:
                dayString = @"Sunday";
                break;
                
            case 1:
                dayString = @"Monday";
                break;
                
            case 2:
                dayString = @"Tuesday";
                break;
                
            case 3:
                dayString = @"Wednesday";
                break;
                
            case 4:
                dayString = @"Thursday";
                break;
                
            case 5:
                dayString = @"Friday";
                break;
                
            case 6:
                dayString = @"Saturday";
                break;
                
            default:
                break;
        }
        
        NSString *humanReadableTimestamp = [NSString stringWithFormat:@"%@, %d/%d/%d at %d:%02d:%02d", dayString, month, day, year, hour, min, sec];
        NLog(@"Did Update Scan Timestamp: %@", humanReadableTimestamp);
        
        _sdCardDataDictionary[kKSTDataManagerSDCard_Timestamp] = humanReadableTimestamp;
        
        [self KSTNanoSDKGetScanBlobVersionForIndex:_scanIndex];
        
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanBlobVersionUUIDString]])
    {
        NLog(@"Did Update Scan Blob Version -> %@", characteristic.value);
        
        _sdCardDataDictionary[kKSTDataManagerSDCard_Version] = characteristic.value;
        
        NSMutableDictionary *savedDict = [_sdCardDataDictionary mutableCopy];
        
        _sdCardDataDictionary = nil;
        _sdCardDataDictionary = [NSMutableDictionary dictionary];
        
        [[[KSTDataManager manager] sdCardArray] addObject:savedDict];
        
        if( ++_currentScanIndex == _totalNumberOfScansOnSDCard )
        {
            float completionPercentage = 100.0;
            
            NSDictionary *nameAndPacketDictionary = @{@"name":kKSTNanoSDKDownloadingData,
                                                      @"percentage":[NSNumber numberWithFloat:completionPercentage]};
            [self performSelectorOnMainThread:@selector(triggerNotificationWithNamePercentage:) withObject:nameAndPacketDictionary waitUntilDone:YES];
            [self changeToState:KSTNanoSDKStateReady];
            
            [_allScanIndicesData setData:nil];
            _allScanIndicesData = nil;
        }
        else
        {
            NSData *scanDataIndex = [_allScanIndicesData subdataWithRange:NSMakeRange(_currentScanIndex*4, 4)];
            [_scanIndex setData:scanDataIndex];
            
            _sdCardDataDictionary[kKSTDataManagerSDCard_Index] = [_scanIndex mutableCopy];
            
            [self KSTNanoSDKGetScanNameForIndex:_scanIndex];
            
            float completionPercentage = 100.0*((float)_currentScanIndex/(float)_totalNumberOfScansOnSDCard);
            
            NSDictionary *nameAndPacketDictionary = @{@"name":kKSTNanoSDKDownloadingData,
                                                      @"percentage":[NSNumber numberWithFloat:completionPercentage]};
            [self performSelectorOnMainThread:@selector(triggerNotificationWithNamePercentage:) withObject:nameAndPacketDictionary waitUntilDone:YES];
            
        }
        
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanDataUUIDString]])
    {
        if( !_scanDataBuffer)
        {
            // You have to allocate the object but then snarf the byte count
            _scanDataBuffer = [NSMutableData data];
            NSData *byteCount = [characteristic.value subdataWithRange:NSMakeRange(1, 4)]; // note that i'm bypassing the packet count reference itself
            _scanDataByteCount = *(int*)([byteCount bytes]);
            
            NLog(@"Did Update SCAN DATA count buffer %@ %d", byteCount, _scanDataByteCount);
            
            // I don't add this to the data array so that the Spectrum C Library satisfies the format.
        }
        else
        {
            // I need to throw out the first byte
            NSMutableData *thisCharacteristicData = [NSMutableData dataWithData:characteristic.value];
            NSRange range = NSMakeRange(0, 1);
            [thisCharacteristicData replaceBytesInRange:range withBytes:NULL length:0];
            
            [_scanDataBuffer appendData:thisCharacteristicData];
            
            // only change state when you get everything
            if( _scanDataBuffer.length == _scanDataByteCount )
            {
                unsigned char *scanData = (unsigned char *)[_scanDataBuffer bytes];
                int i, j;
                int retVal;
                
                // There are some big, meaty sized comments in this section that really deserve a seperate compiler flag - great for troubleshooting!
#pragma mark TODO Create a new compiler flag for these
                // Print the raw scan data
                /*
                 i = SCAN_DATA_BLOB_SIZE;
                 WLog(@"*** ADC_DATA_LEN = %d", ADC_DATA_LEN);
                 WLog(@"*** SCAN_DATA_BLOB_SIZE = %lu", SCAN_DATA_BLOB_SIZE);
                 
                 WLog(@"***** scanData - BEFORE, Start (predict: %lu // const: %lu)", (unsigned long)_scanDataBuffer.length, SCAN_DATA_BLOB_SIZE);
                 for(j = 0; j < (unsigned long)_scanDataBuffer.length; ++j)
                 printf("%02x ", ((uint8_t*)scanData)[j]);
                 WLog(@"***** scanData - BEFORE, End");
                 */
                //
                
                // Before pushing data to the Spectrum C Library, let's snapshot the Ref Cal Matrix Data; temporary fix until data corruption can be resolved
                NSMutableData *snapshotRefCalMatrix = [_lockedDownReferenceMatrixBuffer mutableCopy];
                NSMutableData *snapshotRefCal = [_lockedDownReferenceCalCoefficientsBuffer mutableCopy];
                
                // 1 - CONVERT SCAN DATA TO SCAN RESULTS
                scanResults finalScanResults;
                NSLog(@"dlpspec_scan_interpret");
                //                 void *scanDataByte = (void *)[_scanConfigurationBuffer bytes];
                retVal = dlpspec_scan_interpret(scanData, _scanDataBuffer.length, &finalScanResults);
                if( retVal < 0 )
                {
                    NSLog(@"FATAL");
                    return;
                }
                
                /*
                 printf("== SUMMARY: dlpspec_scan_interpret Results ==\n");
                 printf("ADC Length: %d\n", finalScanResults.adc_data_length);
                 printf("Black Pattern First: %d\n", finalScanResults.black_pattern_first);
                 printf("Black Pattern Period: %d\n", finalScanResults.black_pattern_period);
                 printf("Shift Vector Coefficients[0]: %f\n", finalScanResults.calibration_coeffs.ShiftVectorCoeffs[0]);
                 printf("Pixel to Wavelength Coefficients[0]: %f\n", finalScanResults.calibration_coeffs.PixelToWavelengthCoeffs[0]);
                 printf("Date/Time: %d/%d/%d [%d] %d:%02d:%02d\n", finalScanResults.month, finalScanResults.day, finalScanResults.year, finalScanResults.day_of_week, finalScanResults.hour, finalScanResults.minute, finalScanResults.second);
                 printf("Det Temperature: %f\n", finalScanResults.detector_temp_hundredths/100.0);
                 printf("Header Version: %d\n", finalScanResults.header_version);
                 printf("Humidity: %f\n", finalScanResults.humidity_hundredths/100.0);
                 printf("Intensity[0]: %d\n", finalScanResults.intensity[0]);
                 printf("Lamp PD: %d\n", finalScanResults.lamp_pd);
                 printf("Length: %d\n", finalScanResults.length);
                 printf("PGA: %d\n", finalScanResults.pga);
                 printf("Scan name: %s\n", finalScanResults.scan_name);
                 printf("Scan Data Index: %d\n", finalScanResults.scanDataIndex);
                 printf("Serial Number: %s\n", finalScanResults.serial_number);
                 printf("Sys Temperature: %f\n", finalScanResults.system_temp_hundredths/100.0);
                 printf("Wavelength[0]: %f\n", finalScanResults.wavelength[0]);
                 // scanConfig.cfg
                 printf("Config Name: %s\n", finalScanResults.cfg.config_name);
                 printf("Num Patterns: %d\n", finalScanResults.cfg.num_patterns);
                 printf("Num Repeats: %d\n", finalScanResults.cfg.num_repeats);
                 printf("Scan Type: %d\n", finalScanResults.cfg.scan_type);
                 printf("Scan Config Serial Number: %s\n", finalScanResults.cfg.ScanConfig_serial_number);
                 printf("Scan Config Index: %hu\n", finalScanResults.cfg.scanConfigIndex);
                 printf("Wavelength End: %d\n", finalScanResults.cfg.wavelength_end_nm);
                 printf("Wavelength Start: %d\n", finalScanResults.cfg.wavelength_start_nm);
                 printf("Wavelength Width: %d\n", finalScanResults.cfg.width_px);
                 printf("==================================\n");
                 */
                
                // Store Wavelength, Wavenumber, Intensity
                NSMutableArray *intensityArray = [NSMutableArray array];
                NSMutableArray *wavelengthArray = [NSMutableArray array];
                NSMutableArray *wavenumberArray = [NSMutableArray array];
                
                i = 0;
                while( i < finalScanResults.length )
                {
                    double wavelength = finalScanResults.wavelength[i];     // nm
                    double wavenumber = 10000000 / wavelength;              // cm-1
                    int intensity = finalScanResults.intensity[i];
                    
                    [intensityArray addObject:[NSNumber numberWithInt:intensity]];
                    [wavelengthArray addObject:[NSNumber numberWithDouble:wavelength]];
                    [wavenumberArray addObject:[NSNumber numberWithDouble:wavenumber]];
                    
                    i++;
                }
                
                // Invert the Wavenumber sequence for easier plotting
#pragma mark TODO Double-check this; are we plotting wavelength vs. wavenumber properly?
                NSArray *waveNumberReverseArray = [[wavenumberArray reverseObjectEnumerator] allObjects];
                NSArray *intensityReverseArray = [[intensityArray reverseObjectEnumerator] allObjects];
                
                // 2 - COMPUTE REFERENCE
                // This converts the NSData object representing the Reference Scan Data Blob that comes over the GATT
                unsigned char *referenceCalCoefficients = (unsigned char *)[_lockedDownReferenceCalCoefficientsBuffer bytes];
                
                // This converts the NSData object representing the Reference Matrix Data Blob that comes over the GATT
                char *referenceCalMatrix = (void *)[_lockedDownReferenceMatrixBuffer bytes];
                
                // Reference Cal Coefficients Dump
                /*
                 j=0;
                 i = (int)_lockedDownReferenceCalCoefficientsBuffer.length;
                 WLog(@"***** referenceCalCoefficients - BEFORE, Start (locked - %lu // predict - %lu // const - %lu)", (unsigned long)_lockedDownReferenceCalCoefficientsBuffer.length, sizeof(referenceCalCoefficients), SCAN_DATA_BLOB_SIZE);
                 for(j = 0; j < i; ++j)
                 printf("%02x ", ((uint8_t*)&referenceCalCoefficients)[j]);
                 WLog(@"***** referenceCalCoefficients - BEFORE, End");
                 */
                //
                
                // Reference Cal Matrix Dump
                /*
                 j=0;
                 i = (int)_lockedDownReferenceMatrixBuffer.length;
                 WLog(@"* unsigned char len - %lu", sizeof(unsigned char));
                 WLog(@"***** referenceCalMatrix - BEFORE, Start (locked - %lu // predict - %lu // const - %lu)", (unsigned long)_lockedDownReferenceMatrixBuffer.length, sizeof(referenceCalMatrix), REF_CAL_MATRIX_BLOB_SIZE);
                 for(j = 0; j < i; ++j)
                 printf("%02x ", ((uint8_t*)&referenceCalMatrix)[j]);
                 WLog(@"***** referenceCalMatrix - BEFORE, End");
                 */
                //
                
                // Create the empty Scan Results Struct
                scanResults referenceResults;
                
                // Use the Ref Scan Coefficients and Matrix to calculate a final, scanned result.  &finalScanResults comes from the output of the dlpspec_scan_interpret and is scanData struct.
                NSLog(@"dlpspec_scan_interpReference");
                retVal = dlpspec_scan_interpReference(referenceCalCoefficients, _lockedDownReferenceCalCoefficientsBuffer.length, referenceCalMatrix, REF_CAL_MATRIX_BLOB_SIZE, &finalScanResults, &referenceResults);
                if( retVal < 0 )
                {
                    NSLog(@"FATAL: dlpspec_scan_interpReference err=%d", retVal);
                    return;
                }
                
                /*
                 printf("== SUMMARY: dlpspec_scan_interpReference Results (%d) ==\n", retVal);
                 printf("ADC Length: %d\n", referenceResults.adc_data_length);
                 printf("Black Pattern First: %d\n", referenceResults.black_pattern_first);
                 printf("Black Pattern Period: %d\n", referenceResults.black_pattern_period);
                 printf("Shift Vector Coefficients[0]: %f\n", referenceResults.calibration_coeffs.ShiftVectorCoeffs[0]);
                 printf("Pixel to Wavelength Coefficients[0]: %f\n", referenceResults.calibration_coeffs.PixelToWavelengthCoeffs[0]);
                 printf("Date/Time: %d/%d/%d [%d] %d:%02d:%02d\n", referenceResults.month, referenceResults.day, referenceResults.year, referenceResults.day_of_week, referenceResults.hour, referenceResults.minute, referenceResults.second);
                 printf("Det Temperature: %f\n", referenceResults.detector_temp_hundredths/100.0);
                 printf("Header Version: %d\n", referenceResults.header_version);
                 printf("Humidity: %f\n", referenceResults.humidity_hundredths/100.0);
                 printf("Intensity[0]: %d\n", referenceResults.intensity[0]);
                 printf("Lamp PD: %d\n", referenceResults.lamp_pd);
                 printf("Length: %d\n", referenceResults.length);
                 printf("PGA: %d\n", referenceResults.pga);
                 printf("Scan name %s\n", referenceResults.scan_name);
                 printf("Scan Data Index: %d\n", referenceResults.scanDataIndex);
                 printf("Serial Number: %s\n", referenceResults.serial_number);
                 printf("Sys Temperature: %f\n", referenceResults.system_temp_hundredths/100.0);
                 printf("Wavelength[0]: %f\n", referenceResults.wavelength[0]);
                 // scanConfig.cfg
                 printf("Config Name: %s\n", referenceResults.cfg.config_name);
                 printf("Num Patterns: %d\n", referenceResults.cfg.num_patterns);
                 printf("Num Repeats: %d\n", referenceResults.cfg.num_repeats);
                 printf("Scan Type: %d\n", referenceResults.cfg.scan_type);
                 printf("Scan Config Serial Number: %s\n", referenceResults.cfg.ScanConfig_serial_number);
                 printf("Scan Config Index: %hu\n", referenceResults.cfg.scanConfigIndex);
                 printf("Wavelength End: %d\n", referenceResults.cfg.wavelength_end_nm);
                 printf("Wavelength Start: %d\n", referenceResults.cfg.wavelength_start_nm);
                 printf("Wavelength Width: %d\n", referenceResults.cfg.width_px);
                 printf("==================================\n");
                 */
                
                // Reference Cal Matrix Dump
                /*
                 j=0;
                 i = (int)_lockedDownReferenceMatrixBuffer.length;
                 WLog(@"***** referenceCalMatrix - AFTER, Start");
                 for(j = 0; j < i; ++j)
                 printf("%02x ", ((uint8_t*)referenceCalMatrix)[j]);
                 WLog(@"***** referenceCalMatrix - AFTER, End");
                 //*/
                
                // Final Scan Data Dump
                /*
                 j=0;
                 i = SCAN_DATA_BLOB_SIZE;
                 WLog(@"***** finalScanResults - AFTER, Start");
                 for(j = 0; j < i; ++j)
                 printf("%02x ", ((uint8_t*)&finalScanResults)[j]);
                 WLog(@"***** finalScanResults - AFTER, End");
                 
                 NSLog(@"[DIAG] CAL MATRIX (NSData, post-scan): %@ (%lu bytes)", _lockedDownReferenceMatrixBuffer, (unsigned long)_lockedDownReferenceMatrixBuffer.length);
                 NSLog(@"[DIAG] CAL MATRIX (NSData, never touched): %@ (%lu bytes)", snapshotRefCalMatrix, snapshotRefCalMatrix.length);
                 //*/
                
                // 3 - REFLECTANCE
                NSMutableArray *reflectanceArray = [NSMutableArray array];
                
                i = 0;
                while( i < referenceResults.length )
                {
                    double wavelength = finalScanResults.wavelength[i];
                    float answer = (float)finalScanResults.intensity[i]/(float)referenceResults.intensity[i];
                    
                    if( isinf(answer) || isnan(answer) )
                    {
                        ELog(@"Skipping Wavelength %f because answer=%f intensity=%d reference=%d", wavelength, answer, (int)finalScanResults.intensity[i], (int)referenceResults.intensity[i]);
                        [reflectanceArray addObject:[NSNumber numberWithFloat:0.0]];
                        
                    }
                    else
                    {
                        // WLog(@"Wavelength %f // answer=%f // intensity=%d // reference=%d", wavelength, answer, (int)finalScanResults.intensity[i], (int)referenceResults.intensity[i]);
                        [reflectanceArray addObject:[NSNumber numberWithFloat:answer]];
                    }
                    i++;
                }
                NSArray *reflectanceReverseArray = [[reflectanceArray reverseObjectEnumerator] allObjects];
                
                // 4 - ABSORBANCE
                NSMutableArray *absorbanceArray = [NSMutableArray array];
                
                i = 0;
                while( i < referenceResults.length )
                {
                    double wavelength = finalScanResults.wavelength[i];
                    
                    float answer = (float)(finalScanResults.intensity[i] / (float)referenceResults.intensity[i]);
                    float absorbance = -log10f(answer);
                    
                    if( isinf(absorbance) || isnan(absorbance) )
                    {
                        ELog(@"Skipping Wavelength %f because answer=%f intensity=%f reference=%f absorbance=%f", wavelength, answer, (float)finalScanResults.intensity[i], (float)referenceResults.intensity[i], absorbance);
                        [absorbanceArray addObject:[NSNumber numberWithFloat:0.0]];
                    }
                    else
                    {
                        //WLog(@"Wavelength %f \\ answer=%f \\ intensity=%f \\ reference=%f \\ absorbance=%f", wavelength, answer, (float)finalScanResults.intensity[i], (float)referenceResults.intensity[i], absorbance);
                        
                        [absorbanceArray addObject:[NSNumber numberWithFloat:absorbance]];
                    }
                    i++;
                }
                
                NSArray *absorbanceReverseArray = [[absorbanceArray reverseObjectEnumerator] allObjects];
                
                // Calculate Total Measurement Time
                /*
                 (1) Fixed overhead:
                 Startup (before scanning): 0.5s
                 
                 (2) Variable time: (seconds)
                 (num_repeats + 1) * ceiling(num_patterns / 24) * (1/ 61.53Hz)
                 (6 + 1) * (228 / 24) * (1/61.53) = (7) * (9.5) * (.01625) = 1.08-sec
                 
                 (3) Fixed overhead:
                 Settle time after scanning: 0.5s (we may reduce this, this delay was just to prevent a latch condition in the lamp driver)
                 */
                
                float fixedOverHeadPre = 0.5;
                float fixedOverheadPost = 0.5;
                int variableTime1 = finalScanResults.cfg.head.num_repeats + 1;
                //float variableTime2 = (float)ceilf((int)finalScanResults.cfg.num_patterns / 24.0);
                float variableTime2 = 800.0 / 24.0;     // HACK
                float variableTime3 = 1.0/61.53;
                float variableTime =  variableTime1 * variableTime2 * variableTime3;
                float totalMeasurementTime = fixedOverHeadPre + variableTime + fixedOverheadPost;
                
                // package up the data
                NSDate *rightNow = [NSDate new];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MM/dd/yyyy @ HH:mm:ss"];
                NSString *dateFromString = [dateFormatter stringFromDate:rightNow];
                
                NSDateFormatter *dateFormatterForFilename = [[NSDateFormatter alloc] init];
                [dateFormatterForFilename setDateFormat:@"MM-dd-yyyy_HH:mm:ss"];
                NSString *formattedDateString = [dateFormatterForFilename stringFromDate:rightNow];
                
                NSDictionary *sampleDictionary;
                sampleDictionary = @{kKSTDataManagerFilename:[NSString stringWithFormat:@"%@_%@.csv", _stubName, formattedDateString],
                                     kKSTDataManagerSerialNumber:_KSTNanoSDKdeviceInfo[kKSTNanoSDKKeySerialNumber],
                                     kKSTDataManagerKeyMethod:[NSString stringWithFormat:@"%s", finalScanResults.cfg.head.config_name],
                                     kKSTDataManagerKeyTimestamp:dateFromString,
                                     kKSTDataManagerSpectralRangeStart:[NSNumber numberWithInt:finalScanResults.wavelength[0]],
                                     kKSTDataManagerSpectralRangeEnd:[NSNumber numberWithInt:finalScanResults.wavelength[864]],
                                     kKSTDataManagerNumberOfWavelengthPoints:[NSNumber numberWithInt:finalScanResults.cfg.head.num_sections],
                                     kKSTDataManagerDigitalResolution:[NSNumber numberWithInt:finalScanResults.wavelength[1]-finalScanResults.wavelength[0]],
                                     kKSTDataManagerNumberOfAverages:[NSNumber numberWithInt:finalScanResults.cfg.head.num_repeats],
                                     kKSTDataManagerTotalMeasurementTime:[NSNumber numberWithFloat:totalMeasurementTime],
                                     kKSTDataManagerAbsorbance:absorbanceArray,
                                     kKSTDataManagerReflectance:reflectanceArray,
                                     kKSTDataManagerIntensity:intensityArray,
                                     kKSTDataManagerWavelength:wavelengthArray,
                                     kKSTDataManagerWavenumber:wavenumberArray,
                                     kKSTDataManagerReverseAbsorbance:absorbanceReverseArray,
                                     kKSTDataManagerReverseReflectance:reflectanceReverseArray,
                                     kKSTDataManagerReverseIntensity:intensityReverseArray
                                     };
                
                if( _KSTNanoSDKshouldSaveToiOSDevice.boolValue == YES )
                {
                    NLog(@"Save data to iOS");
                    [[[KSTDataManager manager] dataArray] addObject:sampleDictionary];
                    [[KSTDataManager manager] KSTDataManagerSave];
                }
                else
                {
                    NLog(@"Skipping save to iOS");
                }
                
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKScanCompleted waitUntilDone:YES];
                
                [self changeToState:KSTNanoSDKStateReady];
                
                // This is a temporary hack; restore the Cal Coefficients and Matrix
                _lockedDownReferenceMatrixBuffer = [NSData dataWithData:snapshotRefCalMatrix];
                _lockedDownReferenceCalCoefficientsBuffer = [NSData dataWithData:snapshotRefCal];
                
                _scanDataBuffer = nil;
                _scanDataByteCount = 0;
                
            }
            else
            {
                float completionPercentage = 100.0*((float)_scanDataBuffer.length/(float)_scanDataByteCount);
                NLog(@"Received Data - %2.0f%% Complete (%@)", completionPercentage, characteristic.value);
                
                NSDictionary *nameAndPacketDictionary = @{@"name":kKSTNanoSDKDownloadingData,
                                                          @"percentage":[NSNumber numberWithFloat:completionPercentage]};
                [self performSelectorOnMainThread:@selector(triggerNotificationWithNamePercentage:) withObject:nameAndPacketDictionary waitUntilDone:YES];
            }
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicNumberOfStoredConfigurationsUUIDString]])
    {
        _totalNumberOfScanConfigurations = ((const int *)[characteristic.value bytes])[0];
        
        NLog(@"Did Update Number of Stored Scan Configurations -> %d", _totalNumberOfScanConfigurations);
        
        if( _state == KSTNanoSDKStateReadingScanConfigurations )
        {
            [self KSTNanoSDKRequestStoredScanConfigurationIndicesList];
        }
        
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnStoredConfigurationsListUUIDString]])
    {
        if( !_scanConfigurationListBuffer)
        {
            // You have to allocate the object but then snarf the byte count
            _scanConfigurationListBuffer = [NSMutableData data];
            NSData *byteCount = [characteristic.value subdataWithRange:NSMakeRange(1, 4)]; // note that i'm bypassing the packet count reference itself
            _scanConfigurationListByteCount = *(int*)([byteCount bytes]);
        }
        else
        {
            // I need to throw out the first byte
            NSMutableData *thisCharacteristicData = [NSMutableData dataWithData:characteristic.value];
            NSRange range = NSMakeRange(0, 1);
            [thisCharacteristicData replaceBytesInRange:range withBytes:NULL length:0];
            
            [_scanConfigurationListBuffer appendData:thisCharacteristicData];
            
            // only change state when you get everything
            if( _scanConfigurationListBuffer.length == _scanConfigurationListByteCount )
            {
                // grab the 2-byte data indices and snarf them all, set current scan config index, etc.
                _currentScanConfigIndex = 0;
                
                if( !_scanConfigDataDictionary )
                    _scanConfigDataDictionary = [NSMutableDictionary dictionary];
                
                NSData *scanConfigIndex = [_scanConfigurationListBuffer subdataWithRange:NSMakeRange(_currentScanConfigIndex*2, 2)];
                
                if( !_scanConfigIndex )
                    _scanConfigIndex = [NSMutableData data];
                else
                    [_scanConfigIndex setData:nil];
                
                [_scanConfigIndex setData:scanConfigIndex];
                _scanConfigDataDictionary[kKSTDataManagerScanConfig_Index] = [_scanConfigIndex mutableCopy];
                
                [self KSTNanoSDKGetScanConfigurationDataForIndex:_scanConfigIndex];
                
                // clear the byte count
                _totalScanConfigByteCount = 0;
            }
        }
        
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanConfigurationDataUUIDString]])
    {
        if( !_scanConfigurationBuffer)
        {
            // You have to allocate the object but then snarf the byte count
            _scanConfigurationBuffer = [NSMutableData data];
            NSData *byteCount = [characteristic.value subdataWithRange:NSMakeRange(1, 4)]; // note that i'm bypassing the packet count reference itself
            _scanConfigurationByteCount = *(int*)([byteCount bytes]);
        }
        else
        {
            // I need to throw out the first byte
            NSMutableData *thisCharacteristicData = [NSMutableData dataWithData:characteristic.value];
            NSRange range = NSMakeRange(0, 1);
            [thisCharacteristicData replaceBytesInRange:range withBytes:NULL length:0];
            
            [_scanConfigurationBuffer appendData:thisCharacteristicData];
            
            // only change state when you get everything
            if( _scanConfigurationBuffer.length == _scanConfigurationByteCount )
            {
                //NSMutableData *fillerData = [NSMutableData dataWithData:_scanConfigurationBuffer];
                NSUInteger originalSize = _scanConfigurationBuffer.length;

                void *scanDataByte = (void *)[_scanConfigurationBuffer bytes];

                dlpspec_scan_read_configuration(scanDataByte, originalSize);
                uScanConfig *aScanConfig = (uScanConfig *)scanDataByte;
                
                if( aScanConfig->scanCfg.scan_type == SLEW_TYPE )
                {
                    NSLog(@"Contains a Slew Scan Configuration - sections = %d", aScanConfig->slewScanCfg.head.num_sections);
                    
                    _scanConfigDataDictionary[kKSTDataManagerScanConfig_NumRepeats] = [NSNumber numberWithInt:aScanConfig->slewScanCfg.head.num_repeats];
                    _scanConfigDataDictionary[kKSTDataManagerScanConfig_SerialNumber] = [NSString stringWithFormat:@"%s", aScanConfig->slewScanCfg.head.ScanConfig_serial_number];

                    NSMutableArray *arrayOfScanConfigurations = [NSMutableArray array];

                    for(int i=0; i < aScanConfig->slewScanCfg.head.num_sections; i++)
                    {
                        NSMutableDictionary *aScanConfiguration = [NSMutableDictionary dictionary];
                        aScanConfiguration[kKSTDataManagerScanConfig_Type] = [NSNumber numberWithInt:aScanConfig->slewScanCfg.section[i].section_scan_type];
                        aScanConfiguration[kKSTDataManagerScanConfig_ConfigName] = [NSString stringWithFormat:@"%s", aScanConfig->scanCfg.config_name];
                        aScanConfiguration[kKSTDataManagerScanConfig_WavelengthStart] = [NSNumber numberWithInt:aScanConfig->slewScanCfg.section[i].wavelength_start_nm];
                        aScanConfiguration[kKSTDataManagerScanConfig_WavelengthEnd] = [NSNumber numberWithInt:aScanConfig->slewScanCfg.section[i].wavelength_end_nm];
                        aScanConfiguration[kKSTDataManagerScanConfig_Width] = [NSNumber numberWithInt:aScanConfig->slewScanCfg.section[i].width_px];
                        aScanConfiguration[kKSTDataManagerScanConfig_NumPatterns] = [NSNumber numberWithInt:aScanConfig->slewScanCfg.section[i].num_patterns];
                        [arrayOfScanConfigurations addObject:aScanConfiguration];
                    }
                    _scanConfigDataDictionary[kKSTDataManagerScanConfig_SectionsArray] = arrayOfScanConfigurations;
                }
                else
                {
                    NSLog(@"Is Not a Slew Scan Configuration");
                    NSMutableDictionary *aScanConfiguration = [NSMutableDictionary dictionary];
                    
                    aScanConfiguration[kKSTDataManagerScanConfig_SerialNumber] = [NSString stringWithFormat:@"%s", aScanConfig->scanCfg.ScanConfig_serial_number];

                    aScanConfiguration[kKSTDataManagerScanConfig_WavelengthStart] = [NSNumber numberWithInt:aScanConfig->scanCfg.wavelength_start_nm];
                    aScanConfiguration[kKSTDataManagerScanConfig_WavelengthEnd] = [NSNumber numberWithInt:aScanConfig->scanCfg.wavelength_end_nm];
                    aScanConfiguration[kKSTDataManagerScanConfig_Width] = [NSNumber numberWithInt:aScanConfig->scanCfg.width_px];
                    aScanConfiguration[kKSTDataManagerScanConfig_NumPatterns] = [NSNumber numberWithInt:aScanConfig->scanCfg.num_patterns];
                    aScanConfiguration[kKSTDataManagerScanConfig_NumRepeats] = [NSNumber numberWithInt:aScanConfig->scanCfg.num_repeats];
                    
                    _scanConfigDataDictionary[kKSTDataManagerScanConfig_SectionsArray] = [NSArray arrayWithObject:aScanConfiguration];
                }
                
                // save this off
                uint16_t humidityAsUINT = aScanConfig->scanCfg.scanConfigIndex;
                NSData *humidityThresholdData = [NSData dataWithBytes:&humidityAsUINT length:sizeof(humidityAsUINT)];
                _scanConfigDataDictionary[kKSTDataManagerScanConfig_Index] = humidityThresholdData;

                NSMutableDictionary *savedDict = [_scanConfigDataDictionary mutableCopy];
                
                if( _state == KSTNanoSDKStateConnecting )
                {
                    if( !_activeScanConfigDataDictionary )
                        _activeScanConfigDataDictionary = [NSMutableDictionary dictionary];
                    
                    _activeScanConfigDataDictionary = [_scanConfigDataDictionary mutableCopy];
                }
                
                _scanConfigDataDictionary = nil;
                _scanConfigDataDictionary = [NSMutableDictionary dictionary];
                
                [[[KSTDataManager manager] scanConfigArray] addObject:savedDict];
                
                _scanConfigurationBuffer = nil;
                
                if( ++_currentScanConfigIndex == _totalNumberOfScanConfigurations )
                {
                    float completionPercentage = 100.0;
                    
                    NSDictionary *nameAndPacketDictionary = @{@"name":kKSTNanoSDKDownloadingData,
                                                              @"percentage":[NSNumber numberWithFloat:completionPercentage]};
                    [self performSelectorOnMainThread:@selector(triggerNotificationWithNamePercentage:) withObject:nameAndPacketDictionary waitUntilDone:YES];
                    
                    NLog(@"Setting Current Scan Config Index to %@", _activeScanConfigurationData);
                    [[KSTDataManager manager] KSTDataManagerSetActiveScanConfigurationIndexToIndex:_activeScanConfigurationData];
                    
                    [self changeToState:KSTNanoSDKStateReady];
                    
                    [_scanConfigurationListBuffer setData:nil];
                    _scanConfigurationListBuffer = nil;
                }
                else
                {
                    NSData *scanConfigIndex = [_scanConfigurationListBuffer subdataWithRange:NSMakeRange(_currentScanConfigIndex*2, 2)];
                    [_scanConfigIndex setData:scanConfigIndex];
                    
                    _scanConfigDataDictionary[kKSTDataManagerScanConfig_Index] = [scanConfigIndex mutableCopy];
                    
                    [self KSTNanoSDKGetScanConfigurationDataForIndex:_scanConfigIndex];
                    
                    float completionPercentage = 100.0*((float)_currentScanConfigIndex/(float)_totalNumberOfScanConfigurations);
                    
                    NSDictionary *nameAndPacketDictionary = @{@"name":kKSTNanoSDKDownloadingData,
                                                              @"percentage":[NSNumber numberWithFloat:completionPercentage]};
                    [self performSelectorOnMainThread:@selector(triggerNotificationWithNamePercentage:) withObject:nameAndPacketDictionary waitUntilDone:YES];
                    
                }
                
            }
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicNumberOfStoredScansUUIDString]])
    {
        _totalNumberOfScansOnSDCard = ((const int *)[characteristic.value bytes])[0];
        
        NLog(@"Did Update Number of Stored Scans -> %d", _totalNumberOfScansOnSDCard);
        
        if( _state == KSTNanoSDKStateReadingSDCard )
        {
            _totalStoredScanIndicesByteCount = (uint32_t)(_totalNumberOfScansOnSDCard * 4); // 4 byte indices
            [self KSTNanoSDKRequestStoredScanIndicesList];
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicRequestStoredScanIndicesListUUIDString]])
    {
        NLog(@"Did Update Stored Scan Data Indices List -> %@", characteristic.value);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicRequestStoredConfigurationsListUUIDString]])
    {
        NLog(@"Did Update Stored Scan Configurations Indices List -> %@", characteristic.value);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicSetScanNameStubUUIDString]])
    {
        NLog(@"Did Update Scan Name Stub -> %@", characteristic.value);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicInternalCommandUUIDString]])
    {
        NLog(@"Did Update Internal Command -> %@", characteristic.value);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReadScanConfigurationDataUUIDString]])
    {
        NLog(@"Did Update Scan Configuration Data -> %@", characteristic.value);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicActiveScanConfigurationUUIDString]])
    {
        NLog(@"Did Update Active Scan Configuration -> %@", characteristic.value);
        if( !_activeScanConfigurationData )
            _activeScanConfigurationData = [NSMutableData data];
        
        [_activeScanConfigurationData setData:characteristic.value];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A2A"]])
    {
        NLog(@"Did Update IEEE Regulatory Certification -> %@", characteristic.value);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A50"]])
    {
        NLog(@"Did Update PnP ID -> %@", characteristic.value);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A23"]])
    {
        NLog(@"Did Update System ID -> %@", characteristic.value);
    }
    else
    {
        WLog(@"Unaccounted for didUpdateValue %@ for Characteristic %@", characteristic.value, characteristic.UUID);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicCurrentTimeUUIDString]] && _state == KSTNanoSDKStateInitializingTime )
    {
        [self changeToState:KSTNanoSDKStateFetchSpectrumCalCoefficients];
    }
}

#pragma mark - Convenience Methods: Connection Logic
-(void)KSTNanoSDKConnect
{
    _shouldConnect = YES;
    _KSTNanoSDKshouldSaveToiOSDevice = @YES;
    
    WLog(@"%@", [NSString stringWithFormat:@"Connect - SDK v%d.%d.%d", VERSION_MAJOR, VERSION_MINOR, VERSION_SUB]);
    
    if( !_KSTNanoSDKdeviceInfo )
    {
        _KSTNanoSDKdeviceInfo = [[NSMutableDictionary alloc] init];
    }
    
    if( !_KSTNanoSDKdeviceStatus )
    {
        _KSTNanoSDKdeviceStatus = [[NSMutableDictionary alloc] init];
    }
    
    // State Initialization
    _state = KSTNanoSDKStateDisconnected;
    
    if( !_nanoCentralManager )
        [self changeToState:KSTNanoSDKStateIdle];
    else
        [self changeToState:KSTNanoSDKStateScanning];
}

-(void)KSTNanoSDKDisconnect
{
    NLog(@"Tearing down peripheral notifications prior to releasing connection");
    
    for( CBService *aServ in peripheral.services )
        for (CBCharacteristic *aChar in aServ.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicTemperatureMeasurementUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicHumidityMeasurementUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicDeviceStatusUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicErrorStatusUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicInternalCommandUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnReferenceCalCoefficients]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnReferenceCalMatrix]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicStartScanUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicClearScanUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanNameUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanTypeUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanTimestampUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanBlobVersionUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanDataUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetStoredScanIndicesListUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnStoredConfigurationsListUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReturnScanConfigurationDataUUIDString]])
            {
                [peripheral setNotifyValue:NO forCharacteristic:aChar];
            }
        }
    
    // Might consider an assert here if the State Machine doesn't line up with a connected peripheral
    if( peripheral.state == CBPeripheralStateConnected )
        [_nanoCentralManager cancelPeripheralConnection:peripheral];
    
    [self changeToState:KSTNanoSDKStateDisconnected];
}

#pragma mark - Convenience Methods: Non-Command Setters
-(void)KSTNanoSDKSetTemperatureThreshold:(NSNumber *)temperatureThreshold
{
    int16_t tempAsInt = temperatureThreshold.intValue;
    int16_t tempAsUINT = tempAsInt * 100;
    NSData *temperatureThresholdData = [NSData dataWithBytes:&tempAsUINT length:sizeof(tempAsUINT)];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicTemperatureThresholdUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Tx: %@ to %@", temperatureThresholdData, kNanoCharacteristicTemperatureThresholdUUIDString);
                                   [peripheral writeValue:temperatureThresholdData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKSetHumidityThreshold:(NSNumber *)humidityThreshold
{
    uint16_t humidityAsUINT = humidityThreshold.intValue*100;
    NSData *humidityThresholdData = [NSData dataWithBytes:&humidityAsUINT length:sizeof(humidityAsUINT)];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicHumidityThresholdUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Tx: %@ to %@", humidityThresholdData, kNanoCharacteristicHumidityThresholdUUIDString);
                                   [peripheral writeValue:humidityThresholdData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKClearScanAtIndex:(NSData *)scanIndexData
{
    WLog(@"Deleting Scan With Index %@", scanIndexData);
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicClearScanUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Tx: %@ to %@", scanIndexData, kNanoCharacteristicClearScanUUIDString);
                                   [peripheral writeValue:scanIndexData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

#pragma mark - Convenience Methods: Commands
-(void)KSTNanoSDKSetActiveScanConfigurationToIndex:(NSData *)scanConfigurationIndexData
{
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicActiveScanConfigurationUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Tx: %@ to %@", scanConfigurationIndexData, kNanoCharacteristicActiveScanConfigurationUUIDString);
                                   [peripheral writeValue:scanConfigurationIndexData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKReadSpectrumCalCoefficients
{
    uint8_t val;
    NSMutableData *buildupData = [NSMutableData data];
    
    // No value is required for this
    val = 0x00;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReadSpectrumCalCoefficients]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKReadReferenceCalCoefficients
{
    uint8_t val;
    NSMutableData *buildupData = [NSMutableData data];
    
    // No value is required for this
    val = 0x00;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReadReferenceCalCoefficients]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKReadReferenceCalMatrix
{
    uint8_t val;
    NSMutableData *buildupData = [NSMutableData data];
    
    // No value is required for this
    val = 0x00;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReadReferenceCalMatrix]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKGetStoredConfigurationsList
{
    uint8_t val;
    NSMutableData *buildupData = [NSMutableData data];
    
    // No value is required for this
    val = 0x00;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReadReferenceCalCoefficients]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKSetCurrentTime
{
    NSDate *rightNow = [NSDate new];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:rightNow];
    
    uint8_t hour = (uint8_t)[components hour];
    uint8_t minute = (uint8_t)[components minute];
    uint8_t seconds = (uint8_t)[components second];
    NSInteger year = [components year];
    uint8_t month = (uint8_t)[components month];
    uint8_t day = (uint8_t)[components day];
    uint8_t dayofWeek = (uint8_t)[components weekday]-1;
    
    uint8_t yearShort = year - 2000;
    
    NLog(@"Setting Time Based on iOS Device -> %d:%02d:%02d, %d/%d/%d (Day of Week:%d)", hour, minute, seconds, yearShort, month, day, dayofWeek);
    
    NSData *hourData = [NSData dataWithBytes:&hour length:sizeof(hour)];
    NSData *minuteData = [NSData dataWithBytes:&minute length:sizeof(minute)];
    NSData *secondsData = [NSData dataWithBytes:&seconds length:sizeof(seconds)];
    NSData *yearData = [NSData dataWithBytes:&yearShort length:sizeof(yearShort)];
    NSData *monthData = [NSData dataWithBytes:&month length:sizeof(month)];
    NSData *dayData = [NSData dataWithBytes:&day length:sizeof(day)];
    NSData *dayOfWeekData = [NSData dataWithBytes:&dayofWeek length:sizeof(dayofWeek)];
    
    NSMutableData *buildupData = [NSMutableData data];
    [buildupData appendData:[NSData dataWithData:yearData]];
    [buildupData appendData:[NSData dataWithData:monthData]];
    [buildupData appendData:[NSData dataWithData:dayData]];
    [buildupData appendData:[NSData dataWithData:dayOfWeekData]];
    [buildupData appendData:[NSData dataWithData:hourData]];
    [buildupData appendData:[NSData dataWithData:minuteData]];
    [buildupData appendData:[NSData dataWithData:secondsData]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicCurrentTimeUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

#pragma mark - Convenience Methods: Diagnostics
-(void)KSTNanoSDKSetDiagnosticBattery:(NSNumber *)battery
{
    uint8_t val;
    NSMutableData *buildupData = [NSMutableData data];
    
    val = 0xFF;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x01;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x02;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x01;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = battery.intValue;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicInternalCommandUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKSetDiagnosticTemperature:(NSNumber *)temperature
{
    uint8_t val;
    NSMutableData *buildupData = [NSMutableData data];
    
    val = 0xFF;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x02;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x02;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x01;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = temperature.intValue;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicInternalCommandUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKSetDiagnosticHumidity:(NSNumber *)humidity
{
    uint8_t val;
    NSMutableData *buildupData = [NSMutableData data];
    
    val = 0xFF;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x03;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x02;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x01;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = humidity.intValue;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicInternalCommandUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKSetDiagnosticHoursOfUse:(NSNumber *)usageHours
{
    uint8_t val8;
    uint16_t val16;
    NSMutableData *buildupData = [NSMutableData data];
    
    val8 = 0xFF;
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val8 = 0x06;
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val8 = 0x02;
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val8 = 0x02;
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val16 = usageHours.intValue;
    Byte *byteData = (Byte*)malloc(2);
    byteData[1] = val16 & 0xff;
    byteData[0] = (val16 & 0xff00) >> 8;
    NSData * result = [NSData dataWithBytes:byteData length:2];
    
    [buildupData appendData:result];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicInternalCommandUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"[Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKSetDiagnosticBattCycles:(NSNumber *)battCycles
{
    uint8_t val8;
    uint16_t val16;
    NSMutableData *buildupData = [NSMutableData data];
    
    val8 = 0xFF;
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val8 = 0x07;
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val8 = 0x02;
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val8 = 0x02;
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val16 = battCycles.intValue;
    
    Byte *byteData = (Byte*)malloc(2);
    byteData[1] = val16 & 0xff;
    byteData[0] = (val16 & 0xff00) >> 8;
    NSData * result = [NSData dataWithBytes:byteData length:2];
    
    [buildupData appendData:result];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicInternalCommandUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKSetDiagnosticLampHours:(NSNumber *)lampHours
{
    uint8_t val8;
    uint16_t val16;
    NSMutableData *buildupData = [NSMutableData data];
    
    val8 = 0xFF;
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val8 = 0x08;
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val8 = 0x02;
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val8 = 0x02;    // length
    [buildupData appendData:[NSData dataWithBytes:&val8 length:sizeof(val8)]];
    
    val16 = lampHours.intValue;
    
    Byte *byteData = (Byte*)malloc(2);
    byteData[1] = val16 & 0xff;
    byteData[0] = (val16 & 0xff00) >> 8;
    NSData * result = [NSData dataWithBytes:byteData length:2];
    
    [buildupData appendData:result];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicInternalCommandUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKSetYellowLEDOn:(NSNumber *)on
{
    uint8_t val;
    NSMutableData *buildupData = [NSMutableData data];
    
    val = 0xFF;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x00;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x02;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    val = 0x01;
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    if( on.intValue == NO)
        val = 0x00;
    else
        val = 0x01;
    
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicInternalCommandUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKShouldActivelyScanForNano:(NSNumber *)shouldScan
{
    if( shouldScan.boolValue == YES )
    {
        if( _state == KSTNanoSDKStateConnected )
            [self KSTNanoSDKDisconnect];
        
        _shouldConnect = NO;
        [self changeToState:KSTNanoSDKStateScanning];
    }
    else
    {
        [self changeToState:KSTNanoSDKStateIdle];
    }
}


-(void)KSTNanoSDKRefreshDeviceStatus
{
    isForcingTemperatureRead = YES;
    [self readValueForCharacteristic:kNanoCharacteristicTemperatureMeasurementUUIDString];
    
    isForcingHumidityRead = YES;
    [self readValueForCharacteristic:kNanoCharacteristicHumidityMeasurementUUIDString];
    
    [self readValueForCharacteristic:@"2A19"];
    
    [self readValueForCharacteristic:kNanoCharacteristicDeviceStatusUUIDString];
    [self readValueForCharacteristic:kNanoCharacteristicErrorStatusUUIDString];
    [self readValueForCharacteristic:kNanoCharacteristicNumberOfUsageHoursUUIDString];
    [self readValueForCharacteristic:kNanoCharacteristicNumberOfBatteryRechargeCyclesUUIDString];
    [self readValueForCharacteristic:kNanoCharacteristicTotalLampHoursUUIDString];
    [self readValueForCharacteristic:kNanoCharacteristicErrorLogUUIDString];
}

#pragma mark - Working With SD Card Files
-(void)KSTNanoSDKSetStubName:(NSString *)stubName
{
    _stubName = stubName;
    
    NSData *buildupData = [self _reverseData:[stubName dataUsingEncoding:NSUTF8StringEncoding]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicSetScanNameStubUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ (len=%lu) to Char: %@ Serv: %@", buildupData, (unsigned long)buildupData.length, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKRefreshSDCardStatus
{
    [self changeToState:KSTNanoSDKStateReadingSDCard];
    [self KSTNanoSDKRequestNumberOfStoredScans];
}

-(void)KSTNanoSDKRefreshScanConfigStatus
{
    [self changeToState:KSTNanoSDKStateReadingScanConfigurations];
    
    // read the # of scan configurations
    [self KSTNanoSDKRequestNumberOfStoredScanConfigurations];
}

- (NSData *)_reverseData:(NSData *)myData
{
    const char *bytes = [myData bytes];
    
    NSUInteger datalength = [myData length];
    
    char *reverseBytes = malloc(sizeof(char) * datalength);
    NSUInteger index = datalength - 1;
    
    for (int i = 0; i < datalength; i++)
        reverseBytes[index--] = bytes[i];
    
    NSData *reversedData = [NSData dataWithBytesNoCopy:reverseBytes length: datalength freeWhenDone:YES];
    
    return reversedData;
}

-(void)KSTNanoSDKRequestNumberOfStoredScans
{
    [self readValueForCharacteristic:kNanoCharacteristicNumberOfStoredScansUUIDString];
}

-(void)KSTNanoSDKRequestNumberOfStoredScanConfigurations
{
    [self readValueForCharacteristic:kNanoCharacteristicNumberOfStoredConfigurationsUUIDString];
}

-(void)KSTNanoSDKRequestStoredScanConfigurationIndicesList
{
    uint8_t val;
    NSMutableData *buildupData = [NSMutableData data];
    
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicRequestStoredConfigurationsListUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKRequestStoredScanIndicesList
{
    uint8_t val;
    NSMutableData *buildupData = [NSMutableData data];
    
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicRequestStoredScanIndicesListUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKStartScanWithSDCardSave:(BOOL)shouldSave
{
    WLog(@"Starting Scan");
    // clear out the storage buffer
    _scanDataBuffer = nil;
    _scanDataByteCount = 0;
    
    uint8_t val;
    NSMutableData *buildupData = [NSMutableData data];
    
    if( shouldSave )
        val = 0x01;
    else
        val = 0x00;
    
    [buildupData appendData:[NSData dataWithBytes:&val length:sizeof(val)]];
    
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicStartScanUUIDString]])
            {
                if( aCharacteristic.properties == CBCharacteristicPropertyWrite || aCharacteristic.properties == CBCharacteristicPropertyWriteWithoutResponse)
                {
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                                   {
                                       NLog(@"Write %@ to Char: %@ Serv: %@", buildupData, aCharacteristic.UUID, aService.UUID);
                                       [peripheral writeValue:buildupData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                                   });
                }
            }
        }
    }
}

-(void)KSTNanoSDKGetScanNameForIndex:(NSData *)scanIndexData
{
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetScanNameUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ (len=%lu) to Char: %@ Serv: %@", scanIndexData, scanIndexData.length, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:scanIndexData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKGetScanTypeForIndex:(NSData *)scanIndexData
{
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetScanTypeUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", scanIndexData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:scanIndexData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKGetScanTimestampForIndex:(NSData *)scanIndexData
{
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetScanTimestampUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", scanIndexData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:scanIndexData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKGetScanBlobVersionForIndex:(NSData *)scanIndexData
{
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetScanBlobVersionUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", scanIndexData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:scanIndexData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKGetScanBlobDataForIndex:(NSData *)scanIndexData
{
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicGetScanDataUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"Write %@ to Char: %@ Serv: %@", scanIndexData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:scanIndexData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

-(void)KSTNanoSDKGetScanConfigurationDataForIndex:(NSData *)scanConfigurationIndexData
{
    for(CBService *aService in peripheral.services)
    {
        for( CBCharacteristic *aCharacteristic in aService.characteristics )
        {
            if ([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:kNanoCharacteristicReadScanConfigurationDataUUIDString]])
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WRITE_DELAY * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   NLog(@"[KSTNanoSDKGetScanConfigurationDataForIndex] Write %@ to Char: %@ Serv: %@", scanConfigurationIndexData, aCharacteristic.UUID, aService.UUID);
                                   [peripheral writeValue:scanConfigurationIndexData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse ];
                               });
            }
        }
    }
}

#pragma mark - Read and Write Characteristics
-(void)readValueForCharacteristic:(NSString *) characteristicUUID{
    for(CBService *service in peripheral.services){
        for(CBCharacteristic *characteristic in service.characteristics){
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristicUUID]]){
                NLog(@"Reading %@", characteristic.UUID);
                [peripheral readValueForCharacteristic:characteristic];
            }
        }
    }
}

#pragma mark - Logging methods
-(void)log:(NSString *)fileMessage
{
    // Timestamp
    NSDate *rightNow = [NSDate new];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    NSString *dateFromString = [dateFormatter stringFromDate:rightNow];
    
    // Add to the log
    NSFileHandle *aFileHandle;
    NSString *aFile;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentDBFolderPath = [documentsDirectory stringByAppendingPathComponent:_logFilename];
    
    if( ![fileManager fileExistsAtPath: documentDBFolderPath] )
    {
        // The File does not yet exist
        NLog(@"Creating a new Log File (%@)", documentDBFolderPath);
        [fileMessage writeToFile:documentDBFolderPath atomically:YES encoding:NSASCIIStringEncoding error:NULL];
    }
    else
    {
        // File Exists; go to its end and write
        aFile = documentDBFolderPath;
        
        aFileHandle = [NSFileHandle fileHandleForWritingAtPath:aFile];
        [aFileHandle truncateFileAtOffset:[aFileHandle seekToEndOfFile]];
        
        NSString *finalString = [NSString stringWithFormat:@"%@,%@", dateFromString, fileMessage];
        [aFileHandle writeData:[finalString dataUsingEncoding:NSASCIIStringEncoding]];
    }
    
}

#pragma mark - State Machine
-(NSString *)KSTNanoSDKGetCurrentState
{
    
    switch (_state)
    {
        case KSTNanoSDKStateIdle:
            return @"KSTNanoSDKStateIdle";
            break;
            
        case KSTNanoSDKStateScanning:
            return @"KSTNanoSDKStateScanning";
            break;
            
        case KSTNanoSDKStateConnecting:
            return @"KSTNanoSDKStateConnecting";
            break;
            
        case KSTNanoSDKStateConnected:
            return @"KSTNanoSDKStateConnected";
            break;
            
        case KSTNanoSDKStateInitializingTime:
            return @"KSTNanoSDKStateInitializingTime";
            break;
            
        case KSTNanoSDKStateFetchSpectrumCalCoefficients:
            return @"KSTNanoSDKStateFetchSpectrumCalCoefficients";
            break;
            
        case KSTNanoSDKStateFetchReferenceCalCoefficients:
            return @"KSTNanoSDKStateFetchReferenceCalCoefficients";
            break;
            
        case KSTNanoSDKStateFetchReferenceCalMatrix:
            return @"KSTNanoSDKStateFetchReferenceCalMatrix";
            break;
            
        case KSTNanoSDKStateReady:
            return @"KSTNanoSDKStateReady";
            break;
            
        case KSTNanoSDKStateWritingData:
            return @"KSTNanoSDKStateWritingData";
            break;
            
        case KSTNanoSDKStateDeletingData:
            return @"KSTNanoSDKStateDeletingData";
            break;
            
        case KSTNanoSDKStateTransferringData:
            return @"KSTNanoSDKStateTransferringData";
            break;
            
        case KSTNanoSDKStateReadingSDCard:
            return @"KSTNanoSDKStateReadingSDCard";
            break;
            
        case KSTNanoSDKStateReadingScanConfigurations:
            return @"KSTNanoSDKStateReadingScanConfigurations";
            break;
            
        case KSTNanoSDKStateScanningSample:
            return @"KSTNanoSDKStateScanningSample";
            break;
            
        case KSTNanoSDKStateDisconnected:
            return @"KSTNanoSDKStateDisconnected";
            break;
            
        default:
            return @"WARNING!  Invalid State";
            break;
    }
    
}

-(void)changeToState:(KSTNanoSDKState)nextState
{
    if( _state != nextState )
    {
        _state = nextState;
        
        WLog(@"State: %@ ", [self KSTNanoSDKGetCurrentState]);
        
        switch (_state)
        {
            case KSTNanoSDKStateIdle:
            {
                if( _nanoCentralManager )
                {
                    [_nanoCentralManager stopScan];
                }
                else
                {
                    dispatch_queue_t centralQueue = dispatch_queue_create("com.kstechnologies.nano.scanner", DISPATCH_QUEUE_SERIAL);
                    
                    if( !_nanoCentralManager )
                    {
                        _nanoCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
                        _nanoCentralManager.delegate = self;
                    }
                }
                
            } break;
                
            case KSTNanoSDKStateScanning:
            {
#pragma mark TODO Scan for a particular Nano Service.
                // We've put the plumbing in there for this but need the TI firmware to comply
                //NSString *servUUID = @"xxxx";
                //CBUUID *cbuuidServ = [CBUUID UUIDWithString:servUUID];
                
                if( _nanoCentralManager.state == CBCentralManagerStatePoweredOn )
                {
                    // This will scan for a Nano that is not yet connected.
                    /*
                     [_nanoCentralManager scanForPeripheralsWithServices:@[cbuuidServ]
                     options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
                     */
                    
                    [_nanoCentralManager scanForPeripheralsWithServices:nil
                                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
                    
                    
                    // This will retrieve the device if already connected.
                    /*
                     if( _shouldConnect )
                     [_nanoCentralManager retrieveConnectedPeripherals];
                     */
                }
                else
                {
                    ELog(@"Failed to initialize BLE");
                }
            } break;
                
            case KSTNanoSDKStateConnecting:
            {
                [_nanoCentralManager stopScan];
                if( peripheral )
                {
                    [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKBusy waitUntilDone:YES];
                    [_nanoCentralManager connectPeripheral:peripheral options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES }];
                }
                else
                    ELog(@"Warning! Peripheral is not set");
                
            } break;
                
            case KSTNanoSDKStateConnected:
            {
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKBusy waitUntilDone:YES];
                [_nanoCentralManager stopScan];
                [self changeToState:KSTNanoSDKStateInitializingTime];
            } break;
                
            case KSTNanoSDKStateInitializingTime:
            {
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKBusy waitUntilDone:YES];
                [self KSTNanoSDKSetCurrentTime];    // triggers KSTNanoSDKStateFetchSpectrumCalCoefficients upon didWrite:
            } break;
                
            case KSTNanoSDKStateFetchSpectrumCalCoefficients:
            {
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKBusy waitUntilDone:YES];
                [self changeToState:KSTNanoSDKStateFetchReferenceCalCoefficients];
            } break;
                
            case KSTNanoSDKStateFetchReferenceCalCoefficients:
            {
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKBusy waitUntilDone:YES];
                [self KSTNanoSDKReadReferenceCalCoefficients];
            } break;
                
            case KSTNanoSDKStateFetchReferenceCalMatrix:
            {
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKBusy waitUntilDone:YES];
                [self KSTNanoSDKReadReferenceCalMatrix];
            } break;
                
                // NOTE:  This is temporarily bypassed; KSTNanoSDKReadReferenceCalMatrix goes right to KSTNanoSDKStateReady
            case KSTNanoSDKStateFetchScanConfigurations:
            {
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKBusy waitUntilDone:YES];
                [self KSTNanoSDKRefreshScanConfigStatus];
            } break;
                
            case KSTNanoSDKStateReadingSDCard:
            {
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKBusy waitUntilDone:YES];
            } break;
                
            case KSTNanoSDKStateReadingScanConfigurations:
            {
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKBusy waitUntilDone:YES];
            } break;
                
            case KSTNanoSDKStateReady:
            {
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKReady waitUntilDone:YES];
            } break;
                
            case KSTNanoSDKStateDisconnected:
            {
                [self performSelectorOnMainThread:@selector(triggerNotificationWithName:) withObject:kKSTNanoSDKDisconnected waitUntilDone:YES];
                
                // nil out the current peripheral to prepare for a new one
                if( peripheral )
                {
                    [peripheral setDelegate:nil];
                    peripheral = nil;
                }
                
                // clear out the reference calibration data
                _spectrumCalCoefficientsBuffer = nil;
                _spectrumCalCoefficientsByteCount = 0;
                _lockedDownSpectrumCalCoefficientsBuffer = nil;
                
                _referenceCalCoefficientsBuffer = nil;
                _referenceCalCoefficientsByteCount = 0;
                _lockedDownReferenceCalCoefficientsBuffer = nil;
                
                _referenceCalMatrixBuffer = nil;
                _referenceCalMatrixByteCount = 0;
                _lockedDownReferenceMatrixBuffer = nil;
                
                _scanDataBuffer = nil;
                _scanDataByteCount = 0;
                
                [self changeToState:KSTNanoSDKStateIdle];
                
            } break;
                
            default:
            {
                [self changeToState:KSTNanoSDKStateIdle];
            } break;
        }
    }
}

#pragma mark - Thread-safe Notifications
- (void)triggerNotificationWithName:(NSString *)notificationName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
}

- (void)triggerNotificationWithNamePercentage:(NSDictionary *)namePercentageDict
{
    [[NSNotificationCenter defaultCenter] postNotificationName:namePercentageDict[@"name"] object:self userInfo:namePercentageDict];
}

@end