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

+ (void)addAlarmClockWithAlarmClockContent:(NSString *)content
                            AlarmClockDateTime:(NSString *)dateTime
                            AlarmClockType:(NSString *)alarType
                            AlarmClockIdentifier:(NSString *)clockIdentifier
{
    
    //Local Notification
    UNMutableNotificationContent *notificationContent = [[UNMutableNotificationContent alloc] init];
    notificationContent.title = @"提醒";
    notificationContent.subtitle = @"我爱我家";
    notificationContent.body = content;
    notificationContent.sound = [UNNotificationSound soundNamed:@"ThunderSong.m4r"];
//    notificationContent.badge = @1;
    
    NSArray *arr = [dateTime componentsSeparatedByString:@":"];
    NSInteger hour = [arr[0] integerValue];
    NSInteger minute = [arr[1] integerValue];
    
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
        
        //周日
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.weekday = 1;
        components.hour = hour;
        components.minute = minute;
        UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
        
        NSString *requestIdentifier = [NSString stringWithFormat:@"%@%ld",clockIdentifier,components.weekday];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier
                                                                              content:notificationContent
                                                                              trigger:trigger];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            
        }];
        
        //周六
        components.weekday = 7;
        UNCalendarNotificationTrigger *trigger7 = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
        
        NSString *requestIdentifier7 = [NSString stringWithFormat:@"%@%ld",clockIdentifier,components.weekday];
        UNNotificationRequest *request7 = [UNNotificationRequest requestWithIdentifier:requestIdentifier7
                                                                              content:notificationContent
                                                                              trigger:trigger7];
        [center addNotificationRequest:request7 withCompletionHandler:^(NSError * _Nullable error) {
            
        }];
        
    } else {
        
        NSDate *dateNow = [NSDate date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        
        NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;//这句我也不明白具体时用来做什么。。。
        comps = [calendar components:unitFlags fromDate:dateNow];
        
        long weekNumber = [comps weekday]; //获取星期对应的长整形字符串
        
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.weekday = weekNumber;
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

+ (void)cancelAllAlarmClock {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    [center removeAllPendingNotificationRequests];
    [center removeAllDeliveredNotifications];
    
}
+ (void)cancelAlarmClockWithRemindItem:(RemindItem *)remindItem{
   
    
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

    
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center removePendingNotificationRequestsWithIdentifiers:identifiers];
    [center removeDeliveredNotificationsWithIdentifiers:identifiers];
    
}

+(void)cancelAllExpireAlarmClock {
    
    return;
    if (![CoreArchive dicForKey:USERINFO]) {
        return;
    }
    NSString *databaseTableName = @"remindList";
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *userID = userInfo? userInfo[@"userId"] : @"";
    databaseTableName = [databaseTableName stringByAppendingFormat:@"_%@",userID];
    
    NSDictionary *keys = @{@"remindtype"                 : @"string",
                           @"remindtime"                 : @"string",
                           @"createtimestamp"            : @"string",
                           @"content"                    : @"string"};
    
//    __weak __typeof__(self) weakSelf = self;
    [[DBManager defaultManager] createTableWithName:databaseTableName AndKeys:keys Result:^(BOOL isOK) {
        
    } FMDatabase:^(FMDatabase *database) {
//        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        //[strongSelf removeAllExpRemind:database andDatabaseName:databaseTableName];
        
        if ([database open]) {
            
            NSInteger nowSp = [[NSDate date] timeIntervalSince1970];
            NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindtype == 'onlyonce' and createtimestamp < %ld",databaseTableName,nowSp];
            NSLog(@"sql = %@",sql);
            
            NSMutableArray *dataArr = [[NSMutableArray alloc] init];
            FMResultSet * res = [database executeQuery:sql];
            
            while ([res next]) {
                RemindItem *item = [[RemindItem alloc] init];
                item.remindtype = [res stringForColumn:@"remindtype"];
                item.remindtime = [res stringForColumn:@"remindtime"];
                item.content = [res stringForColumn:@"content"];
                item.createtimestamp = [res stringForColumn:@"createtimestamp"];
                [dataArr addObject:item];
            }
            
            NSMutableArray *identifiers = [@[] mutableCopy];
            for (NSInteger i = 0; i < dataArr.count; i++) {
                RemindItem *remindItem = dataArr[i];
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate *remindDate = [NSDate dateWithTimeIntervalSince1970:[remindItem.createtimestamp integerValue]];
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;//这句我也不明白具体时用来做什么。。。
                comps = [calendar components:unitFlags fromDate:remindDate];
                
                [identifiers addObject:[NSString stringWithFormat:@"%@%@%ld",remindItem.remindtype,remindItem.remindtime,comps.weekday]];
                
            }
            
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center removePendingNotificationRequestsWithIdentifiers:identifiers];
            [center removeDeliveredNotificationsWithIdentifiers:identifiers];
            
        }

        
        
    }];
    
}

- (void)removeAllExpRemind:(FMDatabase *)database andDatabaseName:(NSString *)databaseTableName {

    if ([database open]) {
        
        NSInteger nowSp = [[NSDate date] timeIntervalSince1970];
        NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindtype == 'onlyonce' and createtimestamp < %ld",databaseTableName,nowSp];
        NSLog(@"sql = %@",sql);
        
        NSMutableArray *dataArr = [[NSMutableArray alloc] init];
        FMResultSet * res = [database executeQuery:sql];
        
        while ([res next]) {
            RemindItem *item = [[RemindItem alloc] init];
            item.remindtype = [res stringForColumn:@"remindtype"];
            item.remindtime = [res stringForColumn:@"remindtime"];
            item.content = [res stringForColumn:@"content"];
            item.createtimestamp = [res stringForColumn:@"createtimestamp"];
            [dataArr addObject:item];
        }
        
        NSMutableArray *identifiers = [@[] mutableCopy];
        for (NSInteger i = 0; i < dataArr.count; i++) {
            RemindItem *remindItem = dataArr[i];
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *remindDate = [NSDate dateWithTimeIntervalSince1970:[remindItem.createtimestamp integerValue]];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;//这句我也不明白具体时用来做什么。。。
            comps = [calendar components:unitFlags fromDate:remindDate];
            
            [identifiers addObject:[NSString stringWithFormat:@"%@%@%ld",remindItem.remindtype,remindItem.remindtime,comps.weekday]];
            
        }
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removePendingNotificationRequestsWithIdentifiers:identifiers];
        [center removeDeliveredNotificationsWithIdentifiers:identifiers];
        
    }
}

@end









