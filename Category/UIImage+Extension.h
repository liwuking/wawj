

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

+ (UIImage *)ew_fixOrientation:(UIImage *)srcImg;

- (UIImage *)ew_scaleToSize:(CGSize)size;

+ (UIImage *)ew_imageWithContentOfFile:(NSString *)fileName;

@end
