

#import <UIKit/UIKit.h>

@interface UIWebView (Extension)

- (NSString *)ew_title;
- (NSURL *)ew_url;
- (NSString *)ew_html;
- (void)ew_clean;

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(CGRect)frame;

@end
