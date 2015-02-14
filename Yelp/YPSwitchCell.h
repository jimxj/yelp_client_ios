//
//  YPSwitchCell.h
//  Yelp
//
//  Created by Jim Liu on 2/12/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YPSwitchCell;

@protocol YPSwitchCellDelegate <NSObject>

-(void) switchCell:(YPSwitchCell *) switchCell
    didUpdateValue:(BOOL) value;

@end

@interface YPSwitchCell : UITableViewCell

@property (nonatomic, weak) id<YPSwitchCellDelegate> delegate;

@property (nonatomic, assign) BOOL on;

@property (nonatomic, strong) NSString * title;

-(void) setOn:(BOOL)on animated:(BOOL) animated;

@end
