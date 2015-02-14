//
//  YelpRestaurantCell.m
//  Yelp
//
//  Created by Jim Liu on 2/11/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "YelpRestaurantCell.h"
#import "UIImageView+AFNetworking.h"

@interface YelpRestaurantCell ()

@property (weak, nonatomic) IBOutlet UIImageView *businessImage;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *ratingImage;


@property (weak, nonatomic) IBOutlet UILabel *ratingNumLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UILabel *styleLabel;



@end

@implementation YelpRestaurantCell

- (void)awakeFromNib {
    // Initialization code
    //self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
    self.businessImage.layer.cornerRadius = 3;
    self.businessImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setBusiness:(YPBusiness *)business {
    _business = business;
    
    [self.nameLabel setText:business.name];
    [self.distanceLabel setText:[NSString stringWithFormat:@"%.2f mi",business.distance]];
    [self.ratingNumLabel setText:[NSString stringWithFormat:@"%ld Reviews", business.numReviews]];
    //[self.priceLabel setText:business.];
    [self.addressLabel setText:business.address];
    [self.styleLabel setText:business.categories];
    
    [self.businessImage setImageWithURL:[NSURL URLWithString:business.imageUrl]];
    [self.ratingImage setImageWithURL:[NSURL URLWithString:business.retingImageUrl]];
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    //self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;

}

@end
