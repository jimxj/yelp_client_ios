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
#import <MapKit/MapKit.h>

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

static NSString * const kCellName = @"YelpRestaurantCell";

double const METERS_PER_MILE= 1609.344;

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, YPFilterDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (nonatomic, strong) NSMutableArray *searchResultBusinesses;
@property (nonatomic, assign) BOOL isInSearchMode;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIBarButtonItem* rightUIBarButton;

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
    
    // set uptable view
    [self.tableView registerNib:[UINib nibWithNibName:kCellName bundle:nil] forCellReuseIdentifier:kCellName];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 85;
    
    // set up map view
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 37.774866;
    zoomLocation.longitude= -122.394556;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 5*METERS_PER_MILE, 5*METERS_PER_MILE);
    [self.mapView setRegion:viewRegion animated:YES];
    self.mapView.hidden = YES;
    self.mapView.showsUserLocation = YES;
    
    self.title = @"Yelp";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    
    self.rightUIBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Map View" style:UIBarButtonItemStylePlain target:self action:@selector(onSwitchViewButton)];
    self.navigationItem.rightBarButtonItem = self.rightUIBarButton;

    self.searchBar = [[UISearchBar alloc] init];//[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/2, 30)];
    self.searchBar.prompt = @"Business Name";
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
    return [self businessesToDisplay].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YelpRestaurantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellName];
    cell.business = [self businessesToDisplay][indexPath.row];
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
    if(!self.tableView.hidden) {
        self.mapView.hidden = NO;
        self.tableView.hidden = YES;
        [self.rightUIBarButton setTitle:@"List View"];
    } else {
        self.mapView.hidden = YES;
        self.tableView.hidden = NO;
        [self.rightUIBarButton setTitle:@"Map View"];
    }
    
    [self reloadViewData];
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@",searchText];
        self.searchResultBusinesses = [NSMutableArray arrayWithArray:[self.businesses filteredArrayUsingPredicate:predicate]];
    }
    
    [self reloadViewData];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isInSearchMode = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isInSearchMode = NO;
    
    // To dismiss keyboard
    [self.searchBar resignFirstResponder];
}

-(NSArray *) businessesToDisplay {
    return self.isInSearchMode ? self.searchResultBusinesses : self.businesses;
}

-(void) reloadMapData {
    NSArray *oldAnnotations = self.mapView.annotations;
    [self.mapView removeAnnotations: oldAnnotations];
    [self.mapView showAnnotations:[self businessesToDisplay] animated:YES];
}

-(void) reloadViewData {
    if(!self.tableView.hidden) {
       [self.tableView reloadData];
    } else {
       [self reloadMapData];
    }
}

@end
