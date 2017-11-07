//
//  AlarmClockItem.h
//  闹钟test
//
//  Created by 焦庆峰 on 2016/12/21.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemindItem.h"

@interface AlarmClockItem : NSObject


+ (void)addAlarmClockWithAlarmClockContent:(NSString *)content
                        AlarmClockDateTime:(NSString *)dateTime
                            AlarmClockType:(NSString *)alarType
                      AlarmClockIdentifier:(NSString *)clockIdentifier
                                  isOhters:(BOOL)isOther;
+ (void)cancelAllAlarmClock;
+ (void)cancelAllExpireAlarmClock;
+ (void)cancelAlarmClockWithRemindItem:(RemindItem *)remindItem;


+(void)addWholePointTellTime;
+(void)cancelWholePointTellTime;

@end
