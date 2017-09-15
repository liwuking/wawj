//
//  WARemindListViewController.h
//  wawj
//
//  Created by ruiyou on 2017/8/21.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "iflyMSC/IFlyMSC.h"
#import "PcmPlayer.h"
#import "MJRefresh.h"


@class IFlyDataUploader;
@class IFlySpeechUnderstander;
@class IFlySpeechSynthesizer;

typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,//普通合成
    UriType             = 6, //uri合成
};

typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2, //高异常分析需要的级别
    Paused              = 4,
};

@interface WARemindListViewController : UIViewController<IFlySpeechRecognizerDelegate,IFlySpeechSynthesizerDelegate>

//语音语义理解对象
@property (nonatomic,strong) IFlySpeechUnderstander *iFlySpeechUnderstander;
//文本语义理解对象
//@property (nonatomic,strong) IFlyTextUnderstander *iFlyUnderStand;

@property (nonatomic, copy)  NSString * defaultText;
@property (nonatomic) BOOL isCanceled;
@property (nonatomic,strong) NSString *result;
@property (nonatomic) BOOL isSpeechUnderstander;//当前状态是否是语音语义理解

//语音合成对象
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property (nonatomic, assign) BOOL isSpeechCanceled;
@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, assign) BOOL isViewDidDisappear;
@property (nonatomic, strong) PcmPlayer *audioPlayer;
@property (nonatomic, assign) Status state;
@property (nonatomic, assign) SynthesizeType synType;
@end
