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
#import "DBManager.h"
#import "iflyMSC/IFlyMSC.h"
#import "TTSConfig.h"
#import "RemindItem.h"
#import <MJRefresh.h>
#import "EditRemindViewController.h"
#import <UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,//普通合成
    UriType             = 6, //uri合成
};

typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2, //高异常分析需要的级别
    Paused              = 4,
};

@interface OverdueViewController ()<UITableViewDelegate,UITableViewDataSource,OverdueRemindCellDelegate,IFlySpeechSynthesizerDelegate,EditRemindViewControllerDelegate>

@property(nonatomic, strong)FMDatabase             *db;
@property(nonatomic, strong)NSString               *databaseTableName;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong)NSMutableArray         *dataArr;
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property(nonatomic, strong)ListeningView          *listeningView;
@property (nonatomic, strong) PcmPlayer *audioPlayer;
@property(nonatomic, strong)AppDelegate            *myApp;
@property (nonatomic, assign) Status state;

@property (nonatomic, assign) BOOL isChange;

@property (nonatomic,strong) AVAudioPlayer *audioFilePlayer;//音频播放器，用于播放录音文件


@end

@implementation OverdueViewController



-(void)leftAction {
    
//    if (self.isChange) {
//        [self.delegate OverdueViewControllerRefresh];
//    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing),dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    __weak __typeof__(self) weakSelf = self;
    // The drop-down refresh
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf getDataFromDatabase];
    }];
    
}

-(void)initViews {
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = @"过期提醒";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setupRefresh];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.databaseTableName = @"remindList";
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *userID = userInfo? userInfo[@"userId"] : @"";
    self.databaseTableName = [self.databaseTableName stringByAppendingFormat:@"_%@",userID];
    
    self.dataArr = [@[] mutableCopy];
    [self initViews];
    
    [self initSynthesizer];
    //pcm播放器初始化
    _audioPlayer = [[PcmPlayer alloc] init];
    
    [self createDatabaseTable];
    
}

#pragma -mark 创建数据库表
- (void)createDatabaseTable {
    
    
    NSDictionary *keys = @{@"remindorigintype"           : @"string",
                           @"remindid"                   : @"string",
                           @"audiourl"                   : @"string",
                           @"headurl"                    : @"string",
                           @"remindtype"                 : @"string",
                           @"remindtime"                 : @"string",
                           @"createtimestamp"            : @"string",
                           @"content"                    : @"string"
                           };
    
    __weak __typeof__(self) weakSelf = self;
    [[DBManager defaultManager] createTableWithName:self.databaseTableName AndKeys:keys Result:^(BOOL isOK) {
        
    } FMDatabase:^(FMDatabase *database) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        strongSelf.db = database;
        [strongSelf getDataFromDatabase];
    }];
    
}

#pragma -mark
#pragma -mark 从数据库获取数据
- (void)getDataFromDatabase {
    
    if ([self.db open]) {
        
        NSInteger nowSp = [[NSDate date] timeIntervalSince1970];
        NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindtype == 'onlyonce' and createtimestamp < %ld order by createtimestamp desc",self.databaseTableName,nowSp];
        NSLog(@"sql = %@",sql);
        
        NSMutableArray *dataArr = [[NSMutableArray alloc] init];
        FMResultSet * res = [self.db executeQuery:sql];
        
        while ([res next]) {
      
            RemindItem *item = [[RemindItem alloc] init];
            item.remindorigintype = [res stringForColumn:@"remindorigintype"];
            item.remindtype = [res stringForColumn:@"remindtype"];
            item.remindtime = [res stringForColumn:@"remindtime"];
            item.content = [res stringForColumn:@"content"];
            item.createtimestamp = [res stringForColumn:@"createtimestamp"];
            if ([item.remindorigintype isEqualToString:REMINDORIGINTYPE_REMOTE]) {
                item.headurl = [res stringForColumn:@"headurl"];
                item.audiourl = [res stringForColumn:@"audiourl"];
            }
            
            item.remindDate = [self showDateTimeWithCreateTimeStamp:item.createtimestamp];
            item.recentlyRemindDate = [self dateTimeWithCreateTimeStamp:item.createtimestamp];
            NSLog(@"item.recentlyRemindDate = %@",item.recentlyRemindDate);
            [dataArr addObject:item];
        }
        
        
        if (dataArr.count) {
//            NSArray *recentlyDataArr = [dataArr sortedArrayUsingComparator:^NSComparisonResult(RemindItem *obj1, RemindItem *obj2) {
//                NSLog(@"obj1: %@",obj1.recentlyRemindDate);
//                return [obj2.recentlyRemindDate compare:obj1.recentlyRemindDate];
//            }];
//
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:dataArr];
            [self.tableView reloadData];
        }
        
        
        if (self.tableView.mj_header.isRefreshing) {
            [self.tableView.mj_header endRefreshing];
        }
        
    }else{
        
        [MBProgressHUD showSuccess:@"获取提醒数据失败"];
        
        if (self.tableView.mj_header.isRefreshing) {
            [self.tableView.mj_header endRefreshing];
        }
    }
    
}

-(NSDate *)dateTimeWithCreateTimeStamp:(NSString *)timeStamp {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate *remindDate = [NSDate dateWithTimeIntervalSince1970:[timeStamp integerValue]];
    
    return remindDate;
}

-(NSString *)showDateTimeWithCreateTimeStamp:(NSString *)timeStamp {
    
    NSString *dateTime = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
    NSDate *remindDate = [NSDate dateWithTimeIntervalSince1970:[timeStamp integerValue]];
    
    NSString *remindDateStr = [dateFormatter stringFromDate:remindDate];
    remindDate = [dateFormatter dateFromString:remindDateStr];
    
    
    NSDate *todaydayDate = [NSDate dateWithTimeIntervalSinceNow:-0*60*60];
    NSDate *yesterdayDate = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
    NSDate *beforeYesterdayDate = [NSDate dateWithTimeIntervalSinceNow:-2*24*60*60];
    
    
    NSString *todayDateStr = [dateFormatter stringFromDate:todaydayDate];
    todaydayDate = [dateFormatter dateFromString:todayDateStr];
    
    NSString *yesterdayDateStr = [dateFormatter stringFromDate:yesterdayDate];
    yesterdayDate = [dateFormatter dateFromString:yesterdayDateStr];
    
    NSString *beforeYesterdayDateStr = [dateFormatter stringFromDate:beforeYesterdayDate];
    beforeYesterdayDate = [dateFormatter dateFromString:beforeYesterdayDateStr];
    
    
    if ([remindDate compare:beforeYesterdayDate] == NSOrderedSame) {
        dateTime = @"前天";
    } else if ([remindDate compare:yesterdayDate] == NSOrderedSame) {
        dateTime = @"昨天";
    } else if ([remindDate compare:todaydayDate] == NSOrderedSame) {
         dateTime = @"今天";
    }else {
        dateTime = [dateFormatter stringFromDate:remindDate];
    }
    
    return dateTime;
}

#pragma mark - table data source and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifiter = @"OverdueRemindCell";
    OverdueRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiter];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"OverdueRemindCell" owner:self options:nil][0];
        cell.delegate = self;
    }
    
    
    RemindItem *remindItem = [self.dataArr objectAtIndex:indexPath.row];
    cell.contentLab.text = remindItem.content;
    cell.remindTimeLab.text = remindItem.remindtime;
    cell.remindDateLab.text = remindItem.remindDate;
    cell.cellIndexPath = indexPath;
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:remindItem.headurl] placeholderImage:[UIImage imageNamed:@"friends"]];
    
    return cell;
}

#pragma -mark
#pragma -mark EditRemindViewControllerDelegate
-(void)editRemindViewControllerWithEditRemind {
    self.isChange = YES;
    [self getDataFromDatabase];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RemindItem *remindItem = [self.dataArr objectAtIndex:indexPath.row];
    
    if ([remindItem.remindorigintype isEqualToString:REMINDORIGINTYPE_REMOTE]) {
        [self showAlertViewWithTitle:@"互动提醒不允许编辑" message:nil buttonTitle:@"确定" clickBtn:^{
            
        }];
        
        return;
    }
    
    EditRemindViewController *vc = [[EditRemindViewController alloc] initWithNibName:@"EditRemindViewController" bundle:nil];
    vc.eventType = ExpRemind;
    vc.remindItem = remindItem;
    vc.database = self.db;
    [self.navigationController pushViewController:vc animated:YES];
    
    __weak __typeof__(self) weakSelf = self;
    vc.editRemindViewControllerWithDelRemind = ^(RemindItem *remindItem) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
        [strongSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    };
    
    vc.editRemindViewControllerWithEditRemind = ^(RemindItem *remindItem) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        strongSelf.overdueViewControllerWithAddRemind(remindItem);
        [strongSelf.navigationController popViewControllerAnimated:YES];        
    };
    
    
    
}

#pragma -mark 播放本地音频
-(void)playAudioWithFilePath:(NSString *)audioFilePath {
    
    if (self.audioFilePlayer.isPlaying) {
        [MBProgressHUD showSuccess:@"正在播放"];
        return;
    }
    
//    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
//    NSString *audioPath = [NSString stringWithFormat:@"%@/%@", documentPath,audioFilePath];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:audioFilePath];
    if (!exists) {
        [MBProgressHUD showSuccess:@"播放失败"];
        return;
    }
    
    NSURL *url= [NSURL URLWithString:audioFilePath];
    NSError *error=nil;
    self.audioFilePlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
   self.audioFilePlayer.numberOfLoops=0;
    self.audioFilePlayer.volume = 1;
//    self.audioFilePlayer.delegate = self;
    [self.audioFilePlayer prepareToPlay];
    if (error) {
//        NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
        [MBProgressHUD showError:@"播放失败"];
        return ;
    }
    
    [self.audioFilePlayer play];
    
}

#pragma mark - cell delegate
- (void)OverdueRemindCell:(OverdueRemindCell *)cell AndClickAudioIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isReachable]) {
        
        RemindItem *remindItem = self.dataArr[indexPath.row];
        if ([remindItem.remindorigintype isEqualToString:REMINDORIGINTYPE_REMOTE]) {
            
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
            NSURL *URL = [NSURL URLWithString:remindItem.audiourl];
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
                
                [strongSelf playAudioWithFilePath:downLoadAudioUrl];
                
            }];
            [downloadTask resume];
            
            
        } else {
            
            NSString *readText = [NSString stringWithFormat:@"%@%@%@",cell.remindDateLab.text,cell.remindTimeLab.text,cell.contentLab.text];
            [self readTextWithString:readText];
            
        }
        
        
        
    }else{
        
        [self showAlertViewWithTitle:@"提醒" message:@"网络中断，无法朗读提醒" buttonTitle:@"我知道了" clickBtn:^{
            
        }];
    }
    
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
        _state = Playing;
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
