//
//  BaseField.m
//  unionlife
//
//  Created by 曾勇兵 on 15/10/27.
//  Copyright © 2015年 allinfinance. All rights reserved.
//

#import "BaseField.h"

@implementation BaseField

//重写这方法让输入框不可复制黏贴剪切。。。。
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{

        return NO;

}

@end
