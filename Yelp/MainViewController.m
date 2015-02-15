//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "YPBusiness.h"
#import "YelpRestaurantCell.h"
#import "FilterViewController.h"
#import "SVProgressHUD.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

static NSString * const kCellName = @"YelpRestaurantCell";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, YPFilterDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (nonatomic, strong) NSMutableArray *searchResultBusinesses;
@property (nonatomic, assign) BOOL isInSearchMode;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

-(void) fetchBusinessesWithQuery:(NSString *) query params:(NSDictionary *) params;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:kCellName bundle:nil] forCellReuseIdentifier:kCellName];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 85;
    
    self.title = @"Yelp";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map View" style:UIBarButtonItemStylePlain target:self action:@selector(onSwitchViewButton)];

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/2, 30)];
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
//    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/2, 30)];
//    titleView.backgroundColor = [UIColor greenColor];
//    UISearchBar *searchBar = [[UISearchBar alloc] init];
//    [titleView addSubview:searchBar];
    //UIButton *viewTypeButton = [[UIButton alloc] init];
    //[titleView addSubview:viewTypeButton];

//    self.navigationItem.titleView = titleView;
    
    [self fetchBusinessesWithQuery:@"Restaurants" params:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isInSearchMode ? self.searchResultBusinesses.count : self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YelpRestaurantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellName];
    cell.business = self.isInSearchMode ? self.searchResultBusinesses[indexPath.row] : self.businesses[indexPath.row];
    return cell;
}

-(void) fetchBusinessesWithQuery:(NSString *) query params:(NSDictionary *) params {
    [SVProgressHUD show];

    // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
    self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
    
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"response: %@", response);
        NSArray *businessesDictionary = response[@"businesses"];
        self.businesses = [[YPBusiness businessesWithDictionaries:businessesDictionary] mutableCopy];
        NSLog(@"businesses: %@", self.businesses);
        
        [self.tableView reloadData];
        
        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
        
        [SVProgressHUD dismiss];
    }];
}

-(void) onFilterButton {
    FilterViewController *vc = [[FilterViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

-(void) onSwitchViewButton {
    
}

#pragma mark - filter delegate
-(void)filterViewController:(FilterViewController *)filterViewController didChangeFilters:(NSDictionary *)filters {
    NSLog(@"%@", filters);
    [self fetchBusinessesWithQuery:@"Restaurants" params:filters];
}

#pragma mark search
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.searchResultBusinesses removeAllObjects];
    
    if(!searchText || ![searchText length]) {
        self.isInSearchMode = NO;
    } else {
        self.isInSearchMode = YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name BEGINSWITH[c] %@",searchText];
        self.searchResultBusinesses = [NSMutableArray arrayWithArray:[self.businesses filteredArrayUsingPredicate:predicate]];
    }
    
    [self.tableView reloadData];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isInSearchMode = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isInSearchMode = NO;
    
    // To dismiss keyboard
    [self.searchBar resignFirstResponder];
}

@end
