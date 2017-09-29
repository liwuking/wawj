//
//  NSDictionary+Util.h
//  wawj
//
//  Created by ruiyou on 2017/9/15.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Util)

-(NSMutableDictionary*)transforeNullValueInSimpleDictionary ;
-(NSMutableDictionary*)transforeNullValueToEmptyStringInSimpleDictionary;

@end
