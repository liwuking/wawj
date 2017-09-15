//
//  ContactPersonView.m
//  wawj
//
//  Created by ruiyou on 2017/9/8.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "ContactPersonView.h"

@implementation ContactPersonView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)clickCloseBtn:(UIButton *)sender {
    self.hidden = YES;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hidden = YES;
}

@end
