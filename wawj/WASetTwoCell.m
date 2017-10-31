//
//  WASetTwoCell.m
//  wawj
//
//  Created by ruiyou on 2017/8/1.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WASetTwoCell.h"

@implementation WASetTwoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)clickSwitchBtn:(UISwitch *)sender {
    
   //
    
    self.switchState(sender.on);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
