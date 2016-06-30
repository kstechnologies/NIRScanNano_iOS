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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSArray *arrayOfConfigurations = _dataManager.scanConfigArray;
    NSDictionary *aSingleConfiguration = arrayOfConfigurations[indexPath.row];
    NSArray *arrayOfDictionary = aSingleConfiguration[kKSTDataManagerScanConfig_SectionsArray];

    NSDictionary *aSingleElement = arrayOfDictionary[0];
    NSString *configName = aSingleElement[kKSTDataManagerScanConfig_ConfigName];
    
    cell.textLabel.text = configName;
    
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

@end