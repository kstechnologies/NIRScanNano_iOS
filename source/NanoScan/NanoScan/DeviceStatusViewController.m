//
//  DeviceStatusViewController.m
//  NanoScan
//
//  Created by bob on 2/4/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import "DeviceStatusViewController.h"
#import "KSTNanoSDK.h"
#import "SettingsViewController.h"

typedef enum
{
    kDeviceStatusRowBattery = 0,
    kDeviceStatusRowTemperature,
    kDeviceStatusRowHumidity,
    kDeviceStatusRowDeviceStatus,
    kDeviceStatusRowErrorStatus,
    kDeviceStatusRowTemperatureThreshold,
    kDeviceStatusRowHumidityThreshold
    //kDeviceStatusRowUsageHours,
    //kDeviceStatusRowBatteryRechargeHours,
    //kDeviceStatusRowTotalLampHours,
    //kDeviceStatusRowErrorLog
} kDeviceStatusRow;

@interface DeviceStatusViewController ()
@end

@implementation DeviceStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Device Status";
    
    //Remove blank cells at the bottom of the table view
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    _deviceStatusTableView.tableFooterView = footer;
    
    UIBarButtonItem *configureButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"Write"
                                        style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(writeToNano)];
    self.navigationItem.rightBarButtonItem = configureButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)writeToNano
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kDeviceStatusRowHumidityThreshold+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    KSTNanoSDK *nano = [KSTNanoSDK manager];
    
    switch (indexPath.row)
    {
        case kDeviceStatusRowBattery:
            cell.textLabel.text = @"Battery";
            if( nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyBattery] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyBattery];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceStatusRowTemperature:
            cell.textLabel.text = @"Temperature";
            if( nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyTemperature] )
            {
                NSNumber *temperaturePref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsTemperaturePreference];
                switch (temperaturePref.intValue)
                {
                    case kTemperaturePreferenceCelsius:
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\u00b0C", nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyTemperature]];
                        break;
                        
                    case kTemperaturePreferenceFahr:
                    {
                        float tempFahr = ([nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyTemperature] floatValue] * (9.0/5.0)) + 32.0;
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%2.1f\u00b0F", tempFahr];
                    } break;
                        
                    default:
                        cell.detailTextLabel.text = @"Not Specififed";
                        break;
                }
            }
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceStatusRowHumidity:
            cell.textLabel.text = @"Humidity";
            if( nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyHumidity] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyHumidity];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceStatusRowDeviceStatus:
            cell.textLabel.text = @"Device Status";
            if( nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyDeviceStatus] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyDeviceStatus];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceStatusRowErrorStatus:
            cell.textLabel.text = @"Error Status";
            if( nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyErrorStatus] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyErrorStatus];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceStatusRowTemperatureThreshold:
        {
            cell.textLabel.text = @"Temperature Threshold";
            cell.detailTextLabel.text = @"";
            
            UITextField *tempThresholdTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100.0, cell.frame.size.height/4.0, 80.0, cell.frame.size.height/2.0)];
            tempThresholdTextField.delegate = self;
            tempThresholdTextField.tag = kDeviceStatusRowTemperatureThreshold;
            tempThresholdTextField.placeholder = @"deg C";
            tempThresholdTextField.borderStyle = UITextBorderStyleRoundedRect;
            tempThresholdTextField.keyboardType = UIKeyboardTypeNumberPad;
            
            if( nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyTemperatureThreshold] )
                tempThresholdTextField.text = nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyTemperatureThreshold];
            
            [cell addSubview:tempThresholdTextField];
            
        } break;
            
        case kDeviceStatusRowHumidityThreshold:
        {
            cell.textLabel.text = @"Humidity Threshold";
            cell.detailTextLabel.text = @"";
            
            UITextField *humidityThresholdTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100.0, cell.frame.size.height/4.0, 80.0, cell.frame.size.height/2.0)];
            humidityThresholdTextField.delegate = self;
            humidityThresholdTextField.tag = kDeviceStatusRowHumidityThreshold;
            humidityThresholdTextField.placeholder = @"% RH";
            humidityThresholdTextField.borderStyle = UITextBorderStyleRoundedRect;
            humidityThresholdTextField.keyboardType = UIKeyboardTypeNumberPad;
            
            if( nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyHumidityThreshold] )
                humidityThresholdTextField.text = nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyHumidityThreshold];
            
            [cell addSubview:humidityThresholdTextField];

        } break;
            
            /*
        case kDeviceStatusRowUsageHours:
            cell.textLabel.text = @"Total Usage, Hours";
            if( nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyUsageHours] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyUsageHours];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceStatusRowBatteryRechargeHours:
            cell.textLabel.text = @"Battery Recharge Cycles";
            if( nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyBatteryRechargeCycles] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyBatteryRechargeCycles];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceStatusRowTotalLampHours:
            cell.textLabel.text = @"Total Lamp Hours";
            if( nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyTotalLampHours] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyTotalLampHours];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            
        case kDeviceStatusRowErrorLog:
            cell.textLabel.text = @"Last Error";
            if( nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyErrorLog] )
                cell.detailTextLabel.text = nano.KSTNanoSDKdeviceStatus[kKSTNanoSDKKeyErrorLog];
            else
                cell.detailTextLabel.text = @"Not Specified";
            break;
            */
        default:
            break;
    }
    
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITextField Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    // You cannot scroll to the row because the contentHeight of the table would be exceeded.
    // This is marginal and could be improved.
    CGPoint origin = textField.frame.origin;
    CGPoint point = [textField.superview convertPoint:origin toView:_deviceStatusTableView];
    CGPoint offset = _deviceStatusTableView.contentOffset;
    offset.y += point.y - 100.0;
    [_deviceStatusTableView setContentOffset:offset animated:YES];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    // Maybe not 100% ideal; we force the view here bsck to the top no matter where I am.
    [_deviceStatusTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    switch (textField.tag)
    {
        case kDeviceStatusRowTemperatureThreshold:
        {
            NSCharacterSet *wholeNumberSet = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *tempThresholdSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
            
            if ([wholeNumberSet isSupersetOfSet:tempThresholdSet])
            {
                NSNumber *tempThreshold = [NSNumber numberWithInt:textField.text.intValue];
                [[KSTNanoSDK manager] KSTNanoSDKSetTemperatureThreshold:tempThreshold];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:nil
                                                      message:@"Valid temperature thresholds are integers between 0degC and 255degC."
                                                      preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                           }];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        } break;
            
        case kDeviceStatusRowHumidityThreshold:
        {
            NSCharacterSet *wholeNumberSet = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *humidityThresholdSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
            
            if ([wholeNumberSet isSupersetOfSet:humidityThresholdSet])
            {
                NSNumber *humidityThreshold = [NSNumber numberWithUnsignedInteger:textField.text.intValue];
                [[KSTNanoSDK manager] KSTNanoSDKSetHumidityThreshold:humidityThreshold];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:nil
                                                      message:@"Valid humidity thresholds are integers between 0% RH and 100% RH."
                                                      preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                           }];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        } break;
            
        default:
            break;
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

