//
//  AlarmClockItem.m
//  闹钟test
//
//  Created by 焦庆峰 on 2016/12/21.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import "AlarmClockItem.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "DBManager.h"
#import "FMDatabase.h"

@implementation AlarmClockItem

+(NSInteger)getCurrentWeekDay {
    NSDate *dateNow = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;//这句我也不明白具体时用来做什么。。。
    comps = [calendar components:unitFlags fromDate:dateNow];
    
    long weekNumber = [comps weekday]; //获取星期对应的长整形字符串
    
    return weekNumber;
}

+ (void)scheduleNotificationWithAlertContent:(NSString *)alertContent requestIdentifier:(NSString *)requestIdentifier AlarmClockType:(NSString *)alarType fireDate:(NSDate*)remindDate
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //在选中的时间发出提醒
    notification.fireDate = remindDate;
    if ([alarType isEqualToString:REMINDTYPE_ONLYONCE]) {
        //重复次数，一次
        notification.repeatInterval = 0;
    } else if ([alarType isEqualToString:REMINDTYPE_EVERYDAY]) {
        //重复次数，一天一次
        notification.repeatInterval = kCFCalendarUnitDay;
    } else {
        //重复次数，一周一次
        notification.repeatInterval = kCFCalendarUnitWeekday;
    }
    
    NSLog(@"本地推送时间: %@  类型: %@", remindDate,alarType);
    notification.timeZone = [NSTimeZone defaultTimeZone];
    //设置推送时的声音，一个30秒的音乐
    notification.soundName = @"ThunderSong.m4r";//UILocalNotificationDefaultSoundName;
    notification.alertAction = @"确定";//改变提示框按钮文字
    notification.hasAction = YES;//为no时按钮显示默认文字，为yes时，上一句代码起效
    notification.alertTitle = @"我爱我家";
    notification.alertBody = alertContent;
    //            //显示在icon上的红色圈中的数字,右上角数字加1
    //            notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    
    NSDictionary *infoDict = @{@"requestIdentifier":requestIdentifier,@"alarType":REMINDTYPE_ONLYONCE};
    //设置userinfo 方便在之后需要撤销的时候使用 也可以传递其他值，当通知触发时可以获取
    notification.userInfo = infoDict;
    
    //将这个notification添加到UIApplication中
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}


+ (void)addAlarmClockWithAlarmClockContent:(NSString *)content
                            AlarmClockDateTime:(NSString *)dateTime
                            AlarmClockType:(NSString *)alarType
                            AlarmClockIdentifier:(NSString *)clockIdentifier
{
    
    NSArray *arr = [dateTime componentsSeparatedByString:@":"];
    NSInteger hour = [arr[0] integerValue];
    NSInteger minute = [arr[1] integerValue];

    if (SYSTEM_VERSION < 10) {
        
        //取得系统的时间，并将其一个个赋值给变量
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
        calendar.timeZone = [NSTimeZone localTimeZone];
        NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;//这句我也不明白具体时用来做什么。。。
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps = [calendar components:unitFlags fromDate: [NSDate date]];
        
        if ([alarType isEqualToString:REMINDTYPE_ONLYONCE] || [alarType isEqualToString:REMINDTYPE_EVERYDAY]) {
            
            [comps setHour:hour];
            [comps setMinute:minute];
            [comps setSecond:0];
            NSDate *newFireDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
            
            [self scheduleNotificationWithAlertContent:content requestIdentifier:clockIdentifier AlarmClockType:alarType fireDate:newFireDate];
           
        } else  if ([alarType isEqualToString:REMINDTYPE_WORKDAY]) {

            for (NSInteger newWeekDay =2; newWeekDay<=6; newWeekDay++) {
                
                NSInteger temp = 0;
                NSInteger days = 0;
                
                temp = newWeekDay - comps.weekday;
                days = (temp >= 0 ? temp : temp + 7);
                
                [comps setHour:hour];
                [comps setMinute:minute];
                [comps setSecond:0];
                
                NSDate *newFireDate = [[[NSCalendar currentCalendar] dateFromComponents:comps] dateByAddingTimeInterval:3600 * 24 * days];
                clockIdentifier = [NSString stringWithFormat:@"%@%ld",clockIdentifier,newWeekDay];
                [self scheduleNotificationWithAlertContent:content requestIdentifier:clockIdentifier AlarmClockType:alarType fireDate:newFireDate];
            }

        } else {
            //周末
            for (NSInteger newWeekDay =1; newWeekDay<=7; newWeekDay++) {
                
                if (1== newWeekDay || 7 == newWeekDay) {
                    NSInteger temp = 0;
                    NSInteger days = 0;
                    
                    temp = newWeekDay - comps.weekday;
                    days = (temp >= 0 ? temp : temp + 7);
                    
                    [comps setHour:hour];
                    [comps setMinute:minute];
                    [comps setSecond:0];
                    
                    NSDate *newFireDate = [[[NSCalendar currentCalendar] dateFromComponents:comps] dateByAddingTimeInterval:3600 * 24 * days];
                    
                    clockIdentifier = [NSString stringWithFormat:@"%@%ld",clockIdentifier,newWeekDay];
                    [self scheduleNotificationWithAlertContent:content requestIdentifier:clockIdentifier AlarmClockType:alarType fireDate:newFireDate];
                }
                
            }
        }
        
    } else {
        //Local Notification
        UNMutableNotificationContent *notificationContent = [[UNMutableNotificationContent alloc] init];
        notificationContent.title = @"提醒";
        notificationContent.subtitle = @"我爱我家";
        notificationContent.body = content;
        notificationContent.sound = [UNNotificationSound soundNamed:@"ThunderSong.m4r"];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        if ([alarType isEqualToString:REMINDTYPE_EVERYDAY]) {
            
            for (NSInteger i = 1; i <= 7; i++) {
                NSDateComponents *components = [[NSDateComponents alloc] init];
                components.weekday = i;
                components.hour = hour;
                components.minute = minute;
                UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
                
                NSString *requestIdentifier = [NSString stringWithFormat:@"%@%ld",clockIdentifier,components.weekday];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier
                                                                                      content:notificationContent
                                                                                      trigger:trigger];
                [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    
                }];
            }
            
        } else  if ([alarType isEqualToString:REMINDTYPE_WORKDAY]) {
            
            for (NSInteger i = 2; i <= 6; i++) {
                NSDateComponents *components = [[NSDateComponents alloc] init];
                components.weekday = i;
                components.hour = hour;
                components.minute = minute;
                UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
                
                NSString *requestIdentifier = [NSString stringWithFormat:@"%@%ld",clockIdentifier,components.weekday];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier
                                                                                      content:notificationContent
                                                                                      trigger:trigger];
                [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    
                }];
            }
            
        } else  if ([alarType isEqualToString:REMINDTYPE_WEEKEND]) {
            
            //周末
            for (NSInteger i = 1; i <= 7; i++) {
                
                if (7 == i || 1 == i) {
                    NSDateComponents *components = [[NSDateComponents alloc] init];
                    components.weekday = i;
                    components.hour = hour;
                    components.minute = minute;
                    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
                    
                    NSString *requestIdentifier = [NSString stringWithFormat:@"%@%ld",clockIdentifier,components.weekday];
                    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier
                                                                                          content:notificationContent
                                                                                          trigger:trigger];
                    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                        
                    }];
                }
            }
            
        } else {
            
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.weekday = [self getCurrentWeekDay];
            components.hour = hour;
            components.minute = minute;
     
            NSLog(@"%@ 提醒时间：%@", alarType,components);
            UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
            
            NSString *requestIdentifier = [NSString stringWithFormat:@"%@%ld",clockIdentifier,components.weekday];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier
                                                                                  content:notificationContent
                                                                                  trigger:trigger];
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@ 本地提醒失败： %@",alarType,components);
                }
            }];
            
        }
    }
    
    
    
}

+ (void)cancelAlarmClockWithRemindItem:(RemindItem *)remindItem{
   
    if(SYSTEM_VERSION < 10){
        
        NSArray *notiArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
        if ([remindItem.remindtype isEqualToString:REMINDTYPE_ONLYONCE] || [remindItem.remindtype isEqualToString:REMINDTYPE_EVERYDAY]) {
            
            NSString *requestIdentifier = [NSString stringWithFormat:@"%@%@",remindItem.remindtype,remindItem.remindtime];
            for (UILocalNotification *notification in notiArray) {
                NSDictionary *info = notification.userInfo;
                if ([info[@"requestIdentifier"] isEqualToString:requestIdentifier]) {
                    //将这个notification从UIApplication中移除
                    [[UIApplication sharedApplication] cancelLocalNotification:notification];
                }
            }
            NSLog(@"删除requestIdentifier： %@", requestIdentifier);
        } else  if ([remindItem.remindtype isEqualToString:REMINDTYPE_WORKDAY]) {
            for (NSInteger i = 2; i <= 6; i++) {
                NSString *requestIdentifier = [NSString stringWithFormat:@"%@%@%ld",remindItem.remindtype,remindItem.remindtime,i];
                for (UILocalNotification *notification in notiArray) {
                    NSDictionary *info = notification.userInfo;
                    if ([info[@"requestIdentifier"] isEqualToString:requestIdentifier]) {
                        //将这个notification从UIApplication中移除
                        [[UIApplication sharedApplication] cancelLocalNotification:notification];
                    }
                }
                NSLog(@"删除requestIdentifier： %@", requestIdentifier);
            }
            
        } else  if ([remindItem.remindtype isEqualToString:REMINDTYPE_WEEKEND]) {
            for (NSInteger i = 1; i <= 7; i++) {
                if (1 == i || 7 == i) {
                    NSString *requestIdentifier = [NSString stringWithFormat:@"%@%@%ld",remindItem.remindtype,remindItem.remindtime,i];
                    for (UILocalNotification *notification in notiArray) {
                        NSDictionary *info = notification.userInfo;
                        if ([info[@"requestIdentifier"] isEqualToString:requestIdentifier]) {
                            //将这个notification从UIApplication中移除
                            [[UIApplication sharedApplication] cancelLocalNotification:notification];
                        }
                    }
                    NSLog(@"删除requestIdentifier： %@", requestIdentifier);
                }
            }
        }
        
    } else {
        
        NSMutableArray *identifiers = [@[] mutableCopy];
        if ([remindItem.remindtype isEqualToString:REMINDTYPE_EVERYDAY]) {
            for (NSInteger i = 1; i <= 7; i++) {
                [identifiers addObject:[NSString stringWithFormat:@"%@%@%ld",remindItem.remindtype,remindItem.remindtime,i]];
            }
        } else  if ([remindItem.remindtype isEqualToString:REMINDTYPE_WORKDAY]) {
            for (NSInteger i = 2; i <= 6; i++) {
                [identifiers addObject:[NSString stringWithFormat:@"%@%@%ld",remindItem.remindtype,remindItem.remindtime,i]];
            }
        } else  if ([remindItem.remindtype isEqualToString:REMINDTYPE_WEEKEND]) {
            [identifiers addObject:[NSString stringWithFormat:@"%@%@1",remindItem.remindtype,remindItem.remindtime]];
            [identifiers addObject:[NSString stringWithFormat:@"%@%@7",remindItem.remindtype,remindItem.remindtime]];
        } else {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *remindDate = [NSDate dateWithTimeIntervalSince1970:[remindItem.createtimestamp integerValue]];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            
            NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;//这句我也不明白具体时用来做什么。。。
            comps = [calendar components:unitFlags fromDate:remindDate];
            
            [identifiers addObject:[NSString stringWithFormat:@"%@%@%ld",remindItem.remindtype,remindItem.remindtime,comps.weekday]];
            
        }
        
        NSLog(@"删除requestIdentifiers[arr]： %@", identifiers);
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removePendingNotificationRequestsWithIdentifiers:identifiers];
        [center removeDeliveredNotificationsWithIdentifiers:identifiers];
    }
    
    
}

+ (void)cancelAllAlarmClock {
    
    if(SYSTEM_VERSION >= 10){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
        [center removeAllDeliveredNotifications];
    } else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    
}


+(void)cancelAllExpireAlarmClock {
    
    if(SYSTEM_VERSION >= 10){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            NSMutableArray *deliveredIdentifiers = [@[] mutableCopy];
            for (UNNotification *notification in notifications) {
                [deliveredIdentifiers addObject:notification.request.identifier];
            }
            [center removeDeliveredNotificationsWithIdentifiers:deliveredIdentifiers];
        }];
    } else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    

}
    
//    return;
//    if (![CoreArchive dicForKey:USERINFO]) {
//        return;
//    }
//    NSString *databaseTableName = @"remindList";
//    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
//    NSString *userID = userInfo? userInfo[@"userId"] : @"";
//    databaseTableName = [databaseTableName stringByAppendingFormat:@"_%@",userID];
//
//    NSDictionary *keys = @{@"remindtype"                 : @"string",
//                           @"remindtime"                 : @"string",
//                           @"createtimestamp"            : @"string",
//                           @"content"                    : @"string"};
//
////    __weak __typeof__(self) weakSelf = self;
//    [[DBManager defaultManager] createTableWithName:databaseTableName AndKeys:keys Result:^(BOOL isOK) {
//
//    } FMDatabase:^(FMDatabase *database) {
////        __strong __typeof__(weakSelf) strongSelf = weakSelf;
//        //[strongSelf removeAllExpRemind:database andDatabaseName:databaseTableName];
//
//        if ([database open]) {
//
//            NSInteger nowSp = [[NSDate date] timeIntervalSince1970];
//            NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindtype == 'onlyonce' and createtimestamp < %ld",databaseTableName,nowSp];
//            NSLog(@"sql = %@",sql);
//
//            NSMutableArray *dataArr = [[NSMutableArray alloc] init];
//            FMResultSet * res = [database executeQuery:sql];
//
//            while ([res next]) {
//                RemindItem *item = [[RemindItem alloc] init];
//                item.remindtype = [res stringForColumn:@"remindtype"];
//                item.remindtime = [res stringForColumn:@"remindtime"];
//                item.content = [res stringForColumn:@"content"];
//                item.createtimestamp = [res stringForColumn:@"createtimestamp"];
//                [dataArr addObject:item];
//            }
//
//            NSMutableArray *identifiers = [@[] mutableCopy];
//            for (NSInteger i = 0; i < dataArr.count; i++) {
//                RemindItem *remindItem = dataArr[i];
//
//
//                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//
//                NSDate *remindDate = [NSDate dateWithTimeIntervalSince1970:[remindItem.createtimestamp integerValue]];
//                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
//                NSDateComponents *comps = [[NSDateComponents alloc] init];
//                NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;//这句我也不明白具体时用来做什么。。。
//                comps = [calendar components:unitFlags fromDate:remindDate];
//
//                [identifiers addObject:[NSString stringWithFormat:@"%@%@%ld",remindItem.remindtype,remindItem.remindtime,comps.weekday]];
//
//            }
//
//            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//            [center removePendingNotificationRequestsWithIdentifiers:identifiers];
//            [center removeDeliveredNotificationsWithIdentifiers:identifiers];
//
//        }
//
//
//
//    }];
//
//}

//- (void)removeAllExpRemind:(FMDatabase *)database andDatabaseName:(NSString *)databaseTableName {
//
//    if ([database open]) {
//
//        NSInteger nowSp = [[NSDate date] timeIntervalSince1970];
//        NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindtype == 'onlyonce' and createtimestamp < %ld",databaseTableName,nowSp];
//        NSLog(@"sql = %@",sql);
//
//        NSMutableArray *dataArr = [[NSMutableArray alloc] init];
//        FMResultSet * res = [database executeQuery:sql];
//
//        while ([res next]) {
//            RemindItem *item = [[RemindItem alloc] init];
//            item.remindtype = [res stringForColumn:@"remindtype"];
//            item.remindtime = [res stringForColumn:@"remindtime"];
//            item.content = [res stringForColumn:@"content"];
//            item.createtimestamp = [res stringForColumn:@"createtimestamp"];
//            [dataArr addObject:item];
//        }
//
//        NSMutableArray *identifiers = [@[] mutableCopy];
//        for (NSInteger i = 0; i < dataArr.count; i++) {
//            RemindItem *remindItem = dataArr[i];
//
//
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//
//            NSDate *remindDate = [NSDate dateWithTimeIntervalSince1970:[remindItem.createtimestamp integerValue]];
//            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
//            NSDateComponents *comps = [[NSDateComponents alloc] init];
//            NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;//这句我也不明白具体时用来做什么。。。
//            comps = [calendar components:unitFlags fromDate:remindDate];
//
//            [identifiers addObject:[NSString stringWithFormat:@"%@%@%ld",remindItem.remindtype,remindItem.remindtime,comps.weekday]];
//
//        }
//
//        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//        [center removePendingNotificationRequestsWithIdentifiers:identifiers];
//        [center removeDeliveredNotificationsWithIdentifiers:identifiers];
//
//    }
//}

@end









