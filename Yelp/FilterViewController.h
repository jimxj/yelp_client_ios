//
//  FilterViewController.h
//  Yelp
//
//  Created by Jim Liu on 2/12/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterViewController;

@protocol YPFilterDelegate <NSObject>

- (void) filterViewController:(FilterViewController *) filterViewController
             didChangeFilters:(NSDictionary *) filters;
@end

@interface FilterViewController : UIViewController

@property (nonatomic, weak) id<YPFilterDelegate> delegate;

@end
