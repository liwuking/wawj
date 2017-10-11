//
//  NSDictionary+Util.m
//  wawj
//
//  Created by ruiyou on 2017/9/15.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "NSDictionary+Util.h"

@implementation NSDictionary (Util)

//-(NSMutableDictionary*)transforeNullValueInSimpleDictionary {
//    
//    NSMutableDictionary *translatedDic = [@{} mutableCopy];
//    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        
//        if ([obj isKindOfClass:[NSNull class]]) {
//            //[translatedDic setObject:@"" forKey:key];
//            
//        }else{
//            [translatedDic setObject:obj forKey:key];
//        }
//        
//    }];
//    
//    return translatedDic;
//}

-(NSMutableDictionary*)transforeNullValueToEmptyStringInSimpleDictionary {
    
    NSMutableDictionary *translatedDic = [@{} mutableCopy];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSNull class]]) {
            [translatedDic setObject:@"" forKey:key];
        }else{
            if ([obj isKindOfClass:[NSNumber class]]) {
                [translatedDic setObject:[obj stringValue] forKey:key];
            } else {
                [translatedDic setObject:obj forKey:key];
            }
            
        }
        
    }];
    
    return translatedDic;
}

@end
