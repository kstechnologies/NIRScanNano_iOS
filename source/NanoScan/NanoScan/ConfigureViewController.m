//
//  ConfigureViewController.m
//  NanoScan
//
//  Created by bob on 12/13/14.
//  Copyright (c) 2014 KS Technologies. All rights reserved.
//

#import "ConfigureViewController.h"
#import "KSTNanoSDK.h"

typedef enum
{
    kConfigureRowDeviceInfo = 0,
    kConfigureRowDeviceStatus,
    //kConfigureRowDeviceDiagnostic,
    kConfigureRowDeviceConfigurations,
    kConfigureRowDeviceData             // always the last row
} kConfigureRow;

@interface ConfigureViewController ()
@end

@implementation ConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Configure";
    
    //Remove blank cells at the bottom of the table view
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    _configureTableView.tableFooterView = footer;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[KSTNanoSDK manager] KSTNanoSDKRefreshDeviceStatus];
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
    return kConfigureRowDeviceData+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    switch (indexPath.row)
    {
        case kConfigureRowDeviceInfo:
            cell.textLabel.text = @"Device Information";
            break;
            
        case kConfigureRowDeviceStatus:
            cell.textLabel.text = @"Device Status";
            break;
           
            /*
        case kConfigureRowDeviceDiagnostic:
            cell.textLabel.text = @"Diagnostic";
            break;
            */
            
        case kConfigureRowDeviceConfigurations:
            cell.textLabel.text = @"Scan Configurations";
            break;
            
        case kConfigureRowDeviceData:
            cell.textLabel.text = @"Stored Scan Data";
            break;
            
        default:
            break;
    }
    
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case kConfigureRowDeviceInfo:
            [self performSegueWithIdentifier:@"showDeviceInfo" sender:self];
            break;
            
        case kConfigureRowDeviceStatus:
            [self performSegueWithIdentifier:@"showDeviceStatus" sender:self];
            break;
           
            /*
        case kConfigureRowDeviceDiagnostic:
            [self performSegueWithIdentifier:@"showDiagnostics" sender:self];
            break;
            */

        case kConfigureRowDeviceConfigurations:
            [self performSegueWithIdentifier:@"showConfigurations" sender:self];
            break;

        case kConfigureRowDeviceData:
            [self performSegueWithIdentifier:@"showScanData" sender:self];
            break;
            
        default:
        {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:nil
                                                  message:@"Sorry!  This feature is not yet implemented."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                       }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        } break;
    }
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
