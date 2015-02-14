//
//  YPBusiness.m
//  Yelp
//
//  Created by Jim Liu on 2/11/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "YPBusiness.h"

@implementation YPBusiness

-(instancetype) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    if(self) {
        _name = dictionary[@"name"];
        _imageUrl = dictionary[@"image_url"];
        _address = [NSString stringWithFormat:@"%@, %@", [dictionary valueForKey:@"location.address"][0], [dictionary valueForKey:@"location.neighborhoods"][0]];
        _numReviews = [dictionary[@"review_count"] integerValue];
        _retingImageUrl = dictionary[@"rating_img_url"];
        static float milesPerMeter = 0.000621371;
        _distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
        _address = [NSString stringWithFormat:@"%@, %@", [dictionary valueForKeyPath:@"location.address"][0], [dictionary valueForKeyPath:@"location.neighborhoods"][0]];
        
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryNames = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryNames addObject:obj[0]];
        }];
        _categories = [categoryNames componentsJoinedByString:@","];
    }
    
    return self;
}

+(NSArray *)businessesWithDictionaries:(NSArray *) dictionaries {
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
         [result addObject:[[YPBusiness alloc] initWithDictionary:dictionary]];
    }
    
    return result;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@, %@, %@", self.name, self.address, self.categories];
}

@end
