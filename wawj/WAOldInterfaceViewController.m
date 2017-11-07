//
//  WAOldInterfaceViewController.m
//  wawj
//
//  Created by ruiyou on 2017/7/7.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAOldInterfaceViewController.h"

#import "WANetViewController.h"
#import "WAHomeViewController.h"
#import "WAFuctionSetViewController.h"
#import "WACommonlyPhoneViewController.h"
#import "WACommonlyAPPViewController.h"
#import<AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import "WABindIphoneViewController.h"
#import "WANewInterfaceViewController.h"
#import <Photos/Photos.h>
#import <JPUSHService.h>
#import <sys/utsname.h>
#define ChineseMonths @[@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",@"九月", @"十月", @"冬月", @"腊月"]
#define ChineseDays @[@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",@"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十", @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十"]

@interface WAOldInterfaceViewController ()<MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnViewConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleViewHeght;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantHeadTop;

@property (weak, nonatomic) IBOutlet UIImageView *backGroudImg;
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet UILabel *timeOne;
@property (weak, nonatomic) IBOutlet UILabel *timeTwo;
@property (weak, nonatomic) IBOutlet UILabel *phoneText;
@property(nonatomic, strong)NSArray *arrText;
@property (weak, nonatomic) IBOutlet UIView *phoneView;

@end

@implementation WAOldInterfaceViewController
{
    BOOL LightOn;
    AVCaptureDevice *device;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}


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

-(BOOL)checkPhotoLibraryPermission {
//    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied ){
        //无权限
        [self showAlertViewWithTitle:@"\n未开启 \"相机\"权限 \n\n" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"去开启" clickOtherBtn:^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                
                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
                
            }
        }];
        
        return NO;
        
    } else if (status == AVAuthorizationStatusNotDetermined) {
        
//        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//
//            if (status == PHAuthorizationStatusAuthorized) {
//
//                // TODO:...
//            }
//        }];
        
        return NO;
    }
    
    return YES;
}

-(void)initViews {
    
    self.arrText = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"*",@"0",@"后退"];
    CGFloat height = (SCREEN_HEIGHT- 423 - 1 - 1.5)/4;
    if ([self isIphone5]) {
        self.constantHeadTop.constant = -50;
        self.middleViewHeght.constant = 160;
        height = (SCREEN_HEIGHT-350 - 1 - 1.5)/4;
    }
    CGFloat width = (SCREEN_WIDTH-1)/3;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 1, 1);
    UIImage *bgImage = [UIImage imageNamed:@"grayBg"];
    bgImage = [bgImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeTile];
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 3; j++) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            NSInteger index = i*3+j;
            [btn setTitle:self.arrText[index] forState:UIControlStateNormal];
            btn.titleLabel.textColor = [UIColor whiteColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:35];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.frame = CGRectMake(j*(width+0.5), i*(height+0.5), width, height);
//            NSLog(@"btn.frame: %@", NSStringFromCGRect(btn.frame));
            [btn setBackgroundImage:bgImage forState:UIControlStateNormal];
            btn.tag = index;
            [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            [self.btnView addSubview:btn];
            
        }
    }
    
    
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSString *weekDay;
    NSDate *dateNow;
    dateNow = [NSDate date];//[NSDate dateWithTimeIntervalSinceNow:dayDelay*24*60*60];//dayDelay代表向后推几天，如果是0则代表是今天，如果是1就代表向后推24小时，如果想向后推12小时，就可以改成dayDelay*12*60*60,让dayDelay＝1
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
     NSCalendar *chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];

    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;//这句我也不明白具体时用来做什么。。。
    comps = [calendar components:unitFlags fromDate:dateNow];
   
    long weekNumber = [comps weekday]; //获取星期对应的长整形字符串
    long day=[comps day];//获取日期对应的长整形字符串
    long month=[comps month];//获取月对应的长整形字符串

    switch (weekNumber) {
        case 1:
            weekDay=@"周日";
            break;
        case 2:
            weekDay=@"周一";
            break;
        case 3:
            weekDay=@"周二";
            break;
        case 4:
            weekDay=@"周三";
            break;
        case 5:
            weekDay=@"周四";
            break;
        case 6:
            weekDay=@"周五";
            break;
        case 7:
            weekDay=@"周六";
            break;
            
        default:
            break;
    }
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    self.timeOne.text = currentDateStr;
    
    NSString *monthStr = month < 10 ? [NSString stringWithFormat:@"0%ld",month] : [NSString stringWithFormat:@"%ld",month];
    NSString *dayStr = day < 10 ? [NSString stringWithFormat:@"0%ld",day] : [NSString stringWithFormat:@"%ld",day];
    
    comps = [chineseCalendar components:unitFlags fromDate:dateNow];
    NSString *riQi =[NSString stringWithFormat:@"%@月%@日   %@   %@%@",monthStr,dayStr,weekDay, ChineseMonths[comps.month-1],ChineseDays[comps.day-1]];//把日期长整形转成对应的汉字字符串
    
    self.timeTwo.text = riQi;

    
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeUp) userInfo:nil repeats:YES];
    
    
    self.phoneView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
    
    
    
    
}

-(void)timeUp {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    self.timeOne.text = [dateFormatter stringFromDate:[NSDate date]];
    
}

-(void)clickBtn:(UIButton *)btn {
    
    NSString *origin = self.phoneText.text;
    if (![self.arrText[btn.tag] isEqualToString:@"后退"]) {
        self.phoneText.text = [origin stringByAppendingString:self.arrText[btn.tag]];
    } else {
        self.phoneText.text = origin.length ? [origin substringToIndex:origin.length-1] : @"";
    }
    
    //self.phoneView.hidden = self.phoneText.text.length ? NO:YES;
    
    if (self.phoneText.text.length) {
        self.phoneText.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    } else {
        self.phoneText.backgroundColor = [UIColor clearColor];
    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViews];
    
    [CoreArchive setBool:NO key:INTERFACE_NEW];
    
    
//    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
////    //删除别名
////    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
////
////    } seq:[[NSDate date] timeIntervalSince1970]];
//    
//    //设置别名
//    NSString *userid = [NSString stringWithFormat:@"%@", userInfo[USERID]];
//    [JPUSHService setAlias:userid completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
//        if (0 == iResCode) {
//            NSLog(@"设置别名成功: %@", iAlias);
//        } else {
//            NSLog(@"设置别名失败");
//        }
//    } seq:[[NSDate date] timeIntervalSince1970]];
    [JPUSHService getAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        NSLog(@"得到别名: %@", iAlias);
    } seq:1];
}

- (IBAction)clickAOne:(UIButton *)sender {
    
    WAHomeViewController *vc = [[WAHomeViewController alloc] initWithNibName:@"WAHomeViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)clickATwo:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"WANetViewController" sender:nil];
    
}

- (IBAction)clickAThree:(UIButton *)sender {
    
    WACommonlyAPPViewController *vc = [[WACommonlyAPPViewController alloc] initWithNibName:@"WACommonlyAPPViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];

    
}

- (IBAction)clickAFour:(UIButton *)sender {
    
    if ([self.phoneText.text isEqualToString:@""]) {
        WACommonlyPhoneViewController *vc = [[WACommonlyPhoneViewController alloc] initWithNibName:@"WACommonlyPhoneViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
//        [self showAlertViewWithTitle:@"您还未拨号" message:nil buttonTitle:@"确定" clickBtn:^{
//
//        }];
    } else {
        
        [self showAlertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"是否拨打%@",self.phoneText.text] cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"拨打" clickOtherBtn:^{
            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",self.phoneText.text];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

        }];
        
    }
    
}

- (IBAction)clickBOne:(UIButton *)sender {
    
    if (![device hasTorch]) {
     
        return;
        
    }
    
    LightOn = !LightOn;
    
    if (LightOn) {
        
        
        
        [self turnOn];
        
    }else{
        
        [self turnOff];
        
    }
    
}

-(void) turnOn

{
 
    [self.backGroudImg setImage:[UIImage imageNamed:@"homeLightOn"]];
    
    [device lockForConfiguration:nil];
    
    [device setTorchMode:AVCaptureTorchModeOn];
    
    [device unlockForConfiguration];
    
}

-(void) turnOff

{
    [self.backGroudImg setImage:[UIImage imageNamed:@"homeLightOff"]];
    
    [device lockForConfiguration:nil];
    
    [device setTorchMode: AVCaptureTorchModeOff];
    
    [device unlockForConfiguration];
    
}

- (IBAction)clickBTwo:(UIButton *)sender {
    
    WAFuctionSetViewController *vc = [[WAFuctionSetViewController alloc] initWithNibName:@"WAFuctionSetViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)clickBThree:(UIButton *)sender {

    //[[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

    [self handlePhoto];
//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=Photos"]];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Photos"]];
    
    [self playAudioWithFilePath:@"Users/ruiyou/Library/Developer/CoreSimulator/Devices/0FCA3E2B-6364-48BA-BE4F-8DF57166C841/data/Containers/Data/Application/ED7D5C5B-DC73-4159-AB54-505913BBF7F0/Documents/1509273420.caf"];
}

#pragma -mark 播放本地音频
-(void)playAudioWithFilePath:(NSString *)audioFilePath {
    
    
//    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:audioFilePath];
//    if (!exists) {
//        [MBProgressHUD showError:@"播放失败"];
//        return;
//    }
//    
//    NSData *data = [[NSFileManager defaultManager] contentsAtPath:audioFilePath];
//    //    NSURL *url= [NSURL URLWithString:audioFilePath];
//    
//    NSError *error=nil;
//    self.audioFilePlayer=[[AVAudioPlayer alloc] initWithData:data error:&error];
//    self.audioFilePlayer.numberOfLoops=0;
//    self.audioFilePlayer.volume = 1;
//    [self.audioFilePlayer prepareToPlay];
//    if (error) {
//        NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
//        [MBProgressHUD showError:@"播放失败"];
//        return ;
//    }
//    
//    [self.audioFilePlayer play];
    
}


- (void)handlePhoto {
    
    
    if (![self checkPhotoLibraryPermission]) {
        return;
    }
    
    // UIImagePickerControllerCameraDeviceRear 后置摄像头
    // UIImagePickerControllerCameraDeviceFront 前置摄像头
    
    //判断摄像头是否可用
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    
    if (!isCamera) {
        NSLog(@"没有摄像头");
        return;
    }
    //初始化图片选择控制器
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;//设置通过照相来选取照片
    
    imagePicker.allowsEditing = YES; //设置拍照时的下方的工具栏是否显示，如果需要自定义拍摄界面，则可把该工具栏隐藏
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

//得到图片或者视频后, 调用该代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //在这个方法里我们可以进行图片的修改, 保存, 或者视频的保存
    // UIImagePickerControllerOriginalImage 原始图片
    // UIImagePickerControllerEditedImage 编辑后图片
//    UIImage *images = [info objectForKey:UIImagePickerControllerOriginalImage];
////    _imageView.image = image;
//    CGFloat fixelW = CGImageGetWidth(images.CGImage);
//    CGFloat fixelH = CGImageGetHeight(images.CGImage);
//    NSLog(@"fixelW: %f %f", fixelH,fixelW);
//
//    NSString *imageDocPath = [self getImageSavePath];//保存
//    _photoUrl = imageDocPath;
//    NSLog(@"imageDocPath == %@", imageDocPath);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//当用户取消相册时, 调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//在这里创建一个路径，用来在照相的代理方法里作为照片存储的路径
-(NSString *)getImageSavePath{
    //获取存放的照片
    //获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"PhotoFile"];
    return imageDocPath;
}

//发短信
- (IBAction)clickBFour:(UIButton *)sender {
    
    [self sendMessageBut];
}

/** 点击发送短信按钮*/
- (void)sendMessageBut {
    /** 如果可以发送文本消息(不在模拟器情况下*/
    if ([MFMessageComposeViewController canSendText]) {
        /** 创建短信界面(控制器*/
        MFMessageComposeViewController *controller = [MFMessageComposeViewController new];
//        controller.recipients = @[self.phoneTextField.text];//短信接受者为一个NSArray数组
//        controller.body = self.messageBody.text;//短信内容
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








