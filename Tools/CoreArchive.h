//
//  ToolArc.h
//  私人通讯录
//
//  Created by muxi on 14-9-3.
//  Copyright (c) 2014年 muxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSString+Extension.h"

#define USER_QIMI_ARR  @"user_qinmi_ARR"
#define USERINFO  @"userINFO"
#define UNSHOWPHOTOS  @"unshowphotos"

#define USER_PHOTO_ARR  @"user_photo_ARR"
#define LASTTIME  @"lastestTime"

#define INTERFACE_NEW  @"interface_new"   //是否新界面    YES表示新界面，NO表示旧界面
#define FIRST_ENTER  @"first_enter"       //是否第一次进入 YES表示是，NO表示否

//#define USERIHEADIMG  @"userimg"   //yes表示已经上传
#define ISZHENGDIAN_BAOSHI  @"zhengdianbaoshi"

@interface CoreArchive : NSObject

#pragma mark - 偏好类信息存储

+(void)setDic:(NSMutableDictionary *)obj key:(NSString *)key;
+(NSDictionary *)dicForKey:(NSString *)key;

+(void)setArr:(NSMutableArray *)arr key:(NSString *)key;
+(NSMutableArray *)arrForKey:(NSString *)key;

//+(void)setSet:(NSMutableSet *)set key:(NSString *)key;
//+(NSMutableSet *)setForKey:(NSString *)key;

/**
 *  保存普通字符串
 */
+(void)setStr:(NSString *)str key:(NSString *)key;

/**
 *  读取
 */
+(NSString *)strForKey:(NSString *)key;

/**
 *  删除
 */
+(void)removeStrForKey:(NSString *)key;


/**
 *  保存int
 */
+(void)setInt:(NSInteger)i key:(NSString *)key;

/**
 *  读取int
 */
+(NSInteger)intForKey:(NSString *)key;



/**
 *  保存float
 */
+(void)setFloat:(CGFloat)floatValue key:(NSString *)key;

/**
 *  读取float
 */
+(CGFloat)floatForKey:(NSString *)key;



/**
 *  保存bool
 */
+(void)setBool:(BOOL)boolValue key:(NSString *)key;

/**
 *  读取bool
 */
+(BOOL)boolForKey:(NSString *)key;


#pragma mark - 文件归档

/**
 *  归档
 */
+(BOOL)archiveRootObject:(id)obj toFile:(NSString *)path;
/**
 *  删除
 */
+(BOOL)removeRootObjectWithFile:(NSString *)path;

/**
 *  解档
 */
+(id)unarchiveObjectWithFile:(NSString *)path;









@end