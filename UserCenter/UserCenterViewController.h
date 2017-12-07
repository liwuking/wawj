//
//  UserCenterViewController.h
//  AFanJia
//
//  Created by 焦庆峰 on 2016/11/24.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WAGender) {
    WAGenderMan,
    WAGenderWoMan,
    WAGenderNull
};

@protocol UserCenterViewControllerDelegate <NSObject>

-(void)userCenterViewControllerWithHeadImgRefresh:(UIImage *)image;

@end

@interface UserCenterViewController : UIViewController

@property(nonatomic, strong)id<UserCenterViewControllerDelegate> delegate;

@end
