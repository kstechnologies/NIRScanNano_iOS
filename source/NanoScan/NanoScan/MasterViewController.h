//
//  MasterViewController.h
//  NanoScan
//
//  Created by bob on 12/13/14.
//  Copyright (c) 2014 KS Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSTDataManager.h"

@interface MasterViewController : UIViewController <KSTDataManagerDelegate, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating>

@property( nonatomic, strong ) IBOutlet UITableView *scanTableView;
@property( nonatomic, strong ) KSTDataManager *dataManager;
@property( nonatomic, strong ) UISearchController *searchController;

@end

