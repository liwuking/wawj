

#import "WDLabel.h"
#import <CoreText/CoreText.h>

@interface WDLabel (){
@private
    NSMutableAttributedString *attributedString;
}

- (void)initAttributedString;

@end

@implementation WDLabel

@synthesize characterSpacing = characterSpacing_;

@synthesize linesSpacing = lineSpacing_;

@synthesize paragraphSpacing = paragraphSpacing_;

- (instancetype)initWithFrame:(CGRect)frame
{
    //初始化字间距、行间距
    if (self = [super initWithFrame:frame]) {
        self.characterSpacing = 1.5f;
        self.linesSpacing = 4.0f;
        self.paragraphSpacing = 10.0f;
    }
    return self;
}

//外部调用设置字间距
- (void)setCharacterSpacing:(CGFloat)characterSpacing{
    characterSpacing_ = characterSpacing;
    [self setNeedsDisplay];
}

/**
 *  外部调用设置行间距
 */
- (void)setLinesSpacing:(long)linesSpacing{
    lineSpacing_ = linesSpacing;
    [self setNeedsDisplay];
}

/**
 *  初始化AttributedString并进行相应设置
 */
- (void)initAttributedString{
    if (attributedString == nil) {
        NSString *labelString = self.text;
        
        //创建AttributeString
        attributedString = [[NSMutableAttributedString alloc] initWithString:labelString];
        //设置字体大小及字体
        CTFontRef helveticaBold = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
        [attributedString addAttribute:(id)kCTFontAttributeName value:(__bridge id)helveticaBold range:NSMakeRange(0, [attributedString length])];
        
        //设置字间距
        long number = self.characterSpacing;
        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &number);
        [attributedString addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0, [attributedString length])];
        CFRelease(num);
        
        //设置字体颜色
        [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)(self.textColor.CGColor) range:NSMakeRange(0, [attributedString length])];
        
        //创建文本对齐方式
        CTTextAlignment aligment = kCTLeftTextAlignment;
        if (self.textAlignment == NSTextAlignmentCenter) {
            aligment = kCTCenterTextAlignment;
        }
        if (self.textAlignment == NSTextAlignmentRight) {
            aligment = kCTRightTextAlignment;
        }
        
        CTParagraphStyleSetting alignmentStyle;
        
        alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;
        alignmentStyle.valueSize = sizeof(aligment);
        alignmentStyle.value = &aligment;
        
        //设置文本行间距
        CGFloat lineSpace = self.linesSpacing;
        CTParagraphStyleSetting lineSpaceStyle;
        lineSpaceStyle.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
        lineSpaceStyle.valueSize = sizeof(lineSpace);
        lineSpaceStyle.value = &lineSpace;
        
        //设置文本段间距
        CGFloat paragraphSpacings  = self.paragraphSpacing;
        CTParagraphStyleSetting paragraphSpaceStyle;
        paragraphSpaceStyle.spec = kCTParagraphStyleSpecifierParagraphSpacing;
        paragraphSpaceStyle.valueSize = sizeof(CGFloat);
        paragraphSpaceStyle.value = &paragraphSpacings;
        
        //创建设置数组(c语言数组)
        CTParagraphStyleSetting settings[ ] = {alignmentStyle, lineSpaceStyle, paragraphSpaceStyle};
        CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 3);
        
        //给文本添加设置
        [attributedString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)style range:NSMakeRange(0, [attributedString length])];
        CFRelease(helveticaBold);
    }
}

/**
 *  重写setText方法
 */
- (void)setText:(NSString *)text{
    [super setText:text];
}

/**
 *  开始绘制
 */
- (void)drawTextInRect:(CGRect)requestRect{
    [self initAttributedString];
    
    //排版
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
    
    CGPathAddRect(leftColumnPath, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), leftColumnPath, NULL);
    
    //翻转坐标系统
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //画文本
    CTFrameDraw(leftFrame, context);
    
    //释放
    CGPathRelease(leftColumnPath);
    CFRelease(framesetter);
    UIGraphicsPushContext(context);
    
}

/**
 *  绘制前获取label的高度
 */
- (int)getAttributedStringHeightWidthValue:(int)width{
    [self initAttributedString];
    
    int total_height = 0;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);//string为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, 100000);//这里的高要设置足够大
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    
    /**
     *  The range, of the attributed string that was used to create the framesetter, that is to be typeset in lines fitted into the frame. If the length portion of the range is set to 0, then the framesetter continues to add lines until it runs out of text or space.
     */
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *)CTFrameGetLines(textFrame);
    
    CGPoint origins[[linesArray count]];//c语言数组，结构体数组
    
    /**
     *  The range of line origins you wish to copy. If the length of the range is 0, then the copy operation continues from the start index of the range to the last line origin.
     */
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    int line_y = (int) origins[[linesArray count] -1].y;
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef line = (__bridge CTLineRef)[linesArray objectAtIndex:[linesArray count]-1];
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    total_height = 100000 - line_y + (int) descent +1;//加1为了纠正descent转换成int小数点后舍去的值
    
    CFRelease(textFrame);
    
    return total_height;
    
}

@end
