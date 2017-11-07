//
//  WAHelpDetailViewController.m
//  wawj
//
//  Created by ruiyou on 2017/11/6.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAHelpDetailViewController.h"
#import <WebKit/WebKit.h>

@interface WAHelpDetailViewController ()<WKNavigationDelegate>
@property (strong, nonatomic)WKWebView   *webView;

@end

@implementation WAHelpDetailViewController

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = self.helpItem.title;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;

    // 创建配置
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 创建UserContentController（提供JavaScript向webView发送消息的方法）
    WKUserContentController* userContent = [[WKUserContentController alloc] init];
    // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
    //    [userContent addScriptMessageHandler:self name:@"NativeMethod"];
    // 将UserConttentController设置到配置文件
    config.userContentController = userContent;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-44) configuration:config];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
   
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.helpItem.url]];
    [self.webView loadRequest:request];
    
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
