//
//  NSDictionary+StringConversion.m
//  wawj
//
//  Created by ruiyou on 2017/9/6.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "NSDictionary+StringConversion.h"

@implementation NSDictionary (StringConversion)


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
   // [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
    jsonString = [[jsonString componentsSeparatedByCharactersInSet: doNotWant]componentsJoinedByString: @""];
    
//    NSLog(@"jsonString: %@", jsonString);
    return jsonString;
}

@end
