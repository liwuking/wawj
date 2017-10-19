
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
#define RECORD_TOTAL_TIME   10
#define kRecordAudioFile @"myRecord.caf"

@interface WARemindFamilyViewController ()<UITextViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,CircularViewDelegate,DatePickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *recordTimeLab;
@property (weak, nonatomic) IBOutlet UIButton *previewBtn;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet CircularView *cicularView;

@property (weak, nonatomic) IBOutlet UIButton *recordbtn;
@property (weak, nonatomic) IBOutlet UILabel *timeOneLab;
@property (weak, nonatomic) IBOutlet UILabel *timeTwoLab;
@property (weak, nonatomic) IBOutlet UIButton *startStopBtn;

//@property(nonatomic,strong)NSTimer *recordTimer;
@property(nonatomic,assign)NSInteger recordedTime;
@property(nonatomic,strong)DatePickerView *datePickerView;

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
//@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）
@end
//219CE0
@implementation WARemindFamilyViewController

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = [NSString stringWithFormat:@"给%@定个闹钟",self.closeFamilyItem.qinmiName];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!HeaderFamily",self.closeFamilyItem.headUrl]] placeholderImage:[UIImage imageNamed:@"头像设置"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *currentDateDD = [dateFormatter stringFromDate:[NSDate date]];
    self.timeOneLab.text = currentDateDD;;

    
    self.cicularView.delegate = self;
    [self.startStopBtn setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [self.startStopBtn setImage:[UIImage imageNamed:@"friends"] forState:UIControlStateSelected];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.recordedTime = 0;
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
-(NSURL *)getSavePath{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
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
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
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
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
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
        NSURL *url=[self getSavePath];
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
    } else {
        [self.cicularView endCircle];
        [self.audioPlayer stop];
    }
}

- (IBAction)clickPreviewBtn:(UIButton *)sender {
    
    WAPreviewRecordViewController *vc = [[WAPreviewRecordViewController alloc] initWithNibName:@"WAPreviewRecordViewController" bundle:nil];
    vc.headUrl = self.closeFamilyItem.headUrl;
    vc.recordedTime = self.recordedTime;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)clickRecordBtn:(UIButton *)sender {
    
    if ([self.recordbtn.titleLabel.text isEqualToString:@"点击录音"]) {
        
        [self.recordbtn setTitle:@"停止录音" forState:UIControlStateNormal];
        
        self.recordTimeLab.hidden = NO;
        self.previewBtn.hidden = NO;
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
        self.previewBtn.hidden = NO;
        self.startStopBtn.hidden = NO;
         self.startStopBtn.selected = NO;
        
    } else if ([self.recordbtn.titleLabel.text isEqualToString:@"重新录音"]) {
        
        if (![self.audioRecorder isRecording]) {
            [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        }
        
        [self.recordbtn setTitle:@"停止录音" forState:UIControlStateNormal];
        
        self.recordTimeLab.hidden = NO;
        self.previewBtn.hidden = NO;
        self.startStopBtn.hidden = YES;
        
        self.recordedTime = 0;
        [self.cicularView startCircleWithTimeLength:RECORD_TOTAL_TIME];
        
    }
    
}

#pragma -mark CircularViewDelegate

-(void)circularViewStartDraw {
    
}

-(void)circularViewWithProgress:(NSInteger)progress {
    
    if ([self.audioRecorder isRecording]) {
        self.recordTimeLab.text =  [NSString stringWithFormat:@"%lds",  RECORD_TOTAL_TIME-progress];
        self.recordedTime = progress;
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
    
}

-(void)datePickerViewWithHidden {
    [self.datePickerView removeFromSuperview];
    self.datePickerView = nil;
}

- (IBAction)clickSelectTimeView:(UITapGestureRecognizer *)sender {
    
    self.datePickerView = [[[NSBundle mainBundle] loadNibNamed:@"DatePickerView" owner:self options:nil] lastObject];
    self.datePickerView.delegate = self;
    self.datePickerView.currentTime = self.timeOneLab.text;
    [self.view addSubview:self.datePickerView];
    
    
    
}

- (IBAction)clickRemindBtn:(UIButton *)sender {
    
    if ([self.timeTwoLab.text isEqualToString:@"今天"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone localTimeZone];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDateDD = [dateFormatter stringFromDate:[NSDate date]];
        NSString *remindDateMM = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,self.timeOneLab.text];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *remindDate = [dateFormatter dateFromString:remindDateMM];
        NSDate *validDate = [NSDate dateWithTimeIntervalSinceNow:5*60];
        if ([remindDate compare:validDate] == NSOrderedAscending ) {
            [MBProgressHUD showSuccess:@"请选择有效时间"];
            return;
        }
        
    }
    
}

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
