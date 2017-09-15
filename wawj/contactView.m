//
//  contactView.m
//  wawj
//
//  Created by ruiyou on 2017/9/12.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "contactView.h"

@implementation contactView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.delegate clickContactViewWith:@"1"];
}

@end
