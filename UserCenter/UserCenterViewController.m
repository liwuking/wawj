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

@end

@implementation UserCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [leftItem setTintColor:HEX_COLOR(0x666666)];
    [leftItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _sexManBGView.layer.cornerRadius = 16.5;
    _sexWomanBGView.layer.cornerRadius = 16.5;
    _sexWomanBGView.layer.borderWidth = 1;
    _sexWomanBGView.layer.borderColor = blueColor.CGColor;
    isSexWithMan = YES;
    
    _calendarBGView.layer.masksToBounds = YES;
    _calendarBGView.layer.cornerRadius = 13.5;
    _calendarBGView.layer.borderWidth = 1;
    _calendarBGView.layer.borderColor = blueColor.CGColor;
    _saveButton.layer.masksToBounds = YES;
    _saveButton.layer.cornerRadius = 6;
    
    _picImgView.layer.masksToBounds = YES;
    _picImgView.layer.cornerRadius = 50;
    
    if (SCREEN_HEIGHT == 480) {
        _contentViewHeight.constant = 88+64;
    }
    
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    if (userInfo[@"headUrl"]) {
        self.imageUrl = userInfo[@"headUrl"];
        NSURL *imgurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@!HeaderInfo",userInfo[@"headUrl"]]];
        [_picImgView sd_setImageWithURL:imgurl placeholderImage:[UIImage imageNamed:@"个人设置-我的头像"]];
    }
    
    if (userInfo[@"userName"]) {
        nameTextField.text = userInfo[@"userName"];
    }
    
    if (userInfo[@"birthday"]) {
        [_selectTimeButton setTitle:userInfo[@"birthday"] forState:UIControlStateNormal];
    }

    UIButton *yangButton = [_calendarBGView viewWithTag:200];
    UIButton *yinButton = [_calendarBGView viewWithTag:201];
    if ([userInfo[@"birthdayType"] isEqualToString:@"1"]) {

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
    
//    NSString *manImgName = @"UC_man.png";//sender.view.tag >500 ? @"UC_man.png":@"UC_man_click.png";
//    NSString *womanImgName = @"UC_woman_click.png";//sender.view.tag >500 ? @"UC_woman_click.png":@"UC_woman.png";
    
    if ([userInfo[@"gender"] isEqualToString:@"1"]) {
        isSexWithMan = NO;
        UIView *womanBGView = _sexWomanBGView;//sender.view;
        womanBGView.backgroundColor = blueColor;
        UIImageView *womanImgView = [womanBGView viewWithTag:100];
        womanImgView.image = [UIImage imageNamed:@"UC_woman_click.png"];
        UILabel *womanLabel = [womanBGView viewWithTag:101];
        womanLabel.textColor = whiteColor;
        
        
        UIView *manBGView = _sexManBGView;
        manBGView.backgroundColor = whiteColor;
        UIImageView *manImgView = [manBGView viewWithTag:100];
        manImgView.image = [UIImage imageNamed:@"UC_woman.png"];
        UILabel *manLabel = [manBGView viewWithTag:101];
        manLabel.textColor = blueColor;
        manBGView.layer.borderWidth = 1;
        manBGView.layer.borderColor = blueColor.CGColor;
        
    } else {
    
        isSexWithMan = YES;
        UIView *manBGView = _sexWomanBGView;//sender.view;
        manBGView.backgroundColor = blueColor;
        UIImageView *manImgView = [manBGView viewWithTag:100];
        manImgView.image = [UIImage imageNamed:@"UC_man.png"];
        UILabel *manLabel = [manBGView viewWithTag:101];
        manLabel.textColor = whiteColor;
        
        
        UIView *womanBGView = _sexWomanBGView;
        womanBGView.backgroundColor = whiteColor;
        UIImageView *womanImgView = [womanBGView viewWithTag:100];
        womanImgView.image = [UIImage imageNamed:@"UC_woman.png"];
        UILabel *womanLabel = [womanBGView viewWithTag:101];
        womanLabel.textColor = blueColor;

    }
    
}

- (IBAction)selectSex:(UITapGestureRecognizer *)sender {
    NSString *manImgName = sender.view.tag >500 ? @"UC_man.png":@"UC_man_click.png";
    NSString *womanImgName = sender.view.tag >500 ? @"UC_woman_click.png":@"UC_woman.png";
    
    switch (sender.view.tag) {
        case 500:
        {
            isSexWithMan = YES;
            UIView *manBGView = sender.view;
            manBGView.backgroundColor = blueColor;
            UIImageView *manImgView = [manBGView viewWithTag:100];
            manImgView.image = [UIImage imageNamed:manImgName];
            UILabel *manLabel = [manBGView viewWithTag:101];
            manLabel.textColor = whiteColor;
            
            
            UIView *womanBGView = _sexWomanBGView;
            womanBGView.backgroundColor = whiteColor;
            UIImageView *womanImgView = [womanBGView viewWithTag:100];
            womanImgView.image = [UIImage imageNamed:womanImgName];
            UILabel *womanLabel = [womanBGView viewWithTag:101];
            womanLabel.textColor = blueColor;
            
        }
            
            break;
        case 501:
        {
            isSexWithMan = NO;
            UIView *womanBGView = sender.view;
            womanBGView.backgroundColor = blueColor;
            UIImageView *womanImgView = [womanBGView viewWithTag:100];
            womanImgView.image = [UIImage imageNamed:womanImgName];
            UILabel *womanLabel = [womanBGView viewWithTag:101];
            womanLabel.textColor = whiteColor;
            
            
            UIView *manBGView = _sexManBGView;
            manBGView.backgroundColor = whiteColor;
            UIImageView *manImgView = [manBGView viewWithTag:100];
            manImgView.image = [UIImage imageNamed:manImgName];
            UILabel *manLabel = [manBGView viewWithTag:101];
            manLabel.textColor = blueColor;
            manBGView.layer.borderWidth = 1;
            manBGView.layer.borderColor = blueColor.CGColor;
        }
            
        default:
            break;
    }
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectPic:(UITapGestureRecognizer *)sender {
    
    __weak typeof(self) weakSelf = self;
    
    [ImagePicker showImagePickerFromViewController:self allowsEditing:YES finishAction:^(UIImage *image) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (image)
        {
            
            _picImgView.image = image;
            
            [strongSelf uploadImage];
        
            
//            NSData *imgData =  UIImageJPEGRepresentation(image, 0.1);
//            [userImage sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:image];
//            
//            boundary = @"----------V2ymHFg03ehbqgZCaKO6jy";
//            fileParam = @"file";
//            baseUrl = [NSString stringWithFormat:@"%@yh/n/uploadHeadPortrait",BASE_URL];
//            fileName = @"image.png";//此文件提前放在可读写区域
//            //此处首先指定了图片存取路径（默认写到应用程序沙盒中）
//            NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//            
//            //并给文件起个文件名
//            NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"image.png"];
//            
//            BOOL result=[imgData writeToFile:uniquePath atomically:YES];
//            if(result){
//                
//            }else{
//                
//            }
//            [self method4];
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
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
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
    AppDelegate *app = [UIApplication sharedApplication].delegate;
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
                             
                             [MBProgressHUD hideHUD];
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             strongSelf.imageUrl = [NSString stringWithFormat:@"%@/%@",HTTP_IMAGE,imgName];
                             
                             [CoreArchive setBool:YES key:USERIHEADIMG];
                             
                             [strongSelf personHeadDataRefresh];
                             
                             
                         }failure:^(NSError *error,NSHTTPURLResponse *response,NSDictionary *responseBody) { //上传失败
                             
                             [MBProgressHUD hideHUD];
                            __strong typeof(weakSelf) strongSelf = weakSelf;
                             
                             _picImgView.image = nil;
                             [strongSelf showAlertViewWithTitle:@"提示" message:@"请求失败" buttonTitle:@"确定" clickBtn:^{
                                 
                             }];
                             
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
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
            NSMutableDictionary *dict = [@{} mutableCopy];
            [dict setObject:strongSelf.imageUrl forKey:@"headUrl"];
            [dict setObject:strongSelf.imageUrl forKey:@"portraitUrl"];
            [dict addEntriesFromDictionary:userInfo];
            [CoreArchive setDic:dict key:USERINFO];
            
            [strongSelf.delegate userCenterViewControllerWithHeadImgRefresh:_picImgView.image];
            
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

-(void)refreshPersonData {

    NSString *gender = isSexWithMan ? @"0":@"1";
    NSString *birthday_type = isYingLi ? @"0": @"1";
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //用[NSDate date]可以获取系统当前时间
    NSString *birthday = [dateFormatter stringFromDate:[NSDate date]];
    
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
        [CoreArchive setDic:[userInfo transforeNullValueInSimpleDictionary] key:USERINFO];

        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            [MBProgressHUD showSuccess:@"保存成功"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf.navigationController popViewControllerAnimated:YES];
            });
            
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
