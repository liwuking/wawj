//
//  WANetViewController.m
//  wawj
//
//  Created by ruiyou on 2017/7/7.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WANetViewController.h"

#import "WAInternetViewController.h"
#import <AFNetworking.h>
@interface WANetViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *mobileFlowImg;
@property (weak, nonatomic) IBOutlet UIImageView *WIFIFlowImg;
@property(nonatomic,assign)AFNetworkReachabilityStatus status;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *costantX;

@end

@implementation WANetViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}


-(void)initViews {
    
    self.title = @"网络设置";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    __weak __typeof(&*self)weakSelf =self;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        __strong typeof(weakSelf)strongSelf=weakSelf;
        
        strongSelf.status = status;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                NSLog(@"noknown");
                strongSelf.mobileFlowImg.image = [UIImage imageNamed:@"Umnselected"];
                strongSelf.WIFIFlowImg.image = [UIImage imageNamed:@"WIFIUnselect"];
                
            }
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
            {
                NSLog(@"unconnect");
                strongSelf.mobileFlowImg.image = [UIImage imageNamed:@"Umnselected"];
                strongSelf.WIFIFlowImg.image = [UIImage imageNamed:@"WIFIUnselect"];
                
            }
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                NSLog(@"4G");
                strongSelf.mobileFlowImg.image = [UIImage imageNamed:@"mselected"];
                strongSelf.WIFIFlowImg.image = [UIImage imageNamed:@"WIFIUnselect"];
                strongSelf.costantX.constant = 70;
                
            }
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                NSLog(@"wifi");
                strongSelf.mobileFlowImg.image = [UIImage imageNamed:@"Umnselected"];
                strongSelf.WIFIFlowImg.image = [UIImage imageNamed:@"WIFSelected"];
                strongSelf.costantX.constant = SCREEN_WIDTH-130;
                
            }
                break;
            default:
                break;
        }
    }];
    [manager startMonitoring];
    
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViews];
    
}
- (IBAction)clickContinueNet:(UIButton *)sender {
    
    if (self.status == AFNetworkReachabilityStatusUnknown || self.status == AFNetworkReachabilityStatusNotReachable) {
        
        [self showAlertViewWithTitle:@"提示" message:@"当前无网络" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
        return;
        
    } 
    
    [self performSegueWithIdentifier:@"WAInternetViewController" sender:nil];
    
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
