//
//  WACloseFamilyDetailViewController.m
//  wawj
//
//  Created by ruiyou on 2017/9/19.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WACloseFamilyDetailViewController.h"
#import <UIImageView+WebCache.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>

@interface WACloseFamilyDetailViewController ()<CLLocationManagerDelegate,MFMessageComposeViewControllerDelegate>
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;

@end

@implementation WACloseFamilyDetailViewController
{
    CLGeocoder *_geocoder;
}
-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initView {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.title = self.closeFamilyItem.qinmiName;
    [self.phoneBtn setTitle:self.closeFamilyItem.qinmiPhone forState:UIControlStateNormal];
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.closeFamilyItem.headUrl] placeholderImage:[UIImage imageNamed:@""]];
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
    
    [MBProgressHUD showMessage:nil];
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
    NSLog(@"纬度:%f 经度:%f", coordinate.latitude, coordinate.longitude);
    
    // 2.停止定位
    [manager stopUpdatingLocation];
    [MBProgressHUD hideHUD];
    
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
        NSLog(@"详细信息:%@",placemark.addressDictionary);
        NSString *locationString = [NSString stringWithFormat:@"我现在的位置: %@; http://api.map.baidu.com/staticimage?zoom=17&markers=%f,%f",placemark.addressDictionary[@"City"],latitude, longitude];
        
        [strongSelf sendMessageBut:locationString];
        
    }];
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (!self.closeFamilyItem.headUrl) {
        [self getFamilyDetail];
    }
    
    [self initView];
}
- (IBAction)clickPhoneBtn:(UIButton *)sender {
    
    [self showAlertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"是否拨打%@的号码",self.closeFamilyItem.qinmiName] cancelButtonTitle:@"取消" clickCancelBtn:^{
        
    } otherButtonTitles:@"拨打" clickOtherBtn:^{
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",self.closeFamilyItem.qinmiPhone];
        //NSLog(@"str======%@",str);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }];

    
}


- (IBAction)clickRemind:(UIButton *)sender {
}


- (IBAction)clickSendLocation:(UIButton *)sender {
    
    if (![CLLocationManager locationServicesEnabled])//确定用户的位置服务启用
    {
        [self showAlertViewWithTitle:@"提示" message:@"请先开启定位功能" buttonTitle:@"确定" clickBtn:^{
            
        }];
    } else if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied) {//位置服务是在设置中禁用
        [self showAlertViewWithTitle:@"提示" message:@"请先打开此应用的定位功能" buttonTitle:@"确定" clickBtn:^{
            
        }];
    } else {
        
        [self startLocation];
        
    }
    
}

/** 点击发送短信按钮*/
- (void)sendMessageBut:(NSString *)text {
    /** 如果可以发送文本消息(不在模拟器情况下*/
    if ([MFMessageComposeViewController canSendText]) {
        /** 创建短信界面(控制器*/
        MFMessageComposeViewController *controller = [MFMessageComposeViewController new];
        //        controller.recipients = @[self.phoneTextField.text];//短信接受者为一个NSArray数组
        controller.body = text;//短信内容
        controller.messageComposeDelegate = self;//设置代理,代理可不是 controller.delegate = self 哦!!!
        /** 取消按钮的颜色(附带,可不写) */
        controller.navigationBar.tintColor = [UIColor redColor];
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        NSLog(@"模拟器不支持发送短信");
    }
}
#pragma mark - MFMessageComposeViewControllerDelegate
/**
 *  协议方法,在信息界面处理完信息结果时调用(比如点击发送,取消发送,发送失败)
 *
 *  @param controller 信息控制器
 *  @param result     返回的信息发送成功与否状态
 */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    /** 发送完信息就回到原程序*/
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
            NSLog(@"发送成功");
            break;
        case MessageComposeResultFailed:
            NSLog(@"发送失败");
            break;
        case MessageComposeResultCancelled:
            NSLog(@"发送取消");
        default:
            break;
    }
}

-(void)getFamilyDetail {
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1101" andModel:@{@"qinmi_user":@"",@"qinmi_phone":self.closeFamilyItem.qinmiPhone}];
    __weak __typeof__(self) weakSelf = self;
    [MBProgressHUD showMessage:nil];
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        [MBProgressHUD hideHUD];
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            if ( data[@"body"][@"qinmiUser"]) {
                NSString *user = data[@"body"][@"qinmiUser"];
                if (user.length > 2) {
                    NSMutableArray *qimiArr = [CoreArchive arrForKey:USER_QIMI_ARR];
                    
                    for (NSInteger i = 0; i < qimiArr.count; i++) {
                        NSDictionary *subDict = qimiArr[i];
                        if ([subDict[@"qinmiPhone"] isEqualToString:data[@"body"][@"qinmiPhone"]]) {
                            [qimiArr removeObjectAtIndex:i];
                            [qimiArr insertObject:data[@"body"] atIndex:i];
                            break;
                        }
                    }
                    
                    //[qimiArr addObject:data[@"body"]];
                    [CoreArchive setArr:qimiArr key:USER_QIMI_ARR];
                    
                }
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
