
//  AppDelegate.m
//  wawj
//
//  Created by ruiyou on 2017/7/5.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "AppDelegate.h"
#import "iflyMSC/IFlyMSC.h"
#import "AlarmClockItem.h"
#import "UIAlertView+Extension.h"
#import "CoreArchive.h"
#import <UMSocialCore/UMSocialCore.h>

#import "WAOldInterfaceViewController.h"
#import "WANewInterfaceViewController.h"
#import "WABindIphoneViewController.h"
#import "WAGuideViewController.h"

#import "EditRemindViewController.h"
#import "WAPreviewRecordViewController.h"

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>
#import "WAApplyRemindViewController.h"
#define USHARE_APPKEY  @"59ae0a1782b635489c000dab"



@interface AppDelegate ()<UNUserNotificationCenterDelegate,JPUSHRegisterDelegate,AVAudioPlayerDelegate>

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s", __FUNCTION__);
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self handleVC];
    [self.window makeKeyAndVisible];
    
    //设置科大讯飞
    [self iFlySet];
    //设置本地推送
    [self setLocalNotificationWithOptions:launchOptions];
    [self setJPush:launchOptions];//设置极光推送
    //网络监控
    [self netMonitor];
    //设置友盟
    [self setUMShare];
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
    NSString *recordPath = [documentPath stringByAppendingPathComponent:@"MyRecord"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:recordPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:recordPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSString *contactPath = [documentPath stringByAppendingPathComponent:@"MyContact"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:contactPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:contactPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![CoreArchive boolForKey:ISZHENGDIAN_BAOSHIDefaultSet]) {
        [self openWholeRemind];
    }
    
    [self getAdvertisingData];
    
  
    return YES;
    
}

-(void)handleVC {
    if (![CoreArchive boolForKey:FIRST_ENTER]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WAGuideViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WAGuideViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = nav;
        //表明不是第一次登录了
        [CoreArchive setBool:YES key:FIRST_ENTER];
        
    } else if ([CoreArchive boolForKey:INTERFACE_NEW]) {
        WANewInterfaceViewController *vc = [[WANewInterfaceViewController alloc] initWithNibName:@"WANewInterfaceViewController" bundle:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = nav;
    } else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WAOldInterfaceViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WAOldInterfaceViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = nav;
    }
}

-(void)openWholeRemind {
    [CoreArchive setBool:YES key:ISZHENGDIAN_BAOSHI];
    [CoreArchive setBool:YES key:ISZHENGDIAN_BAOSHIDefaultSet];
    [AlarmClockItem addWholePointTellTime];

}


-(void)getAdvertisingData {
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P0006" andModel:nil];
    
//    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
//        __strong __typeof__(weakSelf) strongSelf = weakSelf;
//        [MBProgressHUD hideHUD];
        
        NSString *code = data[@"code"];
//        NSString *desc = data[@"desc"];
        NSMutableDictionary *adAblum = [[NSMutableDictionary alloc] initWithDictionary:data[@"body"][@"adAlbum"]];
        if ([code isEqualToString:@"0000"] && adAblum.count) {
            
            [CoreArchive setDic:[adAblum transforeNullValueToEmptyStringInSimpleDictionary] key:ADALBUM];
            
        }
        
    } fail:^(NSError *error) {
        
    }];
}

-(void)setJPush:(NSDictionary *)launchOptions {

    [JPUSHService setLogOFF];
    
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(serviceError:)
                          name:kJPFServiceErrorNotification
                        object:nil];
}

#pragma -mark UIApplicationDelegate
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSDictionary *dictionary =[NSJSONSerialization JSONObjectWithData:deviceToken options:NSJSONReadingMutableContainers error:nil];
    [JPUSHService registerDeviceToken:deviceToken];
    NSLog(@"%s  %@", __func__,[NSString stringWithFormat:@"Device Token: %@", dictionary]);
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"%s \ndid Fail To Register For Remote Notifications With Error: %@",__func__, error);
}

-(void)handleRemoteNotificationWithUserInfo:(NSDictionary *)userInfo {
    
    NSString *audioUrl = userInfo[@"nativeData"][@"remindAudio"];
    NSInteger createUser = [userInfo[@"nativeData"][@"createUser"] integerValue];
    NSString *headUrl = @"";
    NSString *qinmiName = @"";
    NSMutableArray *arr = [CoreArchive arrForKey:USER_QIMI_ARR];
    for (NSDictionary *dict in arr) {
        if ([dict[@"qinmiUser"] isEqualToString:[NSString stringWithFormat:@"%ld",createUser]]) {
            headUrl = dict[@"headUrl"];
            qinmiName = dict[@"qinmiName"];
            break;
        }
    }
    
    NSInteger remindTimeStamp = [userInfo[@"nativeData"][@"remindTime"] integerValue]/1000;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:remindTimeStamp];
    NSString *recordTime = [dateFormatter stringFromDate:date];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
    NSString *tomorrow = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
    NSString *aftertomorrow = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
    
   NSString *remindDate = [dateFormatter stringFromDate:date];
    if ([remindDate isEqualToString:today]) {
        remindDate = @"今天";
    } else if([remindDate isEqualToString:tomorrow]) {
        remindDate = @"明天";
    } else if([remindDate isEqualToString:aftertomorrow]){
        remindDate = @"后天";
    }
    NSInteger remindSeconds = [userInfo[@"nativeData"][@"remindSeconds"] integerValue];
    
    WAPreviewRecordViewController *vc = [[WAPreviewRecordViewController alloc] initWithNibName:@"WAPreviewRecordViewController" bundle:nil];
    vc.audioUrl = audioUrl;
    vc.recordedTime = remindSeconds;
    vc.headUrl = headUrl;
    vc.qinmiName = qinmiName;
    vc.recordedDate = recordTime;
    vc.recordedDay = remindDate;
    [[[self topViewController] navigationController] pushViewController:vc animated:YES];
    
}

- (void)networkDidLogin:(NSNotification *)notification {
    NSLog(@"已登录");
    
    
    [JPUSHService getAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        
        if (0 == iResCode && ![iAlias isEqualToString:@""]) {
            NSLog(@"得到别名: %@", iAlias);
        } else {
            NSLog(@"得到别名失败");
            
            if ([CoreArchive dicForKey:USERINFO]) {
                NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
                //设置别名
                NSString *userid = [NSString stringWithFormat:@"%@", userInfo[USERID]];
                [JPUSHService setAlias:userid completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    if (0 == iResCode) {
                        NSLog(@"设置别名成功: %@", iAlias);
                    } else {
                        NSLog(@"设置别名失败");
                    }
                } seq:[[NSDate date] timeIntervalSince1970]];
            }
            
            
        }
        
    } seq:[[NSDate date] timeIntervalSince1970]];
    
    
    JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
    identifier.identifiers = nil;
    identifier.findCompletionHandler = ^(NSArray *results) {
        NSLog(@"未处理通知数量: %ld", results.count);
        
        for (NSInteger i = 0; i < results.count; i++) {
            if ([results[i] isKindOfClass:[UNNotificationRequest class]]) {
                UNNotificationRequest *request = results[i];
                NSDictionary * userInfo = request.content.userInfo;
//                NSLog(@"未处理的通知:%@", [self logDic:userInfo]);
            } else {
                UNNotificationRequest *request = results[i];
                NSDictionary * userInfo = request.content.userInfo;
//                NSLog(@"未处理的通知:%@", [self logDic:userInfo]);
            }
        }
        
        for (UNNotificationRequest *request in results) {
            
        }
        
        //         [JPUSHService removeNotification:identifierWeak];
    };
    [JPUSHService findNotification:identifier];
    
    
    
    
    //     if(SYSTEM_VERSION >= 10){
    //         identifier.delivered = YES;  //iOS10以上有效，等于YES则查找所有在通知中心显示的，等于NO则为查找所有待推送的；iOS10以下无效
    //         [JPUSHService removeNotification:identifier];
    //     }
    
    
    
}

#pragma -mark 创建数据库表
- (void)createDatabaseTableWithUserid:(NSString *)userId andCompletion:(void (^)(void))completionHandler{
    
    self.databaseTableName = [NSString stringWithFormat:@"remindList_%@", userId];
    NSDictionary *keys = @{@"remindorigintype"           : @"string",
                           @"remindid"                   : @"string",
                           @"audiourl"                   : @"string",
                           @"headurl"                    : @"string",
                           @"remindtype"                 : @"string",
                           @"remindtime"                 : @"string",
                           @"createtimestamp"            : @"string",
                           @"content"                    : @"string"
                           };
    
    __weak __typeof__(self) weakSelf = self;
    [[DBManager defaultManager] createTableWithName:self.databaseTableName AndKeys:keys Result:^(BOOL isOK) {
        if (!isOK) {
        } else {
        }
        
    } FMDatabase:^(FMDatabase *database) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        strongSelf.database = database;
        completionHandler();
    }];
    
    
}


-(void)insertRemoteRemindToDB:(NSArray *)remindArr {
    NSLog(@"%s", __FUNCTION__);
    for (RemindItem *remindItem in remindArr) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindorigintype = '%@' and remindid = %@",self.databaseTableName,REMINDORIGINTYPE_REMOTE,remindItem.remindid];
        NSLog(@"sql = %@",sql);
        
        if ([self.database open]) {
            FMResultSet * res = [self.database executeQuery:sql];
            if (![res next]) {
                NSString *sql = [NSString stringWithFormat:@"insert into %@ (remindorigintype,remindid,remindtype,remindtime,content,audiourl,headurl,createtimestamp) values ('%@','%@','%@','%@','%@','%@','%@','%@')",self.databaseTableName,REMINDORIGINTYPE_REMOTE,remindItem.remindid,REMINDTYPE_ONLYONCE,remindItem.remindtime,@"",remindItem.audiourl,remindItem.headurl,remindItem.createtimestamp];
                NSLog(@"语音提醒sql: %@",sql);
                BOOL isCreate = [self.database executeUpdate:sql];
                if (isCreate) {
                    NSLog(@"插入成功");
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.timeZone = [NSTimeZone localTimeZone];
                    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                    NSDate *remindDate = [NSDate dateWithTimeIntervalSince1970:[remindItem.createtimestamp integerValue]];
                    //添加一个新的闹钟
                    NSString *clockIdentifier = [NSString stringWithFormat:@"remote_%@_%@%@",remindItem.remindid,REMINDTYPE_ONLYONCE,remindItem.remindtime];
                    [AlarmClockItem addAlarmClockWithAlarmClockContent:@"" fireDate:remindDate AlarmClockType:REMINDTYPE_ONLYONCE AlarmClockIdentifier:clockIdentifier isOhters:YES];
                    
                }else {
                    NSLog(@"插入失败");
                }
                
            } else {
                NSLog(@"已存在");
            }
        }
    }
    
}

-(void)handleRemoteRemindToDB:(NSDictionary *)daDict {
    
    if (daDict[@"acceptPhone"]) {
        return;
    }
    
    NSDictionary *dataDict = [daDict transforeNullValueToEmptyStringInSimpleDictionary];
    
    RemindItem *item = [[RemindItem alloc] init];
    item.remindtype = REMINDTYPE_ONLYONCE;
    item.content = @"";
    item.createtimestamp = [NSString stringWithFormat:@"%ld",[dataDict[@"remindTime"] integerValue]/1000];
    item.audiourl = dataDict[@"remindAudio"];
    item.remindid = dataDict[@"remindId"];
    NSInteger remindTimeStamp = [ item.createtimestamp integerValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:remindTimeStamp];
    item.remindtime = [dateFormatter stringFromDate:date];
    
    NSString *createUser = dataDict[@"createUser"];
    NSString *headUrl = @"";
    NSString *qinmiName = @"";
    NSMutableArray *arr = [CoreArchive arrForKey:USER_QIMI_ARR];
    for (NSDictionary *dict in arr) {
        if ([dict[@"qinmiUser"] isEqualToString:createUser]) {
            headUrl = dict[@"headUrl"];
            qinmiName = dict[@"qinmiName"];
            break;
        }
    }
    item.headurl = headUrl;

    [self insertRemoteRemindToDB:@[item]];
    
    NSString *remindSeconds = dataDict[@"remindSeconds"];
    
    //存储对应的提醒人
    NSMutableDictionary *remoteDict = [[NSMutableDictionary alloc] initWithDictionary:[CoreArchive dicForKey:REMOTE_REMIND_ARR]];
    [remoteDict setObject:@{@"createUser":createUser,@"remindSeconds":remindSeconds,@"headUrl":headUrl,@"qinmiName":qinmiName} forKey:item.remindid];
    [CoreArchive setDic:remoteDict key:REMOTE_REMIND_ARR];
    
}

#pragma mark- JPUSHRegisterDelegate
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
   
    NSLog(@"%s -- identifier: %@", __FUNCTION__, notification.request.identifier);
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    NSString *title = userInfo[@"aps"][@"alert"];
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
        
        if ([title isEqualToString:@"亲， 您的提醒对方已知晓"]) {
            
        } else if ([title containsString:@"申请添加你"]) {
            __weak __typeof__(self) weakSelf = self;
            [self.window.rootViewController showAlertViewWithTitle:title message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            } otherButtonTitles:@"确定" clickOtherBtn:^{
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                WAApplyRemindViewController *vc = [[WAApplyRemindViewController alloc] initWithNibName:@"WAApplyRemindViewController" bundle:nil];
                [[[strongSelf topViewController] navigationController] pushViewController:vc animated:YES];
            }];
            
        }  else {
            if (!self.remoteEnterN) {
                self.remoteEnterN = 1;
                NSString *title = userInfo[@"aps"][@"alert"];
                __weak __typeof__(self) weakSelf = self;
                [self.window.rootViewController showAlertViewWithTitle:title message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
                    __strong __typeof__(weakSelf) strongSelf = weakSelf;
                    strongSelf.remoteEnterN = 0;
                } otherButtonTitles:@"确定" clickOtherBtn:^{
                    __strong __typeof__(weakSelf) strongSelf = weakSelf;
                    strongSelf.remoteEnterN = 0;
                    [strongSelf handleRemoteNotificationWithUserInfo:userInfo];
                }];
            }
            
            if (userInfo[@"nativeData"]) {
                if (!self.database) {
                    __weak __typeof__(self) weakSelf = self;
                    NSString *userID = [CoreArchive dicForKey:USERINFO][USERID];
                    [self createDatabaseTableWithUserid:userID andCompletion:^{
                        __strong __typeof__(weakSelf) strongSelf = weakSelf;
                        [strongSelf handleRemoteRemindToDB:userInfo[@"nativeData"]];
                    }];
                } else {
                    [self handleRemoteRemindToDB:userInfo[@"nativeData"]];
                }
            }
        }
        
    } else {
        // 判断为本地通知
//        NSLog(@"iOS10及以上 前台收到本地通知:%@\n}",userInfo);
        if (![notification.request.content.title isEqualToString:@"整点报时"]) {
            [[self topViewController] showAlertViewWithTitle:@"我的提醒" message:notification.request.content.body buttonTitle:@"确定" clickBtn:^{

            }];

        }
        
        NSString *requestIdentifier = notification.request.identifier;//notification.userInfo[@"requestIdentifier"];
        if ([requestIdentifier hasPrefix:@"remote"]) {
            
            NSString *remindid = [requestIdentifier componentsSeparatedByString:@"_"][1];
            if (!self.database) {
                NSString *userID = [CoreArchive dicForKey:USERINFO][USERID];
                __weak __typeof__(self) weakSelf = self;
                [self createDatabaseTableWithUserid:userID andCompletion:^{
                    __strong __typeof__(weakSelf) strongSelf = weakSelf;
                    RemindItem *remindItem = [strongSelf getRemindItemWithRequestIdentifier:remindid];
                    [strongSelf enterpreVC:remindItem];
                }];
            } else {
                RemindItem *remindItem = [self getRemindItemWithRequestIdentifier:remindid];
                [self enterpreVC:remindItem];
            }
            
        } else {
//            //播放声音
//            [self playRemindAudioWithSoundName:notification.soundName];
//            NSLog(@"notification.soundName: %@", notification.soundName);
            
            
//            NSString *str = [[notification.soundName componentsSeparatedByString:@"."] firstObject];
//            if (!(str.length == 2)) {
//                __weak __typeof__(self) weakSelf = self;
//                [[self topViewController] showAlertViewWithTitle:@"我的提醒" message:notification.alertBody buttonTitle:@"确定" clickBtn:^{
//                    __strong __typeof__(weakSelf) strongSelf = weakSelf;
//                    //关闭震动
//                    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
//                    //关闭声音
//                    [strongSelf.audioFilePlayer stop];
//                }];
//
//            }
        }
        
    }
    
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%s -- identifier: %@", __FUNCTION__, response.notification.request.identifier);
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSString *title = userInfo[@"aps"][@"alert"];
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {

        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"OS10及以上 后台转前台收到远程通知:%@", [self logDic:userInfo]);
        

        if ([title isEqualToString:@"亲， 您的提醒对方已知晓"]) {
            
        } else if ([title containsString:@"申请添加你"]) {

            WAApplyRemindViewController *vc = [[WAApplyRemindViewController alloc] initWithNibName:@"WAApplyRemindViewController" bundle:nil];
            [[[self topViewController] navigationController] pushViewController:vc animated:YES];
            
        } else {
            
            [self handleRemoteNotificationWithUserInfo:userInfo];
            
             if (userInfo[@"nativeData"]) {
             
                if (!self.database) {
                    self.databaseTableName = userInfo[@"nativeData"][@"remindUser"];
                    __weak __typeof__(self) weakSelf = self;
                    [self createDatabaseTableWithUserid:userInfo[@"nativeData"][@"remindUser"] andCompletion:^{
                        __strong __typeof__(weakSelf) strongSelf = weakSelf;
                        [strongSelf handleRemoteRemindToDB:userInfo[@"nativeData"]];
                    }];
                } else {
                    [self handleRemoteRemindToDB:userInfo[@"nativeData"]];
                }
             }
        }
  
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:userInfo：%@\n}",userInfo);

    }
    completionHandler();  // 系统要求执行这个方法
}
#endif

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS7及iOS9，前台收到通知:%@", [self logDic:userInfo]);
    NSString *title = userInfo[@"aps"][@"alert"];
    
    if ([title isEqualToString:@"亲， 您的提醒对方已知晓"]) {
        
    } else if ([title containsString:@"申请添加你"]) {

        __weak __typeof__(self) weakSelf = self;
        [self.window.rootViewController showAlertViewWithTitle:title message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
        } otherButtonTitles:@"确定" clickOtherBtn:^{
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            WAApplyRemindViewController *vc = [[WAApplyRemindViewController alloc] initWithNibName:@"WAApplyRemindViewController" bundle:nil];
            [[[strongSelf topViewController] navigationController] pushViewController:vc animated:YES];
        }];
        
    } else {
        
        if (!self.remoteEnterN) {
            self.remoteEnterN = 1;
            __weak __typeof__(self) weakSelf = self;
            [self.window.rootViewController showAlertViewWithTitle:title message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                strongSelf.remoteEnterN = 0;
            } otherButtonTitles:@"确定" clickOtherBtn:^{
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                strongSelf.remoteEnterN = 0;
                [strongSelf handleRemoteNotificationWithUserInfo:userInfo];
            }];
        }
        
        if (userInfo[@"nativeData"]) {
            
            if (!self.database) {
                self.databaseTableName = userInfo[@"nativeData"][@"remindUser"];
                __weak __typeof__(self) weakSelf = self;
                [self createDatabaseTableWithUserid:userInfo[@"nativeData"][@"remindUser"] andCompletion:^{
                    __strong __typeof__(weakSelf) strongSelf = weakSelf;
                    [strongSelf handleRemoteRemindToDB:userInfo[@"nativeData"]];
                }];
            } else {
                [self handleRemoteRemindToDB:userInfo[@"nativeData"]];
            }
            
        }
       
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%s", __FUNCTION__);
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS6及以下系统，收到通知:%@", [self logDic:userInfo]);
//    [rootViewController addNotificationCount];
}

-(void)setLocalNotificationWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s", __FUNCTION__);
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        // 这里添加处理代码
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
    }
    
    if(SYSTEM_VERSION >= 10){
        //iOS 10
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        __weak __typeof__(self) weakSelf = self;
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (!error) {
                        NSLog(@"request authorization succeeded!");
                    }
                }];
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                
            } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                [[strongSelf topViewController] showAlertViewWithTitle:@"\n需开启 \"通知\" 权限 \n\n"  message:nil buttonTitle:@"确定" clickBtn:^{
                }];
            }
            
        }];
        
    } else {
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } 
    
    [AlarmClockItem cancelAllExpireAlarmClock];

}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSLog(@"%s", __FUNCTION__);
    completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
    
    
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    
}

-(void)enterpreVC:(RemindItem *)remindItem {
    NSMutableDictionary *remoteDict = [[NSMutableDictionary alloc] initWithDictionary:[CoreArchive dicForKey:REMOTE_REMIND_ARR]];
    NSString *createUser = remoteDict[remindItem.remindid][@"createUser"];
    NSString *headUrl = remoteDict[remindItem.remindid][@"headUrl"];
    NSString *qinmiName = remoteDict[remindItem.remindid][@"qinmiName"];
    
    WAPreviewRecordViewController *vc = [[WAPreviewRecordViewController alloc] initWithNibName:@"WAPreviewRecordViewController" bundle:nil];
    vc.audioUrl = remindItem.audiourl;
    vc.recordedTime = [remoteDict[remindItem.remindid][@"remindSeconds"] integerValue];
    vc.headUrl = headUrl;
    vc.qinmiName = qinmiName;
    vc.recordedDate = remindItem.remindtime;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
    NSString *tomorrow = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
    NSString *aftertomorrow = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[remindItem.createtimestamp longLongValue]];
    NSString *remindDate = [dateFormatter stringFromDate:date];
    if ([remindDate isEqualToString:today]) {
        remindDate = @"今天";
    } else if([remindDate isEqualToString:tomorrow]) {
        remindDate = @"明天";
    } else if([remindDate isEqualToString:aftertomorrow]){
        remindDate = @"后天";
    }
    vc.recordedDay = remindDate;
    
//    vc.isFromRemindVC = YES;
    vc.createUser = createUser;
    
    [[[self topViewController] navigationController] pushViewController:vc animated:YES];
}

-(RemindItem *)getRemindItemWithRequestIdentifier:(NSString *)remindid {
    
    [self.database open];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindid == '%@'",self.databaseTableName,remindid];
    
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    FMResultSet * res = [self.database executeQuery:sql];
    NSMutableDictionary *remoteDict = [[NSMutableDictionary alloc] initWithDictionary:[CoreArchive dicForKey:REMOTE_REMIND_ARR]];
    while ([res next]) {
        
        RemindItem *item = [[RemindItem alloc] init];
        item.remindorigintype = [res stringForColumn:@"remindorigintype"];
        item.remindtype = [res stringForColumn:@"remindtype"];
        item.remindtime = [res stringForColumn:@"remindtime"];
        item.content = [res stringForColumn:@"content"];
        item.remindid = [res stringForColumn:@"remindid"];
        item.createtimestamp = [res stringForColumn:@"createtimestamp"];
        if ([item.remindorigintype isEqualToString:REMINDORIGINTYPE_REMOTE]) {
            item.headurl = [res stringForColumn:@"headurl"];
            item.audiourl = [res stringForColumn:@"audiourl"];
            NSString *qinmiName = remoteDict[item.remindid][@"qinmiName"];
            item.content = [NSString stringWithFormat:@"%@的提醒",qinmiName];
        }
        [dataArr addObject:item];
    }
    
    return dataArr[0];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    NSLog(@"%s  %@", __FUNCTION__,  [[UIApplication sharedApplication] scheduledLocalNotifications]);
    
    NSString *requestIdentifier = notification.userInfo[@"requestIdentifier"];
    if ([requestIdentifier hasPrefix:@"remote"]) {
        
        NSString *remindid = [requestIdentifier componentsSeparatedByString:@"_"][1];
        if (!self.database) {
            NSString *userID = [CoreArchive dicForKey:USERINFO][USERID];
            __weak __typeof__(self) weakSelf = self;
            [self createDatabaseTableWithUserid:userID andCompletion:^{
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                RemindItem *remindItem = [strongSelf getRemindItemWithRequestIdentifier:remindid];
                [strongSelf enterpreVC:remindItem];
            }];
        } else {
            RemindItem *remindItem = [self getRemindItemWithRequestIdentifier:remindid];
            [self enterpreVC:remindItem];
        }
    
    } else {
        //播放声音
        [self playRemindAudioWithSoundName:notification.soundName];
        NSLog(@"notification.soundName: %@", notification.soundName);
        
        
        NSString *str = [[notification.soundName componentsSeparatedByString:@"."] firstObject];
        if (!(str.length == 2)) {
            __weak __typeof__(self) weakSelf = self;
            [[self topViewController] showAlertViewWithTitle:@"我的提醒" message:notification.alertBody buttonTitle:@"确定" clickBtn:^{
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                //关闭震动
                AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
                //关闭声音
                [strongSelf.audioFilePlayer stop];
            }];
            
        }
    }

}

#pragma -mark 播放本地音频
-(void)playRemindAudioWithSoundName:(NSString *)soundName {
    
    if (self.audioFilePlayer.isPlaying) {
//        [MBProgressHUD showSuccess:@"正在播放"];
        return;
    }

    NSArray *audioNames = [soundName componentsSeparatedByString:@"."];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[[NSBundle mainBundle] pathForResource:audioNames[0] ofType:audioNames[1]]];
    
    NSError *error=nil;
    self.audioFilePlayer=[[AVAudioPlayer alloc] initWithData:data error:&error];
    self.audioFilePlayer.numberOfLoops=0;
    self.audioFilePlayer.volume = 1;
    [self.audioFilePlayer prepareToPlay];
    NSString *str = [[soundName componentsSeparatedByString:@"."] firstObject];
    if (!(str.length == 2)) {
         self.audioFilePlayer.delegate = self;
    }
   
    if (error) {
        NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
        return ;
    }
    
    [self.audioFilePlayer play];
    
}

//播放结束后调用这个函数
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
     NSLog(@"%s", __func__);
    //开启震动
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemAudioCallback, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //关闭震动
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    });
    
}

void systemAudioCallback()
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSLog(@"%s", __func__);
}

/* AVAudioPlayer INTERRUPTION NOTIFICATIONS ARE DEPRECATED - Use AVAudioSession instead. */

/* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player  {
    NSLog(@"%s", __func__);
}

/* audioPlayerEndInterruption:withOptions: is called when the audio session interruption has ended and this player had been interrupted while playing. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags  {
    NSLog(@"%s", __func__);
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags  {
    NSLog(@"%s", __func__);
}

/* audioPlayerEndInterruption: is called when the preferred method, audioPlayerEndInterruption:withFlags:, is not implemented. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    NSLog(@"%s", __func__);
}


-(void)setUMShare {
    
    /* 打开调试日志 */
    [[UMSocialManager defaultManager] openLog:NO];
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:USHARE_APPKEY];
    [self configUSharePlatforms];
    [self confitUShareSettings];
    
}

-(void)iFlySet {
    //科大讯飞
    //设置sdk的log等级，log保存在下面设置的工作路径中
    [IFlySetting setLogFile:LVL_ALL];
    //打开输出在console的log开关
    [IFlySetting showLogcat:NO];
    //设置sdk的工作路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",APPID_VALUE];
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
}

-(void)configUSharePlatforms {
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx099dba771f998057" appSecret:@"01a2b074dec803a2128e429c507aa95c" redirectURL:@"http://mobile.umeng.com/social"];
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1106320575"/*设置QQ平台的appID*/  appSecret:@"LP9RurOicFzMEkmr" redirectURL:@"http://mobile.umeng.com/social"];
}

-(void)confitUShareSettings {
    
}

- (void)netMonitor{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status == AFNetworkReachabilityStatusNotReachable){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"networkAnomaly" object:nil];
            
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络连接中断，请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alertView show];
            
            [[self topViewController] showAlertViewWithTitle:@"提示" message:@"网络连接中断，请检查网络" buttonTitle:@"确定" clickBtn:^{
                
            }];
            
        }
    }];
}









- (UIViewController*)topViewController
{
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)networkDidSetup:(NSNotification *)notification {
    NSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {
    NSLog(@"未连接");
}

- (void)networkDidRegister:(NSNotification *)notification {
    NSLog(@"%@", [notification userInfo]);
    NSLog(@"已注册");
}

//-(void)deleteNotification {
//
//    if(SYSTEM_VERSION >= 10){
//        JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
//        identifier.identifiers = nil;
//        identifier.delivered = YES;  //iOS10以上有效，等于YES则查找所有在通知中心显示的，等于NO则为查找所有待推送的；iOS10以下无效
//        [JPUSHService removeNotification:identifier];
//    } else {
//
//    }
//}



- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extra = [userInfo valueForKey:@"extras"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSString *currentContent = [NSString
                                stringWithFormat:
                                @"收到自定义消息:%@\ntitle:%@\ncontent:%@\nextra:%@\n",
                                [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                               dateStyle:NSDateFormatterNoStyle
                                                               timeStyle:NSDateFormatterMediumStyle],
                                title, content, [self logDic:extra]];
    NSLog(@"%s %@", __FUNCTION__,currentContent);
    
}

- (void)serviceError:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *error = [userInfo valueForKey:@"error"];
    NSLog(@"%@", error);
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:nil error:nil];
    return str;
}


-(BOOL)adjustRemindRepeatWithRemindType:(NSString *)remindType andRemindTime:(NSString *)remindTime {
    
    NSInteger remindTimeHash = [remindTime hash];
    
    if ([self.database open]) {
        
        NSInteger nowSp = [[NSDate date] timeIntervalSince1970];
        NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindtype != 'onlyonce' or createtimestamp > %ld",self.databaseTableName,nowSp];
        NSLog(@"sql = %@",sql);
        
        FMResultSet * res = [self.database executeQuery:sql];
        
        NSMutableArray *dataArrOnlyOnce = [@[] mutableCopy];
        NSMutableArray *dataArrEveryDay = [@[] mutableCopy];
        NSMutableArray *dataArrWeekend = [@[] mutableCopy];
        NSMutableArray *dataArrWorkDay = [@[] mutableCopy];
        
        while ([res next]) {
            RemindItem *item = [[RemindItem alloc] init];
            item.remindtype = [res stringForColumn:@"remindtype"];
            item.remindtime = [res stringForColumn:@"remindtime"];
            item.content = [res stringForColumn:@"content"];
            item.createtimestamp = [res stringForColumn:@"createtimestamp"];
            
            if ([item.remindtype isEqualToString:REMINDTYPE_ONLYONCE]) {
                [dataArrOnlyOnce addObject:item.remindtime];
            } else if ([item.remindtype isEqualToString:REMINDTYPE_EVERYDAY]) {
                [dataArrEveryDay addObject:item.remindtime];
            } else if ([item.remindtype isEqualToString:REMINDTYPE_WEEKEND]) {
                [dataArrWeekend addObject:item.remindtime];
            } else if ([item.remindtype isEqualToString:REMINDTYPE_WORKDAY]) {
                [dataArrWorkDay addObject:item.remindtime];
            }
        }
        
        NSString *weekDay = [Utility getDayWeek];
        BOOL isWeekend =
        [weekDay isEqualToString:SATURDAY] ||
        [weekDay isEqualToString:SUNDAY];
        
        //比较是否有重复
        if ([remindType isEqualToString:REMINDTYPE_ONLYONCE]) {
            
            for (NSString *remindtimeStr in dataArrOnlyOnce) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            if (isWeekend) {
                
                for (NSString *remindtimeStr in dataArrWeekend) {
                    if ([remindtimeStr hash] == remindTimeHash) {
                        return NO;
                    }
                }
                
            } else {
                
                for (NSString *remindtimeStr in dataArrWorkDay) {
                    if ([remindtimeStr hash] == remindTimeHash) {
                        return NO;
                    }
                }
                
            }
            
            
            
        } else if ([remindType isEqualToString:REMINDTYPE_EVERYDAY]) {
            
            for (NSString *remindtimeStr in dataArrOnlyOnce) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            for (NSString *remindtimeStr in dataArrWeekend) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            for (NSString *remindtimeStr in dataArrWorkDay) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            
        } else if ([remindType isEqualToString:REMINDTYPE_WEEKEND]) {
            
            for (NSString *remindtimeStr in dataArrWeekend) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            if (isWeekend) {
                for (NSString *remindtimeStr in dataArrOnlyOnce) {
                    if ([remindtimeStr hash] == remindTimeHash) {
                        return NO;
                    }
                }
            }
            
        } else if ([remindType isEqualToString:REMINDTYPE_WORKDAY]) {
            
            for (NSString *remindtimeStr in dataArrWorkDay) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            if (!isWeekend) {
                for (NSString *remindtimeStr in dataArrOnlyOnce) {
                    if ([remindtimeStr hash] == remindTimeHash) {
                        return NO;
                    }
                }
            }
            
        }
        
        
        for (NSString *remindtimeStr in dataArrEveryDay) {
            if ([remindtimeStr hash] == remindTimeHash) {
                return NO;
            }
        }
        
        return YES;
    }
    
    return YES;
    
}

-(void)checkAppVesion {
    
    NSDictionary *model = @{};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P0001" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        NSString *code = data[@"code"];
//        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            if (![data[@"body"] isKindOfClass:[NSNull class]]) {
                NSDictionary *bodyDict = [data[@"body"] transforeNullValueToEmptyStringInSimpleDictionary];
                NSString *versionDesc = bodyDict[@"versionDesc"];
                NSString *updateContent = bodyDict[@"updateContent"];
                NSString *downloadUrl = bodyDict[@"downloadUrl"];
                NSLog(@"%@", data);
                [CoreArchive setStr:versionDesc key:APP_VERSION_DESC];
                
                if ([bodyDict[@"versionForce"] isEqualToString:@"0"]) {
                    
                    [[strongSelf topViewController] showAlertViewWithTitle:versionDesc message:updateContent buttonTitle:@"立即更新" clickBtn:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];
                    }];
                    
                } else {
                    [[strongSelf topViewController] showAlertViewWithTitle:versionDesc message:updateContent cancelButtonTitle:@"取消" clickCancelBtn:^{
                    } otherButtonTitles:@"立即更新" clickOtherBtn:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];
                    }];
                }
            }
            
        }
        
    } fail:^(NSError *error) {
        
        
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self checkAppVesion];
        //移除通知栏所有推送
    JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
    identifier.identifiers = nil;
    identifier.delivered = YES;  //iOS10以上有效，等于YES则查找所有在通知中心显示的，等于NO则为查找所有待推送的；iOS10以下无效
    identifier.findCompletionHandler = ^(NSArray *results) {
        NSLog(@"返回结果为：%@", results); // iOS10以下返回UILocalNotification对象数组，iOS10以上根据delivered传入值返回UNNotification或UNNotificationRequest对象数组
    };
    [JPUSHService findNotification:identifier];
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
