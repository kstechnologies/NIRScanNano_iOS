//
//  ScannerViewController.m
//  NanoScan
//
//  Created by bob on 5/7/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import "ScannerViewController.h"
#import "SettingsViewController.h"
#import "KSTNanoSDK.h"

@interface ScannerViewController ()

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePeripheralList) name:kKSTNanoSDKUpdatedVisiblePeripherals object:nil];
    
    [[KSTNanoSDK manager] KSTNanoSDKShouldActivelyScanForNano:@YES];
}

-(IBAction)doneScanning:(id)sender
{
    [[KSTNanoSDK manager] KSTNanoSDKShouldActivelyScanForNano:@NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didUpdatePeripheralList
{
    [_scannerTableView reloadData];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    KSTNanoSDK *nanoSDK = [KSTNanoSDK manager];
    return [nanoSDK.KSTNanoSDKvisiblePeripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    KSTNanoSDK *nanoSDK = [KSTNanoSDK manager];
    
    NSDictionary *aVisiblePeripheral = nanoSDK.KSTNanoSDKvisiblePeripherals[indexPath.row];
    cell.textLabel.text = aVisiblePeripheral[@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ dBm", aVisiblePeripheral[@"rssi"]];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KSTNanoSDK *nanoSDK = [KSTNanoSDK manager];
    NSDictionary *aVisiblePeripheral = nanoSDK.KSTNanoSDKvisiblePeripherals[indexPath.row];
    
    // store the uuid
    [[NSUserDefaults standardUserDefaults] setObject:aVisiblePeripheral[@"uuid"] forKey:kNanoSettingsDeviceIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // set the filter
    nanoSDK.KSTNanoSDKmyNanoUUIDString = aVisiblePeripheral[@"uuid"];
    
    [self doneScanning:nil];
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
