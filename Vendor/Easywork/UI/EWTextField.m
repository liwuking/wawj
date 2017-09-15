

#import "EWTextField.h"

@interface EWTextField ()
@property (nonatomic, strong) UIColor *placeHolderColor;
@end

@implementation EWTextField

- (id)initWithFrame:(CGRect)frame placeHolderColor:(UIColor *)color;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _placeHolderColor = color;
    }
    return self;
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [_placeHolderColor setFill];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    [[self placeholder] drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:_placeHolderColor}];
#else
    [[self placeholder] drawInRect:rect withFont:[UIFont systemFontOfSize:14]];

#endif
}

-(CGRect)placeholderRectForBounds:(CGRect)bounds
{

    CGRect inset = CGRectMake(bounds.origin.x, bounds.origin.y+12, bounds.size.width -10, bounds.size.height);
    return inset;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
