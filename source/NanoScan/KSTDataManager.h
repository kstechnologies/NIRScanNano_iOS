//
//  KSTDataManager.h
//  NanoScan
//
//  Created by bob on 3/6/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

// Keys
static NSString *kKSTDataManagerKeyData = @"kKSTDataManagerKeyData";

// Data file details (stored on iOS Device)
static NSString *kKSTDataManagerFilename = @"kKSTDataManagerFilename";
static NSString *kKSTDataManagerSerialNumber = @"kKSTDataManagerSerialNumber";
static NSString *kKSTDataManagerKeyMethod = @"kKSTDataManagerKeyMethod";
static NSString *kKSTDataManagerKeyTimestamp = @"kKSTDataManagerKeyTimestamp";
static NSString *kKSTDataManagerSpectralRangeStart = @"kKSTDataManagerSpectralRangeStart";
static NSString *kKSTDataManagerSpectralRangeEnd = @"kKSTDataManagerSpectralRangeEnd";
static NSString *kKSTDataManagerNumberOfWavelengthPoints = @"kKSTDataManagerNumberOfWavelengthPoints";
static NSString *kKSTDataManagerDigitalResolution = @"kKSTDataManagerDigitalResolution";
static NSString *kKSTDataManagerNumberOfAverages = @"kKSTDataManagerNumberOfAverages";
static NSString *kKSTDataManagerTotalMeasurementTime = @"kKSTDataManagerTotalMeasurementTime";
static NSString *kKSTDataManagerAbsorbance = @"kKSTDataManagerAbsorbance";
static NSString *kKSTDataManagerReflectance = @"kKSTDataManagerReflectance";
static NSString *kKSTDataManagerIntensity = @"kKSTDataManagerIntensity";
static NSString *kKSTDataManagerWavelength = @"kKSTDataManagerWavelength";
static NSString *kKSTDataManagerWavenumber = @"kKSTDataManagerWavenumber";
static NSString *kKSTDataManagerReverseAbsorbance = @"kKSTDataManagerReverseAbsorbance";
static NSString *kKSTDataManagerReverseReflectance = @"kKSTDataManagerReverseReflectance";
static NSString *kKSTDataManagerReverseIntensity = @"kKSTDataManagerReverseIntensity";

// Data file details (stored on SD Card)
static NSString *kKSTDataManagerSDCard_Index = @"kKSTDataManagerSDCard_Index";
static NSString *kKSTDataManagerSDCard_Name = @"kKSTDataManagerSDCard_Name";
static NSString *kKSTDataManagerSDCard_Type = @"kKSTDataManagerSDCard_Type";
static NSString *kKSTDataManagerSDCard_Timestamp = @"kKSTDataManagerSDCard_Timestamp";
static NSString *kKSTDataManagerSDCard_Version = @"kKSTDataManagerSDCard_Version";

// Scan Configuration Details
static NSString *kKSTDataManagerScanConfig_Type = @"kKSTDataManagerScanConfig_Type";
static NSString *kKSTDataManagerScanConfig_Index = @"kKSTDataManagerScanConfig_Index";
static NSString *kKSTDataManagerScanConfig_SerialNumber = @"kKSTDataManagerScanConfig_SerialNumber";
static NSString *kKSTDataManagerScanConfig_ConfigName = @"kKSTDataManagerScanConfig_ConfigName";
static NSString *kKSTDataManagerScanConfig_WavelengthStart = @"kKSTDataManagerScanConfig_WavelengthStart";
static NSString *kKSTDataManagerScanConfig_WavelengthEnd = @"kKSTDataManagerScanConfig_WavelengthEnd";
static NSString *kKSTDataManagerScanConfig_Width = @"kKSTDataManagerScanConfig_Width";
static NSString *kKSTDataManagerScanConfig_NumPatterns = @"kKSTDataManagerScanConfig_NumPatterns";
static NSString *kKSTDataManagerScanConfig_NumRepeats = @"kKSTDataManagerScanConfig_NumRepeats";

#pragma mark - Delegate Methods
@protocol KSTDataManagerDelegate <NSObject>
-(void)KSTDataManagerDidAddNewFile;
@end

@interface KSTDataManager : NSObject

#pragma mark - Class Methods
+ (id)manager;
@property(readwrite, unsafe_unretained) id <KSTDataManagerDelegate> delegate;

@property( nonatomic, retain ) NSMutableArray *dataArray;
@property( nonatomic, retain ) NSMutableArray *sdCardArray;
@property( nonatomic, retain ) NSMutableArray *scanConfigArray;
@property( nonatomic, retain ) NSNumber *activeScanConfiguration;


-(void)KSTDataManagerInitialize;
-(void)KSTDataManagerSave;

-(void)KSTDataManagerSetActiveScanConfigurationIndexToIndex:(NSData *)index;

@end
