

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EWUtils : NSObject

/** Bundle version */
+ (NSString *)ew_bundleVersion;
+ (void)ew_jumpToAppleStore;

/** File path */
+ (NSString *)ew_documentsPath;
+ (NSString *)ew_cachePath;
+ (NSString *)ew_bundleFile:(NSString*)file;
+ (NSString *)ew_documentFile:(NSString*)file;

/**File */
+ (BOOL)ew_fileExist:(NSString *)fileName;  //document file

/** Play sound*/
+ (void)ew_playSound:(NSString *)path;
+ (void)ew_playSoundWithVibrate:(NSString *)path;
+ (void)ew_playVibrate;

/** Notification */
+ (void)uninstallNotification:(id)data;

/** UserDefault */
+ (void)setObject:(id)data key:(NSString *)key;
+ (id)getObjectForKey:(NSString *)key;
+ (void)deleteObject:(NSString *)key;

/** Status bar */
+ (void)showStatusBar;
+ (void)hideStatusBar;

/** Cookies */
+ (void)saveCookies;
+ (void)loadCookies;

/** uiimage */
+ (UIImage *)scaleToSize:(UIImage *)img;

/** Alert message */
void AlertWithError(NSError *error);
void AlertWithMessage(NSString *message);
void AlertWithMessageAndDelegate(NSString *message, id delegate);


/**utils*/
+ (void)ew_callNumber:(NSString *)phone;

@end
