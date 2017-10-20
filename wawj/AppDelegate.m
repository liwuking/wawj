//
//  AppDelegate.m
//  wawj
//
//  Created by ruiyou on 2017/7/5.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "AppDelegate.h"
#import "iflyMSC/IFlyMSC.h"
#import <AddressBook/AddressBook.h>
#import "AlarmClockItem.h"
#import "UIAlertView+Extension.h"
#import "CoreArchive.h"
#import <UMSocialCore/UMSocialCore.h>

#import "WAOldInterfaceViewController.h"
#import "WANewInterfaceViewController.h"
#import "WABindIphoneViewController.h"
#import "WAGuideViewController.h"

#import "EditRemindViewController.h"
#import "WARemindFamilyViewController.h"

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>


#define USHARE_APPKEY  @"59ae0a1782b635489c000dab"



@interface AppDelegate ()<UNUserNotificationCenterDelegate,JPUSHRegisterDelegate>

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [CoreArchive setBool:YES key:FIRST_ENTER];
    if ([CoreArchive dicForKey:USERINFO]) {
        
        if ([CoreArchive boolForKey:INTERFACE_NEW]) {
            
            WANewInterfaceViewController *vc = [[WANewInterfaceViewController alloc] initWithNibName:@"WANewInterfaceViewController" bundle:nil];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            self.window.rootViewController = nav;
            
        } else {
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            WAOldInterfaceViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WAOldInterfaceViewController"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            self.window.rootViewController = nav;
            
//            EditRemindViewController *vc  = [[EditRemindViewController alloc] initWithNibName:@"EditRemindViewController" bundle:nil];
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//            self.window.rootViewController = nav;
//            WARemindFamilyViewController *vc  = [[WARemindFamilyViewController alloc] initWithNibName:@"WARemindFamilyViewController" bundle:nil];
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//            self.window.rootViewController = nav;

        }
        
        
    } else {
        
        if ([CoreArchive boolForKey:FIRST_ENTER]) {
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            WAGuideViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WAGuideViewController"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            self.window.rootViewController = nav;
            
        } else {
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            WABindIphoneViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WABindIphoneViewController"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            self.window.rootViewController = nav;
        }
        
    }
    
    [self.window makeKeyAndVisible];
    
    
    //设置科大讯飞
    [self iFlySet];
    //设置本地推送
    [self setLocalNotificationWithOptions:launchOptions];
    [self setJPush:launchOptions];//设置极光推送
 

    
    //获取通讯录授权
//    [self requestAuthorizationAddressBook];
    //网络监控
    [self netMonitor];
    //设置友盟
    [self setUMShare];
    

    return YES;
    
}


-(void)setJPush:(NSDictionary *)launchOptions {
    //Required
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

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
//    rootViewController.deviceTokenValueLabel.text =
//    [NSString stringWithFormat:@"%@", deviceToken];
//    rootViewController.deviceTokenValueLabel.textColor =
//    [UIColor colorWithRed:0.0 / 255
//                    green:122.0 / 255
//                     blue:255.0 / 255
//                    alpha:1];
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
#pragma mark- JPUSHRegisterDelegate
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
//        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
//
//        [rootViewController addNotificationCount];
//
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
//        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
//        [rootViewController addNotificationCount];
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
//    NSLog(@"iOS7及以上系统，收到通知:%@", [self logDic:userInfo]);
//
//    if ([[UIDevice currentDevice].systemVersion floatValue]<10.0 || application.applicationState>0) {
//        [rootViewController addNotificationCount];
//    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
//    NSLog(@"iOS6及以下系统，收到通知:%@", [self logDic:userInfo]);
//    [rootViewController addNotificationCount];
}




-(void)setLocalNotificationWithOptions:(NSDictionary *)launchOptions {

    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        // 这里添加处理代码
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
    }
    
    
    if(SYSTEM_VERSION >= 10){
        //iOS 10
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];//UNAuthorizationOptionBadge |
        __weak __typeof__(self) weakSelf = self;
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (!error) {
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                        NSLog(@"request authorization succeeded!");
                    }
                }];
                
            } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                [[strongSelf topViewController] showAlertViewWithTitle:@"提醒" message:@"您还没打开推送通知权限" buttonTitle:@"确定" clickBtn:^{
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
    
    completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
    
//    //播放声音
//    AudioServicesPlaySystemSound(1007);
//    //开启震动
//    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemAudioCallback, NULL);
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//
//    NSString *body = notification.request.content.body ;
//    [[self topViewController] showAlertViewWithTitle:@"提醒" message:body buttonTitle:@"确定" clickBtn:^{
//        //关闭震动
//        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
//    }];
//
//    //    //删除已过期的闹钟
//    //    [AlarmClockItem cancelAllExpireAlarmClock];
    
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    
    //点击后台进入
    if (application.applicationState == UIApplicationStateInactive) {
        
        [[self topViewController] showAlertViewWithTitle:@"提醒" message:notification.alertBody buttonTitle:@"确定" clickBtn:^{
            
        }];
        
        NSLog(@"UIApplicationStateInactive");
    }else{
        
        //播放声音
        AudioServicesPlaySystemSound(1007);
        //开启震动
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemAudioCallback, NULL);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        [[self topViewController] showAlertViewWithTitle:@"提醒" message:notification.alertBody buttonTitle:@"确定" clickBtn:^{
            //关闭震动
            AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
        }];
        
    }
    //这里，你就可以通过notification的useinfo，干一些你想做的事情了
    NSLog(@"info = %@",notification.userInfo);
    //删除已过期的闹钟
    [AlarmClockItem cancelAllExpireAlarmClock];
    
}

void systemAudioCallback()
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(void)setUMShare {
    
    /* 打开调试日志 */
    [[UMSocialManager defaultManager] openLog:YES];
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



//- (void)requestAuthorizationAddressBook {
//    // 判断是否授权
//    ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
//    if (authorizationStatus == kABAuthorizationStatusNotDetermined) {
//        // 请求授权
//        ABAddressBookRef addressBookRef = ABAddressBookCreate();
//        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
//            if (granted) { // 授权成功
//                NSLog(@"授权成功！");
//            } else {  // 授权失败
//                NSLog(@"授权失败！");
//            }
//        });
//    }
//}






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

- (void)networkDidLogin:(NSNotification *)notification {
    NSLog(@"已登录");
}

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
    NSLog(@"%@", currentContent);
    
//    [_messageContents insertObject:currentContent atIndex:0];
//
//    NSString *allContent = [NSString
//                            stringWithFormat:@"%@收到消息:\n%@\nextra:%@",
//                            [NSDateFormatter
//                             localizedStringFromDate:[NSDate date]
//                             dateStyle:NSDateFormatterNoStyle
//                             timeStyle:NSDateFormatterMediumStyle],
//                            [_messageContents componentsJoinedByString:nil],
//                            [self logDic:extra]];
//
//    _messageContentView.text = allContent;
//    _messageCount++;
//    [self reloadMessageCountLabel];
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

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
