//
//  WAPreviewRecordViewController.m
//  wawj
//
//  Created by ruiyou on 2017/10/19.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAPreviewRecordViewController.h"
#import <UIImageView+WebCache.h>
#import "CircularView.h"
#import <AVFoundation/AVFoundation.h>

#define kRecordAudioFile @"myRecord.caf"

@interface WAPreviewRecordViewController ()<AVAudioPlayerDelegate,CircularViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIButton *startStopBtn;
@property (weak, nonatomic) IBOutlet CircularView *cicularView;
@property (weak, nonatomic) IBOutlet UILabel *recordDateLab;

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件

@end

@implementation WAPreviewRecordViewController

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = @"预览闹钟";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!%@",self.headUrl,WEBP_HEADER_FAMILY]] placeholderImage:[UIImage imageNamed:@"头像设置"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    
    self.recordDateLab.text = self.recordedDate;
    self.cicularView.delegate = self;
    
    self.startStopBtn.selected = YES;
    [self.startStopBtn setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [self.startStopBtn setImage:[UIImage imageNamed:@"friends"] forState:UIControlStateSelected];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
    [self setAudioSession];
    
    
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.cicularView startCircleWithTimeLength:self.recordedTime];
    [self.audioPlayer play];
    
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

///**
// *  取得录音文件保存路径
// *
// *  @return 录音文件路径
// */
//-(NSURL *)getSavePath{
//    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
//    NSLog(@"file path:%@",urlStr);
//    NSURL *url=[NSURL fileURLWithPath:urlStr];
//    return url;
//}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url= [NSURL URLWithString:self.audioUrl];//[self getSavePath];
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

#pragma -mark CircularViewDelegate

-(void)circularViewStartDraw {
    
}

-(void)circularViewWithProgress:(NSInteger)progress {
    
    if (self.recordedTime == progress) {
        self.startStopBtn.selected = NO;
    }
}

-(void)circularViewEndDraw {
    
    self.startStopBtn.selected = NO;
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
