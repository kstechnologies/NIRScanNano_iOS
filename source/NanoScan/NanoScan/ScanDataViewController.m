//
//  ScanDataViewController.m
//  NanoScan
//
//  Created by bob on 2/25/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import "ScanDataViewController.h"
#import "KSTNanoSDK.h"

@interface ScanDataViewController ()

@end

@implementation ScanDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Scan Data on SD Card";
    
    _dataManager = [KSTDataManager manager];
    
    //Remove blank cells at the bottom of the table view
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    _scanDataTableView.tableFooterView = footer;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateDataPercentComplete:) name:kKSTNanoSDKDownloadingData object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [[KSTNanoSDK manager] KSTNanoSDKRefreshSDCardStatus];
    
    _progressView.progress = 0.0;
    _statusLabel.text = @"Reading SD Card ...";
    _scanDataTableView.hidden = YES;
}

-(void)didUpdateDataPercentComplete:(NSNotification *)aNotification
{
    _statusLabel.hidden = NO;
    _progressView.hidden = NO;
    _scanDataTableView.hidden = YES;
    
    self.navigationController.navigationItem.leftBarButtonItem.enabled = NO;
    
    NSDictionary *percentCompleteDict = [aNotification userInfo];
    NSNumber *percentComplete = percentCompleteDict[@"percentage"];
    
    _progressView.progress = percentComplete.floatValue/100.0;
        
    [_scanDataTableView reloadData];
    
    if( percentComplete.floatValue == 100.0 )
    {
        _statusLabel.hidden = YES;
        _progressView.hidden = YES;
        _scanDataTableView.hidden = NO;
        self.navigationController.navigationItem.leftBarButtonItem.enabled = YES;
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
    return _dataManager.sdCardArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSMutableDictionary *anSDfile = [_dataManager.sdCardArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = anSDfile[kKSTDataManagerSDCard_Name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", anSDfile[kKSTDataManagerSDCard_Timestamp]];
    
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSMutableDictionary *anSDfile = [_dataManager.sdCardArray objectAtIndex:indexPath.row];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Delete File"
                                          message:[NSString stringWithFormat:@"Are you sure you want to permanently delete filename '%@' from your SD Card?", anSDfile[kKSTDataManagerSDCard_Name]]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action)
                               {
                                   [[KSTNanoSDK manager] KSTNanoSDKClearScanAtIndex:anSDfile[kKSTDataManagerSDCard_Index]];
                                   [_dataManager.sdCardArray removeObjectAtIndex:indexPath.row];
                                   [_scanDataTableView reloadData];
                               }];
    [alertController addAction:okAction];
    
    UIAlertAction *cancelAction = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
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
