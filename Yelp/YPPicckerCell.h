//
//  YPPicckerCell.h
//  Yelp
//
//  Created by Jim Liu on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YPPicckerCell;

@interface YPPicckerCell : UITableViewCell

@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSArray *pickerDataList;

@end
