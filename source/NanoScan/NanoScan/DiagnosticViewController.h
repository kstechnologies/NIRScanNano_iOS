//
//  DiagnosticViewController.h
//  NanoScan
//
//  Created by bob on 2/5/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiagnosticViewController : UIViewController <UITextFieldDelegate>

@property( weak, nonatomic ) IBOutlet UITableView *diagnosticTableView;

@end
