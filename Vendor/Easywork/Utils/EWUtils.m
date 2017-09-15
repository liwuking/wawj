

#import "EWUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import <AudioToolbox/AudioServices.h>
#import "EWLog.h"

@implementation EWUtils

#pragma mark - bundle version
//bundle version
+ (NSString *)ew_bundleVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
}

+ (void)ew_jumpToAppleStore
{
    NSString *iTunesLink = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8",@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

#pragma mark - file path
//file path
+ (NSString *)ew_documentsPath
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

+ (NSString *)ew_cachePath
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"Caches"];
}

+ (NSString*)ew_bundleFile:(NSString*)file
{
    return [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
}

+ (NSString*)ew_documentFile:(NSString*)file
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:file];
}

+ (BOOL)ew_fileExist:(NSString *)fileName
{
    NSString *path = [[self ew_documentsPath] stringByAppendingPathComponent:fileName];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

#pragma mark - play sound
+ (void)ew_playSound:(NSString *)path
{
    if (path) {
        NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        SystemSoundID aSoundID;
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)aFileURL, &aSoundID);
        if (error == kAudioServicesNoError) {
            AudioServicesPlaySystemSound(aSoundID);
        }
    }
}

+ (void)ew_playSoundWithVibrate:(NSString *)path
{
    if (path) {
        NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        SystemSoundID aSoundID;
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)aFileURL, &aSoundID);
        if (error == kAudioServicesNoError) {
            AudioServicesPlaySystemSound(aSoundID);
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

+ (void)ew_playVibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


#pragma mark - notification
+ (void)uninstallNotification:(id)data
{
    [[NSNotificationCenter defaultCenter] removeObserver:data];
}

#pragma mark - UserDefault
+ (void)setObject:(id)data key:(NSString *)key
{
    if (data) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        DBLog(@"%@值为空的，不做存储~",key);
    }
}

+ (id)getObjectForKey:(NSString *)key
{
    return  [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)deleteObject:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - status bar
+ (void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

+ (void)hideStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

/** Cookies */
+ (void)saveCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    [self setObject:cookiesData key:@"Cookies"];
}


+ (void)loadCookies
{
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [self getObjectForKey:@"Cookies"]];

    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookies){
        //DBLog(@"CCCC=%@",cookie);
        [cookieStorage setCookie: cookie];
    }
    
}


+ (UIImage *)scaleToSize:(UIImage *)img
{
    CGSize size = CGSizeMake(img.size.width/2, img.size.height/2);
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


#pragma mark - alert
//alert c function
void AlertWithError(NSError *error)
{
    NSString *message = [NSString stringWithFormat:@"Error! %@ %@",
                         [error localizedDescription],
                         [error localizedFailureReason]];
    
    AlertWithMessage (message);
}


void AlertWithMessage(NSString *message)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    [alert show];
}


void AlertWithMessageAndDelegate(NSString *message, id delegate)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:delegate 
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles: @"确定", nil];
    [alert show];
}


+ (void)ew_callNumber:(NSString *)phone
{
    NSString *telUrl = [NSString stringWithFormat:@"telprompt:%@",phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telUrl]];
}



@end
