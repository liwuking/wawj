//
//  Utility.h
//  juhuayou
//
//  Created by AaronRuan on 15-1-18.
//  Copyright (c) 2015年 juhuayou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>


@interface Utility : NSObject

+(NSString *)getDayWeek;

#pragma mark - 验证输入手机号码
+ (BOOL)isValidatePhone:(NSString *)phone;

#pragma mark - 根据格式获取日期
+ (NSString *)currentDateWithFormatter:(NSString *)formatter;


+ (NSString *)getCurrentTime;

+ (NSString * )getNowTime;

+ (NSString * )getDate;

+(NSString *) md5: (NSString *) inPutText;

+(NSString *) md5_32: (NSString *) inPutText;

+(NSString *) md5HexDigest:(NSString *) inPutText;

//+(CDPMenuViewController *)getMindVC;
//
//+(CDPMenuViewController *)getCDPMenuVC;
//
//+(void)setCDPMenuVC:(CDPMenuViewController *)vc;

+(NSString *)changetochinese:(NSString *)numstr;

+(void)setTabbarIndex:(NSInteger)index;

+(void)setUserinfo:(NSDictionary *)userinfo;

+(NSMutableDictionary *)getUserinfo;

/**取得流水号序号*/
+(NSInteger)getRequestNoOrder;

/**取得流水号序号*/
+(void)addRequestNoOrder;

/**获取app当前版本号*/
+(NSString*)getCurrentAppVersion;

/**取得当前用户的未确认的订单数*/
+(NSInteger)getUnconfirmedOrderCout;

/**设置当前用户的未确认的订单数*/
+(void)setUnconfirmedOrderCout:(NSInteger) count;



//+(void)setUsableBankInfos:(NSArray *)usableBankInfos;

+(NSArray *)getUsableBankInfos;


//判断登陆时效是否超过30分钟，超过则弹出重新登陆
+ (void)intervalSinceNow:(NSString *)theDate;



/**
 *  根据字符串生成一张CIImage
 *
 *  @param qrString 字符串
 *
 *  @return CIImage对象
 */
+ (CIImage *)createQRForString:(NSString *)qrString;

/**
 *  返回一张自定义大小的二维码图片
 *
 *  @param image 原始的图片
 *  @param size  尺寸
 *
 *  @return 自定义大小的二维码图片
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size;

/**
 *  给二维码图片自定义颜色
 *  @return 一张自定义图片的二维码
 */
+ (UIImage *)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;

//颜色生成图片
+(UIImage*) createImageWithColor:(UIColor*)color;
@end
