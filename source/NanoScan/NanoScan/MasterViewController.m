//
//  MasterViewController.m
//  NanoScan
//
//  Created by bob on 12/13/14.
//  Copyright (c) 2014 KS Technologies. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "KSTNanoSDK.h"
#import "KSTDataManager.h"

@interface MasterViewController ()
@property (strong, nonatomic) NSMutableArray *filteredList;
@end

@implementation MasterViewController

bool fresh = YES;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Edit"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(toggleEditMode)];
    self.navigationItem.leftBarButtonItem = editButton;
    
    // Search Bar
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    //self.searchController.searchBar.scopeButtonTitles = @[@"All",@"Cars",@"Bikes"];

    /*
     self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"Scan Data",@"Scan Data"),
     NSLocalizedString(@"Scan Configurations",@"Scan Configurations")];
     */
    self.searchController.searchBar.delegate = self;
    self.scanTableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [self.searchController.searchBar sizeToFit];
    
    [_scanTableView reloadData];
    _scanTableView.backgroundColor = [UIColor clearColor];
    _scanTableView.delegate = self;
    
    _filteredList = nil;
    _filteredList = [NSMutableArray array];
    _filteredList = [_dataManager.dataArray mutableCopy];
    
}

-(void)toggleEditMode
{
    if( _scanTableView.isEditing )
        [_scanTableView setEditing:NO animated:YES];
    else
        [_scanTableView setEditing:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [[KSTNanoSDK manager] KSTNanoSDKDisconnect];
    
    if( fresh )
    {
        _dataManager = [KSTDataManager manager];
        _dataManager.delegate = self;
        
        [_dataManager KSTDataManagerInitialize];
    }
    else
    {
        NSLog(@"[NOTICE] Total Scans: %lu", (unsigned long)[[[KSTDataManager manager] dataArray] count]);
        [_scanTableView reloadData];    // forces reload from Data Manager
    }
    
    _filteredList = nil;
    _filteredList = [NSMutableArray array];
    _filteredList = [_dataManager.dataArray mutableCopy];
    [_scanTableView reloadData];    // forces reload from Data Manager
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - KST Data Manager Delegate
-(void)KSTDataManagerDidAddNewFile
{
    [_scanTableView reloadData];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [_scanTableView indexPathForSelectedRow];
        NSDictionary *aStoredScan = _filteredList[indexPath.row];
        NSLog(@"Selecting %@", aStoredScan[kKSTDataManagerFilename]);
        [[segue destinationViewController] setDetailItem:aStoredScan];
    }
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_filteredList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary *aStoredScan = _filteredList[indexPath.row];
    cell.textLabel.text = aStoredScan[kKSTDataManagerFilename];
    cell.detailTextLabel.text = aStoredScan[kKSTDataManagerKeyTimestamp];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.userInteractionEnabled = YES;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_filteredList removeObjectAtIndex:indexPath.row];
        
        [_dataManager.dataArray removeObjectAtIndex:indexPath.row];
        [_dataManager KSTDataManagerSave];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - Search Bar
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.scanTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_filteredList removeAllObjects];
    [_filteredList addObjectsFromArray:_dataManager.dataArray];
    [_scanTableView reloadData];    // forces reload from Data Manager
}

- (void)searchForText:(NSString *)searchText
{
    if( searchText.length > 0 )
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kKSTDataManagerFilename contains %@", searchText];
        
        [_filteredList removeAllObjects];
        _filteredList = [[_dataManager.dataArray filteredArrayUsingPredicate:predicate] mutableCopy];
        [_scanTableView reloadData];
    }
    
}

@end