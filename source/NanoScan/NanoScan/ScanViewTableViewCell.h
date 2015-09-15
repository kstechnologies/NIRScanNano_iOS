//
//  ScanViewTableViewCell.h
//  NanoScan
//
//  Created by bob on 12/15/14.
//  Copyright (c) 2014 KS Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanViewTableViewCell : UITableViewCell

@property( nonatomic, strong ) IBOutlet UILabel *cellLabel;
@property( nonatomic, strong ) IBOutlet UITextField *cellTextField;

@end
