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
#import "CloseFamilyItem.h"
#import <objc/runtime.h>
#import "WZLSerializeKit.h"
#import <CoreLocation/CoreLocation.h>
#import <JPUSHService.h>
@interface WABindIphoneViewController ()<CLLocationManagerDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *getVeryCodeGes;
@property (nonatomic, strong) CLLocationManager* locationManager;

    @property (weak, nonatomic) IBOutlet UITextField *iphoneTextField;
    @property (weak, nonatomic) IBOutlet UITextField *msgTextField;
    @property (weak, nonatomic) IBOutlet UILabel *timeLab;
    @property (weak, nonatomic) IBOutlet UILabel *msgStatusLab;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, assign)NSInteger fixedTime;
@property(nonatomic, strong)NSString *locationString;

@end

@implementation WABindIphoneViewController
{
    CLGeocoder *_geocoder;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [self initView];
    
    //表明不是第一次登录了
    [CoreArchive setBool:NO key:FIRST_ENTER];
    
    self.locationString = @" ";
    [self startLocation];
   
    //[self performSegueWithIdentifier:@"WAOldInterfaceViewController" sender:nil];
}

-(void)initView {
    
    self.msgStatusLab.hidden = YES;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSLog(@"%@-- %@", self.iphoneTextField.text,self.msgTextField.text);
    if (self.iphoneTextField.text.length > 1 && self.msgTextField.text.length > 1) {
        self.nextBtn.enabled = YES;
        self.nextBtn.backgroundColor = HEX_COLOR(0x219CE0);
       
    }else {
        self.nextBtn.enabled = NO;
        self.nextBtn.backgroundColor = HEX_COLOR(0xd1d1d8);
    }
    
    return YES;
}

- (IBAction)clickSendVericode:(UITapGestureRecognizer *)sender {
    
    
    self.getVeryCodeGes.enabled = NO;
    
    [MBProgressHUD showMessage:nil];
    NSDictionary *model = @{@"phone_no": self.iphoneTextField.text, @"message_type": @"SMS_104815008"};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P9010" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        [MBProgressHUD hideHUD];
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            [MBProgressHUD showSuccess:@"已发送成功"];
            [strongSelf startTime];

            
        } else {
            strongSelf.getVeryCodeGes.enabled = YES;
            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
                
            }];
            
        }
        
    } fail:^(NSError *error) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        strongSelf.getVeryCodeGes.enabled = YES;
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
//        self.getVeryCodeGes.enabled = NO;
        self.timeLab.text = [NSString stringWithFormat:@"%ldS", --self.fixedTime];
        self.timeLab.textColor = [UIColor grayColor];
    } else {
        self.getVeryCodeGes.enabled = YES;
        self.timeLab.text = @"获取验证码";
        self.timeLab.textColor = HEX_COLOR(0x219ce0);
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

- (void)startLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    /** 由于IOS8中定位的授权机制改变 需要进行手动授权
     * 获取授权认证，两个方法：
     * [self.locationManager requestWhenInUseAuthorization];
     * [self.locationManager requestAlwaysAuthorization];
     */
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        NSLog(@"requestWhenInUseAuthorization");
        [self.locationManager requestWhenInUseAuthorization];
        //        [self.locationManager requestAlwaysAuthorization];
    }
    
    //开始定位，不断调用其代理方法
    //设置定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //设置距离筛选
    [self.locationManager setDistanceFilter:100];
    //开始定位
    [self.locationManager startUpdatingLocation];
    //设置开始识别方向
    [self.locationManager startUpdatingHeading];
    NSLog(@"start gps");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    // 1.获取用户位置的对象
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    //NSLog(@"纬度:%f 经度:%f", coordinate.latitude, coordinate.longitude);
    
    // 2.停止定位
    [manager stopUpdatingLocation];
    
    _geocoder=[[CLGeocoder alloc]init];
    [self getAddressByLatitude:coordinate.latitude longitude:coordinate.longitude];
    
}

#pragma mark 根据坐标取得地名
-(void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude{
    
    //反地理编码
    __weak __typeof__(self) weakSelf = self;
    CLLocation *location=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        CLPlacemark *placemark=[placemarks firstObject];
        strongSelf.locationString = [placemark.addressDictionary[@"FormattedAddressLines"] lastObject];
        
    }];
    
}

- (IBAction)clickNext:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([self.iphoneTextField.text isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"提示" message:@"手机号不能为空" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if ([self.msgTextField.text isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"提示" message:@"验证码不能为空" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if (self.msgTextField.text.length > 6) {
        [self showAlertViewWithTitle:@"提示" message:@"验证码不能大于6位" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    //手机号绑定（即登录注册）
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *modal = [[UIDevice currentDevice] model];
    NSString *verson = [[UIDevice currentDevice] systemVersion];
    self.locationString = self.locationString ? self.locationString : @" ";
    NSDictionary *model  = @{
                             @"phone_no":self.iphoneTextField.text,
                             @"bind_os":@"iOS",
                             @"bind_os_version": verson,
                             @"bind_brand":modal,
                             @"bind_sn":uuid,
                             @"bind_lbs":self.locationString,
                             @"invite_code":@"",
                             @"message_type":@"SMS_104815008",
                             @"message_code":self.msgTextField.text
                             
                             };
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1002" andModel:model];
    
    
    [MBProgressHUD showMessage:nil];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        [MBProgressHUD hideHUD];
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        if ([data[@"code"] isEqualToString:@"0000"]) {
 
            NSMutableArray *qimiArr = [@[] mutableCopy];
            for (NSDictionary *subDict in data[@"body"][@"qinMiList"]) {
                
                NSDictionary *dict = [subDict transforeNullValueToEmptyStringInSimpleDictionary];
                
                NSDictionary *item = @{@"headUrl":dict[@"headUrl"],
                                       @"qinmiName":dict[@"qinmiName"],
                                       @"qinmiPhone":dict[@"qinmiPhone"],
                                       @"qinmiUser":dict[@"qinmiUser"],
                                       @"qinmiRole":dict[@"qinmiRole"],
                                       @"qinmiRoleName":dict[@"qinmiRoleName"]};
                [qimiArr addObject:item];
            }

            [CoreArchive setArr:qimiArr key:USER_QIMI_ARR];
            
            NSDictionary *userInfo = data[@"body"][@"userInfo"];
            [CoreArchive setDic:[userInfo transforeNullValueToEmptyStringInSimpleDictionary] key:USERINFO];
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            WAOldInterfaceViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WAOldInterfaceViewController"];
            [strongSelf.navigationController pushViewController:vc animated:YES];
            
            

            
            //设置别名
            NSString *userid = [NSString stringWithFormat:@"%@", userInfo[USERID]];
            [JPUSHService setAlias:userid completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                if (0 == iResCode) {
                    NSLog(@"设置别名成功: %@", iAlias);
                } else {
                    NSLog(@"设置别名失败");
                }
            } seq:[[NSDate date] timeIntervalSince1970]];
            
            
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
