//
//  HomeCell.m
//  wawj
//
//  Created by ruiyou on 2017/9/13.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "HomeCell.h"
#import <UIImageView+WebCache.h>
#import <UIImageView+AFNetworking.h>
@implementation HomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.title.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.title.bounds;
    maskLayer.path = maskPath.CGPath;
    self.title.layer.mask = maskLayer;
    
}

-(void)setCloseFamilyItem:(CloseFamilyItem *)closeFamilyItem {
    
    _closeFamilyItem = closeFamilyItem;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!HeaderFamily",closeFamilyItem.headUrl]] placeholderImage:[UIImage imageNamed:@"头像设置"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
   
    self.title.text = closeFamilyItem.qinmiName;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
