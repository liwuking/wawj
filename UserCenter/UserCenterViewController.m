//
//  UserCenterViewController.m
//  AFanJia
//
//  Created by 焦庆峰 on 2016/11/24.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import "UserCenterViewController.h"
#import "ImagePicker.h"
#import "AppDelegate.h"
#import "UIView+Extension.h"
#import "UpYun.h"
#import "UpYunFormUploader.h"
#import <UIImageView+WebCache.h>
#import <sys/utsname.h>
#define blueColor RGB_COLOR(45, 168, 232)
#define whiteColor [UIColor whiteColor]
@interface UserCenterViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>
{
    
    IBOutlet UIScrollView       *_bgScrollView;
    IBOutlet UIView             *_sexManBGView;
    IBOutlet UIView             *_sexWomanBGView;
    IBOutlet UIView             *_calendarBGView;
    IBOutlet UIButton           *_saveButton;
    WAGender                    _waGender;
    BOOL                        isYingLi;
    IBOutlet UIImageView        *_picImgView;
    IBOutlet NSLayoutConstraint *_contentViewHeight;
    UIDatePicker                *_datePicker;
    UILabel                     *_onDatePickerLabel;
    __weak IBOutlet UITextField *nameTextField;
    __weak IBOutlet UITextField *birthdayTextField;
    
    
//    IBOutlet UIButton *_selectTimeButton;
    
}

@property(nonatomic, strong)NSString *imageUrl;
@property(nonatomic,assign)BOOL isChange;
@end

@implementation UserCenterViewController

-(BOOL)isIphone5 {
    //需要导入头文件：
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone5,1"]
       || [platform isEqualToString:@"iPhone5,2"]
       || [platform isEqualToString:@"iPhone5,3"]
       || [platform isEqualToString:@"iPhone5,4"]
       || [platform isEqualToString:@"iPhone6,1"]
       || [platform isEqualToString:@"iPhone6,2"]) {
        return YES;
    }
    return NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人设置";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [leftItem setTintColor:HEX_COLOR(0x666666)];
    [leftItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = leftItem;

//    isSexWithMan = YES;
    
    _calendarBGView.layer.masksToBounds = YES;
    _calendarBGView.layer.cornerRadius = 13.5;
    _calendarBGView.layer.borderWidth = 1;
    _calendarBGView.layer.borderColor = blueColor.CGColor;

    if (SCREEN_HEIGHT == 480) {
        _contentViewHeight.constant = 88+64;
    }
    
    _bgScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 568);
    
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    if (![userInfo[HEADURL] isEqualToString:@""]) {
        self.imageUrl = userInfo[HEADURL];
        NSURL *imgurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@!%@",userInfo[HEADURL],WEBP_HEADER_INFO]];
        [_picImgView sd_setImageWithURL:imgurl placeholderImage:[UIImage imageNamed:@"个人设置-我的头像"]];
    }
    
    if (![userInfo[USERNAME] isEqualToString:@""]) {
        nameTextField.text = userInfo[USERNAME];
    }
    
    if (userInfo[BIRTHDAY] && ![userInfo[BIRTHDAY] isEqualToString:@""]) {
        NSString *birthday = userInfo[BIRTHDAY];
        birthdayTextField.text = birthday;
    }
    
    UIButton *yangButton = [_calendarBGView viewWithTag:200];
    UIButton *yinButton = [_calendarBGView viewWithTag:201];
    if ([userInfo[BIRTHDAYTYPE] isEqualToString:@"1"]) {

        yangButton.backgroundColor = blueColor;
        [yangButton setTitleColor:whiteColor forState:UIControlStateNormal];
        
        yinButton.backgroundColor = whiteColor;
        [yinButton setTitleColor:blueColor forState:UIControlStateNormal];
        isYingLi = NO;

    } else {
    
        yangButton.backgroundColor = whiteColor;
        [yangButton setTitleColor:blueColor forState:UIControlStateNormal];
        
        yinButton.backgroundColor = blueColor;
        [yinButton setTitleColor:whiteColor forState:UIControlStateNormal];
        isYingLi = YES;
        
    }
    

    if (!userInfo[GENDER] || [userInfo[GENDER] isEqualToString:@""]) {
        _waGender = WAGenderNull;
        
        UIView *womanBGView = _sexWomanBGView;//sender.view;
        UIImageView *womanImgView = [womanBGView viewWithTag:100];
        UILabel *womanLabel = [womanBGView viewWithTag:101];
        womanImgView.image = [UIImage imageNamed:@"UC_woman_click"];
        womanLabel.textColor = HEX_COLOR(0x999999);
        
        UIView *manBGView = _sexManBGView;
        UIImageView *manImgView = [manBGView viewWithTag:100];
        UILabel *manLabel = [manBGView viewWithTag:101];
        manImgView.image = [UIImage imageNamed:@"UC_man_click"];
        manLabel.textColor = HEX_COLOR(0x999999);
        
    } else if ([userInfo[GENDER] isEqualToString:@"1"]) {
        
//        isSexWithMan = NO;
        _waGender = WAGenderWoMan;
        UIView *womanBGView = _sexWomanBGView;//sender.view;
        UIImageView *womanImgView = [womanBGView viewWithTag:100];
        UILabel *womanLabel = [womanBGView viewWithTag:101];
        womanImgView.image = [UIImage imageNamed:@"UC_woman"];
        womanLabel.textColor = BLACK_COLOR;

        UIView *manBGView = _sexManBGView;
        UIImageView *manImgView = [manBGView viewWithTag:100];
        UILabel *manLabel = [manBGView viewWithTag:101];
        manImgView.image = [UIImage imageNamed:@"UC_man_click"];
        manLabel.textColor = HEX_COLOR(0x999999);
        

    }  else if([userInfo[GENDER] isEqualToString:@"0"]) {
    
//        isSexWithMan = YES;
        _waGender = WAGenderMan;
        UIView *manBGView = _sexManBGView;
        manBGView.backgroundColor = whiteColor;
        UIImageView *manImgView = [manBGView viewWithTag:100];
        manImgView.image = [UIImage imageNamed:@"UC_man"];
        UILabel *manLabel = [manBGView viewWithTag:101];
        manLabel.textColor = BLACK_COLOR;
        
        
        UIView *womanBGView = _sexWomanBGView;
        womanBGView.backgroundColor = whiteColor;
        UIImageView *womanImgView = [womanBGView viewWithTag:100];
        womanImgView.image = [UIImage imageNamed:@"UC_woman_click"];
        UILabel *womanLabel = [womanBGView viewWithTag:101];
        womanLabel.textColor = HEX_COLOR(0x999999);

    }
    
//    _bgScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT+30);
    
    [self checkCaptureDevicePermission];
    [self checkPhotoLibraryPermission];
}

- (IBAction)selectSex:(UITapGestureRecognizer *)sender {

    switch (sender.view.tag) {
        case 500:
        {
//            isSexWithMan = YES;
            _waGender = WAGenderMan;
            UIView *manBGView = _sexManBGView;
            UIImageView *manImgView = [manBGView viewWithTag:100];
            UILabel *manLabel = [manBGView viewWithTag:101];
            manImgView.image = [UIImage imageNamed:@"UC_man"];
            manLabel.textColor = BLACK_COLOR;
            
            
            UIView *womanBGView = _sexWomanBGView;
            UIImageView *womanImgView = [womanBGView viewWithTag:100];
            womanImgView.image = [UIImage imageNamed:@"UC_woman_click"];
            UILabel *womanLabel = [womanBGView viewWithTag:101];
            womanLabel.textColor = HEX_COLOR(0x999999);
            
            
        }
            
            break;
        case 501:
        {
//            isSexWithMan = NO;
            _waGender = WAGenderWoMan;
            UIView *womanBGView = _sexWomanBGView;//sender.view;
            UIImageView *womanImgView = [womanBGView viewWithTag:100];
            UILabel *womanLabel = [womanBGView viewWithTag:101];
            womanImgView.image = [UIImage imageNamed:@"UC_woman"];
            womanLabel.textColor = BLACK_COLOR;
            
            
            UIView *manBGView = _sexManBGView;
            UIImageView *manImgView = [manBGView viewWithTag:100];
            UILabel *manLabel = [manBGView viewWithTag:101];
            manImgView.image = [UIImage imageNamed:@"UC_man_click"];
            manLabel.textColor = HEX_COLOR(0x999999);
        }
            
        default:
            break;
    }
    
    
   
    
}

-(BOOL)checkCaptureDevicePermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied ){
        //无权限
        [self showAlertViewWithTitle:@"\n需开启 \"相机\" 权限 \n\n" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"去开启" clickOtherBtn:^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:url];
                });
            }
        }];
        
        return NO;
        
    } else if (status == AVAuthorizationStatusNotDetermined) {
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){//点击允许访问时调用
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                NSLog(@"Granted access to %@", AVMediaTypeVideo);
            }
            else {
                NSLog(@"Not granted access to %@", AVMediaTypeVideo);
            }
            
        }];
        
        return NO;
    }
    
    return YES;
}

-(BOOL)checkPhotoLibraryPermission {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if(status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted ){
        //无权限
        [self showAlertViewWithTitle:@"\n需开启 \"照片\" 权限 \n\n" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"去开启" clickOtherBtn:^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:url];
                });
            }
        }];
        
        return NO;
        
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                
                // TODO:...
            }
        }];
        
        return NO;
    }
    
    return YES;
}

- (IBAction)selectDate:(UIButton *)sender {
    UIButton *yangButton = [_calendarBGView viewWithTag:200];
    UIButton *yinButton = [_calendarBGView viewWithTag:201];
    
    if (yangButton == sender) {
       
        yangButton.backgroundColor = blueColor;
        [yangButton setTitleColor:whiteColor forState:UIControlStateNormal];
        
        yinButton.backgroundColor = whiteColor;
        [yinButton setTitleColor:blueColor forState:UIControlStateNormal];
        isYingLi = NO;
        
    }else{
        
        yangButton.backgroundColor = whiteColor;
        [yangButton setTitleColor:blueColor forState:UIControlStateNormal];
        
        yinButton.backgroundColor = blueColor;
        [yinButton setTitleColor:whiteColor forState:UIControlStateNormal];
        isYingLi = YES;
        
    }
}


- (void)backAction {
    
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    BOOL headUrlBool = self.imageUrl ? [userInfo[HEADURL] isEqualToString:self.imageUrl] : YES;
    BOOL userNameBool = [userInfo[USERNAME] isEqualToString:nameTextField.text];
    BOOL birthdayBool = [userInfo[BIRTHDAY] isEqualToString:birthdayTextField.text] || [birthdayTextField.text isEqualToString:@""];
    BOOL birthdayTypeBool = ([userInfo[BIRTHDAYTYPE] isEqualToString:@"1"] && !isYingLi) || ([userInfo[BIRTHDAYTYPE] isEqualToString:@"0"] && isYingLi) || [userInfo[BIRTHDAYTYPE] isEqualToString:@""];
    BOOL genderBool = ([userInfo[GENDER] isEqualToString:@"1"] && _waGender == WAGenderWoMan) || ([userInfo[GENDER] isEqualToString:@"0"] && _waGender == WAGenderMan) || ([userInfo[GENDER] isEqualToString:@""] && _waGender == WAGenderNull);
    
    if (headUrlBool && userNameBool && birthdayBool && birthdayTypeBool && genderBool) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        __weak typeof(self) weakSelf = self;
        [self showAlertViewWithTitle:@"您还没有保存信息，确定离开？" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"确定" clickOtherBtn:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
    
//
//    if (self.isChange) {
//        __weak typeof(self) weakSelf = self;
//        [self showAlertViewWithTitle:@"您还没有保存信息，确定离开？" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
//
//        } otherButtonTitles:@"确定" clickOtherBtn:^{
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            [strongSelf.navigationController popViewControllerAnimated:YES];
//        }];
//    }
    
    
}

- (IBAction)selectPic:(UITapGestureRecognizer *)sender {
    
//    if (![self checkPhotoLibraryPermission]) {
//        return;
//    }
    
    __weak typeof(self) weakSelf = self;
    [ImagePicker showImagePickerFromViewController:self allowsEditing:YES finishAction:^(UIImage *image) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (image)
        {
            
            _picImgView.image = image;
            
            [strongSelf uploadImage];

        }

    }];

}

- (IBAction)selectTime:(UIButton *)sender {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIView *allBGView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    allBGView.opaque = NO;
    allBGView.tag = 600;
    allBGView.backgroundColor = RGBA_COLOR(0, 0, 0, 0.5);
    [app.window addSubview:allBGView];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-270, SCREEN_WIDTH, 270)];
    bgView.backgroundColor = RGB_COLOR(240, 240, 240);
    [allBGView addSubview:bgView];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 49.5, SCREEN_WIDTH, 0.5)];
    lineView.backgroundColor = RGB_COLOR(220, 220, 220);
    [bgView addSubview:lineView];
    
    //取消按钮
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 50)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:RGB_COLOR(6, 122, 218) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [bgView addSubview:cancelButton];
    
    //确定按钮
    UIButton *determineButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-70, 0, 70, 50)];
    [determineButton setTitle:@"确定" forState:UIControlStateNormal];
    [determineButton setTitleColor:RGB_COLOR(6, 122, 218) forState:UIControlStateNormal];
    [determineButton addTarget:self action:@selector(determineButtonAction) forControlEvents:UIControlEventTouchUpInside];
    determineButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [bgView addSubview:determineButton];
    
    
    //time label
    _onDatePickerLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, SCREEN_WIDTH-140, 50)];
    _onDatePickerLabel.font = [UIFont systemFontOfSize:20];
    _onDatePickerLabel.textColor = RGB_COLOR(50, 50, 50);
    _onDatePickerLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:_onDatePickerLabel];
    
    _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 220)];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [bgView addSubview:_datePicker];
    
    [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged ];

}

- (void)cancelButtonAction {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [[app.window viewWithTag:600] removeFromSuperview];
    
    //键盘收回后视图移动回原位的动画
    [UIView animateWithDuration:0.3 animations:^{
        
        float width = self.view.frame.size.width;
        float hight = self.view.frame.size.height;
        
        CGRect rect = CGRectMake(0, 0, width, hight);
        self.view.frame = rect;
    }];
}
- (void)determineButtonAction {
    [self cancelButtonAction];
    NSDate *select = [_datePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    NSLog(@"dateAndTime = %@",dateAndTime);
//    _selectTimeButton.titleLabel.font = [UIFont systemFontOfSize:16];
//    [_selectTimeButton setTitleColor:RGBA_COLOR(50, 50, 50, 1) forState:UIControlStateNormal];
//    [_selectTimeButton setTitle:dateAndTime forState:UIControlStateNormal];
    birthdayTextField.text = dateAndTime;
}

- (void)dateChanged:(id)dataPicker {
    NSLog(@"dataPicker = %@",dataPicker);
    UIDatePicker* control = (UIDatePicker*)dataPicker;
    NSDate *select = [control date];
    NSLog(@"select = %@",select);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    NSLog(@"dateAndTime = %@",dateAndTime);
    _onDatePickerLabel.text = dateAndTime;
}

-(void)uploadImage {
    
    
    NSData *fileData = UIImageJPEGRepresentation(_picImgView.image, 0.5);
    if([AFNetworkReachabilityManager sharedManager].isReachable){ //----有网络
        
//        //从 app 服务器获取的上传策略 policy
//        NSString *policy = @"eyJleHBpcmF0aW9uIjoxNDg5Mzc4NjExLCJyZXR1cm4tdXJsIjoiaHR0cGJpbi5vcmdcL3Bvc3QiLCJidWNrZXQiOiJmb3JtdGVzdCIsInNhdmUta2V5IjoiXC91cGxvYWRzXC97eWVhcn17bW9ufXtkYXl9XC97cmFuZG9tMzJ9ey5zdWZmaXh9In0=";
//        
//        //从 app 服务器获取的上传策略签名 signature
//        NSString *signature = @"l6BqFmNArztYqj6NtLkTj+PIsxk=";
//        
//    
        //图片命名
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
        
        NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
        NSString *userID = userInfo? userInfo[@"userId"] : @"";
        NSString *imgName=[NSString stringWithFormat:@"share/%@/%@.jpeg",currentDateString,userID];
        
        __weak typeof(self) weakSelf = self;
        UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
        [MBProgressHUD showMessage:nil];
        
        
        [up uploadWithBucketName:YUN_BUCKETNAMEPHOTO
                        operator:YUN_OPERATOR
                        password:YUN_PASSWORD
                        fileData:fileData
                        fileName:nil
                         saveKey:imgName
                 otherParameters:nil
                         success:^(NSHTTPURLResponse *response,NSDictionary *responseBody) {  //上传成功
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             strongSelf.imageUrl = [NSString stringWithFormat:@"%@/%@",YUN_PHOTO,imgName];
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [MBProgressHUD hideHUD];
                                  [strongSelf personHeadDataRefresh];
                             });
                             
                         }failure:^(NSError *error,NSHTTPURLResponse *response,NSDictionary *responseBody) { //上传失败
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [MBProgressHUD hideHUD];
                                 __strong typeof(weakSelf) strongSelf = weakSelf;
                                 _picImgView.image = [UIImage imageNamed:@"头像设置"];
                                 [strongSelf showAlertViewWithTitle:@"提示" message:@"请求失败" buttonTitle:@"确定" clickBtn:^{
                                     
                                 }];
                             });
                           
                             
                         }progress:^(int64_t completedBytesCount,int64_t totalBytesCount) {
                         
                         }];
        
    }else{ //----没有网络
        [self showAlertViewWithTitle:@"提示" message:@"没有网络" buttonTitle:@"确定" clickBtn:^{
            
        }];
    }
    
}

-(void)personHeadDataRefresh {
    
    NSDictionary *model = @{
                            @"head_url":       self.imageUrl? self.imageUrl : @"",
                            @"portrait_url":   self.imageUrl? self.imageUrl : @""
                            };
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1005" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        NSLog(@"更新成功： %@",data);
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
            NSMutableDictionary *dict = [@{} mutableCopy];
            [dict addEntriesFromDictionary:userInfo];
            [dict setObject:strongSelf.imageUrl forKey:@"headUrl"];
            [dict setObject:strongSelf.imageUrl forKey:@"portraitUrl"];
            [CoreArchive setDic:dict key:USERINFO];
            
//            [strongSelf.delegate userCenterViewControllerWithHeadImgRefresh:_picImgView.image];
            
        } else {
            
            _picImgView.image = nil;
            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
                
            }];
            
        }
        
    } fail:^(NSError *error) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
         _picImgView.image = nil;
        NSLog(@"更新头像shibai");
        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
    }];

}

-(void)refreshPersonData {

    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *gender = _waGender == WAGenderMan ? @"0":@"1";
    NSString *birthday_type = isYingLi ? @"0": @"1";
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *birthday = userInfo[BIRTHDAY];
    if (_datePicker) {
        birthday = [dateFormatter stringFromDate:_datePicker.date];
    }
    
    NSDictionary *model = @{
                            @"user_name":      nameTextField.text,
                            @"head_url":       self.imageUrl? self.imageUrl : @"",
                            @"portrait_url":   self.imageUrl? self.imageUrl : @"",
                            @"gender":         gender,
                            @"birthday":       birthday,
                            @"birthday_type":  birthday_type
                            };
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1004" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [MBProgressHUD showMessage:nil];
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
       
        NSDictionary *userInfo = data[@"body"][@"userInfo"];
        [CoreArchive setDic:[userInfo transforeNullValueToEmptyStringInSimpleDictionary] key:USERINFO];

        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            [strongSelf.navigationController popViewControllerAnimated:YES];
            
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

- (IBAction)saveAction:(id)sender {
    
    if ([nameTextField.text isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"提示" message:@"姓名不能为空" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if ([nameTextField.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 12) {
        [self showAlertViewWithTitle:@"姓名太长" message:@"姓名英文为12个字符，汉字为4个" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }

    if ([birthdayTextField.text isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"提示" message:@"生日不能为空" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if (!self.imageUrl  || [self.imageUrl isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"提示" message:@"头像不能为空" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if (_waGender == WAGenderNull) {
        [self showAlertViewWithTitle:@"提示" message:@"必须选择性别:男或者女" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
//    BOOL headUrlBool = self.imageUrl ? [userInfo[HEADURL] isEqualToString:self.imageUrl] : YES;
    BOOL userNameBool = [userInfo[USERNAME] isEqualToString:nameTextField.text];
    BOOL birthdayBool = [userInfo[BIRTHDAY] isEqualToString:birthdayTextField.text] || [birthdayTextField.text isEqualToString:@""];
    BOOL birthdayTypeBool = ([userInfo[BIRTHDAYTYPE] isEqualToString:@"1"] && !isYingLi) || ([userInfo[BIRTHDAYTYPE] isEqualToString:@"0"] && isYingLi) || [userInfo[BIRTHDAYTYPE] isEqualToString:@""];
    BOOL genderBool = ([userInfo[GENDER] isEqualToString:@"1"] && _waGender == WAGenderWoMan) || ([userInfo[GENDER] isEqualToString:@"0"] && _waGender == WAGenderMan) || ([userInfo[GENDER] isEqualToString:@""] && _waGender == WAGenderNull);
    
    if (userNameBool && birthdayBool && birthdayTypeBool && genderBool) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self refreshPersonData];
    }
    
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField == birthdayTextField) {
        [textField resignFirstResponder];
        [self selectTime:nil];
        
        
        CGRect textFieldFrame      = [textField convertRect:textField.bounds toView:self.view];
        //当前输入框的Y
        CGFloat textField_Y        = textFieldFrame.origin.y;
        //当前输入框的高度
        CGFloat textFieldHight     = textFieldFrame.size.height;
        //屏幕高度
        CGFloat screenHight        = self.view.frame.size.height;
        //键盘高度
        CGFloat keyBordHight       = 270;
        //键盘tabbar高度
        CGFloat keyBordTabbarHight = 0;
        //计算输入框向上移动的偏移量
        int offset = 64+textField_Y + textFieldHight - (screenHight - keyBordHight - keyBordTabbarHight);
        
        //根据键盘遮挡的高度开始移动动画
        [UIView animateWithDuration:0.3 animations:^{
            if (offset > 0) {
                
                float width = self.view.frame.size.width;
                float hight = self.view.frame.size.height;
                
                CGRect rect = CGRectMake(0, -offset, width, hight);
                self.view.frame = rect;
            }
        }];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldFrame      = [textField convertRect:textField.bounds toView:self.view];
    //当前输入框的Y
    CGFloat textField_Y        = textFieldFrame.origin.y;
    //当前输入框的高度
    CGFloat textFieldHight     = textFieldFrame.size.height;
    //屏幕高度
    CGFloat screenHight        = self.view.frame.size.height;
    //键盘高度
    CGFloat keyBordHight       = 216;
    //键盘tabbar高度
    CGFloat keyBordTabbarHight = 35;
    //计算输入框向上移动的偏移量
    int offset = 64+textField_Y + textFieldHight - (screenHight - keyBordHight - keyBordTabbarHight);
    
    //根据键盘遮挡的高度开始移动动画
    [UIView animateWithDuration:0.3 animations:^{
        if (offset > 0) {
            
            float width = self.view.frame.size.width;
            float hight = self.view.frame.size.height;
            
            CGRect rect = CGRectMake(0, -offset, width, hight);
            self.view.frame = rect;
        }
    }];
    
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    //键盘收回后视图移动回原位的动画
    [UIView animateWithDuration:0.3 animations:^{
        
        float width = self.view.frame.size.width;
        float hight = self.view.frame.size.height;
        
        CGRect rect = CGRectMake(0, 0, width, hight);
        self.view.frame = rect;
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    //点击Return,键盘收回后视图移动回原位的动画
    [UIView animateWithDuration:0.3 animations:^{
        
        float width = self.view.frame.size.width;
        float hight = self.view.frame.size.height;
        
        CGRect rect = CGRectMake(0, 0, width, hight);
        self.view.frame = rect;
    }];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
