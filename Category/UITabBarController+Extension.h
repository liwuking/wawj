

#import <UIKit/UIKit.h>

@interface UITabBarController (Extension)

/** Config TabBarItem. titles, font, textcolor, images ... */
- (void)ew_configTabBarItemWithTitles:(NSArray *)titles
                                 font:(UIFont *)font
                           titleColor:(UIColor *)titleColor
                   selectedTitleColor:(UIColor *)selectedTitleColor
                               images:(NSArray *)images
                       selectedImages:(NSArray *)selectedImags
                   barBackgroundImage:(UIImage *)barBackgroundImage;

@end
