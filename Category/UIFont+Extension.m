

#import "UIFont+Extension.h"

@implementation UIFont (Extension)

- (CGFloat)ew_lineHeight
{
    return (self.ascender - self.descender);
}


@end
