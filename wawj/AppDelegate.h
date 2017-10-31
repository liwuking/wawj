//
//  AppDelegate.h
//  wawj
//
//  Created by ruiyou on 2017/7/5.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import <AVFoundation/AVFoundation.h>

static NSString *appKey = @"a41b7660ab31fe36f0005e35";
static NSString *channel = @"Publish channel";
static BOOL isProduction = FALSE;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic , strong)FMDatabase         *database;
@property(nonatomic, strong)NSString               *databaseTableName;
@property(nonatomic, strong)NSMutableArray               *databaseArr;
@property (nonatomic,strong) AVAudioPlayer *audioFilePlayer;//音频播放器，用于播放录音文件


@end

