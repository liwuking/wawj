//
//  AlarmClockItem.m
//  闹钟test
//
//  Created by 焦庆峰 on 2016/12/21.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import "AlarmClockItem.h"
#import <UIKit/UIKit.h>
@implementation AlarmClockItem

+ (void)addAlarmClockWithAlarmClockID:(NSString *)ID
                    AlarmClockContent:(NSString *)content
                       AlarmClockDate:(NSString *)date
                       AlarmClockType:(AlarmType)alarType
{
    
    NSString* timeStr = [NSString stringWithFormat:@"%@",date];
    NSLog(@"timeStr = %@",timeStr);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    if (timeStr.length == 16) {
       [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    }else{
       [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
     
    NSDate *fireDate = [formatter dateFromString:timeStr];//触发通知的时间
    
    NSLog(@"触发通知的时间now = %@",fireDate);
     
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (localNotification) {
        
        //设置推送时间
        localNotification.fireDate = fireDate;//=now
        //设置时区
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        //推送声音
        localNotification.soundName = @"ThunderSong.m4r";;
        //内容
        localNotification.alertBody = content;
        
        switch (alarType) {
            case AlarmTypeOnce:
                
                break;
            case AlarmTypeEveryDay:
                localNotification.repeatInterval = kCFCalendarUnitDay;
                break;
            case AlarmTypeOverWeekend:
                localNotification.repeatInterval = kCFCalendarUnitWeekOfMonth;
                break;
            case AlarmTypeWorkDay:
                localNotification.repeatInterval = kCFCalendarUnitWeekday;
                break;
            default:
                break;
        }
        
//        //显示在icon上的红色圈中的数子
//        noti.applicationIconBadgeNumber = 1;
        
        //设置userinfo 方便在之后需要撤销的时候使用---ID即触发本地推送的时间戳
        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:ID forKey:@"noti_ID"];
        localNotification.userInfo = infoDic;
        
        //添加推送到uiapplication
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
}

+ (void)cancelAllAlarmClock {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
+ (void)cancleAlarmClockWithValue:(NSString *)value{
   
    NSArray *notiArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    NSLog(@"notiArray = %@",notiArray);
    if (notiArray) {
        for (UILocalNotification *notification in notiArray) {
            NSDictionary *info = notification.userInfo;
            NSLog(@"dic = %@",info);
            if (info[@"noti_ID"]) {
                NSLog(@"key = %@",info[@"noti_ID"]);
                if ([info[@"noti_ID"] isEqualToString:value]) {
                    [[UIApplication sharedApplication] cancelLocalNotification:notification];
                }
            }
        }
    }
}

+ (void)cancelAllExpireAlarmClock {
    
//    NSDate *date = [[NSDate date] dateByAddingTimeInterval:8*60*60];
    int nowSp = [[NSDate date] timeIntervalSince1970];
    NSLog(@"nowSp = %d",nowSp);
    
    NSArray *notiArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    NSLog(@"notiArray = %@",notiArray);
    if (notiArray) {
        for (UILocalNotification *notification in notiArray) {
            NSDictionary *info = notification.userInfo;
            NSLog(@"dic = %@",info);
            if (info[@"noti_ID"]) {
                NSString *noti_ID = info[@"noti_ID"];
                NSLog(@"key = %@",info[@"noti_ID"]);
                if ([noti_ID intValue] <= nowSp) {
                    [[UIApplication sharedApplication] cancelLocalNotification:notification];
                }
            }
        }
    }
 
}

@end









