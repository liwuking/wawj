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
{
    
    NSString* timeStr = [NSString stringWithFormat:@"%@",date];
    NSLog(@"timeStr = %@",timeStr);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
    if (timeStr.length == 16) {
       [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    }else{
       [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
     
    NSDate *fireDate = [formatter dateFromString:timeStr];//触发通知的时间
    
    NSLog(@"now = %@",fireDate);
     
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    
    if (noti) {
        
        //设置推送时间
        
        noti.fireDate = fireDate;//=now
        
        //设置时区
        
        noti.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
        
        
        //推送声音
        
        noti.soundName = @"father.caf";;
        
        
        //内容
        
        noti.alertBody = content;
        
        //显示在icon上的红色圈中的数子
        
        noti.applicationIconBadgeNumber = 1;
        
        //设置userinfo 方便在之后需要撤销的时候使用
        
        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:ID forKey:@"noti_ID"];
        
        noti.userInfo = infoDic;
        
        //添加推送到uiapplication
        
        UIApplication *app = [UIApplication sharedApplication];
        
        [app scheduleLocalNotification:noti];
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
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:8*60*60];
    int nowSp = [date timeIntervalSince1970];
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
