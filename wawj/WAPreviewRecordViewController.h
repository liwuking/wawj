//
//  WAPreviewRecordViewController.h
//  wawj
//
//  Created by ruiyou on 2017/10/19.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloseFamilyItem.h"
@interface WAPreviewRecordViewController : UIViewController

@property (strong, nonatomic)  NSString *headUrl;
@property (strong, nonatomic)  NSString *audioUrl;
@property(nonatomic,assign)    NSInteger recordedTime;
@property(nonatomic,assign)    NSString *recordedDate;
@property(nonatomic,assign)    NSString *recordedDay;
@property(nonatomic,assign)    NSString *qinmiName;


@property(nonatomic,assign)    BOOL isFromRemindVC;
@property(nonatomic,assign)    NSString *createUser;


@end
