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
}

@end
