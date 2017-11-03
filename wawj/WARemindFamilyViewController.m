
//
//  WARemindFamilyViewController.m
//  wawj
//
//  Created by ruiyou on 2017/10/18.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WARemindFamilyViewController.h"
#import <UIImageView+WebCache.h>
#import "CircularView.h"
#import "WAPreviewRecordViewController.h"
#import "DatePickerView.h"
#import <AVFoundation/AVFoundation.h>
#import "UpYun.h"
#import "UpYunFormUploader.h"
#import "UpYunBlockUpLoader.h"
#import <JPUSHService.h>

#define RECORD_TOTAL_TIME   30
#define kRecordAudioFile @"myRecord.caf"

@interface WARemindFamilyViewController ()<UITextViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,CircularViewDelegate,DatePickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *remindBtn;
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLab;
@property (weak, nonatomic) IBOutlet UIButton *previewBtn;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet CircularView *cicularView;

@property (weak, nonatomic) IBOutlet UIButton *recordbtn;
@property (weak, nonatomic) IBOutlet UILabel *timeOneLab;
@property (weak, nonatomic) IBOutlet UILabel *timeTwoLab;
@property (weak, nonatomic) IBOutlet UIButton *startStopBtn;

@property(nonatomic,assign)NSInteger recordTimeStamp;

@property(nonatomic,assign)NSInteger recordedTime;
@property(nonatomic,strong)DatePickerView *datePickerView;

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@end
//219CE0
@implementation WARemindFamilyViewController

-(void)backAction {
    
    [self removeRecordFile];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = [NSString stringWithFormat:@"给%@定个闹钟",self.closeFamilyItem.qinmiName];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!%@",self.closeFamilyItem.headUrl,WEBP_HEADER_FAMILY]] placeholderImage:[UIImage imageNamed:@"头像设置"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *currentDateMM = [dateFormatter stringFromDate:[NSDate date]];
    self.timeOneLab.text = currentDateMM;;
    
    self.cicularView.delegate = self;
    [self.startStopBtn setImage:[UIImage imageNamed:@"audioStart"] forState:UIControlStateNormal];
    [self.startStopBtn setImage:[UIImage imageNamed:@"audioStop"] forState:UIControlStateSelected];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.recordedTime = 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateDD = [dateFormatter stringFromDate:[NSDate date]];
    NSString *remindDateMM = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,self.timeOneLab.text];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *remindDatem = [dateFormatter dateFromString:remindDateMM];
    NSInteger remindStamp = [remindDatem timeIntervalSince1970];
    self.recordTimeStamp = remindStamp;
    
    [self initViews];
    [self setAudioSession];

}

/**
 *  设置音频会话
 */
-(void)setAudioSession{
    
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSString *)getSavePath{
    

    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    
    NSLog(@"file path:%@",urlStr);
//    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return urlStr;
}

-(void)removeRecordFile {
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url= [NSURL fileURLWithPath:[self getSavePath]];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
//        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url=[NSURL fileURLWithPath:[self getSavePath]];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
        _audioPlayer.volume = 1;
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}


#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    NSLog(@"录音完成!");
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag{
    //播放结束时执行的动作
    self.startStopBtn.selected = NO;
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error{
    //解码错误执行的动作
}
- (void)audioPlayerBeginInteruption:(AVAudioPlayer*)player{
    //处理中断的代码
}
- (void)audioPlayerEndInteruption:(AVAudioPlayer*)player{
    //处理中断结束的代码
}

- (IBAction)clickStartBtn:(UIButton *)sender {
    
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.cicularView startCircleWithTimeLength:self.recordedTime];
        [self.audioPlayer play];
        self.previewBtn.hidden = YES;
    } else {
        [self.cicularView endCircle];
        [self.audioPlayer stop];
        self.previewBtn.hidden = NO;
    }
}

- (IBAction)clickPreviewBtn:(UIButton *)sender {
    
    WAPreviewRecordViewController *vc = [[WAPreviewRecordViewController alloc] initWithNibName:@"WAPreviewRecordViewController" bundle:nil];
    vc.headUrl = self.closeFamilyItem.headUrl;
    vc.recordedTime = self.recordedTime;
    vc.recordedDate = self.timeOneLab.text;
    vc.audioUrl = [self getSavePath];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)clickRecordBtn:(UIButton *)sender {
    
    if ([self.recordbtn.titleLabel.text isEqualToString:@"点击录音"]) {
        
        [self.recordbtn setTitle:@"停止录音" forState:UIControlStateNormal];
        
        self.recordTimeLab.hidden = NO;
        self.previewBtn.hidden = YES;
        self.startStopBtn.hidden = YES;
        
        self.recordedTime = 0;
        [self.cicularView startCircleWithTimeLength:RECORD_TOTAL_TIME];
        
        if (![self.audioRecorder isRecording]) {
            [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        }
        
    } else if ([self.recordbtn.titleLabel.text isEqualToString:@"停止录音"]) {
        
        if ([self.audioRecorder isRecording]) {
            [self.audioRecorder stop];
        }
        [self.cicularView endCircle];
        
        [self.recordbtn setTitle:@"重新录音" forState:UIControlStateNormal];
        
        self.recordTimeLab.text =  [NSString stringWithFormat:@"已录音%lds",  self.recordedTime];
        
        self.previewBtn.hidden = NO;
        self.startStopBtn.hidden = NO;
        self.startStopBtn.selected = NO;
  
    } else if ([self.recordbtn.titleLabel.text isEqualToString:@"重新录音"]) {
        
        if (![self.audioRecorder isRecording]) {
            [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        }
        
        [self.recordbtn setTitle:@"停止录音" forState:UIControlStateNormal];
        
        self.recordTimeLab.hidden = NO;
        self.previewBtn.hidden = YES;
        self.startStopBtn.hidden = YES;
        
        [self.cicularView startCircleWithTimeLength:RECORD_TOTAL_TIME];
        
        self.remindBtn.enabled = NO;
        [self.remindBtn setBackgroundColor:HEX_COLOR(0x79C6ED)];
    }
    
}

#pragma -mark CircularViewDelegate

-(void)circularViewStartDraw {
    
}

-(void)circularViewWithProgress:(NSInteger)progress {
    
    if ([self.audioRecorder isRecording]) {
        self.recordTimeLab.text =  [NSString stringWithFormat:@"%lds",  RECORD_TOTAL_TIME-progress];
        self.recordedTime = progress;
        
        if (self.recordedTime >= 5) {
            self.remindBtn.enabled = YES;
            [self.remindBtn setBackgroundColor:HEX_COLOR(0x219CE0)];
        }
        
    }

}

-(void)circularViewEndDraw {
    
    if (![self.audioPlayer isPlaying]) {
        [self.recordbtn setTitle:@"重新录音" forState:UIControlStateNormal];
        self.recordTimeLab.text =  [NSString stringWithFormat:@"已录音%lds",  self.recordedTime];
        self.previewBtn.hidden = NO;
        self.startStopBtn.hidden = NO;
        self.startStopBtn.hidden = NO;
    }else {
        self.startStopBtn.selected = NO;
    }
    
    
}

#pragma -mark DatePickerViewDelegate

-(void)datePickerViewWithDate:(NSString *)day andTime:(NSString *)time {
    
    [self.datePickerView removeFromSuperview];
    self.datePickerView = nil;
    
    self.timeOneLab.text = time;
    self.timeTwoLab.text = day;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *remindDate;
    if ([day isEqualToString:@"今天"]) {
        remindDate = [NSDate dateWithTimeIntervalSinceNow:0*24*60*60];
    } else if ([day isEqualToString:@"明天"]) {
        remindDate = [NSDate dateWithTimeIntervalSinceNow:1*24*60*60];
    }  else {
        remindDate = [NSDate dateWithTimeIntervalSinceNow:2*24*60*60];
    }
    NSString *currentDateDD = [dateFormatter stringFromDate:remindDate];
    NSString *remindDateMM = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,time];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *remindDatem = [dateFormatter dateFromString:remindDateMM];
    NSInteger remindStamp = [remindDatem timeIntervalSince1970];
    
    self.recordTimeStamp = remindStamp;
    
}

-(void)datePickerViewWithHidden {
    [self.datePickerView removeFromSuperview];
    self.datePickerView = nil;
}

- (IBAction)clickSelectTimeView:(UITapGestureRecognizer *)sender {
    
    self.datePickerView = [[[NSBundle mainBundle] loadNibNamed:@"DatePickerView" owner:self options:nil] lastObject];
    self.datePickerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.datePickerView.delegate = self;
    self.datePickerView.dayTime = self.timeTwoLab.text;
    self.datePickerView.currentTime = self.timeOneLab.text;
    self.datePickerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.datePickerView];

}

- (IBAction)clickRemindBtn:(UIButton *)sender {
    
    if (self.recordedTime < 5) {
        [self showAlertViewWithTitle:@"录音时间不得小于5s" message:nil buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if ([self.timeTwoLab.text isEqualToString:@"今天"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone localTimeZone];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDateDD = [dateFormatter stringFromDate:[NSDate date]];
        NSString *remindDateMM = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,self.timeOneLab.text];

        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *remindDate = [dateFormatter dateFromString:remindDateMM];
        
        NSDate *validDate = [NSDate dateWithTimeIntervalSinceNow:1*60];
        if ([remindDate compare:validDate] == NSOrderedAscending ) {
//            [MBProgressHUD showSuccess:@"请选择有效提醒时间"];
            [self showAlertViewWithTitle:@"请选择有效提醒时间,超出当前时间1分钟" message:nil buttonTitle:@"确定" clickBtn:^{
                
            }];
            return;
        }
    }
    
    //图片命名
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    
    UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
    NSString *bucketName = @"wawj-test";
    NSData *fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[self getSavePath]]];
    NSString *uuid = [NSString stringWithFormat:@"%ld", (long)[currentDate timeIntervalSince1970]];
    NSString *imgName=[NSString stringWithFormat:@"audio/%@/%@.caf", currentDateString,uuid];
    __weak __typeof__(self) weakSelf = self;
    
    [MBProgressHUD showMessage:nil];
    [up uploadWithBucketName:bucketName
                    operator:@"wawj2017"
                    password:@"1+1=2yes"
                    fileData:fileData
                    fileName:nil
                     saveKey:imgName
             otherParameters:nil
                     success:^(NSHTTPURLResponse *response,NSDictionary *responseBody) {  //上传成功
                         __strong __typeof__(weakSelf) strongSelf = weakSelf;
                         
                         NSString *audioUrl = [NSString stringWithFormat:@"%@/%@",HTTP_IMAGE,imgName];
                         
                         NSLog(@"photoUrl: %@", audioUrl);
                         
                         [strongSelf createRemindRequestWith:audioUrl];

                         
                     }failure:^(NSError *error,NSHTTPURLResponse *response,NSDictionary *responseBody) { //上传失败
//                         __strong __typeof__(weakSelf) strongSelf = weakSelf;
                         NSLog(@"上传失败");
                         
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [MBProgressHUD hideHUD];
                             [MBProgressHUD showError:@"上传失败"];
                         });
                         
                        
                         
                     }progress:^(int64_t completedBytesCount,int64_t totalBytesCount) {
                         NSLog(@"totalBytesCount: %lld  completedBytesCount: %lld",totalBytesCount,completedBytesCount);
                     }];
    
}

-(void)createRemindRequestWith:(NSString *)audioUrl {

    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *remindTime = [NSString stringWithFormat:@"%ld",self.recordedTime];
    NSDictionary *model = @{@"remindUser":self.closeFamilyItem.qinmiUser,
                            @"remindTime":[NSString stringWithFormat:@"%ld000",self.recordTimeStamp],
                            @"remindAudio":audioUrl,
                            @"remindSeconds":remindTime,
                            @"createUser":userInfo[USERID],
                            };
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2004" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        [MBProgressHUD hideHUD];
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        
        if ([code isEqualToString:@"1"]) {
//             [MBProgressHUD showError:@"已经提醒"];
//            [strongSelf addNotificationWithRemindContent:nil];
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

/*
- (void)addNotificationWithRemindContent:(NSString *)remindContent {
    
    JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
    content.title = @"提醒";
    content.subtitle = @"我爱我家";
    content.body = @"This is a test code";
    content.categoryIdentifier = @"Custom Category Name";
    
//    // 5s后提醒 iOS 10 以上支持
//    JPushNotificationTrigger *trigger1 = [[JPushNotificationTrigger alloc] init];
//    trigger1.timeInterval = 5;
//    //每小时重复 1 次 iOS 10 以上支持
//    JPushNotificationTrigger *trigger2 = [[JPushNotificationTrigger alloc] init];
//    trigger2.timeInterval = 3600;
//    trigger2.repeat = YES;
//
//    //每周一早上8：00提醒，iOS10以上支持
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    components.weekday = 2;
//    components.hour = 8;
//    JPushNotificationTrigger *trigger3 = [[JPushNotificationTrigger alloc] init];
//    trigger3.dateComponents = components;
//    trigger3.repeat = YES;
//
//    //#import <CoreLocation/CoreLocation.h>
//    //一到某地点提醒，iOS8以上支持
//    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(0, 0) radius:0 identifier:@"test"];
//    JPushNotificationTrigger *trigger4 = [[JPushNotificationTrigger alloc] init];
//    trigger4.region = region;
//
//    //5s后提醒，iOS10以下支持
//    JPushNotificationTrigger *trigger5 = [[JPushNotificationTrigger alloc] init];
//    trigger5.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    
    
    JPushNotificationTrigger *trigger;
    if (SYSTEM_VERSION >= 10) {
        trigger = [[JPushNotificationTrigger alloc] init];
        trigger.timeInterval = 1;
    } else {
        trigger = [[JPushNotificationTrigger alloc] init];
        trigger.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    }
    
    JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
    request.requestIdentifier = @"sampleRequest";
    request.content = content;
    request.trigger = trigger;
    request.completionHandler = ^(id result) {
        if (result) {
            NSLog(@"推送结果返回：%@", result);
        } else {
            NSLog(@"推送失败");
        }
    };
    [JPUSHService addNotification:request];
}
*/

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
