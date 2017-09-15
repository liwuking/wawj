//
//  UIColor+Hex.h
//  juhuayou
//
//  Created by ivan on 15-2-6.
//  Copyright (c) 2015年 juhuayou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(long)hexColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;

@end