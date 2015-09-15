//
//  InfoViewController.m
//  NanoScan
//
//  Created by bob on 2/23/15.
//  Copyright (c) 2015 KS Technologies. All rights reserved.
//

#import "InfoViewController.h"

typedef enum
{
    kInfoRowAboutTISpectroscopy = 0,
    kInfoRowAboutKST,
    kInfoRowBuyNano,
    kInfoRowE2E            // always the last row
} kInfoRow;

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Remove blank cells at the bottom of the table view
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    _infoTableView.tableFooterView = footer;
    
    self.title = @"More Information";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kInfoRowE2E+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    switch (indexPath.row)
    {
        case kInfoRowAboutTISpectroscopy:
            cell.textLabel.text = @"TI DLP Website";
            cell.detailTextLabel.text = @"Learn how TI is revolutionizing mobile spectroscopy";
            break;
            
        case kInfoRowAboutKST:
            cell.textLabel.text = @"KST DLP Website";
            cell.detailTextLabel.text = @"Learn about KST, TI's Strategic Design Partner";
            break;
            
        case kInfoRowBuyNano:
            cell.textLabel.text = @"Purchase a NIRScan Nano";
            cell.detailTextLabel.text = @"Learn how to buy your own Evaluation Module";
            break;
            
        case kInfoRowE2E:
            cell.textLabel.text = @"Support Forums";
            cell.detailTextLabel.text = @"Go deep with TI's E2E Technical Support Forums";
            break;
            
        default:
            break;
    }
    
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSURL *url;
    
    switch (indexPath.row)
    {
        case kInfoRowAboutTISpectroscopy:
            url = [NSURL URLWithString:@"http://www.ti.com/lsds/ti/dlp/advanced-light-control/wavelength-control.page"];
            break;
            
        case kInfoRowAboutKST:
            url = [NSURL URLWithString:@"https://www.kstechnologies.com/spectroscopy"];
            break;
            
        case kInfoRowBuyNano:
            url = [NSURL URLWithString:@"http://www.ti.com/tool/dlpnirscanevm"];
            break;
            
        case kInfoRowE2E:
            url = [NSURL URLWithString:@"http://e2e.ti.com/support/dlp__mems_micro-electro-mechanical_systems/f/983"];
            break;
            
        default:
            break;
    }
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
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
