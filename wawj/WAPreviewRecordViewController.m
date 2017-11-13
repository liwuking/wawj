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
#import "WARemindFamilyViewController.h"
#import "amrFileCodec.h"

#define kRecordAudioFile @"myRecord.caf"

@interface WAPreviewRecordViewController ()<AVAudioPlayerDelegate,CircularViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstant;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *headImageGes;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIButton *startStopBtn;
@property (weak, nonatomic) IBOutlet CircularView *cicularView;
@property (weak, nonatomic) IBOutlet UILabel *recordDateLab;
@property (weak, nonatomic) IBOutlet UILabel *dayLab;

@property (weak, nonatomic) IBOutlet UILabel *remindDescLab;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation WAPreviewRecordViewController
- (IBAction)clickBackBtn:(id)sender {
    
    if (self.isFromRemindVC) {
        
         CloseFamilyItem *closeFamilyItem = [[CloseFamilyItem alloc] init];
        NSMutableArray *arr = [CoreArchive arrForKey:USER_QIMI_ARR];
        for (NSDictionary *dict in arr) {
            if ([dict[@"qinmiUser"] isEqualToString:self.createUser]) {
                closeFamilyItem.headUrl = dict[@"headUrl"];
                closeFamilyItem.qinmiName = dict[@"qinmiName"];
                closeFamilyItem.qinmiPhone = dict[@"qinmiPhone"];
                closeFamilyItem.qinmiUser = dict[@"qinmiUser"];
                closeFamilyItem.qinmiRole = dict[@"qinmiRole"];
                closeFamilyItem.qinmiRoleName = dict[@"qinmiRoleName"];
                break;
            }
        }
        
        WARemindFamilyViewController *vc = [[WARemindFamilyViewController alloc] initWithNibName:@"WARemindFamilyViewController" bundle:nil];
        vc.closeFamilyItem = closeFamilyItem;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        
        [self backAction];
        
    }
    
   
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.isFromRemindVC) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
    
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    if (!self.isFromRemindVC) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
    
    [super viewWillDisappear:animated];
    
    [self.audioPlayer stop];
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
     if (self.isFromRemindVC) {
         self.topConstant.constant = 0;
         self.remindDescLab.hidden = YES;
         self.title = [NSString stringWithFormat:@"%@的提醒", self.qinmiName];
         
         UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
         [backItem setTintColor:HEX_COLOR(0x666666)];
         [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
         self.navigationItem.leftBarButtonItem = backItem;
         
     } else {
         self.remindDescLab.text = [NSString stringWithFormat:@"%@的提醒", self.qinmiName];
     }
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!%@",self.headUrl,WEBP_HEADER_FAMILY]] placeholderImage:[UIImage imageNamed:@"头像设置"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    
    self.recordDateLab.text = self.recordedDate;
    self.dayLab.text = self.recordedDay;
    self.cicularView.radius = 107;
    self.cicularView.delegate = self;
    
    self.startStopBtn.selected = YES;
    [self.startStopBtn setImage:[UIImage imageNamed:@"audioStart"] forState:UIControlStateNormal];
    [self.startStopBtn setImage:[UIImage imageNamed:@"audioStop"] forState:UIControlStateSelected];
    
    if (self.isFromRemindVC) {
        [self.backBtn setTitle:@"我也提醒TA" forState:UIControlStateNormal];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
    [self setAudioSession];
    
    
   
    
}
- (IBAction)clickStart:(id)sender {
    
    self.startStopBtn.selected = !self.startStopBtn.selected;
    if (self.startStopBtn.selected) {
        [self.cicularView startCircleWithTimeLength:self.recordedTime];
        
        [self.audioPlayer play];
        
//        self.backBtn.enabled = NO;
//        [self.backBtn setBackgroundColor:HEX_COLOR(0x79C6ED)];
        
    } else {
        [self.cicularView endCircle];
        
        [self.audioPlayer stop];
        
//
//        self.backBtn.enabled = YES;
//        [self.backBtn setBackgroundColor:HEX_COLOR(0x219CE0)];
    }
}

- (IBAction)clickStartBtn:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.cicularView startCircleWithTimeLength:self.recordedTime];
        [self.audioPlayer play];
        
//        self.backBtn.enabled = NO;
//        [self.backBtn setBackgroundColor:HEX_COLOR(0x79C6ED)];
        
    } else {
        [self.cicularView endCircle];
        [self.audioPlayer stop];
        
//        self.backBtn.enabled = YES;
//        [self.backBtn setBackgroundColor:HEX_COLOR(0x219CE0)];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.audioUrl hasPrefix:@"http"]) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURL *URL = [NSURL URLWithString:self.audioUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        [MBProgressHUD showMessage:nil];
        __weak __typeof__(self) weakSelf = self;
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
           
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"MyRecord/%@",[response suggestedFilename]]];
            
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            [MBProgressHUD hideHUD];
            
            if (error) {
                [MBProgressHUD showError:@"音频播放出错"];
                return ;
            }
            
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            NSURL *sourceFilePath = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
            NSURL *destinationFilePath = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"MyRecord/%@",[response suggestedFilename]]];
            
            
            NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
            NSString *recordPath = [documentPath stringByAppendingPathComponent:@"MyRecord"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:recordPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:recordPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSError *errordd;
            [[NSFileManager defaultManager] moveItemAtURL:sourceFilePath toURL:destinationFilePath error:&errordd];
            
            
            NSString *downLoadAudioUrl = [NSString stringWithFormat:@"%@/%@",recordPath,[response suggestedFilename]];
            NSLog(@"File downloaded to: %@", downLoadAudioUrl);
            
            strongSelf.audioUrl = downLoadAudioUrl;
            [strongSelf.cicularView startCircleWithTimeLength:self.recordedTime];
            [strongSelf.audioPlayer play];
            
        }];
        [downloadTask resume];

    } else {
        [self.cicularView startCircleWithTimeLength:self.recordedTime];
        [self.audioPlayer play];
    }
   
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
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        
        NSURL *url= [NSURL URLWithString:self.audioUrl];
         NSData *audioData = [NSData dataWithContentsOfFile:self.audioUrl];
        
        if ([self.audioUrl hasSuffix:@".amr"]) {
            
        } else {
           
        }
        
        
        
        NSError *error=nil;
//        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer=[[AVAudioPlayer alloc] initWithData:audioData error:&error];
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


#pragma mark - 播放代理方法

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag{
    //播放结束时执行的动作
    
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
    
//    self.backBtn.enabled = YES;
//    [self.backBtn setBackgroundColor:HEX_COLOR(0x219CE0)];
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
