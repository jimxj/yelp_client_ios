//
//  FilterViewController.m
//  Yelp
//
//  Created by Jim Liu on 2/12/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FilterViewController.h"
#import "YPSwitchCell.h"
#import "YPPriceCell.h"
#import "YPPicckerCell.h"
#import "YPListSelectDelegate.h"

static NSString * const kCategoryCellName = @"YPSwitchCell";
static NSString * const kPriceCellName = @"YPPriceCell";
static NSString * const kPickerCellName = @"YPPicckerCell";

static NSString * const kDistanceFilterName = @"radius_filter";
static NSString * const kSortFilterName = @"sort";

@interface FilterViewController () <UITableViewDataSource, UITableViewDelegate, YPSwitchCellDelegate, YPListSelectDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDictionary *fiters;

@property (nonatomic, strong) NSArray *popularFilters;
@property (nonatomic, strong) NSArray *distanceFilters;
@property (nonatomic, strong) NSArray *sortFilters;
@property (nonatomic, strong) NSArray *generalFeatures;
@property (nonatomic, strong) NSArray *categories;

@property (nonatomic, strong) NSMutableSet *selectedCategories;

@property (nonatomic, strong, readonly) NSArray *sectionCells;

@property (nonatomic, assign) NSInteger selectedDistanceFilter;
@property (nonatomic, assign) NSInteger selectedSortFilter;
@property (nonatomic, strong) NSMutableSet *selectedPopularFilters;
@property (nonatomic, strong) NSMutableSet *selectedGeneralFeatures;

@property (nonatomic, strong) UIColor *defaultBackgroundColor;

-(void) initCategories;

@end

@implementation FilterViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        [self initPopularFilters];
        [self initDistanceFilters];
        [self initSortFilters];
        [self initGeneralFeatures];
        [self initCategories];

        _selectedCategories = [NSMutableSet set];
        _selectedPopularFilters = [NSMutableSet set];
        _selectedGeneralFeatures = [NSMutableSet set];

        _selectedDistanceFilter = 0;
        _selectedSortFilter = 0;
        
        _sectionCells = @[kPriceCellName, kCategoryCellName, kCategoryCellName, kCategoryCellName, kCategoryCellName, kCategoryCellName];

        self.defaultBackgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.tableView.backgroundColor = self.defaultBackgroundColor;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    for(NSString *cellname in self.sectionCells) {
        [self.tableView registerNib:[UINib nibWithNibName:cellname bundle:nil] forCellReuseIdentifier:cellname];
    }
    
    //[[UINavigationBar appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: //price
            return 1;
        case 1: //most popular
            return 4;
        case 2: //distance
            return self.distanceFilters.count;
        case 3: //sort by
            return self.sortFilters.count;
        case 4: //general features
            return self.generalFeatures.count;
        case 5: //category
            return self.categories.count;
        default:
            return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: //price
            return @"Price";
        case 1: //most popular
            return @"Most Popular";
        case 2: //distance
            return @"Distance";
        case 3: //sort by
            return @"Sort by";
        case 4: //general features
            return @"General Features";
        case 5: //category
            return @"Categories";
        default:
            return @"";
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UILabel *myLabel = [[UILabel alloc] init];
//    myLabel.frame = CGRectMake(20, 8, 320, 20);
//    myLabel.font = [UIFont boldSystemFontOfSize:14];
//    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
//
//    UIView *headerView = [[UIView alloc] init];
//    [headerView addSubview:myLabel];
//
//    return headerView;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.sectionCells[indexPath.section]];
    switch (indexPath.section) {
        case 0: //price
            break;
        case 1: { //most popular
            YPSwitchCell *ypSwitchCell = (YPSwitchCell *) cell;
            ypSwitchCell.delegate = self;
            ypSwitchCell.on = [self.selectedPopularFilters containsObject:self.popularFilters[indexPath.row]];
            ypSwitchCell.title = self.popularFilters[indexPath.row][@"name"];
            break;
        }
        case 2: {//distance
//            YPPicckerCell *pickerCell = (YPPicckerCell *) cell;
//            pickerCell.typeName = @"radius_filter";
//            pickerCell.pickerDataList = self.distanceFilters;
            YPSwitchCell *ypSwitchCell = (YPSwitchCell *) cell;
            ypSwitchCell.delegate = self;
            ypSwitchCell.on = self.selectedDistanceFilter == indexPath.row;
            ypSwitchCell.title = self.distanceFilters[indexPath.row][@"name"];
            break;
        }
        case 3: {//sort by
//            YPPicckerCell *pickerCell = (YPPicckerCell *) cell;
//            pickerCell.typeName = @"sort";
//            pickerCell.pickerDataList = self.sortFilters;
            YPSwitchCell *ypSwitchCell = (YPSwitchCell *) cell;
            ypSwitchCell.delegate = self;
            ypSwitchCell.on = self.selectedSortFilter == indexPath.row;
            ypSwitchCell.title = self.sortFilters[indexPath.row][@"name"];
            break;
        }
        case 4: {//general features
            YPSwitchCell *ypSwitchCell = (YPSwitchCell *) cell;
            ypSwitchCell.delegate = self;
            ypSwitchCell.on = [self.selectedGeneralFeatures containsObject:self.generalFeatures[indexPath.row]];
            ypSwitchCell.title = self.generalFeatures[indexPath.row][@"name"];
            break;
        }
        case 5: { //category
            YPSwitchCell *ypSwitchCell = (YPSwitchCell *) cell;
            ypSwitchCell.delegate = self;
            ypSwitchCell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            ypSwitchCell.title = self.categories[indexPath.row][@"name"];
            
            return ypSwitchCell;
        }
        default:
            return nil;
    }
    
    return cell;
}

- (void)switchCell:(YPSwitchCell *)switchCell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:switchCell];
    switch (indexPath.section) {
        case 0: //price
            return;
        case 1: {//most popular
//            if(indexPath.row == 2) {
//                self.isOfferingDealSelected = value;
//            }
            if(value) {
                [self.selectedPopularFilters addObject:self.popularFilters[indexPath.row]];
            } else {
                [self.selectedPopularFilters removeObject:self.popularFilters[indexPath.row]];
            }
            return ;
        }
        case 2: {//distance
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.selectedDistanceFilter inSection:indexPath.section];
            self.selectedDistanceFilter = indexPath.row;
            [self.tableView reloadRowsAtIndexPaths:@[previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
        case 3: {//sort by
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.selectedSortFilter inSection:indexPath.section];
            self.selectedSortFilter = indexPath.row;
            [self.tableView reloadRowsAtIndexPaths:@[previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
        case 4: {//general features
            if (value) {
                [self.selectedGeneralFeatures addObject:self.generalFeatures[indexPath.row]];
            } else {
                [self.selectedGeneralFeatures removeObject:self.generalFeatures[indexPath.row]];
            }
            return;
        }
        case 5: { //category
            if (value) {
                [self.selectedCategories addObject:self.categories[indexPath.row]];
            } else {
                [self.selectedCategories removeObject:self.categories[indexPath.row]];
            }
        }
        default:
            return ;
    }
}

-(NSDictionary *) fiters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if(self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for(NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    for(NSDictionary *filter in self.selectedPopularFilters) {
        if(((NSString *)filter[@"code"]).length) {
            [filters setObject:@YES forKey:filter[@"code"]];
        }
    }

    [filters setObject:[NSNumber numberWithDouble:[self.distanceFilters[self.selectedDistanceFilter][@"code"] doubleValue]] forKey:@"radius_filter"];
    [filters setObject:[NSNumber numberWithInt:[self.sortFilters[self.selectedSortFilter][@"code"] intValue]] forKey:@"sort"];

    
    return filters;
}

#pragma mark - picker delegate
-(void) didSelected:(NSInteger) index forType:type {
  if([type isEqualToString:kDistanceFilterName]) {
      self.selectedDistanceFilter = index;
  } else if([type isEqualToString:kSortFilterName]) {
      self.selectedSortFilter = index;
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

#pragma mark - private methods

-(void) onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) onApplyButton {
    [self.delegate filterViewController:self didChangeFilters:self.fiters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) initPopularFilters {
    _popularFilters = @[@{@"name" : @"Open Now", @"code": @"" },
                        @{@"name" : @"Hot & New", @"code": @"" },
                        @{@"name" : @"Offering a deal", @"code": @"deals_filter" },
                        @{@"name" : @"Delivery", @"code": @"" }
                        ];
}

-(void) initDistanceFilters {
    _distanceFilters = @[@{@"name" : @"Best matched", @"code": @"40000" },
                        @{@"name" : @"0.3 miles", @"code": @"482.8" },
                        @{@"name" : @"1 mile", @"code": @"1609" },
                        @{@"name" : @"5 miles", @"code": @"8046" },
                        @{@"name" : @"20 miles", @"code": @"32186.9" }
                        ];
}

-(void) initSortFilters {
    _sortFilters = @[@{@"name" : @"Best matched", @"code": @"0" },
                         @{@"name" : @"Distance", @"code": @"1" },
                         @{@"name" : @"Highest Rated", @"code": @"2" }
                         ];
}

-(void) initGeneralFeatures {
    _generalFeatures = @[@{@"name" : @"Take-out", @"code": @"" },
            @{@"name" : @"Good for Groups", @"code": @"" },
            @{@"name" : @"Take Reservations", @"code": @"" }
    ];
}

-(void) initCategories {
    self.categories = @[@{@"name" : @"Afghan", @"code": @"afghani" },
                                              @{@"name" : @"African", @"code": @"african" },
                                              @{@"name" : @"American, New", @"code": @"newamerican" },
                                              @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
                                              @{@"name" : @"Arabian", @"code": @"arabian" },
                                              @{@"name" : @"Argentine", @"code": @"argentine" },
                                              @{@"name" : @"Armenian", @"code": @"armenian" },
                                              @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
                                              @{@"name" : @"Asturian", @"code": @"asturian" },
                                              @{@"name" : @"Australian", @"code": @"australian" },
                                              @{@"name" : @"Austrian", @"code": @"austrian" },
                                              @{@"name" : @"Baguettes", @"code": @"baguettes" },
                                              @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
                                              @{@"name" : @"Barbeque", @"code": @"bbq" },
                                              @{@"name" : @"Basque", @"code": @"basque" },
                                              @{@"name" : @"Bavarian", @"code": @"bavarian" },
                                              @{@"name" : @"Beer Garden", @"code": @"beergarden" },
                                              @{@"name" : @"Beer Hall", @"code": @"beerhall" },
                                              @{@"name" : @"Beisl", @"code": @"beisl" },
                                              @{@"name" : @"Belgian", @"code": @"belgian" },
                                              @{@"name" : @"Bistros", @"code": @"bistros" },
                                              @{@"name" : @"Black Sea", @"code": @"blacksea" },
                                              @{@"name" : @"Brasseries", @"code": @"brasseries" },
                                              @{@"name" : @"Brazilian", @"code": @"brazilian" },
                                              @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                                              @{@"name" : @"British", @"code": @"british" },
                                              @{@"name" : @"Buffets", @"code": @"buffets" },
                                              @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
                                              @{@"name" : @"Burgers", @"code": @"burgers" },
                                              @{@"name" : @"Burmese", @"code": @"burmese" },
                                              @{@"name" : @"Cafes", @"code": @"cafes" },
                                              @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
                                              @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
                                              @{@"name" : @"Cambodian", @"code": @"cambodian" },
                                              @{@"name" : @"Canadian", @"code": @"New)" },
                                              @{@"name" : @"Canteen", @"code": @"canteen" },
                                              @{@"name" : @"Caribbean", @"code": @"caribbean" },
                                              @{@"name" : @"Catalan", @"code": @"catalan" },
                                              @{@"name" : @"Chech", @"code": @"chech" },
                                              @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
                                              @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
                                              @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
                                              @{@"name" : @"Chilean", @"code": @"chilean" },
                                              @{@"name" : @"Chinese", @"code": @"chinese" },
                                              @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
                                              @{@"name" : @"Corsican", @"code": @"corsican" },
                                              @{@"name" : @"Creperies", @"code": @"creperies" },
                                              @{@"name" : @"Cuban", @"code": @"cuban" },
                                              @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
                                              @{@"name" : @"Cypriot", @"code": @"cypriot" },
                                              @{@"name" : @"Czech", @"code": @"czech" },
                                              @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
                                              @{@"name" : @"Danish", @"code": @"danish" },
                                              @{@"name" : @"Delis", @"code": @"delis" },
                                              @{@"name" : @"Diners", @"code": @"diners" },
                                              @{@"name" : @"Dumplings", @"code": @"dumplings" },
                                              @{@"name" : @"Eastern European", @"code": @"eastern_european" },
                                              @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
                                              @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                                              @{@"name" : @"Filipino", @"code": @"filipino" },
                                              @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
                                              @{@"name" : @"Fondue", @"code": @"fondue" },
                                              @{@"name" : @"Food Court", @"code": @"food_court" },
                                              @{@"name" : @"Food Stands", @"code": @"foodstands" },
                                              @{@"name" : @"French", @"code": @"french" },
                                              @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
                                              @{@"name" : @"Galician", @"code": @"galician" },
                                              @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
                                              @{@"name" : @"Georgian", @"code": @"georgian" },
                                              @{@"name" : @"German", @"code": @"german" },
                                              @{@"name" : @"Giblets", @"code": @"giblets" },
                                              @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
                                              @{@"name" : @"Greek", @"code": @"greek" },
                                              @{@"name" : @"Halal", @"code": @"halal" },
                                              @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
                                              @{@"name" : @"Heuriger", @"code": @"heuriger" },
                                              @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
                                              @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
                                              @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
                                              @{@"name" : @"Hot Pot", @"code": @"hotpot" },
                                              @{@"name" : @"Hungarian", @"code": @"hungarian" },
                                              @{@"name" : @"Iberian", @"code": @"iberian" },
                                              @{@"name" : @"Indian", @"code": @"indpak" },
                                              @{@"name" : @"Indonesian", @"code": @"indonesian" },
                                              @{@"name" : @"International", @"code": @"international" },
                                              @{@"name" : @"Irish", @"code": @"irish" },
                                              @{@"name" : @"Island Pub", @"code": @"island_pub" },
                                              @{@"name" : @"Israeli", @"code": @"israeli" },
                                              @{@"name" : @"Italian", @"code": @"italian" },
                                              @{@"name" : @"Japanese", @"code": @"japanese" },
                                              @{@"name" : @"Jewish", @"code": @"jewish" },
                                              @{@"name" : @"Kebab", @"code": @"kebab" },
                                              @{@"name" : @"Korean", @"code": @"korean" },
                                              @{@"name" : @"Kosher", @"code": @"kosher" },
                                              @{@"name" : @"Kurdish", @"code": @"kurdish" },
                                              @{@"name" : @"Laos", @"code": @"laos" },
                                              @{@"name" : @"Laotian", @"code": @"laotian" },
                                              @{@"name" : @"Latin American", @"code": @"latin" },
                                              @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
                                              @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
                                              @{@"name" : @"Malaysian", @"code": @"malaysian" },
                                              @{@"name" : @"Meatballs", @"code": @"meatballs" },
                                              @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                                              @{@"name" : @"Mexican", @"code": @"mexican" },
                                              @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
                                              @{@"name" : @"Milk Bars", @"code": @"milkbars" },
                                              @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
                                              @{@"name" : @"Modern European", @"code": @"modern_european" },
                                              @{@"name" : @"Mongolian", @"code": @"mongolian" },
                                              @{@"name" : @"Moroccan", @"code": @"moroccan" },
                                              @{@"name" : @"New Zealand", @"code": @"newzealand" },
                                              @{@"name" : @"Night Food", @"code": @"nightfood" },
                                              @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
                                              @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
                                              @{@"name" : @"Oriental", @"code": @"oriental" },
                                              @{@"name" : @"Pakistani", @"code": @"pakistani" },
                                              @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
                                              @{@"name" : @"Parma", @"code": @"parma" },
                                              @{@"name" : @"Persian/Iranian", @"code": @"persian" },
                                              @{@"name" : @"Peruvian", @"code": @"peruvian" },
                                              @{@"name" : @"Pita", @"code": @"pita" },
                                              @{@"name" : @"Pizza", @"code": @"pizza" },
                                              @{@"name" : @"Polish", @"code": @"polish" },
                                              @{@"name" : @"Portuguese", @"code": @"portuguese" },
                                              @{@"name" : @"Potatoes", @"code": @"potatoes" },
                                              @{@"name" : @"Poutineries", @"code": @"poutineries" },
                                              @{@"name" : @"Pub Food", @"code": @"pubfood" },
                                              @{@"name" : @"Rice", @"code": @"riceshop" },
                                              @{@"name" : @"Romanian", @"code": @"romanian" },
                                              @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
                                              @{@"name" : @"Rumanian", @"code": @"rumanian" },
                                              @{@"name" : @"Russian", @"code": @"russian" },
                                              @{@"name" : @"Salad", @"code": @"salad" },
                                              @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
                                              @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
                                              @{@"name" : @"Scottish", @"code": @"scottish" },
                                              @{@"name" : @"Seafood", @"code": @"seafood" },
                                              @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
                                              @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
                                              @{@"name" : @"Singaporean", @"code": @"singaporean" },
                                              @{@"name" : @"Slovakian", @"code": @"slovakian" },
                                              @{@"name" : @"Soul Food", @"code": @"soulfood" },
                                              @{@"name" : @"Soup", @"code": @"soup" },
                                              @{@"name" : @"Southern", @"code": @"southern" },
                                              @{@"name" : @"Spanish", @"code": @"spanish" },
                                              @{@"name" : @"Steakhouses", @"code": @"steak" },
                                              @{@"name" : @"Sushi Bars", @"code": @"sushi" },
                                              @{@"name" : @"Swabian", @"code": @"swabian" },
                                              @{@"name" : @"Swedish", @"code": @"swedish" },
                                              @{@"name" : @"Swiss Food", @"code": @"swissfood" },
                                              @{@"name" : @"Tabernas", @"code": @"tabernas" },
                                              @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
                                              @{@"name" : @"Tapas Bars", @"code": @"tapas" },
                                              @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
                                              @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
                                              @{@"name" : @"Thai", @"code": @"thai" },
                                              @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
                                              @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
                                              @{@"name" : @"Trattorie", @"code": @"trattorie" },
                                              @{@"name" : @"Turkish", @"code": @"turkish" },
                                              @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
                                              @{@"name" : @"Uzbek", @"code": @"uzbek" },
                                              @{@"name" : @"Vegan", @"code": @"vegan" },
                                              @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
                                              @{@"name" : @"Venison", @"code": @"venison" },
                                              @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
                                              @{@"name" : @"Wok", @"code": @"wok" },
                                              @{@"name" : @"Wraps", @"code": @"wraps" },
                                              @{@"name" : @"Yugoslav", @"code": @"yugoslav" }];
}

@end
