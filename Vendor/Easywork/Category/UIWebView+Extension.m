

#import "UIWebView+Extension.h"

@implementation UIWebView (Extension)

- (NSString *)ew_title
{
     return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (NSURL *)ew_url
{
    
    NSString *urlString = [self stringByEvaluatingJavaScriptFromString:@"location.href"];
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }
    return nil;
}


- (NSString *)ew_html
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
}

- (void)ew_clean
{
    [self loadHTMLString:@"" baseURL:nil];
    [self stopLoading];
    self.delegate = nil;
    [self removeFromSuperview];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];

}

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(CGRect)frame
{    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WEBVIEWALERT" object:nil userInfo:@{@"msg":message}];
}


@end
