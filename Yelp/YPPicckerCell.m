//
//  YPPicckerCell.m
//  Yelp
//
//  Created by Jim Liu on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "YPPicckerCell.h"

@interface YPPicckerCell () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *picker;


@end

@implementation YPPicckerCell

- (void)awakeFromNib {
    // Initialization code
    
    // Connect data
    self.picker.dataSource = self;
    self.picker.delegate = self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerDataList.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerDataList[row][@"name"];
}

@end
