

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Extension)

#pragma mark - Tools

/** 中文转拼音*/
+ (NSString *)transform:(NSString *)chinese;

/** Remove spaces and line breaks */
- (NSString *)ew_removeSpacesAndLineBreaks;

/* Remove space */
- (NSString *)ew_removeSpaces;

/** A string has substring */
- (BOOL)ew_hasSubString:(NSString *)subStr;

/** Replace string with string */
- (NSString *)ew_replaceString:(NSString *)str withString:(NSString *)aStr;

/** According to the font size and line width calculation line high*/
- (CGFloat)ew_heightWithFont:(UIFont *)font lineWidth:(CGFloat)width;

/** According to the font size and line Max width calculation line width*/
- (CGFloat)ew_widthWithFont:(UIFont *)font lineWidth:(CGFloat)width;

/** Focus Substring in string */
- (NSMutableAttributedString *)ew_focusSubstring:(NSString *)subString color:(UIColor *)fontColor font:(UIFont *)font;

/** Seprator string with substring */
- (NSArray *)ew_sepratorwithString:(NSString *)str;

/** number of lines */
- (NSInteger)ew_numberOfLinesWithFont:(UIFont*)font lineWidth:(NSInteger)lineWidth;

/** Timestamp change with date */
- (NSString *)ew_timestampWithString:(NSString *)stampStr WithIndex:(int)index;

/** 判断时间为昨天、今天、明天 */
-(NSString *)compareDate:(NSDate *)date;


/** 设置不同字体颜色 */
- (void)ew_setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor;


#pragma mark - file

/*
 *  document根文件夹
 */
+(NSString *)documentFolder;


/*
 *  caches根文件夹
 */
+(NSString *)cachesFolder;




/**
 *  生成子文件夹
 *
 *  如果子文件夹不存在，则直接创建；如果已经存在，则直接返回
 *
 *  @param subFolder 子文件夹名
 *
 *  @return 文件夹路径
 */
-(NSString *)createSubFolder:(NSString *)subFolder;


/**  */

/** Check email */
- (BOOL)ew_checkEmail;

/** Check phone number */
- (BOOL)ew_checkPhoneNumber;

/** Check ID number */
- (BOOL)ew_checkIDNumber;

/** 获取手机ip地址 */
- (NSString *)ew_getIPAddress;
#pragma mark - Encode & Decode

/** MD5 encrypt */
- (NSString *)ew_md5Encrypt;

/** Base64 encode */
- (NSString *)ew_base64Encode;

/** Base64 decode*/
- (NSString *)ew_base64Decode;

/** URL encode*/
- (NSString *)ew_urlEncode;

/** URL decode*/
- (NSString *)ew_urlDecode;


@end
