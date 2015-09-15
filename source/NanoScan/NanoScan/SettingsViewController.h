//
//  SettingsViewController.h
//  NanoScan
//
//  Created by bob on 2/23/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate>

// Keys for NSUserDefaults
extern NSString *const kNanoSettingsDeviceName;
extern NSString *const kNanoSettingsDeviceIdentifier;
extern NSString *const kNanoSettingsTemperaturePreference;
extern NSString *const kNanoSettingsSpatialPreference;

typedef enum
{
    kTemperaturePreferenceCelsius = 0,
    kTemperaturePreferenceFahr
} kTemperaturePreference;

typedef enum
{
    kSpatialPreferenceWavelength = 0,
    kSpatialPreferenceWavenumber
} kSpatialPreference;

@property( nonatomic, strong ) IBOutlet UITableView *settingsTableView;
@property( nonatomic, strong ) UISegmentedControl *temperatureSegmentControl;
@property( nonatomic, strong ) UISegmentedControl *spatialSegmentControl;
@property( nonatomic, strong ) IBOutlet UILabel *versionLabel;

@property( nonatomic, strong ) NSUserDefaults *userDefaults;

-(void)changeTemperaturePreferenceTo:(kTemperaturePreference)temperaturePref;
-(void)changeSpatialPreferenceTo:(kSpatialPreference)spatialPref;

@end
