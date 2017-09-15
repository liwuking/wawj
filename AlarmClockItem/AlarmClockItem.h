//
//  AlarmClockItem.h
//  闹钟test
//
//  Created by 焦庆峰 on 2016/12/21.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmClockItem : NSObject

//add
+ (void)addAlarmClockWithAlarmClockID:(NSString *)ID
                    AlarmClockContent:(NSString *)content
                       AlarmClockDate:(NSString *)date;

//delete
+ (void)cancelAllAlarmClock;
+ (void)cancelAllExpireAlarmClock;
+ (void)cancleAlarmClockWithValue:(NSString *)value;
@end
