//
//  DiagnosticViewController.m
//  NanoScan
//
//  Created by bob on 2/5/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import "DiagnosticViewController.h"
#import "KSTNanoSDK.h"

typedef enum
{
    kDiagnosticRowSetLED = 0,
    kDiagnosticRowSetBattLevel,
    kDiagnosticRowSetTemperature,
    kDiagnosticRowSetHumidity,
    kDiagnosticRowSetDeviceStatus,
    kDiagnosticRowSetErrorStatus,
    kDiagnosticRowSetHoursUsage,
    kDiagnosticRowSetBattCycles,
    kDiagnosticRowSetLampHours
} kDiagnosticRow;

@interface DiagnosticViewController ()
@end

@implementation DiagnosticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Diagnostics";
    
    //Remove blank cells at the bottom of the table view
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    _diagnosticTableView.tableFooterView = footer;
    
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

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kDiagnosticRowSetLampHours+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    switch (indexPath.row)
    {
        case kDiagnosticRowSetLED:
        {
            cell.textLabel.text = @"Set Yellow LED";
            cell.detailTextLabel.text = @"";
            
            UISwitch *ledSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-75.0, cell.frame.size.height/6.0, 80.0, cell.frame.size.height/2.0)];
            ledSwitch.tag = kDiagnosticRowSetLED;
            ledSwitch.on = NO;
            [ledSwitch addTarget:self action:@selector(changeLED:) forControlEvents:UIControlEventValueChanged];

            [cell addSubview:ledSwitch];
            
        } break;
            
        case kDiagnosticRowSetBattLevel:
        {
            cell.textLabel.text = @"Set Batt Level";
            cell.detailTextLabel.text = @"";
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100.0, cell.frame.size.height/4.0, 80.0, cell.frame.size.height/2.0)];
            textField.delegate = self;
            textField.tag = kDiagnosticRowSetBattLevel;
            textField.placeholder = @"%";
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell addSubview:textField];
            
        } break;
            
        case kDiagnosticRowSetTemperature:
        {
            cell.textLabel.text = @"Set Temperature";
            cell.detailTextLabel.text = @"";
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100.0, cell.frame.size.height/4.0, 80.0, cell.frame.size.height/2.0)];
            textField.delegate = self;
            textField.tag = kDiagnosticRowSetTemperature;
            textField.placeholder = @"degC";
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell addSubview:textField];
            
        } break;
            
        case kDiagnosticRowSetHumidity:
        {
            cell.textLabel.text = @"Set Humidity";
            cell.detailTextLabel.text = @"";
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100.0, cell.frame.size.height/4.0, 80.0, cell.frame.size.height/2.0)];
            textField.delegate = self;
            textField.tag = kDiagnosticRowSetHumidity;
            textField.placeholder = @"% RH";
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell addSubview:textField];
            
        } break;
            
        case kDiagnosticRowSetDeviceStatus:
        {
            cell.textLabel.text = @"Set Device Status";
            cell.detailTextLabel.text = @"";
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100.0, cell.frame.size.height/4.0, 80.0, cell.frame.size.height/2.0)];
            textField.delegate = self;
            textField.tag = kDiagnosticRowSetDeviceStatus;
            textField.placeholder = @"Flag";
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell addSubview:textField];
            
        } break;
            
        case kDiagnosticRowSetErrorStatus:
        {
            cell.textLabel.text = @"Set Error Status";
            cell.detailTextLabel.text = @"";
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100.0, cell.frame.size.height/4.0, 80.0, cell.frame.size.height/2.0)];
            textField.delegate = self;
            textField.tag = kDiagnosticRowSetErrorStatus;
            textField.placeholder = @"Flag";
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell addSubview:textField];
            
        } break;
            
        case kDiagnosticRowSetHoursUsage:
        {
            cell.textLabel.text = @"Set Hours of Use";
            cell.detailTextLabel.text = @"";
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100.0, cell.frame.size.height/4.0, 80.0, cell.frame.size.height/2.0)];
            textField.delegate = self;
            textField.tag = kDiagnosticRowSetHoursUsage;
            textField.placeholder = @"Hours";
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell addSubview:textField];
            
        } break;
            
        case kDiagnosticRowSetBattCycles:
        {
            cell.textLabel.text = @"Set Batt Cycles";
            cell.detailTextLabel.text = @"";
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100.0, cell.frame.size.height/4.0, 80.0, cell.frame.size.height/2.0)];
            textField.delegate = self;
            textField.tag = kDiagnosticRowSetBattCycles;
            textField.placeholder = @"Cycles";
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell addSubview:textField];
            
        } break;
            
        case kDiagnosticRowSetLampHours:
        {
            cell.textLabel.text = @"Set Lamp Hours";
            cell.detailTextLabel.text = @"";
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100.0, cell.frame.size.height/4.0, 80.0, cell.frame.size.height/2.0)];
            textField.delegate = self;
            textField.tag = kDiagnosticRowSetLampHours;
            textField.placeholder = @"Hours";
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell addSubview:textField];
            
        } break;
            
        default:
            break;
    }
    
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)changeLED:(UISwitch *)sender
{
    if( sender.isOn )
        [[KSTNanoSDK manager] KSTNanoSDKSetYellowLEDOn:@YES];
    else
        [[KSTNanoSDK manager] KSTNanoSDKSetYellowLEDOn:@NO];

}

-(void)writeToNano
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
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
    CGPoint point = [textField.superview convertPoint:origin toView:_diagnosticTableView];
    CGPoint offset = _diagnosticTableView.contentOffset;
    offset.y += point.y - 100.0;
    [_diagnosticTableView setContentOffset:offset animated:YES];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    // Maybe not 100% ideal; we force the view here bsck to the top no matter where I am.
    [_diagnosticTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    switch (textField.tag)
    {
        case kDiagnosticRowSetBattLevel:
        {
            NSCharacterSet *wholeNumberSet = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *textFieldSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
            
            if ([wholeNumberSet isSupersetOfSet:textFieldSet])
            {
                NSNumber *aValue = [NSNumber numberWithInt:textField.text.intValue];
                [[KSTNanoSDK manager] KSTNanoSDKSetDiagnosticBattery:aValue];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:nil
                                                      message:@"Valid diagnostic battery range is between 0% and 100%."
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
            
        case kDiagnosticRowSetTemperature:
        {
            NSCharacterSet *wholeNumberSet = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *textFieldSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
            
            if ([wholeNumberSet isSupersetOfSet:textFieldSet])
            {
                NSNumber *aValue = [NSNumber numberWithInt:textField.text.intValue];
                [[KSTNanoSDK manager] KSTNanoSDKSetDiagnosticTemperature:aValue];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:nil
                                                      message:@"Valid diagnostic temperature range is between 0degC and 255degC."
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
            
        case kDiagnosticRowSetHumidity:
        {
            NSCharacterSet *wholeNumberSet = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *textFieldSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
            
            if ([wholeNumberSet isSupersetOfSet:textFieldSet])
            {
                NSNumber *aValue = [NSNumber numberWithInt:textField.text.intValue];
                [[KSTNanoSDK manager] KSTNanoSDKSetDiagnosticHumidity:aValue];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:nil
                                                      message:@"Valid diagnostic humidity range is between 0%RH and 100%RH."
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
            
        case kDiagnosticRowSetHoursUsage:
        {
            NSCharacterSet *wholeNumberSet = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *textFieldSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
            
            if ([wholeNumberSet isSupersetOfSet:textFieldSet])
            {
                NSNumber *aValue = [NSNumber numberWithInt:textField.text.intValue];
                [[KSTNanoSDK manager] KSTNanoSDKSetDiagnosticHoursOfUse:aValue];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:nil
                                                      message:@"Valid numbers are between 0 and 65536."
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
            
        case kDiagnosticRowSetBattCycles:
        {
            NSCharacterSet *wholeNumberSet = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *textFieldSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
            
            if ([wholeNumberSet isSupersetOfSet:textFieldSet])
            {
                NSNumber *aValue = [NSNumber numberWithInt:textField.text.intValue];
                [[KSTNanoSDK manager] KSTNanoSDKSetDiagnosticBattCycles:aValue];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:nil
                                                      message:@"Valid numbers are between 0 and 65536."
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
            
        case kDiagnosticRowSetLampHours:
        {
            NSCharacterSet *wholeNumberSet = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *textFieldSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
            
            if ([wholeNumberSet isSupersetOfSet:textFieldSet])
            {
                NSNumber *aValue = [NSNumber numberWithInt:textField.text.intValue];
                [[KSTNanoSDK manager] KSTNanoSDKSetDiagnosticLampHours:aValue];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:nil
                                                      message:@"Valid numbers are between 0 and 65536."
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

@end
