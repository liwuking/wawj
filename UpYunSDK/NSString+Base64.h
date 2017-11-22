//
//  NSString+Base64.h
//  wawj
//
//  Created by ruiyou on 2017/11/21.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)
/**
 *  转换为Base64编码
 */
- (NSString *)base64EncodedString;
/**
 *  将Base64编码还原
 */
- (NSString *)base64DecodedString;
@end
