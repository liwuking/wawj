//
//  WADatePicker.m
//  wawj
//
//  Created by ruiyou on 2017/8/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WADatePicker.h"

@implementation WADatePicker

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)clickCancelBtn:(UIButton *)sender {
    
    [self.delegate WADatePickerWithCancel:self];
    
}
- (IBAction)clickSureBtn:(UIButton *)sender {
    
    [self.delegate WADatePickerWithSure:self];
    
}

@end
