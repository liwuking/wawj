

#import "NSString+Extension.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIFont+Extension.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
@implementation NSString (Extension)

#pragma mark - Tools

+ (NSString *)transform:(NSString *)chinese;
{
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [pinyin uppercaseString];
}

- (NSString *)ew_removeSpacesAndLineBreaks
{
    return [[self stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}
- (NSString *)ew_removeSpaces
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


- (BOOL)ew_hasSubString:(NSString *)subStr
{
    BOOL result = FALSE;
    NSRange range = [self rangeOfString:subStr];
    if (range.location != NSNotFound) {
        result = TRUE;
    }
    
    return result;
}

- (NSString *)ew_replaceString:(NSString *)str withString:(NSString *)aStr
{
   return [self stringByReplacingOccurrencesOfString:str withString:aStr];
}

- (CGFloat)ew_heightWithFont:(UIFont *)font lineWidth:(CGFloat)width
{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_0
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return rect.size.height;
    
#else
    CGSize size = [self sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height;
    
#endif

}

- (CGFloat)ew_widthWithFont:(UIFont *)font lineWidth:(CGFloat)width
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_0
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return rect.size.width;
    
#else
    CGSize size = [self sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return size.wide;
    
#endif
}

- (NSMutableAttributedString *)ew_focusSubstring:(NSString *)subString color:(UIColor *)fontColor font:(UIFont *)font
{
    NSAssert(nil != fontColor, @"nil color!");
    NSAssert(nil != font, @"nil font");
    NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    NSRange range = [self rangeOfString:subString];
    if (range.location != NSNotFound) {
        [attributeString setAttributes:@{NSForegroundColorAttributeName:fontColor,NSFontAttributeName:font} range:range];
    }else{
    }
    return attributeString;

}

- (NSArray *)ew_sepratorwithString:(NSString *)str
{
    return [self componentsSeparatedByString:str];
}


- (NSInteger)ew_numberOfLinesWithFont:(UIFont*)font lineWidth:(NSInteger)lineWidth
{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_0
    CGRect rect = [self boundingRectWithSize:CGSizeMake(lineWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    NSInteger lines = rect.size.height/[font ew_lineHeight];
    return lines;
    
#else
    CGSize size = [self sizeWithFont:font constrainedToSize:CGSizeMake(lineWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    NSInteger lines = size.height / [font ew_lineHeight];
    return lines;

#endif

}


- (NSString *)ew_timestampWithString:(NSString *)stampStr WithIndex:(int)index {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[stampStr doubleValue]];
    NSString *time = [[NSString alloc]initWithFormat:@"%@",date];
    NSString *newTime = [time substringToIndex:index];
    return newTime;
}

-(NSString *)compareDate:(NSDate *)date{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString])
    {
        return @"今天";
    } else if ([dateString isEqualToString:yesterdayString])
    {
        return @"昨天";
    }else if ([dateString isEqualToString:tomorrowString])
    {
        return @"明天";
    }
    else
    {
        return dateString;
    }
}


//设置不同字体颜色
- (void)ew_setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}



- (BOOL)ew_checkEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];

}

- (BOOL)ew_checkPhoneNumber
{
    NSString *phoneRegex = @"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$)";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:self];

}

- (BOOL)ew_checkIDNumber
{
    NSString *idRegex = @"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$";
    NSPredicate *idTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",idRegex];
    return [idTest evaluateWithObject:self];

}


- (NSString *)ew_getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark - Encrypt & Decrypt
- (NSString *)ew_md5Encrypt
{
    const char *concat_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, (CC_LONG)strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++){
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];

}

- (NSString *)ew_base64Encode
{
    return  [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

- (NSString *)ew_base64Decode
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)ew_urlEncode
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)self,NULL,(CFStringRef)@";/?:@&=$+{}<>,",kCFStringEncodingUTF8));
    
    return result;
}


- (NSString *)ew_urlDecode
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8));
    
    return result;
}

#pragma mark - file
/*
 *  document根文件夹
 */
+(NSString *)documentFolder{
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}



/*
 *  caches根文件夹
 */
+(NSString *)cachesFolder{
    
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}





/**
 *  生成子文件夹
 *
 *  如果子文件夹不存在，则直接创建；如果已经存在，则直接返回
 *
 *  @param subFolder 子文件夹名
 *
 *  @return 文件夹路径
 */
-(NSString *)createSubFolder:(NSString *)subFolder{
    
    NSString *subFolderPath=[NSString stringWithFormat:@"%@/%@",self,subFolder];
    
    BOOL isDir = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL existed = [fileManager fileExistsAtPath:subFolderPath isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:subFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return subFolderPath;
}


@end
