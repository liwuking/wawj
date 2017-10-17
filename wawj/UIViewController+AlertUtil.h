//
//  UIViewController+AlertUtil.h
//  alertTest
//
//  Created by user on 2017/5/16.
//  Copyright © 2017年 liwuyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CallBack)(void);

NS_ASSUME_NONNULL_BEGIN
@interface UIViewController (AlertUtil)

-(void)showAlertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message buttonTitle:(nullable NSString *)buttonTitle clickBtn:(CallBack)btnBlock;

-(void)showAlertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle clickCancelBtn:(CallBack)cancelBlock otherButtonTitles:(nullable NSString *)otherButtonTitles clickOtherBtn:(CallBack)otherBlock;

@end
NS_ASSUME_NONNULL_END
