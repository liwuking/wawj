//
//  WAAppCollectionViewCell.m
//  wawj
//
//  Created by ruiyou on 2017/10/27.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAAppCollectionViewCell.h"
#import <UIImageView+WebCache.h>
@implementation WAAppCollectionViewCell


-(void)setAppItem:(AppItem *)appItem {
    _appItem = appItem;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:appItem.appIcoUrl] placeholderImage:[UIImage imageNamed:@"firends"]];
    self.titleLab.text = appItem.appName;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    CALayer *bottomBorder = [CALayer layer];
//    float height=self.frame.size.height-1.0f;
//    float width=self.frame.size.width;
//    bottomBorder.frame = CGRectMake(0.0f, height, width, 1.0f);
//    bottomBorder.backgroundColor = [UIColor redColor].CGColor;
//    [self.layer addSublayer:bottomBorder];
    
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 0.5;
}

@end
