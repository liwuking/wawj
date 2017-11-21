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
#import "RemindItem.h"
#import "FMDatabase.h"
#import "AlarmClockItem.h"
#import "DBManager.h"
#import "WAHelpDetailViewController.h"
@interface WABindIphoneViewController ()<CLLocationManagerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *serviceBtn02;
@property (weak, nonatomic) IBOutlet UILabel *servericeLab01;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *getVeryCodeGes;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (weak, nonatomic) IBOutlet UILabel *topLab;
@property(nonatomic, strong)FMDatabase             *db;

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
    
    
    
    self.locationString = @" ";
    [self startLocation];
   
    //[self performSegueWithIdentifier:@"WAOldInterfaceViewController" sender:nil];
}


-(void)leftAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initView {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.msgStatusLab.hidden = YES;
    
   
    self.title = @"绑定手机号";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
     self.topLab.adjustsFontSizeToFitWidth = YES;
    
    self.servericeLab01.adjustsFontSizeToFitWidth = YES;
    
    self.serviceBtn02.titleLabel.font = self.servericeLab01.font;
}

- (IBAction)clickServiceProtocol:(UIButton *)sender {
    WAHelpDetailViewController *vc = [[WAHelpDetailViewController alloc] initWithNibName:@"WAHelpDetailViewController" bundle:nil];
    //    vc.helpItem = helpItem;
    vc.title = @"用户协议";
    vc.webUrl = @"http://www.wawjapp.com/contract.html";
    [self.navigationController pushViewController:vc animated:YES];
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

-(NSString *)showDateTimeWithRemindType:(NSString *)remindType andRemindTime:(NSString *)remindTime andCreatetimestamp:(NSString *)createtimestamp {
    
    NSString *dateTime = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateDD = [dateFormatter stringFromDate:[NSDate date]];
    NSString *remindDateMM = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,remindTime];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *remindDate = [dateFormatter dateFromString:remindDateMM];
    
    NSString *weekDay = [Utility getDayWeek];
    
    if ([remindType isEqualToString:REMINDTYPE_ONLYONCE]) {
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *createDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[createtimestamp integerValue]]];
        
        NSString *today = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
        NSString *tomorrow = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
        //        NSString *afterday = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
        
        if ([createDateStr isEqualToString:today]) {
            dateTime = @"今天";
        } else if ([createDateStr isEqualToString:tomorrow]) {
            dateTime = @"明天";
        } else {
            dateTime = @"后天";
        }
        
        
        
    } else if ([remindType isEqualToString:REMINDTYPE_WEEKEND]){
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        if ([weekDay isEqualToString:MONDAY]) {
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:5*24*60*60]];
        } else if([weekDay isEqualToString:TUESDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:4*24*60*60]];
        } else if([weekDay isEqualToString:WEDNESDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:3*24*60*60]];
        } else if([weekDay isEqualToString:THURSDAY]){
            dateTime = @"后天";
        } else if([weekDay isEqualToString:FRIDAY]){
            dateTime = @"明天";
        } else if([weekDay isEqualToString:SATURDAY]){
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
                dateTime = @"明天";
            }else {
                dateTime = @"今天";
            }
        } else if([weekDay isEqualToString:SUNDAY]){
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
                dateTime = @"明天";
            }else {
                dateTime = @"今天";
            }
        }
        
    } else if ([remindType isEqualToString:REMINDTYPE_WORKDAY]){
        
        if ([weekDay isEqualToString:SATURDAY]) {
            dateTime = @"后天";
        } else if([weekDay isEqualToString:SUNDAY]){
            dateTime = @"明天";
        } else {
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
                dateTime = @"明天";
            }else {
                dateTime = @"今天";
            }
        }
        
    } else {
        
        if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
            dateTime = @"明天";
        }else {
            dateTime = @"今天";
        }
        
    }
    
    return dateTime;
}

-(NSDate *)dateTimeWithRemindType:(NSString *)remindType andRemindTime:(NSString *)remindTime andCreatetimestamp:(NSString *)createtimestamp isOhter:(BOOL)isOther{
    
    NSString *dateTime = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateDD = [dateFormatter stringFromDate:[NSDate date]];
    NSString *remindDateMM = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,remindTime];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *remindDate = [dateFormatter dateFromString:remindDateMM];
    
    NSString *weekDay = [Utility getDayWeek];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if ([remindType isEqualToString:REMINDTYPE_ONLYONCE]) {
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *createDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[createtimestamp integerValue]]];
        
        NSString *today = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
        NSString *tomorrow = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
        NSString *afterday = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
        
        if ([createDateStr isEqualToString:today]) {
            dateTime = today;
        } else if ([createDateStr isEqualToString:tomorrow]) {
            dateTime = tomorrow;
        } else {
            dateTime = afterday;
        }
        
    } else if ([remindType isEqualToString:REMINDTYPE_WEEKEND]){
        
        if ([weekDay isEqualToString:MONDAY]) {
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:5*24*60*60]];
        } else if([weekDay isEqualToString:TUESDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:4*24*60*60]];
        } else if([weekDay isEqualToString:WEDNESDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:3*24*60*60]];
        } else if([weekDay isEqualToString:THURSDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
        } else if([weekDay isEqualToString:FRIDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
        } else if([weekDay isEqualToString:SATURDAY]){
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
                dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
            }else {
                dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
            }
        } else if([weekDay isEqualToString:SUNDAY]){
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
                dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
            }else {
                dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
            }
        }
        
    } else if ([remindType isEqualToString:REMINDTYPE_WORKDAY]){
        
        if ([weekDay isEqualToString:SATURDAY]) {
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
        } else if([weekDay isEqualToString:SUNDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
        } else {
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
                dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
            }else {
                dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
            }
        }
        
    } else {
        
        if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
        }else {
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
        }
        
    }
    
    NSLog(@"dateTime: %@", dateTime);
    
    if (isOther) {
        dateTime = [NSString stringWithFormat:@"%@ %@:30",dateTime,remindTime];
    } else {
        dateTime = [NSString stringWithFormat:@"%@ %@:00",dateTime,remindTime];
    }
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *recentlyRemindDate = [dateFormatter dateFromString:dateTime];
    
    return recentlyRemindDate;
}


#pragma -mark 创建数据库表
- (void)createDatabaseTableWithUserid:(NSString *)userId {
    
    NSString *databaseTableName = [NSString stringWithFormat:@"remindList_%@", userId];
    NSDictionary *keys = @{@"remindorigintype"           : @"string",
                           @"remindid"                   : @"string",
                           @"audiourl"                   : @"string",
                           @"headurl"                    : @"string",
                           @"remindtype"                 : @"string",
                           @"remindtime"                 : @"string",
                           @"createtimestamp"            : @"string",
                           @"content"                    : @"string"
                           };
    
    __weak __typeof__(self) weakSelf = self;
    [[DBManager defaultManager] createTableWithName:databaseTableName AndKeys:keys Result:^(BOOL isOK) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!isOK) {
            //建表失败！
            [strongSelf showAlertViewWithTitle:@"提示" message:@"建表失败" buttonTitle:@"确定" clickBtn:^{
                
            }];
        } else {
            
            [strongSelf insertOneAdditionalRemindDataWithUserid:userId];
            
        }
        
    } FMDatabase:^(FMDatabase *database) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        strongSelf.db = database;
        [strongSelf insertOneAdditionalRemindDataWithUserid:userId];
    }];

    
}

-(void)insertOneAdditionalRemindDataWithUserid:(NSString *)userId {
    
    
    NSString *databaseTableName = [NSString stringWithFormat:@"remindList_%@", userId];
  
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *remindtime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:5*60]];
    
    RemindItem *item = [[RemindItem alloc] init];
    item.remindorigintype = REMINDORIGINTYPE_LOCAL;
    item.remindtype = REMINDTYPE_ONLYONCE;
    item.remindtime = remindtime;
    item.createtimestamp = [NSString stringWithFormat:@"%ld", (NSInteger)[[NSDate dateWithTimeIntervalSinceNow:5*60] timeIntervalSince1970] ];
    item.content = @"按住话筒说：几点干什么，再松开话筒，自动生成一条提醒，支持今天、明天和后天,例如 按住话筒说：明天下午5点接孩子，再松开话筒，就是这么简单,赶快试试吧~";
    item.audiourl = @"";
    item.headurl = @"";
    item.remindDate = [self showDateTimeWithRemindType:item.remindtype andRemindTime:item.remindtime andCreatetimestamp:item.createtimestamp];
    item.recentlyRemindDate = [self dateTimeWithRemindType:item.remindtype andRemindTime:item.remindtime andCreatetimestamp:item.createtimestamp isOhter:![item.audiourl isEqualToString:@""]];
    
    
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (remindorigintype,remindid, remindtype,remindtime,content,audiourl,headurl,createtimestamp) values ('%@','%@','%@','%@','%@','%@','%@','%@')",databaseTableName,REMINDORIGINTYPE_LOCALADDITIONAL,@"",item.remindtype,item.remindtime,item.content,@"",@"",item.createtimestamp];
    
    if ([self.db executeUpdate:sql]) {
        //添加一个新的闹钟
        NSString *clockIdentifier = [NSString stringWithFormat:@"%@%@",item.remindtype,item.remindtime];
        [AlarmClockItem addAlarmClockWithAlarmClockContent:item.content AlarmClockDateTime:item.remindtime AlarmClockType:item.remindtype AlarmClockIdentifier:clockIdentifier isOhters:NO];
    }
    
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
            
            //插入提醒数据
            [strongSelf createDatabaseTableWithUserid:userInfo[USERID]];
            
            //设置别名
            NSString *userid = [NSString stringWithFormat:@"%@", userInfo[USERID]];
            [JPUSHService setAlias:userid completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                if (0 == iResCode) {
                    NSLog(@"设置别名成功: %@", iAlias);
                } else {
                    NSLog(@"设置别名失败");
                }
            } seq:[[NSDate date] timeIntervalSince1970]];
            
            [strongSelf.navigationController popViewControllerAnimated:YES];
            
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
