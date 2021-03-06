//
//  YPBusiness.h
//  Yelp
//
//  Created by Jim Liu on 2/11/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface YPBusiness : NSObject<MKAnnotation>

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *retingImageUrl;
@property (nonatomic, assign) NSInteger numReviews;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

+(NSArray *)businessesWithDictionaries:(NSArray *) dictionaries;

@end
