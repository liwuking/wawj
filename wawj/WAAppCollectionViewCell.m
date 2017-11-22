//
//  WAAppCollectionViewCell.m
//  wawj
//
//  Created by ruiyou on 2017/10/27.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAAppCollectionViewCell.h"
#import <UIImageView+WebCache.h>
#import "Masonry.h"

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
    
//    self.layer.borderColor = [UIColor blackColor].CGColor;
//    self.layer.borderWidth = 0.5;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //1. frame 需要collectionView宽度 屏幕宽度 + 0.5 否则最右侧显示该颜色竖线
    //    UIView *horLineView = [[UIView alloc] init];
    //    horLineView.backgroundColor = [UIColor redColor];
    //    [self.contentView addSubview:horLineView];
    //    horLineView.frame = CGRectMake(0, self.bounds.size.height - 0.5, self.bounds.size.width, 0.5);
    //
    //    UIView *verLineView = [[UIView alloc] init];
    //    verLineView.backgroundColor = [UIColor redColor];
    //    [self.contentView addSubview:verLineView];
    //    verLineView.frame = CGRectMake(self.bounds.size.width - 0.5, 0, 0.5, self.bounds.size.height);
    
    //2. autolayout 需要collectionView宽度 屏幕宽度 + 0.5 否则6s、7等机型有竖线不显示
    UIView *horLineView = [[UIView alloc] init];
    horLineView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:horLineView];
    [horLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.bottom.and.trailing.equalTo(@0);
        make.height.equalTo(@0.5);
    }];
    
    UIView *verLineView = [[UIView alloc] init];
    verLineView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:verLineView];
    [verLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.and.trailing.equalTo(@0);
        make.width.equalTo(@0.5);
    }];
    
    //3. CALayer 需要collectionView宽度 屏幕宽度 + 0.5 否则最右侧显示该颜色竖线 但6s、7等机型竖线均显示 不存在2. autolayout情况
    //    CALayer *bottomLineLayer = [[CALayer alloc] init];
    //    bottomLineLayer.frame = CGRectMake(0, self.bounds.size.height - 0.5, self.bounds.size.width, 0.5);
    ////    bottomLineLayer.backgroundColor = [UIColor colorWithRed:230/255.0 green:233/255.0 blue:237/255.0 alpha:1].CGColor;
    //    bottomLineLayer.backgroundColor = [UIColor redColor].CGColor;
    //    [self.contentView.layer addSublayer:bottomLineLayer];
    //
    //    CALayer *rightLineLayer = [[CALayer alloc] init];
    //    rightLineLayer.frame = CGRectMake(self.bounds.size.width - 0.5, 0, 0.5, self.bounds.size.height);
    ////    rightLineLayer.backgroundColor = [UIColor colorWithRed:230/255.0 green:233/255.0 blue:237/255.0 alpha:1].CGColor;
    //    rightLineLayer.backgroundColor = [UIColor redColor].CGColor;
    //    [self.contentView.layer addSublayer:rightLineLayer];
    
}

@end
