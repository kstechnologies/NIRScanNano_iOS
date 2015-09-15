//
//  SettingsViewController.m
//  NanoScan
//
//  Created by bob on 2/23/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import "SettingsViewController.h"
#import "KSTNanoSDK.h"

typedef enum
{
    kSettingsRowTemperatureUnits = 0,
    kSettingsRowSpatialFrequencyUnits,
    kSettingsRowNanoStartSearch,
    kSettingsRowClearNano
} kSettingsRow;

// Keys for NSUserDefaults
NSString *const kNanoSettingsDeviceName             = @"kNanoSettingsDeviceName";
NSString *const kNanoSettingsDeviceIdentifier       = @"kNanoSettingsDeviceIdentifier";
NSString *const kNanoSettingsTemperaturePreference  = @"kNanoSettingsTemperaturePreference";    // 0 - Celsius, 1 - Fahrenheit
NSString *const kNanoSettingsSpatialPreference      = @"kNanoSettingsSpatialPreference";        // 0 - Wavelength, 1 - Wavenumber

@interface SettingsViewController ()
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Settings";
    
    // Show the app version for diagnostics
    NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *bundleString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *prettyVersionString = [NSString stringWithFormat:@"v%@ (%@)", versionString, bundleString];
    _versionLabel.text = prettyVersionString;
    
    // Remove blank cells at the bottom of the table view
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    _settingsTableView.tableFooterView = footer;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // If defaults aren't picked for Temperature and Spatial Preferences, pick them for the user and set.
    if( !_userDefaults )
        _userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *temperatureDefault = [_userDefaults objectForKey:kNanoSettingsTemperaturePreference];
    if( !temperatureDefault )
    {
        [self changeTemperaturePreferenceTo:kTemperaturePreferenceCelsius];
    }

    float segmentYLocation = 44.0 - 44.0/2.0 - 44.0/4.0;
    
    _temperatureSegmentControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width-90.0, segmentYLocation, 80.0, 44.0/2.0)];
    
    [_temperatureSegmentControl addTarget:self action:@selector(changeTemperatureUnits:) forControlEvents:UIControlEventValueChanged];
    
    _temperatureSegmentControl.tag = kSettingsRowTemperatureUnits;
    
    [_temperatureSegmentControl insertSegmentWithTitle:@"\u00b0C" atIndex:0 animated:NO];
    [_temperatureSegmentControl insertSegmentWithTitle:@"\u00b0F" atIndex:1 animated:NO];
    
    [_temperatureSegmentControl setSelectedSegmentIndex:temperatureDefault.intValue];
    
    NSNumber *spatialDefault = [_userDefaults objectForKey:kNanoSettingsSpatialPreference];
    if( !spatialDefault )
    {
        [self changeSpatialPreferenceTo:kSpatialPreferenceWavelength];
    }
    
    _spatialSegmentControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_spatialSegmentControl addTarget:self action:@selector(changeSpatialUnits:) forControlEvents:UIControlEventValueChanged];
    
    _spatialSegmentControl.tag = kSettingsRowSpatialFrequencyUnits;
    
    [_spatialSegmentControl insertSegmentWithTitle:@"Wavelength" atIndex:0 animated:NO];
    [_spatialSegmentControl insertSegmentWithTitle:@"Wavenumber" atIndex:1 animated:NO];
    
    [_spatialSegmentControl setFrame:CGRectMake(self.view.frame.size.width-200.0, segmentYLocation, 190.0, 44.0/1.6)];
    
    spatialDefault = [_userDefaults objectForKey:kNanoSettingsSpatialPreference];
    [_spatialSegmentControl setSelectedSegmentIndex:spatialDefault.intValue];
    
    //[_settingsTableView reloadData];

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
    return kSettingsRowClearNano+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    float segmentYLocation = cell.frame.size.height - cell.frame.size.height/1.6 - cell.frame.size.height/4.0;
    
    switch (indexPath.row)
    {
        case kSettingsRowTemperatureUnits:
        {
            cell.textLabel.text = @"Temperature";
            cell.detailTextLabel.text = @"";
            [cell.contentView addSubview:_temperatureSegmentControl];
            
        } break;
            
        case kSettingsRowSpatialFrequencyUnits:
        {
            cell.textLabel.text = @"Spatial Freq";
            cell.detailTextLabel.text = @"";
            [cell.contentView addSubview:_spatialSegmentControl];
           
        } break;
            
        case kSettingsRowNanoStartSearch:
        {
            cell.textLabel.text = @"Set My Nano";
            cell.detailTextLabel.text = @"";
            
            UIButton *findButton = [UIButton buttonWithType:UIButtonTypeSystem];
            findButton.frame = CGRectMake(self.view.frame.size.width-120.0, segmentYLocation, 110.0, cell.frame.size.height/2.0);
            [findButton setTitle:@"Go!" forState:UIControlStateNormal];
            findButton.titleLabel.textAlignment = NSTextAlignmentRight;
            [findButton addTarget:self action:@selector(goFindNano:) forControlEvents:UIControlEventTouchUpInside];
            findButton.tag = kSettingsRowNanoStartSearch;
            
            [cell addSubview:findButton];
            
        } break;
            
        case kSettingsRowClearNano:
        {
            cell.textLabel.text = @"Clear My Nano";
            cell.detailTextLabel.text = @"";
            
            UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
            clearButton.frame = CGRectMake(self.view.frame.size.width-120.0, segmentYLocation, 110.0, cell.frame.size.height/2.0);
            [clearButton setTitle:@"Forget" forState:UIControlStateNormal];
            clearButton.titleLabel.textAlignment = NSTextAlignmentRight;
            [clearButton addTarget:self action:@selector(forgetNano:) forControlEvents:UIControlEventTouchUpInside];
            clearButton.tag = kSettingsRowClearNano;
            
            [cell addSubview:clearButton];
            
        } break;
            
        default:
            break;
    }
    
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)changeSpatialUnits:(UISegmentedControl *)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 0:
            [self changeSpatialPreferenceTo:kSpatialPreferenceWavelength];
            break;
            
        case 1:
            [self changeSpatialPreferenceTo:kSpatialPreferenceWavenumber];
            break;
            
        default:
            break;
    }
}

-(void)changeTemperatureUnits:(UISegmentedControl *)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 0:
            [self changeTemperaturePreferenceTo:kTemperaturePreferenceCelsius];
            break;
            
        case 1:
            [self changeTemperaturePreferenceTo:kTemperaturePreferenceFahr];
            break;
            
        default:
            break;
    }
}

-(void)goFindNano:(UIButton *)button
{
    NSLog(@"DIAG: go find Nano's");
    [self performSegueWithIdentifier:@"showScanner" sender:self];

}

-(void)forgetNano:(UIButton *)button
{
    NSLog(@"DIAG: forget Nano's");
    
    // store the uuid
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNanoSettingsDeviceIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)changeTemperaturePreferenceTo:(kTemperaturePreference)temperaturePref
{
    [_userDefaults setObject:[NSNumber numberWithInt:(int)temperaturePref] forKey:kNanoSettingsTemperaturePreference];
    [_userDefaults synchronize];
}

-(void)changeSpatialPreferenceTo:(kSpatialPreference)spatialPref
{
    [_userDefaults setObject:[NSNumber numberWithInt:(int)spatialPref] forKey:kNanoSettingsSpatialPreference];
    [_userDefaults synchronize];
}

#pragma mark - UITextField Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textAlignment = NSTextAlignmentRight;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [_userDefaults setObject:textField.text forKey:kNanoSettingsDeviceName];
    [_userDefaults synchronize];
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
