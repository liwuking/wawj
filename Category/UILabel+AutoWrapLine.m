

#import "UILabel+AutoWrapLine.h"
@implementation UILabel (AutoWrapLine)

//仅仅显示前N行
- (CGSize)setLines:(NSInteger)lines andText:(NSString *)text LineSpacing:(CGFloat)lineSpacing{
    self.numberOfLines = lines;
    CGFloat oneRowHeight = [text sizeWithAttributes:@{NSFontAttributeName:self.font}].height;
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
    
    //设置文字的属性
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;//结尾部分的内容以……方式省略
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    
    //计算出真实大小
    CGFloat rows = textSize.height / oneRowHeight;
    CGFloat realHeight;
    if (rows >= lines) {
        rows = lines;
    }
    realHeight = (rows * oneRowHeight) + (rows - 1) * lineSpacing;
    [self setAttributedText:attributedString];
    return CGSizeMake(textSize.width, realHeight);
}


//全部显示
- (CGSize)multipleLinesSizeWithLineSpacing:(CGFloat)lineSpacing andText:(NSString *)text{
    self.numberOfLines = 0;
    CGFloat oneRowHeight = [text sizeWithAttributes:@{NSFontAttributeName:self.font}].height;
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    [paragraphStyle setLineSpacing:lineSpacing];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    
    CGFloat rows = textSize.height / oneRowHeight;
    CGFloat realHeight = oneRowHeight;
    if (rows > 1) {
        realHeight = (rows * oneRowHeight) + (rows - 1) * lineSpacing;
    }
    [self setAttributedText:attributedString1];
    return CGSizeMake(textSize.width, realHeight);
}
@end
