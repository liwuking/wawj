//
//  WAAddContactTableViewCell.m
//  wawj
//
//  Created by ruiyou on 2017/9/8.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAAddContactTableViewCell.h"
#import <UIImageView+WebCache.h>
@implementation WAAddContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setApplyItem:(ApplyItem *)applyItem {
    _applyItem = applyItem;
    
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!%@",applyItem.headUrl,WEBP_HEADER_FAMILY]] placeholderImage:[UIImage imageNamed:@"个人设置-我的头像"]];
    self.titleLab.text = [NSString stringWithFormat:@"%@(%@)", applyItem.applyRole,applyItem.applyName];
}

- (IBAction)clickAdd:(UIButton *)sender {
    
    [self.delegate clickAddContactWithCell:self];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
