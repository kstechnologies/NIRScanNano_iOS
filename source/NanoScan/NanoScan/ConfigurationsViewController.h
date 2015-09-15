//
//  ConfigurationsViewController.h
//  NanoScan
//
//  Created by bob on 2/19/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSTDataManager.h"

@interface ConfigurationsViewController : UIViewController

@property( weak, nonatomic ) IBOutlet UITableView *configurationTableView;
@property( weak, nonatomic ) IBOutlet UIProgressView *progressView;
@property( weak, nonatomic ) IBOutlet UILabel *statusLabel;

@property( weak, nonatomic ) KSTDataManager *dataManager;

@end
