//
//  ScanConfigurationTableViewCell.h
//  NanoScan
//
//  Created by bob on 5/28/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanConfigurationTableViewCell : UITableViewCell

@property( strong ) IBOutlet UILabel *type;
@property( strong ) IBOutlet UILabel *index;
@property( strong ) IBOutlet UILabel *serialNumber;
@property( strong ) IBOutlet UILabel *configName;
@property( strong ) IBOutlet UILabel *wavelengthStart;
@property( strong ) IBOutlet UILabel *wavelengthEnd;
@property( strong ) IBOutlet UILabel *width;
@property( strong ) IBOutlet UILabel *numPatterns;
@property( strong ) IBOutlet UILabel *numRepeats;

@end
