//
//  KSTDataManager.m
//  NanoScan
//
//  Created by bob on 3/6/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import "KSTDataManager.h"

static KSTDataManager *manager = nil;

@implementation KSTDataManager

#pragma mark - Singleton Management
+ (KSTDataManager *)manager
{
    if (nil != manager)
    {
        return manager;
    }
    
    // This guarantees that we always only have a single instance of the KSTNanoSDK in a given app lifecycle.
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[KSTDataManager alloc] init];
    });

    return manager;
}

-(void)KSTDataManagerSave
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:_dataArray] forKey:kKSTDataManagerKeyData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"[NOTICE] Data has been saved locally.");
}


-(void)KSTDataManagerInitialize
{
    NSLog(@"[APP] KSTDataManagerInitialize");
    
    if( !_dataArray )
        _dataArray = [NSMutableArray array];
    
    if( !_sdCardArray )
        _sdCardArray = [NSMutableArray array];
    
    if( !_scanConfigArray )
        _scanConfigArray = [NSMutableArray array];
    
    [_dataArray setArray:[[[NSUserDefaults standardUserDefaults] objectForKey:kKSTDataManagerKeyData] mutableCopy]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if( _dataArray.count < 10 )
    {
        
        [self loadCSVfileWithName:@"Apple"
                       withMethod:@"col8"
                    withTimestamp:@"3/3/2015 @ 15:50:00"
           withSpectralRangeStart:[NSNumber numberWithFloat:852.15979]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1780.73645]
          withNumWavelengthPoints:[NSNumber numberWithInt:106]
            withDigitalResolution:[NSNumber numberWithInt:106]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:2]];
        
        [self loadCSVfileWithName:@"aspirin"
                       withMethod:@"standard_scan"
                    withTimestamp:@"2/3/2015 @ 14:46:06"
           withSpectralRangeStart:[NSNumber numberWithFloat:850.804993]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1779.879761]
          withNumWavelengthPoints:[NSNumber numberWithInt:85]
            withDigitalResolution:[NSNumber numberWithInt:85]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:2]];
        
        [self loadCSVfileWithName:@"BC"
                       withMethod:@"standard_scan"
                    withTimestamp:@"2/3/2015 @ 14:47:41"
           withSpectralRangeStart:[NSNumber numberWithFloat:850.804993]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1779.879761]
          withNumWavelengthPoints:[NSNumber numberWithInt:85]
            withDigitalResolution:[NSNumber numberWithInt:85]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:1]];
        
        [self loadCSVfileWithName:@"Bell_Pepper"
                       withMethod:@"col8"
                    withTimestamp:@"3/3/2015 @ 15:6:32"
           withSpectralRangeStart:[NSNumber numberWithFloat:852.15979]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1780.73645]
          withNumWavelengthPoints:[NSNumber numberWithInt:106]
            withDigitalResolution:[NSNumber numberWithInt:106]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:2]];
        
        [self loadCSVfileWithName:@"CoconutOil"
                       withMethod:@"standard_scan"
                    withTimestamp:@"5/3/2015 @ 11:38:43"
           withSpectralRangeStart:[NSNumber numberWithFloat:853.104553]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1794.033813]
          withNumWavelengthPoints:[NSNumber numberWithInt:106]
            withDigitalResolution:[NSNumber numberWithInt:106]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:1]];
        
        [self loadCSVfileWithName:@"coffee"
                       withMethod:@"standard_scan"
                    withTimestamp:@"2/3/2015 @ 14:43:06"
           withSpectralRangeStart:[NSNumber numberWithFloat:850.804993]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1779.879761]
          withNumWavelengthPoints:[NSNumber numberWithInt:85]
            withDigitalResolution:[NSNumber numberWithInt:85]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:2]];
        
        [self loadCSVfileWithName:@"corn_starch"
                       withMethod:@"standard_scan"
                    withTimestamp:@"2/3/2015 @ 14:44:27"
           withSpectralRangeStart:[NSNumber numberWithFloat:850.804993]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1779.879761]
          withNumWavelengthPoints:[NSNumber numberWithInt:85]
            withDigitalResolution:[NSNumber numberWithInt:85]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:1]];
        
        [self loadCSVfileWithName:@"Eucerin_Lotion"
                       withMethod:@"standard_scan"
                    withTimestamp:@"4/3/2015 @ 21:32:00"
           withSpectralRangeStart:[NSNumber numberWithFloat:853.104553]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1794.033813]
          withNumWavelengthPoints:[NSNumber numberWithInt:106]
            withDigitalResolution:[NSNumber numberWithInt:106]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:1]];
        
        [self loadCSVfileWithName:@"Flour"
                       withMethod:@"col8"
                    withTimestamp:@"3/3/2015 @ 15:01:58"
           withSpectralRangeStart:[NSNumber numberWithFloat:852.15979]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1780.73645]
          withNumWavelengthPoints:[NSNumber numberWithInt:106]
            withDigitalResolution:[NSNumber numberWithInt:106]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:2]];
        
        [self loadCSVfileWithName:@"Glucose"
                       withMethod:@"col8"
                    withTimestamp:@"3/3/2015 @ 15:01:14"
           withSpectralRangeStart:[NSNumber numberWithFloat:852.15979]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1780.73645]
          withNumWavelengthPoints:[NSNumber numberWithInt:106]
            withDigitalResolution:[NSNumber numberWithInt:106]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:3]];
        
        [self loadCSVfileWithName:@"out_of_spec_aspirin"
                       withMethod:@"standard_scan"
                    withTimestamp:@"2/3/2015 @ 14:46:55"
           withSpectralRangeStart:[NSNumber numberWithFloat:850.804993]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1779.879761]
          withNumWavelengthPoints:[NSNumber numberWithInt:85]
            withDigitalResolution:[NSNumber numberWithInt:85]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:1]];
        
        [self loadCSVfileWithName:@"SRM2036"
                       withMethod:@"col8"
                    withTimestamp:@"3/3/2015 @ 15:23:47"
           withSpectralRangeStart:[NSNumber numberWithFloat:852.15979]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1780.73645]
          withNumWavelengthPoints:[NSNumber numberWithInt:106]
            withDigitalResolution:[NSNumber numberWithInt:106]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:2]];
        
        [self loadCSVfileWithName:@"Sucrose"
                       withMethod:@"col8"
                    withTimestamp:@"3/3/2015 @ 16:09:20"
           withSpectralRangeStart:[NSNumber numberWithFloat:852.15979]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1780.73645]
          withNumWavelengthPoints:[NSNumber numberWithInt:106]
            withDigitalResolution:[NSNumber numberWithInt:106]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:2]];
        
        [self loadCSVfileWithName:@"Tomato"
                       withMethod:@"col8"
                    withTimestamp:@"3/3/2015 @ 16:17:55"
           withSpectralRangeStart:[NSNumber numberWithFloat:852.15979]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1780.73645]
          withNumWavelengthPoints:[NSNumber numberWithInt:106]
            withDigitalResolution:[NSNumber numberWithInt:106]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:2]];
        
        [self loadCSVfileWithName:@"wonderbread"
                       withMethod:@"standard_scan"
                    withTimestamp:@"2/3/2015 @ 14:51:26"
           withSpectralRangeStart:[NSNumber numberWithFloat:850.804993]
             withSpectralRangeEnd:[NSNumber numberWithFloat:1779.879761]
          withNumWavelengthPoints:[NSNumber numberWithInt:85]
            withDigitalResolution:[NSNumber numberWithInt:85]
                     withAverages:[NSNumber numberWithInt:1]
              withMeasurementTime:[NSNumber numberWithInt:1]];
    }
    else
    {
        // I have files.
        [_delegate KSTDataManagerDidAddNewFile];
    }
}

-(void)loadCSVfileWithName:(NSString *)filename
                withMethod:(NSString *)method
             withTimestamp:(NSString *)timestamp
    withSpectralRangeStart:(NSNumber *)spectralStart
      withSpectralRangeEnd:(NSNumber *)spectralEnd
   withNumWavelengthPoints:(NSNumber *)numberWavelengthPoints
     withDigitalResolution:(NSNumber *)digitalResolution
              withAverages:(NSNumber *)numberAverages
       withMeasurementTime:(NSNumber *)measurementTime
{
    NSMutableArray *reflectanceCoordinates = [NSMutableArray array];
    NSMutableArray *absorbanceCoordinates = [NSMutableArray array];
    NSMutableArray *wavelengthCoordinates = [NSMutableArray array];
    NSMutableArray *wavenumberCoordinates = [NSMutableArray array];

    NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"csv"];
    if (url)
    {
        NSString *myFile = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        if (myFile)
        {
            NSArray *csvArray=[myFile componentsSeparatedByString:@"\n"];
            for( NSString *singlePoint in csvArray )
            {
                NSString *newString = [[singlePoint componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                NSArray *aPoint = [newString componentsSeparatedByString:@","];
                
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                                
                [wavelengthCoordinates addObject:[NSNumber numberWithDouble:[f numberFromString:aPoint[0]].doubleValue]];
                [absorbanceCoordinates addObject:[NSNumber numberWithDouble:[f numberFromString:aPoint[1]].doubleValue]];
                [reflectanceCoordinates addObject:[NSNumber numberWithDouble:[f numberFromString:aPoint[2]].doubleValue]];
                
                double wavenumber = 10000000 / [aPoint[0] floatValue];              // cm-1
                [wavenumberCoordinates addObject:[NSNumber numberWithFloat:wavenumber]];

            }
        }
    }
    
    NSArray *absorbanceReverseArray = [[absorbanceCoordinates reverseObjectEnumerator] allObjects];
    NSArray *reflectanceReverseArray = [[reflectanceCoordinates reverseObjectEnumerator] allObjects];
    NSArray *wavenumberReverseArray = [[wavenumberCoordinates reverseObjectEnumerator] allObjects];

    NSDictionary *sampleDictionary;
    sampleDictionary = @{kKSTDataManagerFilename:[NSString stringWithFormat:@"%@.csv", filename],
                         kKSTDataManagerKeyMethod:method,
                         kKSTDataManagerKeyTimestamp:timestamp,
                         kKSTDataManagerSpectralRangeStart:spectralStart,
                         kKSTDataManagerSpectralRangeEnd:spectralEnd,
                         kKSTDataManagerNumberOfWavelengthPoints:numberWavelengthPoints,
                         kKSTDataManagerDigitalResolution:digitalResolution,
                         kKSTDataManagerNumberOfAverages:numberAverages,
                         kKSTDataManagerTotalMeasurementTime:measurementTime,
                         kKSTDataManagerAbsorbance:absorbanceCoordinates,
                         kKSTDataManagerReflectance:reflectanceCoordinates,
                         kKSTDataManagerWavelength:wavelengthCoordinates,
                         kKSTDataManagerWavenumber:wavenumberReverseArray,
                         kKSTDataManagerReverseAbsorbance:absorbanceReverseArray,
                         kKSTDataManagerReverseReflectance:reflectanceReverseArray,
                         };
        
    if( !_dataArray )
        _dataArray = [NSMutableArray array];
    
    [_dataArray addObject:sampleDictionary];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:_dataArray] forKey:kKSTDataManagerKeyData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_delegate KSTDataManagerDidAddNewFile];
}

-(void)KSTDataManagerSetActiveScanConfigurationIndexToIndex:(NSData *)scanConfigIndexData
{
    NSLog(@"[DIAG] setting scan config to index %@", scanConfigIndexData);
    NSLog(@"[DIAG] current scan config array %@", _scanConfigArray);

    int index = 0;
    while( index < _scanConfigArray.count )
    {
        NSDictionary *testScanConfigDictionary = _scanConfigArray[index];
        NSData *testScanConfigIndex = testScanConfigDictionary[kKSTDataManagerScanConfig_Index];
        
        NSLog(@"[DIAG] comparing %@ to %@", testScanConfigIndex, scanConfigIndexData);
        
        if( [testScanConfigIndex isEqualToData:scanConfigIndexData] )
        {
            _activeScanConfiguration = [NSNumber numberWithInt:index];
            NSLog(@"[DIAG] Setting activeScanConfiguration to %@ (index=%@)", testScanConfigDictionary, _activeScanConfiguration);
        }
        
        index++;
    }
}

@end