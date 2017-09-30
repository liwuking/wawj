//
//  WANewInterfaceViewController.m
//  wawj
//
//  Created by ruiyou on 2017/8/15.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WANewInterfaceViewController.h"
#import "WANetViewController.h"
#import "WAHomeViewController.h"
#import "WAFuctionSetViewController.h"
#import "WACommonlyPhoneViewController.h"
#import "WACommonlyAPPViewController.h"
#import<AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>

#define ChineseMonths @[@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",@"九月", @"十月", @"冬月", @"腊月"]
#define ChineseDays @[@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",@"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十", @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十"]


@interface WANewInterfaceViewController ()<MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;

@end

@implementation WANewInterfaceViewController
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

-(void)initViews {
    
    NSString *weekDay;
    NSDate *dateNow;
    int dayDelay = 0;
    dateNow=[NSDate dateWithTimeIntervalSinceNow:dayDelay*24*60*60];//dayDelay代表向后推几天，如果是0则代表是今天，如果是1就代表向后推24小时，如果想向后推12小时，就可以改成dayDelay*12*60*60,让dayDelay＝1
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
    NSCalendar *chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    //    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;//这句我也不明白具体时用来做什么。。。
    NSInteger unitFlags =NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;//这句我也不明白具体时用来做什么。。。
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
    self.timeLab.text = currentDateStr;
    
    NSString *monthStr = month < 10 ? [NSString stringWithFormat:@"0%ld",month] : [NSString stringWithFormat:@"%ld",month];
    NSString *dayStr = day < 10 ? [NSString stringWithFormat:@"0%ld",day] : [NSString stringWithFormat:@"%ld",day];
    
    comps = [chineseCalendar components:unitFlags fromDate:dateNow];
    long lunarDay=[comps day];//获取日期对应的长整形字符串
    long lunarMonth=[comps month];//获取月对应的长整形字符串
    
    NSString *riQi =[NSString stringWithFormat:@"%@月%@日 %@ %@%@",monthStr,dayStr,weekDay, ChineseMonths[lunarMonth],ChineseDays[lunarDay]];//把日期长整形转成对应的汉字字符串
    
    self.dateLab.text = riQi;
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeUp) userInfo:nil repeats:YES];
    
}

-(void)timeUp {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    self.timeLab.text = [dateFormatter stringFromDate:[NSDate date]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [CoreArchive setBool:YES key:INTERFACE_NEW];
     device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [self initViews];
    
}
- (IBAction)clickMyHome:(UIButton *)sender {
    
    WAHomeViewController *vc = [[WAHomeViewController alloc] initWithNibName:@"WAHomeViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)clickPhone:(UIButton *)sender {
    WACommonlyPhoneViewController *vc = [[WACommonlyPhoneViewController alloc] initWithNibName:@"WACommonlyPhoneViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickWebBtn:(UIButton *)sender {

    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self.navigationController pushViewController:[sb instantiateViewControllerWithIdentifier:@"WANetViewController"] animated:YES];
    
}

- (IBAction)clickCameraBtn:(UIButton *)sender {
    [self handlePhoto];
}

- (IBAction)clickLightBtn:(UIButton *)sender  {
    
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
    
    [self.bgView setImage:[UIImage imageNamed:@"rightImgLight"]];
    
    [device lockForConfiguration:nil];
    
    [device setTorchMode:AVCaptureTorchModeOn];
    
    [device unlockForConfiguration];
    
}

-(void) turnOff

{
    [self.bgView setImage:[UIImage imageNamed:@"rightImgNormal"]];
    
    [device lockForConfiguration:nil];
    
    [device setTorchMode: AVCaptureTorchModeOff];
    
    [device unlockForConfiguration];
    
}
- (IBAction)clickAppBtn:(UIButton *)sender {
    WACommonlyAPPViewController *vc = [[WACommonlyAPPViewController alloc] initWithNibName:@"WACommonlyAPPViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)handlePhoto {
    // UIImagePickerControllerCameraDeviceRear 后置摄像头
    //    UIImagePickerControllerCameraDeviceFront 前置摄像头
    
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
    //    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //    _imageView.image = image;
    
    
    NSString *imageDocPath = [self getImageSavePath];//保存
    //    _photoUrl = imageDocPath;
    NSLog(@"imageDocPath == %@", imageDocPath);
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end