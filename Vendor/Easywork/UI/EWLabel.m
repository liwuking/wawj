

#import "EWLabel.h"

@implementation EWLabel

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:rect];
    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    CGSize textSize = [[self text] sizeWithAttributes:@{NSFontAttributeName:[self font]}];
#else
    CGSize textSize = [[self text] sizeWithFont:[self font]];
#endif
    
    
    CGFloat strikeWidth = textSize.width;
    
    CGRect lineRect;
    
    if ([self textAlignment] == NSTextAlignmentRight){
        // 画线居中
        lineRect = CGRectMake(rect.size.width - strikeWidth, rect.size.height/2, strikeWidth, 0.5);

    }else if ([self textAlignment] == NSTextAlignmentCenter){
        // 画线居中
        lineRect = CGRectMake(rect.size.width/2 - strikeWidth/2, rect.size.height/2, strikeWidth, 0.5);
    }else{
        // 画线居中
        lineRect = CGRectMake(0, rect.size.height/2, strikeWidth, 0.5);

    }
  
    CGContextRef context = UIGraphicsGetCurrentContext();
        
    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
        
    CGContextFillRect(context, lineRect);
}

@end
