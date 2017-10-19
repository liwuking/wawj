//
//  CircularView.h
//  wawj
//
//  Created by ruiyou on 2017/10/18.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CircularViewDelegate <NSObject>

@optional
-(void)circularViewWithProgress:(NSInteger)progress;
-(void)circularViewStartDraw;
-(void)circularViewEndDraw;

@end

@interface CircularView : UIView

@property(nonatomic,weak)id<CircularViewDelegate> delegate;
-(void)startCircleWithTimeLength:(NSInteger)timeLength;
-(void)endCircle;

@end
