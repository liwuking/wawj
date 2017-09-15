//
//  WAAddContactTableViewCell.m
//  wawj
//
//  Created by ruiyou on 2017/9/8.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAAddContactTableViewCell.h"

@implementation WAAddContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)clickAdd:(UIButton *)sender {
    
    [self.delegate clickAddContact];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
