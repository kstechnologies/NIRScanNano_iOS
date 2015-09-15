//
//  ScanViewController.h
//  NanoScan
//
//  Created by bob on 12/13/14.
//  Copyright (c) 2014 KS Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KSTNanoSDK.h"
#import "KSTDataManager.h"

#import <Charts/Charts.h>
@import Charts;

@interface ScanViewController : UIViewController <UITextFieldDelegate, ChartViewDelegate>

@property( weak, nonatomic ) IBOutlet UITableView *scanTableView;
@property( weak, nonatomic ) IBOutlet UIButton *startButton;

@property( weak, nonatomic ) IBOutlet UIActivityIndicatorView *activityIndicator;
@property( weak, nonatomic ) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *scanSegmentControl;

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) UISwitch *switchView;
@property (strong, nonatomic) UISwitch *continuousScanSwitchView;
@property (strong, nonatomic) UISwitch *iOSSwitchView;
@property (strong, nonatomic) UITextField *textField;

@property (nonatomic, strong) IBOutlet LineChartView *chartView;

@property( strong, nonatomic ) KSTNanoSDK *nano;
@property( strong, nonatomic ) KSTDataManager *dataManager;

@property( nonatomic, strong ) NSTimer *connectingWatchdogTimer;

@end
