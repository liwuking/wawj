//
//  NSDictionary+StringConversion.h
//  wawj
//
//  Created by ruiyou on 2017/9/6.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (StringConversion)

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSString*)convertToJSONData:(id)infoDict;

@end
