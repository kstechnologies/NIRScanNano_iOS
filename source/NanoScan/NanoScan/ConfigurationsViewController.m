//
//  ConfigurationsViewController.m
//  NanoScan
//
//  Created by bob on 2/19/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import "ConfigurationsViewController.h"
#import "ScanConfigurationTableViewCell.h"
#import "SettingsViewController.h"

#import "KSTNanoSDK.h"

@interface ConfigurationsViewController ()

@end

@implementation ConfigurationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Scan Configurations";
    _statusLabel.text = @"Reading ...";

    _dataManager = [KSTDataManager manager];
    
    //Remove blank cells at the bottom of the table view
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    _configurationTableView.tableFooterView = footer;
    
    _configurationTableView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateDataPercentComplete:) name:kKSTNanoSDKDownloadingData object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    _progressView.progress = 0.0;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_dataManager.scanConfigArray removeAllObjects];

    [[KSTNanoSDK manager] KSTNanoSDKRefreshScanConfigStatus];
    
    _progressView.progress = 0.0;
    _configurationTableView.hidden = YES;
}

-(void)didUpdateDataPercentComplete:(NSNotification *)aNotification
{
    _statusLabel.hidden = NO;
    _progressView.hidden = NO;
    _configurationTableView.hidden = YES;
    
    self.navigationController.navigationItem.leftBarButtonItem.enabled = NO;
    
    NSDictionary *percentCompleteDict = [aNotification userInfo];
    NSNumber *percentComplete = percentCompleteDict[@"percentage"];
    
    _progressView.progress = percentComplete.floatValue/100.0;
    
    if( percentComplete.floatValue == 100.0 )
    {
        _statusLabel.hidden = YES;
        _progressView.hidden = YES;
        _configurationTableView.hidden = NO;
        self.navigationController.navigationItem.leftBarButtonItem.enabled = YES;
        
        [_configurationTableView reloadData];
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
    return _dataManager.scanConfigArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScanConfigurationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSMutableDictionary *aScanConfig = [_dataManager.scanConfigArray objectAtIndex:indexPath.row];
    
    cell.serialNumber.text = aScanConfig[kKSTDataManagerScanConfig_SerialNumber];
    cell.configName.text = [NSString stringWithFormat:@"%@", aScanConfig[kKSTDataManagerScanConfig_ConfigName]];
    
    cell.type.text = [NSString stringWithFormat:@"%@", aScanConfig[kKSTDataManagerScanConfig_Type]];
    cell.index.text = [NSString stringWithFormat:@"%@", aScanConfig[kKSTDataManagerScanConfig_Index]];
    
    NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
    float testX = [aScanConfig[kKSTDataManagerScanConfig_WavelengthStart] floatValue];
    
    if( spatialPref.intValue == kSpatialPreferenceWavenumber )
    {
        testX = 10000000.0 / testX; // converts to cm-1
        cell.wavelengthStart.text = [NSString stringWithFormat:@"%2.1f cm-1", testX];
    }
    else
    {
        cell.wavelengthStart.text = [NSString stringWithFormat:@"%2.1f nm", testX];
    }

    float testY = [aScanConfig[kKSTDataManagerScanConfig_WavelengthEnd] floatValue];
    
    if( spatialPref.intValue == kSpatialPreferenceWavenumber )
    {
        testY = 10000000.0 / testY; // converts to cm-1
        cell.wavelengthEnd.text = [NSString stringWithFormat:@"%2.1f cm-1", testY];
    }
    else
    {
        cell.wavelengthEnd.text = [NSString stringWithFormat:@"%2.1f nm", testY];
    }
    
    cell.width.text = [NSString stringWithFormat:@"%@ nm", aScanConfig[kKSTDataManagerScanConfig_Width]];
    cell.numPatterns.text = [NSString stringWithFormat:@"%@", aScanConfig[kKSTDataManagerScanConfig_NumPatterns]];
    cell.numRepeats.text = [NSString stringWithFormat:@"%@", aScanConfig[kKSTDataManagerScanConfig_NumRepeats]];
    
    cell.userInteractionEnabled = YES;
    
    if( indexPath.row == _dataManager.activeScanConfiguration.intValue )
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // You can't modify scan configurations over BLE but you can set a new one as active
    _dataManager.activeScanConfiguration = [NSNumber numberWithInt:(int)indexPath.row];
    NSData *newIndex = _dataManager.scanConfigArray[indexPath.row][kKSTDataManagerScanConfig_Index];
    
    [[KSTNanoSDK manager] KSTNanoSDKSetActiveScanConfigurationToIndex:newIndex];
    
    [self.configurationTableView reloadData];

}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
