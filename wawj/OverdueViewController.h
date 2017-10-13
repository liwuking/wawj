//
//  OverdueViewController.h
//  wawj
//
//  Created by ruiyou on 2017/10/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OverdueViewControllerDelegate <NSObject>

@optional
-(void)OverdueViewControllerRefresh;
@end

@interface OverdueViewController : UIViewController

@property(nonatomic,weak)id<OverdueViewControllerDelegate> delegate;

@end
