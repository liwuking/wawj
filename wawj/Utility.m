//
//  Utility.m
//  wawj
//
//  Created by ruiyou on 2017/7/7.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "Utility.h"

@implementation Utility

#pragma mark - 验证输入手机号码
+ (BOOL)isValidatePhone:(NSString *)phone
{
    NSString *phoneRegex = @"^1[0-9]\\d{9}$";
    
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}


@end
