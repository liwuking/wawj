//
//  stringUtil.h
//  Sign on
//
//  Created by 曾勇兵 on 15-1-20.
//  Copyright (c) 2015年 zengyongbing. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreGraphics/CGGeometry.h>
@interface stringUtil : NSObject

+(NSString *)calculateImageRatioWithShowSize:(CGSize)showSize actualSize:(CGSize)actualSize andPhotoUrl:(NSString *)photoUrl;

#pragma mark - 输入是否为电子邮箱的验证
+ (BOOL)isValidateEmail:(NSString *)email;


#pragma mark - 验证输入手机号码
+ (BOOL)isValidatePhone:(NSString *)phone;

#pragma mark - 身份证号
+ (BOOL)validateIdentityCard:(NSString *)cardNo;

#pragma mark - 校验生日
+ (BOOL) isValidBirthday:(NSString*)birthday;


#pragma mark - 验证电话号码
+ (BOOL)isValidTel:(NSString *)tel;

+ (BOOL)isValidYoubian:(NSString *)youbian;

//银行卡
+ (BOOL)validateBankCardNumber: (NSString *)bankCardNumber;

//银行卡后四位
+ (BOOL) validateBankCardLastNumber:(NSString *)bankCardNumber;

+(BOOL)checkAccount:(NSString *)account;
+(BOOL)checkPassWord:(NSString *)password;

//是否是纯数字
+ (BOOL)isNumText:(NSString *)str;

//是否包含特殊字符
+(BOOL)validateNickname:(NSString *)nickname;

//字符串的空值判断
+(BOOL)isNull:(NSString *)str;

//只能是中文
+(BOOL)isChinese:(NSString *)str;

//是否有中文
+(BOOL)isRangeChinese:(NSString *)str;

//验证合同号
+(BOOL)iscontract:(NSString *)str;
@end
