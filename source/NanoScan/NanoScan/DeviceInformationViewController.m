//
//  DeviceInformationViewController.m
//  NanoScan
//
//  Created by bob on 12/15/14.
//  Copyright (c) 2014 KS Technologies. All rights reserved.
//

#import "DeviceInformationViewController.h"
#import "KSTNanoSDK.h"

typedef enum
{
    kDeviceInformationRowManufacturerName = 0,
    kDeviceInformationRowModelNumber,
    kDeviceInformationRowSerialNumber,
    kDeviceInformationRowHardwareRev,
    kDeviceInformationRowTivaRev,
    kDeviceInformationRowSpectrumRev
} kDeviceInformationRow;

@interface DeviceInformationViewController ()
@end

@implementation DeviceInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Device Info";
    
    //Remove blank cells at the bottom of the table view
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    _deviceInfoTableView.tableFooterView = footer;

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
    return kDeviceInformationRowSpectrumRev+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    KSTNanoSDK *nano = [KSTNanoSDK manager];
    
    switch (indexPath.row)
    {
        case kDeviceInformationRowManufacturerName:
            cell.textLabel.text = @"Manufacturer";
            if( nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeyManufacturerName] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeyManufacturerName];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceInformationRowModelNumber:
            cell.textLabel.text = @"Model Number";
            if( nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeyModelNumber] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeyModelNumber];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceInformationRowSerialNumber:
            cell.textLabel.text = @"Serial Number";
            if( nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeyModelNumber] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeySerialNumber];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceInformationRowHardwareRev:
            cell.textLabel.text = @"Hardware Rev";
            if( nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeyModelNumber] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeyHardwareRev];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceInformationRowTivaRev:
            cell.textLabel.text = @"Tiva Rev";
            if( nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeyModelNumber] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeyTivaRev];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceInformationRowSpectrumRev:
            cell.textLabel.text = @"Spectrum Rev";
            if( nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeyModelNumber] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceInfo[kKSTNanoSDKKeySpectrumRev];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        default:
            break;
    }
    
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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
