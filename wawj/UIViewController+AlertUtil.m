//
//  UIViewController+AlertUtil.m
//  alertTest
//
//  Created by user on 2017/5/16.
//  Copyright © 2017年 liwuyang. All rights reserved.
//

#import "UIViewController+AlertUtil.h"

@implementation UIViewController (AlertUtil)

-(void)showAlertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message buttonTitle:(nullable NSString *)buttonTitle clickBtn:(void (^)(void))btnBlock {
    
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            btnBlock();
        }];
        [alert addAction:cancelAction];
        
        [strongSelf presentViewController:alert animated:YES completion:nil];
    });
    
    
    
}

-(void)showAlertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle clickCancelBtn:(void (^)(void))cancelBlock otherButtonTitles:(nullable NSString *)otherButtonTitles clickOtherBtn:(void (^)(void))otherBlock{
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        if (cancelButtonTitle) {
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                cancelBlock();
            }];
            [alert addAction:cancelAction];
        }
        
        if (otherButtonTitles) {
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                otherBlock();
            }];
            [alert addAction:defaultAction];
        }
        
        [strongSelf presentViewController:alert animated:YES completion:nil];
    });
    
    
    
}

@end
