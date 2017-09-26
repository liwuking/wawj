//
//  NSDictionary+Util.m
//  wawj
//
//  Created by ruiyou on 2017/9/15.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "NSDictionary+Util.h"

@implementation NSDictionary (Util)
-(NSMutableDictionary*)transforeNullValueInSimpleDictionary {
    
//    // 判断originJson是不是一个有效的字符串
//    if (![NSJSONSerialization isValidJSONObject:originJson]) {
//        return nil;
//    }
//    NSDictionary *originDic = (NSDictionary*)originJson;
    NSMutableDictionary *translatedDic = [NSMutableDictionary dictionary];
//
//    
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSNull class]]) {
            //[translatedDic setObject:@"" forKey:key];
            
        }else{
            [translatedDic setObject:obj forKey:key];
        }
        
    }];
    
    return translatedDic;
        
}
@end
