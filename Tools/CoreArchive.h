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

#define SYSTEM_VERSION  [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] firstObject] integerValue]

#define  WEBP_HEADER_FAMILY    @"HeaderFamilyWebp"
#define  WEBP_HEADERF_APP      @"HeaderApplyWebp"
#define  WEBP_HEADER_INFO      @"HeaderInfoWebp"

#define  RATIO_IMAGE_30      @"webp30"
#define  RATIO_IMAGE_40      @"webp40"
#define  RATIO_IMAGE_50      @"webp50"
#define  RATIO_IMAGE_60      @"webp60"
#define  RATIO_IMAGE_70      @"webp70"
#define  RATIO_IMAGE_80      @"webp80"
#define  RATIO_IMAGE_90      @"webp90"
#define  RATIO_IMAGE_100     @"webp100"


#define ADALBUM  @"adAlbum"
#define AD_PHOTOURL  @"adPhotoUrl"
#define AD_JUMPURL  @"jumpUrl"
#define AD_TITLE  @"title"


#define USER_CONTACT_ARR  @"user_contact_ARR"

#define USER_APP_ARR  @"user_app_arr"

#define USER_DATAIDENTIFIER_ARR  @"user_dataIdentifier_ARR"

#define USER_QIMI_ARR  @"user_qinmi_ARR"
#define USERINFO  @"userINFO"
#define HEADURL  @"headUrl"
#define USERID  @"userId"
#define USERNAME @"userName"
#define BIRTHDAY @"birthday"
#define BIRTHDAYTYPE @"birthdayType"
#define GENDER @"gender"
#define USERIPHONE @"phoneNo"
#define UNSHOWPHOTOS  @"unshowphotos"

#define USER_PHOTO_ARR  @"user_photo_ARR"
#define LASTTIME  @"lastestTime"

#define PHOTO_LIST_DICT  @"user_photoList_ARR"


#define REMINDTYPE_ONETIMEONCE      @"onetimeonce"


#define REMINDTYPE_ONLYONCE      @"onlyonce"
#define REMINDTYPE_EVERYDAY      @"everyday"
#define REMINDTYPE_WORKDAY       @"workday"
#define REMINDTYPE_WEEKEND       @"weekend"

#define  REMINDORIGINTYPE_LOCALADDITIONAL       @"remind_localaditional"
#define  REMINDORIGINTYPE_LOCAL       @"remind_local"
#define  REMINDORIGINTYPE_REMOTE       @"remind_remote"

#define MONDAY      @"Monday"
#define TUESDAY @   "Tuesday"
#define WEDNESDAY   @"Wednesday"
#define THURSDAY    @"Thursday"
#define FRIDAY      @"Friday"
#define SATURDAY    @"Saturday"
#define SUNDAY      @"Sunday"

#define INTERFACE_NEW  @"interface_new"   //是否新界面    YES表示新界面，NO表示旧界面
#define FIRST_ENTER  @"first_enter"       //是否第一次进入 YES表示是，NO表示否

//#define USERIHEADIMG  @"userimg"   //yes表示已经上传
#define ISZHENGDIAN_BAOSHI  @"zhengdianbaoshi"
#define ISZHENGDIAN_BAOSHIDefaultSet  @"zhengdianbaoshiDefault"

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
