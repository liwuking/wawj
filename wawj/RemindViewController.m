//
//  RemindViewController.m
//  AFanJia
//
//  Created by 焦庆峰 on 2016/10/31.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import "RemindViewController.h"
#import "SpeakingView.h"
#import "AppDelegate.h"
//#import "ExpiredRemindViewController.h"
#import "NewRemindOrEditRmindViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "iflyMSC/IFlyMSC.h"
#import "Definition.h"
#import "IATConfig.h"
#import "RemindCell.h"
#import "MBProgressHUD+Extension.h"
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioSession.h>
#import "TTSConfig.h"
#import "ListeningView.h"
#import "DBManager.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "CoreArchive.h"
#import "AlarmClockItem.h"

@interface RemindViewController ()<UITableViewDelegate,UITableViewDataSource,RemindCellDelegate>
{
    IBOutlet UIView        *_voiceSearchView;
    IBOutlet UIView        *_microphoneBGView;
    SpeakingView           *_speakingView;
    IBOutlet UITableView   *_remindTableView;
    NSMutableArray         *_allDataArr;
    ListeningView          *_listeningView;
    AppDelegate            *_myApp;
    //    IBOutlet UIView        *_noRemindView;
    FMDatabase             *_db;
    NSString               *_tableName;
    BOOL                   isHeaderFresh;
}
@end

@implementation RemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的提醒";
    _microphoneBGView.layer.cornerRadius = 30;
    
    _remindTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"图层30"] style:UIBarButtonItemStyleDone target:self action:@selector(rightAction)];
    [rightItem setTintColor:HEX_COLOR(0x666666)];
    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _iFlySpeechUnderstander = [IFlySpeechUnderstander sharedInstance];
    _iFlySpeechUnderstander.delegate = self;
    
    //pcm播放器初始化
    _audioPlayer = [[PcmPlayer alloc] init];
    
    //add shadow
    _voiceSearchView.layer.masksToBounds = NO;
    _voiceSearchView.layer.shadowColor = RGB_COLOR(220, 220, 200).CGColor;
    _voiceSearchView.layer.shadowOffset = CGSizeMake(0.0f, -2.0f);
    _voiceSearchView.layer.shadowOpacity = 0.9f;
    
    [self createDatabaseTable];
    [self canRecord];
    [self setupRefresh];
    
    if ([self isOpenNotificationJurisdiction]) {
        
//        if ([self isReachable]) {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
//                                                           message:@"若体验更贴心的提醒服务，请开启声音"
//                                                          delegate:nil
//                                                 cancelButtonTitle:@"知道了"
//                                                 otherButtonTitles: nil];
//            [alert show];
//
//        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [self loadData];
    
    
    if ([self isReachable]) {
        
        self.isSpeechUnderstander = NO;
        
        [super viewWillAppear:animated];
        [self initRecognizer];
        [self initSynthesizer];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒"
                                                       message:@"网络中断，无法语音添加提醒和朗读提醒"
                                                      delegate:nil
                                             cancelButtonTitle:@"我知道了"
                                             otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_iFlySpeechUnderstander cancel];//终止语义
    [_iFlySpeechUnderstander setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    [super viewWillDisappear:animated];
}

//判断当前网络状态
- (BOOL)isReachable {
    AFNetworkReachabilityManager*manager = [AFNetworkReachabilityManager sharedManager];
    return manager.isReachable;
}


//是否授权推送权限
- (BOOL)isOpenNotificationJurisdiction {
    UIApplication *application = [UIApplication sharedApplication];
    NSUInteger notificationType = [[application currentUserNotificationSettings] types];
    if (notificationType == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"未开启通知权限"
                                                       message:@"提醒无法主动推送给用户，“设置-通知-我爱我家-允许通知”，开启通知权限，让“提醒”功能更贴心"
                                                      delegate:nil
                                             cancelButtonTitle:@"我知道了"
                                             otherButtonTitles:nil, nil];
        
        [alert show];
        
        return NO;
    }
    
    return YES;
}

- (void)createDatabaseTable {
    
    [MBProgressHUD showMessage:@"正在加载..."];
    if (!_allDataArr) {
        _allDataArr = [[NSMutableArray alloc] init];
    }
    [_allDataArr removeAllObjects];
    
    
    NSDictionary *keys = @{@"date"                 : @"string",
                           @"time"                 : @"string",
                           @"time_interval"        : @"string",
                           @"event"                : @"string",
                           @"time_stamp"           : @"string",
                           @"content"              : @"string",
                           @"dateOrig"             : @"string",
                           @"remind_ID"            : @"string",
                           @"state"                : @"string",
                           @"reserved_parameter_1" : @"string",
                           @"reserved_parameter_2" : @"string",
                           @"reserved_parameter_3" : @"string",
                           @"reserved_parameter_4" : @"string",
                           @"reserved_parameter_5" : @"string",
                           @"reserved_parameter_6" : @"string"};
    
    _tableName = @"remindList";
    if ([CoreArchive strForKey:@"userID"]) {
        _tableName = [_tableName stringByAppendingFormat:@"_%@",[CoreArchive strForKey:@"userID"]];
    }
    
    
    [[DBManager defaultManager] createTableWithName:_tableName AndKeys:keys Result:^(BOOL isOK) {
        if (!isOK) {
            //建表失败！
            [MBProgressHUD hideHUD];
            [self showNoRemindView];
            return ;
        }
    } FMDatabase:^(FMDatabase *database) {
        _db = database;
        [self loadData];
    }];
    
}


/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    _remindTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    _remindTableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    //    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [_remindTableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"investment"];
    
}

- (void)loadData {
    [_allDataArr removeAllObjects];
    if ([_db open]) {
        
        if (isHeaderFresh) {
            [_remindTableView headerEndRefreshing];
            isHeaderFresh = NO;
        }
        [_allDataArr addObjectsFromArray:[self getRemindList]];
        [_remindTableView reloadData];
        
        if (![_allDataArr count]) {
            [self showNoRemindView];
        }else{
            //            [_noRemindView removeFromSuperview];
        }
        
        [MBProgressHUD hideHUD];
        
    }else{
        [self showNoRemindView];
        [MBProgressHUD showSuccess:@"获取提醒数据失败"];
    }
    
}

- (void)showNoRemindView {
    //    [_noRemindView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
    //    [self.view addSubview:_noRemindView];
}
- (NSMutableArray *)getRemindList {
    NSDate *nowDate = [NSDate dateWithTimeIntervalSinceNow:8*60*60];
    int nowSp = [nowDate timeIntervalSince1970];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where time_stamp > %d order by time_stamp",_tableName,nowSp];
    NSLog(@"sql = %@",sql);
    
    NSMutableArray *allDataArr = [[NSMutableArray alloc] init];
    if ([_db open]) {
        FMResultSet * res = [_db executeQuery:sql];
        
        while ([res next]) {
            NSDictionary *itemDic = @{@"date"          : [res stringForColumn:@"date"],
                                      @"time"          : [res stringForColumn:@"time"],
                                      @"time_interval" : [res stringForColumn:@"time_interval"],
                                      @"event"         : [res stringForColumn:@"event"],
                                      @"time_stamp"    : [res stringForColumn:@"time_stamp"],
                                      @"content"       : [res stringForColumn:@"content"],
                                      @"dateOrig"      : [res stringForColumn:@"dateOrig"],
                                      @"remind_ID"     : [res stringForColumn:@"remind_ID"],
                                      @"state"         : [res stringForColumn:@"state"]};
            [allDataArr addObject:itemDic];
        }
        NSLog(@"arr = %@",allDataArr);
    }
    
    return allDataArr;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftAction {
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Remind" bundle:nil];
//    ExpiredRemindViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ExpiredRemindViewController"];
//    vc.hidesBottomBarWhenPushed = YES;
//    vc.database = _db;
//    [self.navigationController pushViewController:vc animated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightAction {
    
    NewRemindOrEditRmindViewController *vc = [[NewRemindOrEditRmindViewController alloc] initWithNibName:@"NewRemindOrEditRmindViewController" bundle:nil];
    vc.type = NewRemind;
    vc.database = _db;
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (IBAction)beginRecording:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        if ([self isReachable]) {
            if ([self isRecord]) {
                _speakingView = [[NSBundle mainBundle] loadNibNamed:@"SpeakingView" owner:self options:nil][0];
                [_speakingView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                //_speakingView.delegate = self;
                _myApp = [UIApplication sharedApplication].delegate;
                [_myApp.window addSubview:_speakingView];
                [_speakingView startAction];
                [self beginDistinguish];
            }else{
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                               message:@"请在“设置-隐私-麦克风”选项中允许我爱我家访问你的麦克风"
                                                              delegate:nil
                                                     cancelButtonTitle:@"我知道了"
                                                     otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提醒"
                                                           message:@"网络中断，无法语音添加提醒"
                                                          delegate:nil
                                                 cancelButtonTitle:@"我知道了"
                                                 otherButtonTitles:nil, nil];
            [alert show];
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

-(void)canRecord
{
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    
    if (permissionStatus == AVAudioSessionRecordPermissionUndetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
            if (granted) {
                // Microphone enabled code
            }
            else {
                // Microphone disabled code
            }
        }];
        
    }
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


#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    isHeaderFresh = YES;
    [self loadData];
}

#pragma mark - table data source and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_allDataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifiter = @"remindCell";
    RemindCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiter];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"RemindCell" owner:self options:nil][0];
        cell.delegate = self;
    }
    
    
    NSDictionary *itemDic = _allDataArr[indexPath.row];
    NSString *contentStr = itemDic[@"event"];
    cell.eventLabel.text = [contentStr substringToIndex:contentStr.length-1];
    NSString *eventTime = itemDic[@"time"];
    cell.eventDateLabel.text = [eventTime substringToIndex:eventTime.length-3];
    cell.cellIndexPath = indexPath;
    
    
    NSString* timeStr = [NSString stringWithFormat:@"%@ %@",itemDic[@"date"],itemDic[@"time"]];
    NSLog(@"timeStr = %@",timeStr);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate* date = [formatter dateFromString:timeStr];
    NSLog(@"date = %@",date);
    
    NSLog(@"123 = %@",[timeStr compareDate:date]);
    
    cell.dateLabel.text = [NSString stringWithFormat:@"%@ %@",[timeStr compareDate:date],itemDic[@"time_interval"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RemindCell *shotCell = (RemindCell *) cell;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1)];
    
    scaleAnimation.toValue  = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [shotCell.layer addAnimation:scaleAnimation forKey:@"transform"];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Remind" bundle:nil];
    NewRemindOrEditRmindViewController *vc = [sb instantiateViewControllerWithIdentifier:@"NewRemindOrEditRmindViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.type = EditRemind;
    vc.editDataDic = [[NSDictionary alloc]initWithDictionary:_allDataArr[indexPath.row]];
    vc.database = _db;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - cell delegate
- (void)tableViewCell:(UITableViewCell *)cell AndIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isReachable]) {
        NSString *readText = _allDataArr[indexPath.row][@"content"];
        [self readTextWithString:readText];
    }else{
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提醒"
//                                                       message:@"网络中断，无法朗读提醒"
//                                                      delegate:nil
//                                             cancelButtonTitle:@"我知道了"
//                                             otherButtonTitles:nil, nil];
//        [alert show];
//        return;
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
    
    if (responseJsonDic[@"semantic"]) {
        //        [_noRemindView removeFromSuperview];
        [self insertRemindWithData:responseJsonDic];
        
    }else{
        [MBProgressHUD showSuccess:@"提醒应按照时间+事件的形式添加！"];
    }
    
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
        _myApp = [UIApplication sharedApplication].delegate;
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


#pragma mark - database event
- (void)insertRemindWithData:(NSDictionary *)data{
    NSLog(@"data = %@",data);
    
    if ([_db open]) {
        
        NSDictionary *itemDic = data[@"semantic"][@"slots"];
        NSString *dateString = itemDic[@"datetime"][@"date"];
        NSString *timeString = itemDic[@"datetime"][@"time"];
        
        NSString* timeStr = [NSString stringWithFormat:@"%@ %@",dateString,timeString];
        NSLog(@"timeStr = %@",timeStr);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
        NSDate* date = [formatter dateFromString:timeStr];
        int timeSp_f = [date timeIntervalSince1970];
        NSLog(@"timeSp_f = %d",timeSp_f);
        
        int nowSp_f = [[NSDate dateWithTimeIntervalSinceNow:8*60*60] timeIntervalSince1970];
        NSLog(@"date = %@",[NSDate dateWithTimeIntervalSinceNow:8*60*60]);
        
        NSLog(@"nowSp_f = %d",nowSp_f);
        if (nowSp_f > timeSp_f) {
            [MBProgressHUD hideHUD];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"设置提醒时间应大于当前时间！"
                                                          delegate:nil
                                                 cancelButtonTitle:@"知道了"
                                                 otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        
        
        NSString *timeSp = [NSString stringWithFormat:@"%d",timeSp_f];
        
        NSString *remindID = [NSString stringWithFormat:@"rd_%@",timeSp];
        NSLog(@"timeSp = %@",timeSp);
        
        NSString *timeInterval = [timeString substringToIndex:2];
        if ([timeInterval intValue] < 12) {
            timeInterval = @"上午";
        }else{
            timeInterval = @"下午";
        }
        
        NSString *dateOrig = nil;
        NSString *currentDate = [NSString stringWithFormat:@"%@",[NSDate dateWithTimeIntervalSinceNow:8*60*60]];
        if (itemDic[@"datetime"][@"dateOrig"]) {
            NSString *dateOrigStr = itemDic[@"datetime"][@"dateOrig"];
            if ([[dateOrigStr substringToIndex:dateOrigStr.length-1] isEqualToString:@"今天"]) {
                if ([[currentDate substringToIndex:10] isEqualToString:dateString]) {
                    dateOrig = @"今天";
                }else{
                    dateOrig = @"明天";
                }
                
            }else{
                dateOrig = itemDic[@"datetime"][@"dateOrig"];
            }
            
        }else{
            if ([[currentDate substringToIndex:10] isEqualToString:dateString]) {
                dateOrig = @"今天";
            }else{
                dateOrig = @"明天";
            }
            
        }
        NSString *content = itemDic[@"content"];
        
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (date,time,time_interval,event,time_stamp,content,dateOrig,remind_ID,state,reserved_parameter_1,reserved_parameter_2,reserved_parameter_3,reserved_parameter_4,reserved_parameter_5,reserved_parameter_6) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",_tableName,dateString,timeString,timeInterval,content,timeSp,data[@"text"],dateOrig,remindID,@"normal",@"0",@"0",@"0",@"0",@"0",@"0"];
        NSLog(@"sql = %@",sql);
        BOOL isCreate = [_db executeUpdate:sql];
        if (isCreate) {
            [MBProgressHUD showSuccess:@"创建成功"];
            [self loadData];
            
            //创建闹钟
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                [AlarmClockItem addAlarmClockWithAlarmClockID:timeSp AlarmClockContent:[content substringToIndex:content.length - 1]  AlarmClockDate:timeStr];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                });
            });
            
            
            
        }else{
            [MBProgressHUD showSuccess:@"创建失败"];
        }
    }
}
@end
