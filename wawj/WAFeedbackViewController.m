//
//  WAFeedbackViewController.m
//  wawj
//
//  Created by ruiyou on 2017/8/16.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAFeedbackViewController.h"
#import <AudioToolbox/AudioSession.h>
//#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVFoundation.h>
#import "iflyMSC/IFlyMSC.h"
#import "PcmPlayer.h"
#import "SpeakingView.h"
#import "AppDelegate.h"
#import "MBProgressHUD+Extension.h"
#import "IATConfig.h"
#import "TTSConfig.h"
#import "ListeningView.h"


typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,//普通合成
    UriType             = 6, //uri合成
};

typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2, //高异常分析需要的级别
    Paused              = 4,
};
@interface WAFeedbackViewController ()<IFlySpeechRecognizerDelegate,IFlySpeechSynthesizerDelegate,UITextViewDelegate>

//语音语义理解对象
@property (nonatomic,strong) IFlySpeechUnderstander *iFlySpeechUnderstander;

@property (nonatomic, copy)  NSString * defaultText;
@property (nonatomic) BOOL isCanceled;
@property (nonatomic,strong) NSString *result;
@property (nonatomic) BOOL isSpeechUnderstander;//当前状态是否是语音语义理解

//语音合成对象
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property (nonatomic, assign) BOOL isSpeechCanceled;
@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, assign) BOOL isViewDidDisappear;
@property (nonatomic, strong) PcmPlayer *audioPlayer;
@property (nonatomic, assign) Status state;
@property (nonatomic, assign) SynthesizeType synType;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *btnOne;
@property (weak, nonatomic) IBOutlet UIButton *btnTwo;
@property (weak, nonatomic) IBOutlet UIButton *btnThree;
@property (nonatomic, strong)NSString *adviceType;

@end

@implementation WAFeedbackViewController
{
    SpeakingView           *_speakingView;
    AppDelegate            *_myApp;
    ListeningView          *_listeningView;

}

- (void)viewWillAppear:(BOOL)animated {
    
    if ([self isReachable]) {
        
        self.isSpeechUnderstander = NO;
        
        [super viewWillAppear:animated];
        [self initRecognizer];
        [self initSynthesizer];
        
    }else{
        
        [self showAlertViewWithTitle:@"提醒" message:@"网络中断，无法语音添加提醒和朗读提醒" buttonTitle:@"我知道了" clickBtn:^{
            
        }];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [_iFlySpeechUnderstander cancel];//终止语义
    [_iFlySpeechUnderstander setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if ([self.textView.text isEqualToString:@"感谢您对我爱我家做出的贡献, 有事请反馈..."]) {
        self.textView.text = @"";
        self.textView.textColor = [UIColor blackColor];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    if ([self.textView.text isEqualToString:@""]) {
        self.textView.text = @"感谢您对我爱我家做出的贡献, 有事请反馈...";
        self.textView.textColor = [UIColor lightGrayColor];
    }

}

- (IBAction)clickSubmitBtn:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    if ([self.textView.text isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"" message:@"反馈内容不能为空" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    NSDictionary *model = @{@"adviceType":     self.adviceType,
                            @"adviceContent": self.textView.text};
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P0003" andModel:model];
    [MBProgressHUD showMessage:nil];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            [MBProgressHUD showSuccess:@"反馈成功"];
            [strongSelf.navigationController popViewControllerAnimated:YES];
            
        } else {
            
            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
                
            }];
            
        }
        
    } fail:^(NSError *error) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
    }];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.title = @"有事您说话";
    self.adviceType = @"1";
    
}

- (IBAction)clickBtnOne:(UIButton *)sender {
    
    self.btnOne.backgroundColor = HEX_COLOR(0xfaa41c);
    self.btnTwo.backgroundColor = HEX_COLOR(0xd1d1d8);
    self.btnThree.backgroundColor = HEX_COLOR(0xd1d1d8);
    
    [self.btnOne setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnTwo setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
    [self.btnThree setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
    
    self.adviceType = @"1";
}

- (IBAction)clickBtnTwo:(UIButton *)sender {
    self.btnOne.backgroundColor = HEX_COLOR(0xd1d1d8);
    self.btnTwo.backgroundColor = HEX_COLOR(0xfaa41c);
    self.btnThree.backgroundColor = HEX_COLOR(0xd1d1d8);
    
    [self.btnOne setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
    [self.btnTwo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnThree setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
    
    self.adviceType = @"3";
}

- (IBAction)clickBtnThree:(UIButton *)sender {
    self.btnOne.backgroundColor = HEX_COLOR(0xd1d1d8);
    self.btnTwo.backgroundColor = HEX_COLOR(0xd1d1d8);
    self.btnThree.backgroundColor = HEX_COLOR(0xfaa41c);
    
    [self.btnOne setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
    [self.btnTwo setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
    [self.btnThree setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.adviceType = @"2";
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        
        [self.textView resignFirstResponder];
        //在这里做你响应return键的代码
        return YES; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
        
        
    }
    
    return YES;
}

- (IBAction)beginRecording:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        if ([self isReachable]) {
            if ([self isRecord]) {
                _speakingView = [[NSBundle mainBundle] loadNibNamed:@"SpeakingView" owner:self options:nil][0];
                [_speakingView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                //_speakingView.delegate = self;
                _myApp = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [_myApp.window addSubview:_speakingView];
                [_speakingView startAction];
                [self beginDistinguish];
            }else{
                
                [self showAlertViewWithTitle:@"提示" message:@"请在“设置-隐私-麦克风”选项中允许我爱我家访问你的麦克风" buttonTitle:@"我知道了" clickBtn:^{
                    
                }];
                
                return;
            }
            
        }else{
            
            [self showAlertViewWithTitle:@"提醒" message:@"网络中断，无法语音添加提醒" buttonTitle:@"我知道了" clickBtn:^{
                
            }];
            return;
            
        }
        
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (![self isReachable]) {
            return;
        }
        
        [_speakingView endSpeak];
        [_iFlySpeechUnderstander stopListening];
        [MBProgressHUD showMessage:@"正在创建..."];
    }
    
    
}

/**
 设置识别参数
 ****/
-(void)initRecognizer
{
    //语义理解单例
    if (_iFlySpeechUnderstander == nil) {
        _iFlySpeechUnderstander = [IFlySpeechUnderstander sharedInstance];
    }
    
    _iFlySpeechUnderstander.delegate = self;
    
    if (_iFlySpeechUnderstander != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        
        //参数意义与IATViewController保持一致，详情可以参照其解释
        [_iFlySpeechUnderstander setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        [_iFlySpeechUnderstander setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        [_iFlySpeechUnderstander setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        [_iFlySpeechUnderstander setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            [_iFlySpeechUnderstander setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            [_iFlySpeechUnderstander setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            [_iFlySpeechUnderstander setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        [_iFlySpeechUnderstander setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
    }
}

#pragma mark - 设置合成参数
- (void)initSynthesizer
{
    TTSConfig *instance = [TTSConfig sharedInstance];
    if (instance == nil) {
        return;
    }
    
    //合成服务单例
    if (_iFlySpeechSynthesizer == nil) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    _iFlySpeechSynthesizer.delegate = self;
    
    //设置语速1-100
    [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
    
    //设置音量1-100
    [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
    
    //设置音调1-100
    [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
    
    //设置采样率
    [_iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //设置发音人
    [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    
    //设置文本编码格式
    [_iFlySpeechSynthesizer setParameter:@"unicode" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    
    
    NSDictionary* languageDic=@{@"Guli":@"text_uighur", //维语
                                @"XiaoYun":@"text_vietnam",//越南语
                                @"Abha":@"text_hindi",//印地语
                                @"Gabriela":@"text_spanish",//西班牙语
                                @"Allabent":@"text_russian",//俄语
                                @"Mariane":@"text_french"};//法语
    
    NSString* textNameKey=[languageDic valueForKey:instance.vcnName];
    NSString* textSample=nil;
    
    if(textNameKey && [textNameKey length]>0){
        textSample=NSLocalizedStringFromTable(textNameKey, @"tts/tts", nil);
    }else{
        textSample=NSLocalizedStringFromTable(@"text_chinese", @"tts/tts", nil);
    }
    
}


//判断当前网络状态
- (BOOL)isReachable {
    AFNetworkReachabilityManager*manager = [AFNetworkReachabilityManager sharedManager];
    return manager.isReachable;
}

- (BOOL)isRecord{
    
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    
    switch (permissionStatus) {
        case AVAudioSessionRecordPermissionDenied:
            // direct to settings...
            NSLog(@"已经拒绝麦克风弹框");
            return NO;
            
            break;
        case AVAudioSessionRecordPermissionGranted:
            NSLog(@"已经允许麦克风弹框");
            return YES;
            // mic access ok...
            break;
        default:
            // this should not happen.. maybe throw an exception.
            break;
    }
    
    return NO;
}

- (void)beginDistinguish {
    if (self.isSpeechUnderstander){
        return;
    }
    //设置为麦克风输入语音
    [_iFlySpeechUnderstander setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    bool ret = [_iFlySpeechUnderstander startListening];
    
    if (ret) {
        
        self.isSpeechUnderstander = YES;
        self.isCanceled = NO;
        
    }
    else
    {
        
    }
    
}


- (void)readTextWithString:(NSString *)str {
    if ([str isEqualToString:@""]) {
        return;
    }
    
    [MBProgressHUD showMessage:@"正在合成..."];
    if (!_listeningView) {
        _listeningView = [[NSBundle mainBundle]loadNibNamed:@"ListeningView" owner:self options:nil][0];
    }
    
    if (_audioPlayer != nil && _audioPlayer.isPlaying == YES) {
        [_audioPlayer stop];
    }
    
    _synType = NomalType;
    
    self.hasError = NO;
    [NSThread sleepForTimeInterval:0.05];
    
    self.isSpeechCanceled = NO;
    
    _iFlySpeechSynthesizer.delegate = self;
    
    [_iFlySpeechSynthesizer startSpeaking:str];
    if (_iFlySpeechSynthesizer.isSpeaking) {
        _state = Playing;
    }
    
}

#pragma mark - iFly 语义理解 delegate
- (void) onBeginOfSpeech
{
    //[_popUpView showText: @"正在录音"];
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    // [_popUpView showText: @"停止录音"];
}

/**
 音量变化回调
 volume 录音的音量，音量范围0~30
 ****/
- (void) onVolumeChanged: (int)volume
{
    //    if (self.isCanceled) {
    //        [_popUpView removeFromSuperview];
    //        return;
    //    }
    //
    //    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    //    [_popUpView showText: vol];
}

/**
 语义理解服务结束回调（注：无论是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s",__func__);
    
    NSString *text ;
    if (self.isCanceled) {
        text = @"语义取消";
        [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:@"录音取消"];
    }
    else if (error.errorCode ==0 ) {
        if (_result.length == 0) {
            text = @"无识别结果";
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"说话时间过短或不太清晰"];
        }
    }
    else
    {
        if (_result.length == 0) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"error.errorDesc"];
        }
    }
    
    self.isSpeechUnderstander = NO;
}


/**
 语义理解结果回调
 result 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    [MBProgressHUD hideHUD];
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = results [0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    
    NSLog(@"听写结果：%@",result);
    if (result.length == 0) {
        _result = @"nil";
    }else{
        _result = result;
    }
    
    NSData *JSONData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJsonDic = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"responseJSON = %@",responseJsonDic);
    
    
    
    
    if (responseJsonDic[@"text"]) {
        
        if ([self.textView.text isEqualToString:@"感谢您对我爱我家做出的贡献, 有事请反馈..."]) {
            self.textView.text = @"";
            self.textView.textColor = [UIColor blackColor];
        }
        self.textView.text = [self.textView.text stringByAppendingString:responseJsonDic[@"text"]];
    }
    
    
    
    
    
//    if (responseJsonDic[@"semantic"]) {
//        //        [_noRemindView removeFromSuperview];
//        [self insertRemindWithData:responseJsonDic];
//        
//    }else{
//        [MBProgressHUD showSuccess:@"提醒应按照时间+事件的形式添加！"];
//    }
    
}

/**
 取消回调
 当调用了[_iFlySpeechUnderstander cancel]后，会回调此函数，
 ****/
- (void) onCancel
{
    NSLog(@"识别取消");
}

#pragma mark - iFly 语音合成 delegate

/**
 开始播放回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakBegin
{
    self.isSpeechCanceled = NO;
    if (_state  != Playing) {
        NSLog(@"开始播放");
    }
    _state = Playing;
    [MBProgressHUD hideHUD];
    
    if (!_myApp) {
        _myApp = (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    
    [_listeningView setFrame:[UIScreen mainScreen].bounds];
    [_myApp.window addSubview:_listeningView];
    
}



/**
 缓冲进度回调
 
 progress 缓冲进度
 msg 附加信息
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onBufferProgress:(int) progress message:(NSString *)msg
{
    NSLog(@"buffer progress %2d%%. msg: %@.", progress, msg);
}




/**
 播放进度回调
 
 progress 缓冲进度
 
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void) onSpeakProgress:(int) progress beginPos:(int)beginPos endPos:(int)endPos
{
    _listeningView.progressLabel.text = [NSString stringWithFormat:@"%2d%%",progress];
    
    //NSLog(@"speak progress %2d%%.", progress);
}


/**
 合成暂停回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakPaused
{
    
    _state = Paused;
}



/**
 恢复合成回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakResumed
{
    _state = Playing;
}

/**
 合成结束（完成）回调
 
 对uri合成添加播放的功能
 ****/
- (void)onCompleted:(IFlySpeechError *) error
{
    NSLog(@"%s,error=%d",__func__,error.errorCode);
    
    //    if (error.errorCode != 0) {
    //        [_inidicateView hide];
    //        [_popUpView showText:[NSString stringWithFormat:@"错误码:%d",error.errorCode]];
    //        return;
    //    }
    //    NSString *text ;
    //    if (self.isCanceled) {
    //        text = @"合成已取消";
    //    }else if (error.errorCode == 0) {
    //        text = @"合成结束";
    //    }else {
    //        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
    //        self.hasError = YES;
    //        NSLog(@"%@",text);
    //    }
    
    _state = NotStart;
    [_iFlySpeechSynthesizer stopSpeaking];
    [_listeningView removeFromSuperview];
    
}




/**
 取消合成回调
 ****/
- (void)onSpeakCancel
{
    if (_isViewDidDisappear) {
        return;
    }
    self.isSpeechCanceled = YES;
    
    if (_synType == UriType) {
        
    }else if (_synType == NomalType) {
        NSLog(@"取消中");
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
