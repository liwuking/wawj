//
//  WAAppListViewController.h
//  wawj
//
//  Created by ruiyou on 2017/10/27.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppItem.h"
typedef void(^WAAppListViewControllerWithAddApp)(AppItem *appItem);

@interface WAAppListViewController : UIViewController
@property(nonatomic,copy)WAAppListViewControllerWithAddApp wAAppListViewControllerWithAddApp;
@property(nonatomic, strong)NSArray *selectedAppItem;
@end
