//
//  UIButton+BtnCategory.m
//  wawj
//
//  Created by ruiyou on 2017/10/25.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "UIButton+BtnCategory.h"
#import <sys/utsname.h>

@implementation UIButton (BtnCategory)
- (void)verticalImageAndTitle:(CGFloat)spacing
{
    
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    NSInteger top = 0;
    NSInteger right = 0;
    if ([self isIphone5]) {
        imageSize = CGSizeMake(imageSize.width-30, imageSize.height-30);
        titleSize = CGSizeMake(titleSize.width-20, titleSize.height-20);
        self.titleLabel.font = [UIFont systemFontOfSize:20];
        top = 20;
        right = 40;
    }
    CGSize textSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0+top, - imageSize.width, - (totalHeight - titleSize.height), 0+right);

    
}

-(BOOL)isIphone5 {
    //需要导入头文件：
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone5,1"]
       || [platform isEqualToString:@"iPhone5,2"]
       || [platform isEqualToString:@"iPhone5,3"]
       || [platform isEqualToString:@"iPhone5,4"]
       || [platform isEqualToString:@"iPhone6,1"]
       || [platform isEqualToString:@"iPhone6,2"]) {
        return YES;
    }
    return NO;
    
}

@end
