//
//  DeviceStatusViewController.h
//  NanoScan
//
//  Created by bob on 2/4/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceStatusViewController : UIViewController <UITextFieldDelegate>

@property( weak, nonatomic ) IBOutlet UITableView *deviceStatusTableView;

@end
