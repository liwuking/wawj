//
//  BuildRemindView.m
//  wawj
//
//  Created by ruiyou on 2017/10/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "BuildRemindView.h"

@implementation BuildRemindView

- (IBAction)clickBuildRemind:(UIButton *)sender {
    [self.delegate BuildRemindViewWithClickBuildRemind];
    [self removeFromSuperview];
}
- (IBAction)clickOverDueRemind:(UIButton *)sender {
    [self.delegate BuildRemindViewWithClickOverDueRemind];
    [self removeFromSuperview];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
