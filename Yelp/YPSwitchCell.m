//
//  YPSwitchCell.m
//  Yelp
//
//  Created by Jim Liu on 2/12/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "YPSwitchCell.h"

@interface YPSwitchCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;

@end

@implementation YPSwitchCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchValueChanged:(UISwitch *)sender {
    [self.delegate switchCell:self didUpdateValue:sender.on];
}

-(void) setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

-(void) setTitle:(NSString *) title {
    [self.titleLabel setText:title];
}

-(void) setOn:(BOOL)on animated:(BOOL) animated {
    _on = on;
    [self.toggleSwitch setOn:on animated:animated];
}


@end
