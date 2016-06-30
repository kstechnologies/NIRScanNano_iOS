//
//  ScanViewController.m
//  NanoScan
//
//  Created by bob on 12/13/14.
//  Copyright (c) 2014 KS Technologies. All rights reserved.
//

#import "ScanViewController.h"
#import "ScanViewTableViewCell.h"
#import "SettingsViewController.h"

#import "KSTDataManager.h"

typedef enum
{
    kDetailRowFilename = 0,
    kDetailRowSDCardSave,
    kDetailRowiOSSave,
    kDetailRowContinuousScan,
    kDetailRowMethod,
    kDetailRowTimestamp,
    //kDetailRowSpectralRangeStart,
    //kDetailRowSpectrialRangeEnd,
    //kDetailRowNumberOfWavelengthPoints,
    //kDetailRowDigitalResolution,
    kDetailRowNumberOfScansToAverage,
    kDetailRowTotalMeasurementTime
} kDetailRow;

@interface ScanViewController ()
@property NSMutableDictionary *localScanDictionary;
@end

LineChartData *_reflectanceData;
LineChartData *_absorbanceData;
LineChartData *_intensityData;

bool shouldKickout;
bool shouldSaveToSDCard;

NSMutableDictionary *_localScanDictionary;

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"New Scan";
    
    UIBarButtonItem *configureButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"Configure"
                                        style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(showConfigureView:)];
    self.navigationItem.rightBarButtonItem = configureButton;
    
    //Remove blank cells at the bottom of the table view
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    _scanTableView.tableFooterView = footer;
    
    _nano = [KSTNanoSDK manager];
    [_nano KSTNanoSDKConnect];
    
    _dataManager = [KSTDataManager manager];
    
    _progressView.hidden = YES;
    _statusLabel.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exceededTemperature) name:kKSTNanoSDKTemperatureThresholdExceeded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exceededHumidity) name:kKSTNanoSDKHumidityThresholdExceeded object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isConnecting:) name:kKSTNanoSDKBusy object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnect:) name:kKSTNanoSDKReady object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishScan:) name:kKSTNanoSDKScanCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateRefCalPercentComplete:) name:kKSTNanoSDKDownloadingRefCalCoefficients object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateRefCalMatrixPercentComplete:) name:kKSTNanoSDKDownloadingRefMatrixCoefficients object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateDataPercentComplete:) name:kKSTNanoSDKDownloadingData object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnect) name:kKSTNanoSDKDisconnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceDisconnect) name:kKSTNanoSDKIncompatibleFirmware object:nil];

    _switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_switchView setOn:NO animated:NO];
    [_switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    shouldSaveToSDCard = NO;
    
    _continuousScanSwitchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_continuousScanSwitchView setOn:NO animated:NO];
    [_continuousScanSwitchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    _iOSSwitchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_iOSSwitchView setOn:YES animated:NO];
    [_iOSSwitchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100.0, 44.0/4.0, 80.0, 44.0/2.0)];
    _textField.delegate = self;
    _textField.tag = kDetailRowFilename;
    _textField.placeholder = @"Data";
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.keyboardType = UIKeyboardTypeAlphabet;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.textAlignment = NSTextAlignmentRight;
    
    _localScanDictionary = [NSMutableDictionary dictionary];
    
    /* NEW CHART */
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"Tap the Start Scan button below to scan and display data.";
    _chartView.noDataText = @"";
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.xAxis.labelPosition = XAxisLabelPositionBottom;
    _chartView.xAxis.spaceBetweenLabels = 5;
    _chartView.maxVisibleValueCount = 25;
    
    // x-axis limit line
    ChartLimitLine *llXAxis = [[ChartLimitLine alloc] initWithLimit:0.0 label:@"0.0"];
    llXAxis.lineWidth = 2.0;
    llXAxis.lineColor = [UIColor redColor];
    llXAxis.lineDashLengths = @[@(5.f), @(5.f)];
    llXAxis.labelPosition = ChartLimitLabelPositionRightTop;
    llXAxis.valueFont = [UIFont systemFontOfSize:10.f];
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis addLimitLine:llXAxis];
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.gridLineDashLengths = @[@5.f, @2.5f];
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    
    _chartView.rightAxis.enabled = NO;
    
    _chartView.legend.form = ChartLegendFormLine;
    _chartView.legend.enabled = NO;
    
    _chartView.autoScaleMinMaxEnabled = YES;
    [_chartView animateWithXAxisDuration:2.5 easingOption:ChartEasingOptionEaseInOutQuart];
    
    _chartView.data = _reflectanceData;
}

-(void)setupAbsorbance
{
    NSDictionary *scanDictionary = [[[KSTDataManager manager] dataArray] lastObject];
    
    NSMutableArray *lineChartDataArrayX = [NSMutableArray array];
    NSMutableArray *lineChartDataArrayY = [NSMutableArray array];
    
    int index = 0;
    int maxIndex = (int)[scanDictionary[kKSTDataManagerWavelength] count];
    
    while( index < maxIndex )
    {
        NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
        NSNumber *aWavelengthOrNumber;
        NSNumber *aReflectance;
        
        if( spatialPref.intValue == kSpatialPreferenceWavenumber )
        {
            aWavelengthOrNumber = (NSNumber *)[scanDictionary[kKSTDataManagerWavenumber] objectAtIndex:index];
            aReflectance = [scanDictionary[kKSTDataManagerReverseAbsorbance] objectAtIndex:index];
        }
        else
        {
            aWavelengthOrNumber = (NSNumber *)[scanDictionary[kKSTDataManagerWavelength] objectAtIndex:index];
            aReflectance = [scanDictionary[kKSTDataManagerAbsorbance] objectAtIndex:index];
        }
        
        [lineChartDataArrayY addObject:[[ChartDataEntry alloc] initWithValue:aReflectance.doubleValue xIndex:index]];
        [lineChartDataArrayX addObject:[NSString stringWithFormat:@"%2.0f", aWavelengthOrNumber.floatValue]];
        index++;
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:lineChartDataArrayY label:@"Absorbance"];
    
    set1.drawValuesEnabled = YES;
    set1.drawFilledEnabled = YES;
    set1.drawCircleHoleEnabled = YES;
    
    set1.lineDashLengths = @[@5.f, @2.5f];
    [set1 setColor:UIColor.blackColor];
    [set1 setCircleColor:UIColor.greenColor];
    set1.lineWidth = 1.0;
    set1.circleRadius = 2.0;
    set1.drawCircleHoleEnabled = YES;
    set1.valueFont = [UIFont systemFontOfSize:9.f];
    set1.fillAlpha = 65/255.0;
    set1.fillColor = UIColor.greenColor;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    _absorbanceData = [[LineChartData alloc] initWithXVals:lineChartDataArrayX dataSets:dataSets];
}

-(void)setupIntensity
{
    NSDictionary *scanDictionary = [[[KSTDataManager manager] dataArray] lastObject];

    NSMutableArray *lineChartDataArrayX = [NSMutableArray array];
    NSMutableArray *lineChartDataArrayY = [NSMutableArray array];
    
    int index = 0;
    int maxIndex = (int)[scanDictionary[kKSTDataManagerWavelength] count];
    while( index < maxIndex )
    {
        NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
        NSNumber *aWavelengthOrNumber;
        NSNumber *aReflectance;
        
        if( spatialPref.intValue == kSpatialPreferenceWavenumber )
        {
            aWavelengthOrNumber = (NSNumber *)[scanDictionary[kKSTDataManagerWavenumber] objectAtIndex:index];
            aReflectance = [scanDictionary[kKSTDataManagerReverseIntensity] objectAtIndex:index];
        }
        else
        {
            aWavelengthOrNumber = (NSNumber *)[scanDictionary[kKSTDataManagerWavelength] objectAtIndex:index];
            aReflectance = [scanDictionary[kKSTDataManagerIntensity] objectAtIndex:index];
        }
        
        [lineChartDataArrayY addObject:[[ChartDataEntry alloc] initWithValue:aReflectance.doubleValue xIndex:index]];
        [lineChartDataArrayX addObject:[NSString stringWithFormat:@"%2.0f", aWavelengthOrNumber.floatValue]];
        index++;
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:lineChartDataArrayY label:@"Intensity"];
    
    set1.drawValuesEnabled = YES;
    set1.drawFilledEnabled = YES;
    set1.drawCircleHoleEnabled = YES;
    
    set1.lineDashLengths = @[@5.f, @2.5f];
    [set1 setColor:UIColor.blackColor];
    [set1 setCircleColor:UIColor.blueColor];
    set1.lineWidth = 1.0;
    set1.circleRadius = 2.0;
    set1.drawCircleHoleEnabled = YES;
    set1.valueFont = [UIFont systemFontOfSize:9.f];
    set1.fillAlpha = 65/255.0;
    set1.fillColor = UIColor.blueColor;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    _intensityData = [[LineChartData alloc] initWithXVals:lineChartDataArrayX dataSets:dataSets];
}

-(void)setupReflectance
{
    NSDictionary *activeConfiguration = _dataManager.scanConfigArray[_dataManager.activeScanConfiguration.intValue];
    NSArray *arrayOfSlewScans = activeConfiguration[kKSTDataManagerScanConfig_SectionsArray];
    for( NSDictionary *aSlewScanDict in arrayOfSlewScans )
    {
        NSNumber *start = aSlewScanDict[kKSTDataManagerScanConfig_WavelengthStart];
        NSNumber *stop = aSlewScanDict[kKSTDataManagerScanConfig_WavelengthEnd];
        NSLog(@"range: %@ to %@", start, stop);
    }
    
    NSDictionary *scanDictionary = [[[KSTDataManager manager] dataArray] lastObject];

    NSMutableArray *lineChartDataArrayX = [NSMutableArray array];
    NSMutableArray *lineChartDataArrayY_0 = [NSMutableArray array];
    NSMutableArray *lineChartDataArrayY_1 = [NSMutableArray array];

    int index = 0;
    int maxIndex = (int)[scanDictionary[kKSTDataManagerWavelength] count];
    while( index < maxIndex )
    {
        NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
        NSNumber *aWavelengthOrNumber;
        NSNumber *aReflectance;
        
        if( spatialPref.intValue == kSpatialPreferenceWavenumber )
        {
            aWavelengthOrNumber = (NSNumber *)[scanDictionary[kKSTDataManagerWavenumber] objectAtIndex:index];
            aReflectance = [scanDictionary[kKSTDataManagerReverseReflectance] objectAtIndex:index];
        }
        else
        {
            aWavelengthOrNumber = (NSNumber *)[scanDictionary[kKSTDataManagerWavelength] objectAtIndex:index];
            aReflectance = [scanDictionary[kKSTDataManagerReflectance] objectAtIndex:index];
        }
        
#pragma mark TODO Look at the boundaries of the slew scan and adjust colors on the plot
        //if( aWavelengthOrNumber.intValue < 1100 )
            [lineChartDataArrayY_0 addObject:[[ChartDataEntry alloc] initWithValue:aReflectance.doubleValue xIndex:index]];
        //else
        //    [lineChartDataArrayY_1 addObject:[[ChartDataEntry alloc] initWithValue:aReflectance.doubleValue xIndex:index]];

        [lineChartDataArrayX addObject:[NSString stringWithFormat:@"%2.0f", aWavelengthOrNumber.floatValue]];
        index++;
    }
    
    LineChartDataSet *set0 = [[LineChartDataSet alloc] initWithYVals:lineChartDataArrayY_0 label:@"Reflectance"];
    
    set0.drawValuesEnabled = YES;
    set0.drawFilledEnabled = YES;
    set0.drawCircleHoleEnabled = YES;
    
    set0.lineDashLengths = @[@5.f, @2.5f];
    [set0 setColor:UIColor.blackColor];
    [set0 setCircleColor:UIColor.redColor];
    set0.lineWidth = 1.0;
    set0.circleRadius = 2.0;
    set0.drawCircleHoleEnabled = YES;
    set0.valueFont = [UIFont systemFontOfSize:9.f];
    set0.fillAlpha = 65/255.0;
    set0.fillColor = UIColor.redColor;
    
    /*
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:lineChartDataArrayY_1 label:@"Reflectance"];
    
    set1.drawValuesEnabled = YES;
    set1.drawFilledEnabled = YES;
    set1.drawCircleHoleEnabled = YES;
    
    set1.lineDashLengths = @[@5.f, @2.5f];
    [set1 setColor:UIColor.blackColor];
    [set1 setCircleColor:UIColor.greenColor];
    set1.lineWidth = 1.0;
    set1.circleRadius = 2.0;
    set1.drawCircleHoleEnabled = YES;
    set1.valueFont = [UIFont systemFontOfSize:9.f];
    set1.fillAlpha = 65/255.0;
    set1.fillColor = UIColor.greenColor;
    */
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set0];
    //[dataSets addObject:set1];
    
    _reflectanceData = [[LineChartData alloc] initWithXVals:lineChartDataArrayX dataSets:dataSets];
}

#pragma mark - ChartViewDelegate
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

-(void)allowViewToPersist
{
    if( self.connectingWatchdogTimer)
    {
        [self.connectingWatchdogTimer invalidate];
        self.connectingWatchdogTimer = nil;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [_activityIndicator setHidesWhenStopped:YES];
    [_activityIndicator stopAnimating];
    
    _statusLabel.hidden = YES;
    _progressView.hidden = YES;
    
    if( !_nano.isConnected.boolValue )
    {
        NSLog(@"DIAGNOSTIC looking for connection ...");
        self.connectingWatchdogTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                        target:self
                                                                      selector:@selector(didDisconnect)
                                                                      userInfo:nil
                                                                       repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.connectingWatchdogTimer forMode:NSRunLoopCommonModes];
    }
    
    [self.scanTableView reloadData];
}

-(void)didDisconnect
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Not Connected"
                                          message:@"Ensure Bluetooth is powered on your iOS Device and your Nano, then tap the Scan button on the main view."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self.navigationController popToRootViewControllerAnimated:YES];
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)forceDisconnect
{
    /*
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Firmware Out of Date"
                                          message:@"You must update the firmware on your NIRScan Nano before continuing."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self.navigationController popToRootViewControllerAnimated:YES];
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    */
}

-(void)didUpdateDataPercentComplete:(NSNotification *)aNotification
{
    _statusLabel.hidden = NO;
    _progressView.hidden = NO;
    [_activityIndicator stopAnimating];
    NSDictionary *percentCompleteDict = [aNotification userInfo];
    NSNumber *percentComplete = percentCompleteDict[@"percentage"];
    
    _progressView.progress = percentComplete.floatValue/100.0;
    _statusLabel.text = @"Receiving Data";
    
}

-(void)didUpdateRefCalPercentComplete:(NSNotification *)aNotification
{
    _statusLabel.hidden = NO;
    _progressView.hidden = NO;
    [_activityIndicator stopAnimating];
    NSDictionary *percentCompleteDict = [aNotification userInfo];
    NSNumber *percentComplete = percentCompleteDict[@"percentage"];
    
    _progressView.progress = percentComplete.floatValue/100.0;
    _statusLabel.text = @"Downloading Ref Cal";
    
}

-(void)didUpdateRefCalMatrixPercentComplete:(NSNotification *)aNotification
{
    _statusLabel.hidden = NO;
    _progressView.hidden = NO;
    [_activityIndicator stopAnimating];
    NSDictionary *percentCompleteDict = [aNotification userInfo];
    NSNumber *percentComplete = percentCompleteDict[@"percentage"];
    
    _progressView.progress = percentComplete.floatValue/100.0;
    _statusLabel.text = @"Downloading Cal Matrix";
    
}

-(void)isConnecting:(NSNotificationCenter *)aNotification
{
    [_chartView setHidden:YES];
    
    [_activityIndicator startAnimating];
    
    [self allowViewToPersist];
    
    _statusLabel.hidden = NO;
    _progressView.hidden = YES;
    [_activityIndicator startAnimating];
    _statusLabel.text = @"Downloading Data";
    
    self.view.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    _startButton.enabled = NO;
}

-(void)didConnect:(NSNotificationCenter *)aNotification
{
    [_chartView setHidden:NO];
    
    NSLog(@"NIRScan Nano is connected via BLE");
    
    [self allowViewToPersist];
    
    if( _activityIndicator )
        [_activityIndicator stopAnimating];
    
    [_nano KSTNanoSDKSetStubName:@"Data"];          // Nothing special about this default
    
    self.view.userInteractionEnabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _startButton.enabled = YES;
    _statusLabel.hidden = YES;
    _progressView.hidden = YES;
    
    [self.scanTableView reloadData];
}

-(void)didFinishScan:(NSNotificationCenter *)aNotification
{
    NSLog(@"NIRScan Nano scan operation is complete.");
    [_activityIndicator stopAnimating];
    
    _progressView.hidden = YES;
    _statusLabel.hidden = YES;
    
    // grab the data from the singleton, shove onto the plot
    NSDictionary *scanDictionary = [[[KSTDataManager manager] dataArray] lastObject];
    
    if( scanDictionary )
    {
        [self setupReflectance];
        [self setupAbsorbance];
        [self setupIntensity];
        
        if( _scanSegmentControl.selectedSegmentIndex == 0 )
        {
            _chartView.data = _reflectanceData;
        }
        else if( _scanSegmentControl.selectedSegmentIndex == 1)
        {
            _chartView.data = _absorbanceData;
        }
        else if( _scanSegmentControl.selectedSegmentIndex == 2)
        {
            _chartView.data = _intensityData;
        }
    }
    
    [_chartView setHidden:NO];
    [_startButton setTitle:@"Start Scan" forState:UIControlStateNormal];
    
    // Now that we have scan data, populate it
    [self.scanTableView reloadData];
    
    self.view.userInteractionEnabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _startButton.enabled = YES;
    
    if( _continuousScanSwitchView.isOn )
    {
        NSLog(@"Scanning Again ...");
        [self didPressScan:nil];
    }
}

-(IBAction)didChangeSegment:(UISegmentedControl *)segmentControl
{
    if( _scanSegmentControl.selectedSegmentIndex == 0 )
    {
        _chartView.data = _reflectanceData;
    }
    else if( _scanSegmentControl.selectedSegmentIndex == 1)
    {
        _chartView.data = _absorbanceData;
    }
    else if( _scanSegmentControl.selectedSegmentIndex == 2)
    {
        _chartView.data = _intensityData;
    }
}

-(void)showConfigureView:(id)sender
{
    [self performSegueWithIdentifier:@"showConfigureView" sender:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)exceededTemperature
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Warning!"
                                          message:@"Your device has exceeded set temperature thresholds."
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

-(void)exceededHumidity
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Warning!"
                                          message:@"Your device has exceeded set humidity thresholds."
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

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kDetailRowTotalMeasurementTime+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryView = nil;
    
    switch (indexPath.row)
    {
        case kDetailRowFilename:
        {
            cell.textLabel.text = @"Filename Prefix";
            cell.detailTextLabel.text = @"";
            
            cell.accessoryView = _textField;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        } break;
            
        case kDetailRowSDCardSave:
        {
            cell.textLabel.text = @"Save To SD Card?";
            cell.detailTextLabel.text = @"";
            
            cell.accessoryView = _switchView;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        } break;
            
        case kDetailRowContinuousScan:
        {
            cell.textLabel.text = @"Continous Scan?";
            cell.detailTextLabel.text = @"";
            
            cell.accessoryView = _continuousScanSwitchView;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        } break;
            
        case kDetailRowiOSSave:
        {
            cell.textLabel.text = @"Save to iOS Device?";
            cell.detailTextLabel.text = @"";
            
            cell.accessoryView = _iOSSwitchView;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        } break;
            
        case kDetailRowMethod:
        {
            cell.textLabel.text = @"Scan Configuration";
            cell.detailTextLabel.text = @"";
            
            if( _dataManager.activeScanConfiguration )
            {
               cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }

        } break;
            
        case kDetailRowTimestamp:
        {
            cell.textLabel.text = @"Timestamp";
          
            NSDictionary *scanDictionary = [[[KSTDataManager manager] dataArray] lastObject];
            
            if( scanDictionary[kKSTDataManagerKeyTimestamp] )
                cell.detailTextLabel.text = scanDictionary[kKSTDataManagerKeyTimestamp];
            else
                cell.detailTextLabel.text = @"--";
            
        } break;
            
            /*
        case kDetailRowSpectralRangeStart:
        {
            cell.textLabel.text = @"Spectral Range Start";
            
            NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
            
            if( _dataManager.activeScanConfiguration.intValue >= 0 && (int)_dataManager.scanConfigArray.count > 0 )
            {
                NSDictionary *activeConfiguration = _dataManager.scanConfigArray[_dataManager.activeScanConfiguration.intValue];
                
                float testX = [activeConfiguration[kKSTDataManagerScanConfig_WavelengthStart] floatValue];
                
                if( spatialPref.intValue == kSpatialPreferenceWavenumber )
                {
                    testX = 10000000.0 / testX; // converts to cm-1
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%2.1f cm-1", testX];
                }
                else
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%2.1f nm", testX];
                }
            }
            else
            {
                cell.detailTextLabel.text = @"--";
            }
        } break;
             */
            /*
        case kDetailRowSpectrialRangeEnd:
        {
            cell.textLabel.text = @"Spectral Range End";
            
            NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
            
            if( _dataManager.activeScanConfiguration.intValue >= 0 && (int)_dataManager.scanConfigArray.count > 0 )
            {
                NSDictionary *activeConfiguration = _dataManager.scanConfigArray[_dataManager.activeScanConfiguration.intValue];
                
                float testX = [activeConfiguration[kKSTDataManagerScanConfig_WavelengthEnd] floatValue];
                
                if( spatialPref.intValue == kSpatialPreferenceWavenumber )
                {
                    testX = 10000000.0 / testX; // converts to cm-1
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%2.1f cm-1", testX];
                }
                else
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%2.1f nm", testX];
                }
            }
            else
            {
                cell.detailTextLabel.text = @"--";
            }
        } break;
            */
            /*
        case kDetailRowNumberOfWavelengthPoints:
        {
            cell.textLabel.text = @"Number of Wavelength Points";

            if( _dataManager.activeScanConfiguration.intValue >= 0 && (int)_dataManager.scanConfigArray.count > 0 )
            {
                NSDictionary *activeConfiguration = _dataManager.scanConfigArray[_dataManager.activeScanConfiguration.intValue];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", activeConfiguration[kKSTDataManagerScanConfig_NumPatterns]];
            }
            else
                cell.detailTextLabel.text = @"--";
            
        } break;
            */
            /*
        case kDetailRowDigitalResolution:
        {
            cell.textLabel.text = @"Digital Resolution";

            if( _dataManager.activeScanConfiguration.intValue >= 0 && (int)_dataManager.scanConfigArray.count > 0 )
            {
                cell.detailTextLabel.hidden = NO;
                cell.accessoryView.hidden = NO;
                
                NSDictionary *activeConfiguration = _dataManager.scanConfigArray[_dataManager.activeScanConfiguration.intValue];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ nm", activeConfiguration[kKSTDataManagerScanConfig_Width] ];
            }
            else
                cell.detailTextLabel.text = @"--";

        } break;
            */

        case kDetailRowNumberOfScansToAverage:
        {
            cell.textLabel.text = @"Number of Scans to Average";

            if( _dataManager.activeScanConfiguration.intValue >= 0 && (int)_dataManager.scanConfigArray.count > 0 )
            {
                NSDictionary *activeConfiguration = _dataManager.scanConfigArray[_dataManager.activeScanConfiguration.intValue];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", activeConfiguration[kKSTDataManagerScanConfig_NumRepeats]];
            }
            else
                cell.detailTextLabel.text = @"--";
            
        } break;
            
        case kDetailRowTotalMeasurementTime:
        {
            cell.textLabel.text = @"Total Measurement Time";
            NSDictionary *scanDictionary = [[[KSTDataManager manager] dataArray] lastObject];

            if( scanDictionary[kKSTDataManagerTotalMeasurementTime] )
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%2.2f sec", [scanDictionary[kKSTDataManagerTotalMeasurementTime] floatValue] ];
            else
                cell.detailTextLabel.text = @"--";
        } break;
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    cell.detailTextLabel.hidden = NO;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == kDetailRowMethod )
    {
        [self performSegueWithIdentifier:@"showScanConfiguration" sender:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)switchChanged:(UISwitch *)aSwitch
{
    if( aSwitch == _switchView )
    {
        NSLog( @"SD Card Save is %@", aSwitch.on ? @"ON" : @"OFF" );
        shouldSaveToSDCard = aSwitch.on;
    }
    // take no action if in continous scan mode; just analyze the state of the switch upon completion
}

-(IBAction)didPressScan:(id)sender
{
    
    if( _iOSSwitchView.isOn )
    {
        _nano.KSTNanoSDKshouldSaveToiOSDevice = [NSNumber numberWithBool:YES];
        NSLog(@"Save to iOS");
    }
    else
    {
        _nano.KSTNanoSDKshouldSaveToiOSDevice = [NSNumber numberWithBool:NO];
        NSLog(@"Do not save to iOS");
    }
    
    [_chartView setHidden:YES];
    
    [_startButton setTitle:@"Scanning ..." forState:UIControlStateNormal];
    
    [_activityIndicator startAnimating];
    
    [_nano KSTNanoSDKStartScanWithSDCardSave:shouldSaveToSDCard];
    
    self.view.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    _startButton.enabled = NO;
    
    if( _continuousScanSwitchView.isOn )
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Continuous Scan Mode"
                                              message:@"Your NIRScan Nano will repeatedly scan until you tap the Stop button."
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"Stop"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [_continuousScanSwitchView setOn:NO animated:YES];
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
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
    /*
     CGPoint origin = textField.frame.origin;
     CGPoint point = [textField.superview convertPoint:origin toView:_scanTableView];
     CGPoint offset = _scanTableView.contentOffset;
     offset.y += point.y - 100.0;
     [_scanTableView setContentOffset:offset animated:YES];
     */
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case kDetailRowFilename:
        {
            if (textField.text.length < 13)
            {
                [[KSTNanoSDK manager] KSTNanoSDKSetStubName:textField.text];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:nil
                                                      message:@"Your filename stub must be 12 characters or less."
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
