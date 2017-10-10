//
//  OverdueViewController.m
//  wawj
//
//  Created by ruiyou on 2017/10/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "OverdueViewController.h"
#import "OverdueRemindCell.h"
#import "AppDelegate.h"
#import "iflyMSC/IFlyMSC.h"
#import "PcmPlayer.h"
#import "ListeningView.h"
#import "FMDatabase.h"


typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,//普通合成
    UriType             = 6, //uri合成
};

typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2, //高异常分析需要的级别
    Paused              = 4,
};

@interface OverdueViewController ()<OverdueRemindCellDelegate,IFlySpeechplusDelegate>

@property(nonatomic, strong)FMDatabase             *db;
@property(nonatomic, strong)NSString               *tableName;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong)NSMutableArray         *allDataArr;
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property(nonatomic, strong)ListeningView          *listeningView;
@property (nonatomic, strong) PcmPlayer *audioPlayer;
@property(nonatomic, strong)AppDelegate            *myApp;
@property (nonatomic, assign) Status state;

@end

@implementation OverdueViewController

#pragma -mark 从数据库获取提醒数据
- (NSMutableArray *)getRemindList {
    
    int nowSp = [[NSDate date] timeIntervalSince1970];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where time_stamp < %d order by time_stamp",_tableName,nowSp];
    NSLog(@"sql = %@",sql);
    
    NSMutableArray *allDataArr = [[NSMutableArray alloc] init];
    if ([self.db open]) {
        FMResultSet * res = [self.db executeQuery:sql];
        
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
        
    }
    
    return allDataArr;
}

-(void)leftAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)initViews {
    
    self.title = @"过期提醒";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableName = @"remindList";
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *userID = userInfo? userInfo[@"userId"] : @"";
    self.tableName = [self.tableName stringByAppendingFormat:@"_%@",userID];
    
    self.allDataArr = [@[] mutableCopy];
    NSMutableArray *dataArr = [self getRemindList];
    [self.allDataArr addObjectsFromArray:dataArr];
    
    [self initViews];
    
}



#pragma -mark OverdueRemindCellDelegate
-(void)tableViewCell:(UITableViewCell *)cell AndClickAudioIndexPath:(NSIndexPath *)indexPath {
    
    
}

#pragma mark - table data source and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allDataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifiter = @"OverdueRemindCell";
    OverdueRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiter];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"OverdueRemindCell" owner:self options:nil][0];
        cell.delegate = self;
    }
    
    
    NSDictionary *itemDic = self.allDataArr[indexPath.row];
    
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
    
    //    cell.dateLabel.text = [NSString stringWithFormat:@"%@ %@",[timeStr compareDate:date],itemDic[@"time_interval"]];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@",[timeStr compareDate:date]];
    
    NSLog(@"date = %@",date);
    NSLog(@"123 = %@",[timeStr compareDate:date]);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OverdueRemindCell *shotCell = (OverdueRemindCell *) cell;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1)];
    
    scaleAnimation.toValue  = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [shotCell.layer addAnimation:scaleAnimation forKey:@"transform"];
    
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    NewRemindOrEditRmindViewController *vc = [[NewRemindOrEditRmindViewController alloc] initWithNibName:@"NewRemindOrEditRmindViewController" bundle:nil];
//    vc.type = EditRemind;
//    vc.editDataDic = [[NSDictionary alloc]initWithDictionary:_allDataArr[indexPath.row]];
//    vc.database = _db;
//    [self.navigationController pushViewController:vc animated:YES];
//    
//}


#pragma mark - cell delegate
- (void)tableViewCell:(UITableViewCell *)cell AndIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isReachable]) {
        
        NSString *readText = _allDataArr[indexPath.row][@"content"];
        [self readTextWithString:readText];
        
    }else{
        
        [self showAlertViewWithTitle:@"提醒" message:@"网络中断，无法朗读提醒" buttonTitle:@"我知道了" clickBtn:^{
            
        }];
    }
    
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
//    self.isSpeechCanceled = NO;
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
//    if (_isViewDidDisappear) {
//        return;
//    }
//    self.isSpeechCanceled = YES;
//
//    if (_synType == UriType) {
//
//    }else if (_synType == NomalType) {
//        NSLog(@"取消中");
//    }
    
}

#pragma -mark 读出文字
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
    
//    _synType = NomalType;
//
//    self.hasError = NO;
    
    [NSThread sleepForTimeInterval:0.05];
    
//    self.isSpeechCanceled = NO;
    
    _iFlySpeechSynthesizer.delegate = self;
    
    [_iFlySpeechSynthesizer startSpeaking:str];
    if (_iFlySpeechSynthesizer.isSpeaking) {
//        _state = Playing;
    }
    
}


//判断当前网络状态
- (BOOL)isReachable {
    AFNetworkReachabilityManager*manager = [AFNetworkReachabilityManager sharedManager];
    return manager.isReachable;
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
