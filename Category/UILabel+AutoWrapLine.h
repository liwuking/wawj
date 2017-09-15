//
//  UILabel+AutoWrapLine.h
//  GuoKuMaijia
//
//  Created by 王宁 on 16/3/9.
//  Copyright © 2016年 北京腾信软创科技股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (AutoWrapLine)
- (CGSize)setLines:(NSInteger)lines andText:(NSString *)text LineSpacing:(CGFloat)lineSpacing;
- (CGSize)multipleLinesSizeWithLineSpacing:(CGFloat)lineSpacing andText:(NSString *)text;
@end
