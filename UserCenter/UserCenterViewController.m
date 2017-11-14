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

#define blueColor RGB_COLOR(45, 168, 232)
#define whiteColor [UIColor whiteColor]
@interface UserCenterViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>
{
    
    IBOutlet UIScrollView       *_bgScrollView;
    IBOutlet UIView             *_sexManBGView;
    IBOutlet UIView             *_sexWomanBGView;
    IBOutlet UIView             *_calendarBGView;
    IBOutlet UIButton           *_saveButton;
    BOOL                        isSexWithMan;
    BOOL                        isYingLi;
    IBOutlet UIImageView        *_picImgView;
    IBOutlet NSLayoutConstraint *_contentViewHeight;
    UIDatePicker                *_datePicker;
    UILabel                     *_onDatePickerLabel;
    __weak IBOutlet UITextField *nameTextField;
    
    
    IBOutlet UIButton *_selectTimeButton;
    
}

@property(nonatomic, strong)NSString *imageUrl;
@property(nonatomic,assign)BOOL isChange;
@end

@implementation UserCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人设置";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [leftItem setTintColor:HEX_COLOR(0x666666)];
    [leftItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = leftItem;

    isSexWithMan = YES;
    
    _calendarBGView.layer.masksToBounds = YES;
    _calendarBGView.layer.cornerRadius = 13.5;
    _calendarBGView.layer.borderWidth = 1;
    _calendarBGView.layer.borderColor = blueColor.CGColor;

    if (SCREEN_HEIGHT == 480) {
        _contentViewHeight.constant = 88+64;
    }
    
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
        [_selectTimeButton setTitle:birthday forState:UIControlStateNormal];
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
    

    if ([userInfo[GENDER] isEqualToString:@"1"]) {
        
        isSexWithMan = NO;
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
        

    } else {
    
        isSexWithMan = YES;
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
    
    _bgScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT+30);
}

- (IBAction)selectSex:(UITapGestureRecognizer *)sender {

    switch (sender.view.tag) {
        case 500:
        {
            isSexWithMan = YES;
            UIView *manBGView = _sexManBGView;
            UIImageView *manImgView = [manBGView viewWithTag:100];
            UILabel *manLabel = [manBGView viewWithTag:101];
            manImgView.image = [UIImage imageNamed:@"UC_man"];
            manLabel.textColor = BLACK_COLOR;
            
            
            UIView *womanBGView = _sexWomanBGView;
//            womanBGView.backgroundColor = whiteColor;
            UIImageView *womanImgView = [womanBGView viewWithTag:100];
            womanImgView.image = [UIImage imageNamed:@"UC_woman_click"];
            UILabel *womanLabel = [womanBGView viewWithTag:101];
            womanLabel.textColor = HEX_COLOR(0x999999);
            
            
        }
            
            break;
        case 501:
        {
            isSexWithMan = NO;
            
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
    
    
    
    [self checkPhotoLibraryPermission];
    
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
    BOOL birthdayBool = [userInfo[BIRTHDAY] isEqualToString:_selectTimeButton.titleLabel.text];
    BOOL birthdayTypeBool = ([userInfo[BIRTHDAYTYPE] isEqualToString:@"1"] && !isYingLi) || ([userInfo[BIRTHDAYTYPE] isEqualToString:@"0"] && isYingLi);
    BOOL genderBool = ([userInfo[GENDER] isEqualToString:@"1"] && !isSexWithMan) || ([userInfo[GENDER] isEqualToString:@"0"] && isSexWithMan);
    
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
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height);
    //CGRect rect = CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    //         NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
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
}
- (void)determineButtonAction {
    [self cancelButtonAction];
    NSDate *select = [_datePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    NSLog(@"dateAndTime = %@",dateAndTime);
    _selectTimeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_selectTimeButton setTitleColor:RGBA_COLOR(50, 50, 50, 1) forState:UIControlStateNormal];
    [_selectTimeButton setTitle:dateAndTime forState:UIControlStateNormal];
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
        NSString *bucketName = @"wawj-test";
        [MBProgressHUD showMessage:nil];
        [up uploadWithBucketName:bucketName
                        operator:@"wawj2017"
                        password:@"1+1=2yes"
                        fileData:fileData
                        fileName:nil
                         saveKey:imgName
                 otherParameters:nil
                         success:^(NSHTTPURLResponse *response,NSDictionary *responseBody) {  //上传成功
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             strongSelf.imageUrl = [NSString stringWithFormat:@"%@/%@",HTTP_IMAGE,imgName];
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [MBProgressHUD hideHUD];
                                  [strongSelf personHeadDataRefresh];
                             });
                             
                         }failure:^(NSError *error,NSHTTPURLResponse *response,NSDictionary *responseBody) { //上传失败
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [MBProgressHUD hideHUD];
                                 __strong typeof(weakSelf) strongSelf = weakSelf;
                                 _picImgView.image = nil;
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
            [dict setObject:strongSelf.imageUrl forKey:@"headUrl"];
            [dict setObject:strongSelf.imageUrl forKey:@"portraitUrl"];
            [dict addEntriesFromDictionary:userInfo];
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
    NSString *gender = isSexWithMan ? @"0":@"1";
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

    if ([_onDatePickerLabel.text isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"提示" message:@"生日不能为空" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if ([self.imageUrl isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"提示" message:@"头像不能为空" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    [self refreshPersonData];
    
}


#pragma mark - text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    float offset = SCREEN_HEIGHT - (textField.superview.bottom + 64);
    if (SCREEN_HEIGHT == 480) {
        offset = _bgScrollView.contentSize.height - (textField.superview.bottom) ;
    }
    
    //NSLog(@"offset = %f",offset);
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset < 260)
    {
        
        CGRect rect = CGRectMake(0.0f, offset-260,width,height);
        self.view.frame = rect;
        
    }
    [UIView commitAnimations];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
