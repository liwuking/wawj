//
//  CustomBtn.m
//  wawj
//
//  Created by ruiyou on 2017/11/14.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "CustomBtn.h"

@implementation CustomBtn

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat midX = self.frame.size.width / 2;
    CGFloat midY = self.frame.size.height/ 2 ;
    self.imageView.center = CGPointMake(midX, midY - 10);
    self.titleLabel.center = CGPointMake(midX, midY + 50);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
