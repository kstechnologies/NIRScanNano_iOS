//
//  DetailViewController.h
//  NanoScan
//
//  Created by bob on 12/13/14.
//  Copyright (c) 2014 KS Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Charts/Charts.h>

@import Charts;

@interface DetailViewController : UIViewController <MFMailComposeViewControllerDelegate, ChartViewDelegate>

@property (strong, nonatomic) NSDictionary *detailItem;
@property (strong, nonatomic) IBOutlet UITableView *scanInfoTableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *scanSegmentControl;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property (nonatomic, strong) IBOutlet LineChartView *chartView;

@end

