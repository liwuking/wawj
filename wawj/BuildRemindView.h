//
//  BuildRemindView.h
//  wawj
//
//  Created by ruiyou on 2017/10/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BuildRemindViewDelegate <NSObject>

- (void)BuildRemindViewWithClickBuildRemind;
- (void)BuildRemindViewWithClickOverDueRemind;
- (void)BuildRemindViewWithHiddenBuildRemind;

@end

@interface BuildRemindView : UIView

@property(nonatomic,weak)id<BuildRemindViewDelegate> delegate;

@end
