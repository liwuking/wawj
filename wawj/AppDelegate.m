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

#import <UserNotifications/UserNotifications.h>

#define USHARE_APPKEY  @"59ae0a1782b635489c000dab"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

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
    [self setLocalNotification];
    
    //获取通讯录授权
//    [self requestAuthorizationAddressBook];
    //网络监控
    [self netMonitor];
    //设置友盟
    [self setUMShare];
    
    return YES;
    
}

-(void)setLocalNotification {
    
    //iOS 10
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];//UNAuthorizationOptionBadge |
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
            [[strongSelf topViewController] showAlertViewWithTitle:@"提醒" message:@"您还没打开推送通知权限" buttonTitle:@"确定" clickBtn:^{
            }];
        }
        
    }];
    
    [AlarmClockItem cancelAllExpireAlarmClock];

}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
    
    //播放声音
    AudioServicesPlaySystemSound(1007);
    //开启震动
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemAudioCallback, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    NSString *body = notification.request.content.body ;
    [[self topViewController] showAlertViewWithTitle:@"提醒" message:body buttonTitle:@"确定" clickBtn:^{
        //关闭震动
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    }];
    
    //    //删除已过期的闹钟
    //    [AlarmClockItem cancelAllExpireAlarmClock];
    
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
