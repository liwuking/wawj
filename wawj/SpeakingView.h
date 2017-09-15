//
//  SpeakingView.h
//  AFanJia
//
//  Created by 焦庆峰 on 2016/12/2.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import <UIKit/UIKit.h>
//@protocol SpeakingViewDelegate;
@interface SpeakingView : UIView
{
    IBOutlet UIView         *_bgView;
    IBOutlet UIImageView    *_volumeImageView;
    NSTimer                 *_timer;
}

//@property (nonatomic, assign)id<SpeakingViewDelegate>delegate;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
- (void)endSpeak;
- (void)cannelSpeak;
- (void)startAction;
@end

//@protocol SpeakingViewDelegate <NSObject>
//- (void)endSpeak;
//- (void)cannelSpeak;
//@end
