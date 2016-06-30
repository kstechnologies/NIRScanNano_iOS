//
//  ScanConfigurationViewController.m
//  NanoScan
//
//  Created by bob on 6/29/16.
//  Copyright © 2016 KS Technologies. All rights reserved.
//

#import "ScanConfigurationViewController.h"

#import "KSTNanoSDK.h"
#import "KSTDataManager.h"

#import "SettingsViewController.h"
#import "ScanConfigurationTableViewCell.h"

@interface ScanConfigurationViewController ()

@property( nonatomic, weak ) IBOutlet UITableView *scanConfigurationTableView;
@property( strong, nonatomic ) KSTDataManager *dataManager;
@property( strong, nonatomic ) NSDictionary *activeConfiguration;

@end

@implementation ScanConfigurationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Current Scan Configuration";
    
    _dataManager = [KSTDataManager manager];
    NSLog(@"TEST _dataManager.activeScanConfiguration %@ %@", _dataManager.activeScanConfiguration, _dataManager.scanConfigArray);
    
    if( _dataManager.activeScanConfiguration )
    {
        self.activeConfiguration = _dataManager.scanConfigArray[_dataManager.activeScanConfiguration.intValue];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.activeConfiguration[kKSTDataManagerScanConfig_SectionsArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ScanConfigurationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSArray *arrayOfDictionary = self.activeConfiguration[kKSTDataManagerScanConfig_SectionsArray];
    NSLog(@"[debug] full array - %@", arrayOfDictionary);
    
    NSDictionary *aSingleSlewScanConfiguration = arrayOfDictionary[indexPath.row];
    NSLog(@"[debug] single %@", aSingleSlewScanConfiguration);

    NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
    float testX = [aSingleSlewScanConfiguration[kKSTDataManagerScanConfig_WavelengthStart] floatValue];
            
    if( spatialPref.intValue == kSpatialPreferenceWavenumber )
    {
        testX = 10000000.0 / testX; // converts to cm-1
        //cell.textLabel.text = @"Spectral Range Start (cm-1)";
    }
    else
    {
        //cell.textLabel.text = @"Spectral Range Start (nm)";
    }
    cell.wavelengthStart.text = [NSString stringWithFormat:@"%2.1f", testX];
    
    testX = [aSingleSlewScanConfiguration[kKSTDataManagerScanConfig_WavelengthEnd] floatValue];
            
    if( spatialPref.intValue == kSpatialPreferenceWavenumber )
    {
        testX = 10000000.0 / testX; // converts to cm-1
        //cell.textLabel.text = @"Spectral Range End (cm-1)";
    }
    else
    {
        //cell.textLabel.text = @"Spectral Range End (nm)";
    }
    
    cell.wavelengthEnd.text = [NSString stringWithFormat:@"%2.1f", testX];
    cell.numPatterns.text = [NSString stringWithFormat:@"%@", aSingleSlewScanConfiguration[kKSTDataManagerScanConfig_NumPatterns]];
    cell.configName.text = [NSString stringWithFormat:@"%@", aSingleSlewScanConfiguration[kKSTDataManagerScanConfig_ConfigName]];
    cell.width.text = [NSString stringWithFormat:@"%@", aSingleSlewScanConfiguration[kKSTDataManagerScanConfig_Width]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
