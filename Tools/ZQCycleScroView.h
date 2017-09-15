//
//  ZQCycleScroView.h
//  ZQCycleScrollView
//
//  Created by quange on 15/6/16.
//  Copyright (c) 2015年 KingHan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZQCycleScroView;
@protocol ZQCycleScrollViewDelegate <NSObject>

- (void)cycleScrollView:(ZQCycleScroView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;

@end

@interface ZQCycleScroView : UIView

@property (nonatomic,assign) CGFloat autoScrollTimeInterval; // 自动滚动的间隔时间

@property (nonatomic,weak) id<ZQCycleScrollViewDelegate> delegate;

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame imagesGroup:(NSArray *)imagesGroup;


@end
