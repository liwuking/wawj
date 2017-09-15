//
//  WABindIphoneViewController.m
//  wawj
//
//  Created by ruiyou on 2017/7/7.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WABindIphoneViewController.h"

#import <MBProgressHUD.h>
#import "WAOldInterfaceViewController.h"
#import "WANewInterfaceViewController.h"

@interface WABindIphoneViewController ()

    @property (weak, nonatomic) IBOutlet UITextField *iphoneTextField;
    @property (weak, nonatomic) IBOutlet UITextField *msgTextField;
    @property (weak, nonatomic) IBOutlet UILabel *timeLab;
    @property (weak, nonatomic) IBOutlet UILabel *msgStatusLab;

@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, assign)NSInteger fixedTime;

@end

@implementation WABindIphoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [self initView];
    
    //表明不是第一次登录了
    [CoreArchive setBool:NO key:FIRST_ENTER];
    
   
    //[self performSegueWithIdentifier:@"WAOldInterfaceViewController" sender:nil];
}

-(void)initView {
    
    self.msgStatusLab.hidden = YES;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
}
- (IBAction)clickSendVericode:(UITapGestureRecognizer *)sender {
    
    NSDictionary *model = @{@"phone_no": self.iphoneTextField.text, @"message_type": @"login"};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1002" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        [MBProgressHUD hideHUD];
        
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            if ([CoreArchive strForKey:INTERFACE_NEW]) {
                
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                WANewInterfaceViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WANewInterfaceViewController"];
                 [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                WAOldInterfaceViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WAOldInterfaceViewController"];
                [self.navigationController pushViewController:vc animated:YES];
            }

            
        } else {
            
            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
                
            }];
            
        }
        
    } fail:^(NSError *error) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
    }];


}

-(void)startTime {
    
    self.fixedTime = 60;
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerReponse) userInfo:nil repeats:YES];
    }
    
}

-(void)timerReponse {
    
    if (self.fixedTime > 0) {
        self.timeLab.text = [NSString stringWithFormat:@"%ldS", --self.fixedTime];
    } else {
        self.msgStatusLab.text = @"获取验证码";
        [self.timer invalidate];
        self.timer = nil;
    }
    
}

-(void)backAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)clickNext:(id)sender {
    
    //手机号绑定（即登录注册）
    NSDictionary *model  = @{@"message_type":@"1",@"message_code":@"111111",@"phone_no":self.iphoneTextField.text};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1002" andModel:model];
    
    
    [MBProgressHUD showMessage:nil];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        [MBProgressHUD hideHUD];
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        if ([data[@"code"] isEqualToString:@"0000"]) {
 
            NSDictionary *userInfo = data[@"body"][@"userInfo"];
            [CoreArchive setDic:[userInfo transforeNullValueInSimpleDictionary] key:USERINFO];
            [CoreArchive setStr:userInfo[@"userId"] key:USERID];
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            WAOldInterfaceViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WAOldInterfaceViewController"];
            [strongSelf.navigationController pushViewController:vc animated:YES];
            
        } else {
            
            [strongSelf showAlertViewWithTitle:@"提示" message:data[@"desc"] buttonTitle:@"确定" clickBtn:^{
                
            }];
            
        }
        
    } fail:^(NSError *error) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
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
