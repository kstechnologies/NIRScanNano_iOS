//
//  DetailViewController.m
//  NanoScan
//
//  Created by bob on 12/13/14.
//  Copyright (c) 2014 KS Technologies. All rights reserved.
//

#import "DetailViewController.h"
#import "KSTDataManager.h"
#import "SettingsViewController.h"

typedef enum
{
    kDetailRowMethod = 0,
    kDetailRowTimestamp,
    kDetailRowSpectralRangeStart,
    kDetailRowSpectrialRangeEnd,
    kDetailRowNumberOfWavelengthPoints,
    kDetailRowDigitalResolution,
    kDetailRowNumberOfScansToAverage,
    kDetailRowTotalMeasurementTime
} kDetailRow;

@interface DetailViewController ()
@end

LineChartData *_reflectanceData;
LineChartData *_absorbanceData;
LineChartData *_intensityData;

@implementation DetailViewController

float xMax;
float xMin;

float yMax;
float yMin;

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSDictionary *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        //[self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.title = _detailItem[kKSTDataManagerFilename];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    
    //Remove blank cells at the bottom of the table view
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    _scanInfoTableView.tableFooterView = footer;
    
    /* NEW CHART */
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"";
    _chartView.noDataText = @"";
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.xAxis.labelPosition = XAxisLabelPositionBottom;
   // _chartView.xAxis.spaceBetweenLabels = 5;
    _chartView.maxVisibleCount = 25;
    
    // x-axis limit line
    ChartLimitLine *llXAxis = [[ChartLimitLine alloc] initWithLimit:0.0 label:@"0.0"];
    llXAxis.lineWidth = 2.0;
    llXAxis.lineColor = [UIColor redColor];
    llXAxis.lineDashLengths = @[@(5.f), @(5.f)];
    llXAxis.labelPosition = ChartLimitLabelPositionRightTop;
    llXAxis.valueFont = [UIFont systemFontOfSize:10.f];
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis addLimitLine:llXAxis];
    //leftAxis.startAtZeroEnabled = NO;
    leftAxis.gridLineDashLengths = @[@5.f, @2.5f];
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    
    _chartView.rightAxis.enabled = NO;
    
    /*
    BalloonMarker *marker = [[BalloonMarker alloc] initWithColor:[UIColor colorWithWhite:180/255. alpha:1.0] font:[UIFont systemFontOfSize:12.0] insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
    marker.minimumSize = CGSizeMake(80.f, 40.f);
    _chartView.marker = marker;
    */
    
    _chartView.legend.form = ChartLegendFormLine;
    _chartView.legend.enabled = NO;
    
    _chartView.autoScaleMinMaxEnabled = YES;
    [_chartView animateWithXAxisDuration:2.5 easingOption:ChartEasingOptionEaseInOutQuart];
    
    [self setupReflectance];
    [self setupAbsorbance];
    [self setupIntensity];
    
    _chartView.data = _reflectanceData;
}

-(void)setupAbsorbance
{
    NSMutableArray *lineChartDataArrayX = [NSMutableArray array];
    NSMutableArray *lineChartDataArrayY = [NSMutableArray array];
    
    int index = 0;
    int maxIndex = (int)[_detailItem[kKSTDataManagerWavelength] count];
    while( index < maxIndex )
    {
        NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
        NSNumber *aWavelengthOrNumber;
        NSNumber *aReflectance;

        if( spatialPref.intValue == kSpatialPreferenceWavenumber )
        {
            aWavelengthOrNumber = (NSNumber *)[_detailItem[kKSTDataManagerWavenumber] objectAtIndex:index];
            aReflectance = [_detailItem[kKSTDataManagerReverseAbsorbance] objectAtIndex:index];
        }
        else
        {
            aWavelengthOrNumber = (NSNumber *)[_detailItem[kKSTDataManagerWavelength] objectAtIndex:index];
            aReflectance = [_detailItem[kKSTDataManagerAbsorbance] objectAtIndex:index];
        }
        
        [lineChartDataArrayY addObject:[[ChartDataEntry alloc] initWithX:index y:aReflectance.doubleValue]];
        [lineChartDataArrayX addObject:[NSString stringWithFormat:@"%2.0f", aWavelengthOrNumber.floatValue]];
        index++;
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithValues:lineChartDataArrayY label:@"Absorbance"];
    
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
    
    _absorbanceData = [[LineChartData alloc] initWithDataSet:set1];
}

-(void)setupIntensity
{
    NSMutableArray *lineChartDataArrayX = [NSMutableArray array];
    NSMutableArray *lineChartDataArrayY = [NSMutableArray array];
    
    int index = 0;
    int maxIndex = (int)[_detailItem[kKSTDataManagerWavelength] count];
    while( index < maxIndex )
    {
        NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
        NSNumber *aWavelengthOrNumber;
        NSNumber *aReflectance;
        
        if( spatialPref.intValue == kSpatialPreferenceWavenumber )
        {
            aWavelengthOrNumber = (NSNumber *)[_detailItem[kKSTDataManagerWavenumber] objectAtIndex:index];
            aReflectance = [_detailItem[kKSTDataManagerReverseIntensity] objectAtIndex:index];
        }
        else
        {
            aWavelengthOrNumber = (NSNumber *)[_detailItem[kKSTDataManagerWavelength] objectAtIndex:index];
            aReflectance = [_detailItem[kKSTDataManagerIntensity] objectAtIndex:index];
        }
        
        [lineChartDataArrayY addObject:[[ChartDataEntry alloc] initWithX:index y:aReflectance.doubleValue]];
        [lineChartDataArrayX addObject:[NSString stringWithFormat:@"%2.0f", aWavelengthOrNumber.floatValue]];
        index++;
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithValues:lineChartDataArrayY label:@"Intensity"];
    
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
    
    _intensityData = [[LineChartData alloc] initWithDataSet:set1];
}

-(void)setupReflectance
{
    NSMutableArray *lineChartDataArrayX = [NSMutableArray array];
    NSMutableArray *lineChartDataArrayY = [NSMutableArray array];
    
    int index = 0;
    int maxIndex = (int)[_detailItem[kKSTDataManagerWavelength] count];
    while( index < maxIndex )
    {
        NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
        NSNumber *aWavelengthOrNumber;
        NSNumber *aReflectance;
        
        if( spatialPref.intValue == kSpatialPreferenceWavenumber )
        {
            aWavelengthOrNumber = (NSNumber *)[_detailItem[kKSTDataManagerWavenumber] objectAtIndex:index];
            aReflectance = [_detailItem[kKSTDataManagerReverseReflectance] objectAtIndex:index];
        }
        else
        {
            aWavelengthOrNumber = (NSNumber *)[_detailItem[kKSTDataManagerWavelength] objectAtIndex:index];
            aReflectance = [_detailItem[kKSTDataManagerReflectance] objectAtIndex:index];
        }
        
        [lineChartDataArrayY addObject:[[ChartDataEntry alloc] initWithX:index y:aReflectance.doubleValue]];
        [lineChartDataArrayX addObject:[NSString stringWithFormat:@"%2.0f", aWavelengthOrNumber.floatValue]];
        index++;
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithValues:lineChartDataArrayY label:@"Reflectance"];
    
    set1.drawValuesEnabled = YES;
    set1.drawFilledEnabled = YES;
    set1.drawCircleHoleEnabled = YES;
    
    set1.lineDashLengths = @[@5.f, @2.5f];
    [set1 setColor:UIColor.blackColor];
    [set1 setCircleColor:UIColor.redColor];
    set1.lineWidth = 1.0;
    set1.circleRadius = 2.0;
    set1.drawCircleHoleEnabled = YES;
    set1.valueFont = [UIFont systemFontOfSize:9.f];
    set1.fillAlpha = 65/255.0;
    set1.fillColor = UIColor.redColor;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    _reflectanceData = [[LineChartData alloc] initWithDataSet:set1];
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
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

#pragma mark - Email Support
- (IBAction)openMail:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"NIRScan Nano Log - %@", _detailItem[kKSTDataManagerFilename]]];
        
        // Setup the file
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *documentDBFolderPath = [documentsDirectory stringByAppendingPathComponent:_detailItem[kKSTDataManagerFilename]];
        
        if(![fileManager fileExistsAtPath: documentDBFolderPath] )
        {
            NSLog(@"Creating a Log File (%@)", documentDBFolderPath);
            NSString *header;
            NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
            if( spatialPref.intValue == kSpatialPreferenceWavenumber )
            {
                header = @"Serial Number,Wavenumber,Intensity,Absorbance,Reflectance\r\n";
            }
            else
            {
                header = @"Serial Number, Wavelength,Intensity,Absorbance,Reflectance\r\n";
            }
            
            [header writeToFile:documentDBFolderPath atomically:YES encoding:NSASCIIStringEncoding error:NULL];
            NSLog(@"HEADER: %@", header);
            
            NSFileHandle *aFileHandle;
            NSString *aFile;
            
            // Iterate through the data arrays
            int index=0;
            while( index < [_detailItem[kKSTDataManagerWavelength] count])
            {
                NSString *fileMessage;
                aFile = documentDBFolderPath;
                aFileHandle = [NSFileHandle fileHandleForWritingAtPath:aFile]; //telling aFilehandle what file write to
                [aFileHandle truncateFileAtOffset:[aFileHandle seekToEndOfFile]]; //setting aFileHandle to write at the end of the file
                
                if( spatialPref.intValue == kSpatialPreferenceWavenumber )
                {
                    fileMessage = [NSString stringWithFormat:@"%@,%@,%@,%@,%@\r\n", _detailItem[kKSTDataManagerSerialNumber], _detailItem[kKSTDataManagerWavenumber][index], _detailItem[kKSTDataManagerReverseIntensity][index], _detailItem[kKSTDataManagerReverseAbsorbance][index], _detailItem[kKSTDataManagerReverseReflectance][index]];
                }
                else
                {
                    fileMessage = [NSString stringWithFormat:@"%@,%@,%@,%@,%@\r\n", _detailItem[kKSTDataManagerSerialNumber], _detailItem[kKSTDataManagerWavelength][index], _detailItem[kKSTDataManagerIntensity][index], _detailItem[kKSTDataManagerAbsorbance][index], _detailItem[kKSTDataManagerReflectance][index]];
                }

                [aFileHandle writeData:[fileMessage dataUsingEncoding:NSASCIIStringEncoding]]; //actually write the data
                index++;
            }
        }
        
        // Determine the MIME type
        NSString *mimeType = @"text/csv";
        
        // Get the resource path and read the file using NSData
        NSData *fileData = [NSData dataWithContentsOfFile:documentDBFolderPath];
        
        // Add attachment
        [mailer addAttachmentData:fileData mimeType:mimeType fileName:_detailItem[kKSTDataManagerFilename]];
        
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"NIRScan Nano"
                                              message:@"Your device does not support in-app email."
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
}

// Send the email and check for success
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Plot View Delegates
-(void)KSTPlotViewDidUpdate
{
    [_scanInfoTableView reloadData];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kDetailRowTotalMeasurementTime+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    switch (indexPath.row)
    {
        case kDetailRowMethod:
            cell.textLabel.text = @"Method";
            cell.detailTextLabel.text = _detailItem[kKSTDataManagerKeyMethod];
            break;
            
        case kDetailRowTimestamp:
            cell.textLabel.text = @"Timestamp";
            cell.detailTextLabel.text = _detailItem[kKSTDataManagerKeyTimestamp];
            break;
            
        case kDetailRowSpectralRangeStart:
        {
            NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
            float testX = [_detailItem[kKSTDataManagerSpectralRangeStart] floatValue];
            
            if( spatialPref.intValue == kSpatialPreferenceWavenumber )
            {
                testX = 10000000.0 / testX; // converts to cm-1
                cell.textLabel.text = @"Spectral Range Start (cm-1)";
            }
            else
            {
                cell.textLabel.text = @"Spectral Range Start (nm)";
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%2.1f", testX];
        } break;
            
        case kDetailRowSpectrialRangeEnd:
        {
            NSNumber *spatialPref = [[NSUserDefaults standardUserDefaults] objectForKey:kNanoSettingsSpatialPreference];
            float testX = [_detailItem[kKSTDataManagerSpectralRangeEnd] floatValue];
            
            if( spatialPref.intValue == kSpatialPreferenceWavenumber )
            {
                testX = 10000000.0 / testX; // converts to cm-1
                cell.textLabel.text = @"Spectral Range End (cm-1)";
            }
            else
            {
                cell.textLabel.text = @"Spectral Range End (nm)";
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%2.1f", testX];
        } break;
            
        case kDetailRowNumberOfWavelengthPoints:
            cell.textLabel.text = @"Number of Wavelength Points";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", _detailItem[kKSTDataManagerNumberOfWavelengthPoints]];
            break;
            
        case kDetailRowDigitalResolution:
            cell.textLabel.text = @"Digital Resolution";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", _detailItem[kKSTDataManagerDigitalResolution]];
            break;
            
        case kDetailRowNumberOfScansToAverage:
            cell.textLabel.text = @"Number of Scans to Average";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", _detailItem[kKSTDataManagerNumberOfAverages]];
            break;
            
        case kDetailRowTotalMeasurementTime:
            cell.textLabel.text = @"Total Measurement Time (s)";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%2.2f", [_detailItem[kKSTDataManagerTotalMeasurementTime] floatValue] ];
            break;
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
