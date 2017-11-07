//
//  WAInternetViewController.m
//  wawj
//
//  Created by ruiyou on 2017/7/7.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAInternetViewController.h"
#import <WebKit/WebKit.h>

@interface WAInternetViewController ()<WKNavigationDelegate>

@property (strong, nonatomic)WKWebView   *webView;

@end

@implementation WAInternetViewController

- (BOOL)prefersStatusBarHidden{
    return YES;
}





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 创建配置
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 创建UserContentController（提供JavaScript向webView发送消息的方法）
    WKUserContentController* userContent = [[WKUserContentController alloc] init];
    // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
//    [userContent addScriptMessageHandler:self name:@"NativeMethod"];
    // 将UserConttentController设置到配置文件
    config.userContentController = userContent;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-44) configuration:config];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://114.wawjapp.com/index.html"]];
    self.webView.navigationDelegate = self;
    
    [self.webView loadRequest:request];
    
    [self.view addSubview:self.webView];
    
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [MBProgressHUD showMessage:nil];
    
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    [MBProgressHUD hideHUD];
    NSLog(@"%s", __FUNCTION__);
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    [MBProgressHUD hideHUD];
    
    [MBProgressHUD showError:[error localizedDescription]];
    
    NSLog(@"%s", __FUNCTION__);
    
}

//- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
//    // 判断是否是调用原生的
//    if ([@"NativeMethod" isEqualToString:message.name]) {
//        // 判断message的内容，然后做相应的操作
//        if ([@"close" isEqualToString:message.body]) {
//            
//    　　}
//    }
//}

- (IBAction)clickGoBack:(UIButton *)sender {
    
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
    
}

- (IBAction)clickBack:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
