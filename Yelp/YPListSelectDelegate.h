//
//  YPListSelectDelegate.h
//  Yelp
//
//  Created by Jim Liu on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

@protocol YPListSelectDelegate <NSObject>

-(void) didSelected:(NSInteger) index forType:type;

@end
