

#import "UITabBarController+Extension.h"

@implementation UITabBarController (Extension)


- (void)ew_configTabBarItemWithTitles:(NSArray *)titles
                                 font:(UIFont *)font
                           titleColor:(UIColor *)titleColor
                   selectedTitleColor:(UIColor *)selectedTitleColor
                               images:(NSArray *)images
                       selectedImages:(NSArray *)selectedImags
                   barBackgroundImage:(UIImage *)barBackgroundImage
{
    if (titles.count != images.count || titles.count != selectedImags.count || images.count != selectedImags.count) {
        
    }else{
    
        //setup background image
        if (barBackgroundImage) {
            self.tabBar.backgroundImage = barBackgroundImage;
        }
        
        //setup titles appearance
        if (!font) {
            font = [UIFont systemFontOfSize:11];
        }
        
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:titleColor,NSFontAttributeName:font} forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:selectedTitleColor,NSFontAttributeName:font} forState:UIControlStateSelected];
        
        //setup titles & image & selected image
        NSInteger i = 0;
        for (UITabBarItem *item in [[self tabBar] items]) {
            [item setTitle:titles[i]];
            [item setImage:[[UIImage imageNamed:images[i]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ]];
            [item setSelectedImage:[[UIImage imageNamed:selectedImags[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            i++;
        }
        
    }
}

@end
