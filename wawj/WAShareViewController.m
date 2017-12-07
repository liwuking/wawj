//
//  WAShareViewController.m
//  wawj
//
//  Created by ruiyou on 2017/8/29.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAShareViewController.h"
#import <UMSocialCore/UMSocialCore.h>

@interface WAShareViewController ()
@property (weak, nonatomic) IBOutlet UILabel *twoLab;
@property (weak, nonatomic) IBOutlet UILabel *oneLab;
@property (weak, nonatomic) IBOutlet UILabel *threeLab;

@end

@implementation WAShareViewController

-(void)initViews {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.title = @"分享邀请";

    if (SCREEN_HEIGHT == 480) {
        self.oneLab.hidden = YES;
        self.twoLab.hidden = YES;
        self.threeLab.hidden = YES;
    }
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self initViews];
}


- (IBAction)clickShareWXFriend:(UITapGestureRecognizer *)sender {
    
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatSession];
    
}
- (IBAction)clickWXFriends:(UITapGestureRecognizer *)sender {
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatTimeLine];
}
- (IBAction)clickQQFriend:(UITapGestureRecognizer *)sender {
    [self shareWebPageToPlatformType:UMSocialPlatformType_QQ];
}
- (IBAction)clickQZone:(UITapGestureRecognizer *)sender {
    [self shareWebPageToPlatformType:UMSocialPlatformType_Qzone];
}


- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"老年桌面，爸妈超喜欢" descr:@"智能手机秒变老人机，开启爸妈网络新生活，还有家庭相册和语音提醒功能~" thumImage:[UIImage imageNamed:@"logo"]];
    //设置网页地址
    shareObject.webpageUrl = @"http://www.wawjapp.com/download.html";//@"https://itunes.apple.com/us/app/我爱我家app/id1209731951?l=zh&ls=1&mt=8";
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
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
