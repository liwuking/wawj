
#import "RemindViewController.h"
#import "SpeakingView.h"
#import "AppDelegate.h"
#import "NewRemindOrEditRmindViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "iflyMSC/IFlyMSC.h"
#import "Definition.h"
#import "IATConfig.h"
#import "RemindCell.h"
#import "MBProgressHUD+Extension.h"
#import <AudioToolbox/AudioSession.h>
#import <AVFoundation/AVFoundation.h>
#import "iflyMSC/IFlyMSC.h"
#import "PcmPlayer.h"
#import <MJRefresh.h>

#import "TTSConfig.h"
#import "ListeningView.h"
#import "DBManager.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "CoreArchive.h"
#import "AlarmClockItem.h"

#import "BuildRemindView.h"
#import "OverdueViewController.h"
#import "EditRemindViewController.h"

#import "RemindItem.h"

typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,//普通合成
    UriType             = 6, //uri合成
};

typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2, //高异常分析需要的级别
    Paused              = 4,
};

@interface RemindViewController ()<UITableViewDelegate,UITableViewDataSource,IFlySpeechRecognizerDelegate,IFlySpeechSynthesizerDelegate,RemindCellDelegate,BuildRemindViewDelegate,EditRemindViewControllerDelegate, OverdueViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *microphoneBGView;
@property (weak, nonatomic) IBOutlet UIView *voiceSearchView;

//语音语义理解对象
@property (nonatomic,strong) IFlySpeechUnderstander *iFlySpeechUnderstander;
//文本语义理解对象
//@property (nonatomic,strong) IFlyTextUnderstander *iFlyUnderStand;

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

@property(nonatomic, strong)SpeakingView           *speakingView;
@property(nonatomic, strong)NSMutableArray<RemindItem*>         *dataArr;
@property(nonatomic, strong)FMDatabase             *db;
@property(nonatomic, strong)AppDelegate            *myApp;
@property(nonatomic, strong)NSString               *databaseTableName;
@property(nonatomic, strong)ListeningView          *listeningView;
@property(nonatomic, strong)BuildRemindView *buildRemindView;
@end


@implementation RemindViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightAction {
    
    if (!self.buildRemindView) {
        self.buildRemindView = [[[NSBundle mainBundle] loadNibNamed:@"BuildRemindView" owner:self options:nil] lastObject];
        self.buildRemindView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
        self.buildRemindView.delegate = self;
        
        [self.view addSubview:self.buildRemindView];
    }
    
}

#pragma -mark BuildRemindViewDelegate
-(void)BuildRemindViewWithClickBuildRemind {

    EditRemindViewController *vc = [[EditRemindViewController alloc] initWithNibName:@"EditRemindViewController" bundle:nil];
    vc.eventType = NRemind;
    vc.database = _db;
    [self.navigationController pushViewController:vc animated:YES];
    
    __weak __typeof__(self) weakSelf = self;
    vc.editRemindViewControllerWithAddRemind = ^(RemindItem *remindItem) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf addRemindItem:remindItem];
        
    };

}

-(void)BuildRemindViewWithClickOverDueRemind {

    OverdueViewController *vc = [[OverdueViewController alloc] initWithNibName:@"OverdueViewController" bundle:nil];
//    vc.delegate = self;
    __weak __typeof__(self) weakSelf = self;

    vc.overdueViewControllerWithAddRemind = ^(RemindItem *remindItem) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf addRemindItem:remindItem];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)BuildRemindViewWithHiddenBuildRemind {
    [self.buildRemindView removeFromSuperview];
    self.buildRemindView = nil;
}

#pragma -mark OverdueViewControllerDelegate
-(void)OverdueViewControllerRefresh {
    [self getDataFromDatabase];
}

-(void)initViews {
    
    self.title = @"我的提醒";
    self.microphoneBGView.layer.cornerRadius = 30;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"图层30"] style:UIBarButtonItemStyleDone target:self action:@selector(rightAction)];
    [rightItem setTintColor:HEX_COLOR(0x666666)];
    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.rightBarButtonItem = rightItem;
 
    //add shadow
    self.voiceSearchView.layer.masksToBounds = NO;
    self.voiceSearchView.layer.shadowColor = RGB_COLOR(220, 220, 200).CGColor;
    self.voiceSearchView.layer.shadowOffset = CGSizeMake(0.0f, -2.0f);
    self.voiceSearchView.layer.shadowOpacity = 0.9f;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setupRefresh];
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

-(void)checkRecord
{
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    if (permissionStatus == AVAudioSessionRecordPermissionDenied) {
        
        [self showAlertViewWithTitle:@"提示" message:@"请在“设置-隐私-麦克风”选项中允许我爱我家访问你的麦克风" buttonTitle:@"我知道了" clickBtn:^{
        }];
        
    }else if (permissionStatus == AVAudioSessionRecordPermissionUndetermined) {
        
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

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initViews];
    
    self.databaseTableName = @"remindList";
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *userID = userInfo? userInfo[@"userId"] : @"";
    self.databaseTableName = [self.databaseTableName stringByAppendingFormat:@"_%@",userID];
    
    self.dataArr = [@[] mutableCopy];
    self.myApp = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //讯飞初始化
    self.isSpeechUnderstander = NO;
    _iFlySpeechUnderstander = [IFlySpeechUnderstander sharedInstance];
    _iFlySpeechUnderstander.delegate = self;
    [self initRecognizer];
    [self initSynthesizer];
    //pcm播放器初始化
    self.audioPlayer = [[PcmPlayer alloc] init];
    
    //检查麦克风
    [self checkRecord];
    
    //判断是否开起推送权限
    [self isOpenNotificationJurisdiction];
    
    //创建数据库表
    [self createDatabaseTable];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.iFlySpeechUnderstander cancel];//终止语义
    [self.iFlySpeechUnderstander setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    [super viewWillDisappear:animated];
}

//是否授权推送权限
- (BOOL)isOpenNotificationJurisdiction {
    UIApplication *application = [UIApplication sharedApplication];
    NSUInteger notificationType = [[application currentUserNotificationSettings] types];
    if (notificationType == 0) {
  
        [self showAlertViewWithTitle:@"未开启通知权限" message:@"提醒无法主动推送给用户，“设置-通知-我爱我家-允许通知”，开启通知权限，让“提醒”功能更贴心" buttonTitle:@"我知道了" clickBtn:^{
            
        }];
        
        return NO;
    }
    
    return YES;
}

#pragma -mark EditRemindViewControllerDelegate
-(void)editRemindViewControllerWithNewAddRemind:(RemindItem *)remindItem {
    
    remindItem.recentlyRemindDate = [self dateTimeWithRemindType:remindItem.remindtype andRemindTime:remindItem.remindtime];
    
    NSIndexPath *indexPath;
    NSMutableArray *oriDataArr = [[NSMutableArray alloc] initWithArray:self.dataArr];
    for (NSInteger i = 0; i < oriDataArr.count; i++) {
        RemindItem *oriRemindItem = oriDataArr[i];
        if ([oriRemindItem.recentlyRemindDate compare:remindItem.recentlyRemindDate] == NSOrderedDescending) {
            [oriDataArr insertObject:remindItem atIndex:i];
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        }
    }
    
    
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:oriDataArr];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView layoutIfNeeded];
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        //刷新完成
        [strongSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
    
}

-(void)editRemindViewControllerWithEditRemind:(RemindItem *)remindItem {
    
    remindItem.recentlyRemindDate = [self dateTimeWithRemindType:remindItem.remindtype andRemindTime:remindItem.remindtime];
    
    NSIndexPath *indexPath;
    NSMutableArray *oriDataArr = [[NSMutableArray alloc] initWithArray:self.dataArr];
    for (NSInteger i = 0; i < oriDataArr.count; i++) {
        RemindItem *oriRemindItem = oriDataArr[i];
        if ([oriRemindItem.recentlyRemindDate compare:remindItem.recentlyRemindDate] == NSOrderedDescending) {
//            [oriDataArr insertObject:remindItem atIndex:i];
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        }
    }
    
    
    [self.dataArr removeAllObjects];
    [self.dataArr removeObjectAtIndex:indexPath.row];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView layoutIfNeeded];
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        //刷新完成
        [strongSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
    
}

#pragma -mark 创建数据库表
- (void)createDatabaseTable {
    
    NSDictionary *keys = @{@"remindtype"                 : @"string",
                           @"remindtime"                 : @"string",
                           @"createtimestamp"            : @"string",
                           @"content"                    : @"string"};
    
    __weak __typeof__(self) weakSelf = self;
    [[DBManager defaultManager] createTableWithName:self.databaseTableName AndKeys:keys Result:^(BOOL isOK) {
//         __strong __typeof__(weakSelf) strongSelf = weakSelf;
//        if (!isOK) {
//            //建表失败！
//            [strongSelf showAlertViewWithTitle:@"提示" message:@"建表失败" buttonTitle:@"确定" clickBtn:^{
//
//            }];
//            return ;
//        }
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
        NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindtype != 'onlyonce' or createtimestamp > %ld",self.databaseTableName,nowSp];
        NSLog(@"sql = %@",sql);
        
        NSMutableArray<RemindItem *> *dataArr = [[NSMutableArray alloc] init];
        if ([self.db open]) {
            FMResultSet * res = [self.db executeQuery:sql];
            
            while ([res next]) {
                RemindItem *item = [[RemindItem alloc] init];
                item.remindtype = [res stringForColumn:@"remindtype"];
                item.remindtime = [res stringForColumn:@"remindtime"];
                item.content = [res stringForColumn:@"content"];
                item.createtimestamp = [res stringForColumn:@"createtimestamp"];
                item.remindDate = [self showDateTimeWithRemindType:item.remindtype andRemindTime:item.remindtime];
                item.recentlyRemindDate = [self dateTimeWithRemindType:item.remindtype andRemindTime:item.remindtime];

                if ([item.remindtype isEqualToString:REMINDTYPE_EVERYDAY]) {
                    item.content = [NSString stringWithFormat:@"每天 %@",item.content];
                } else  if ([item.remindtype isEqualToString:REMINDTYPE_WORKDAY]) {
                    item.content = [NSString stringWithFormat:@"工作日 %@",item.content];
                } else  if ([item.remindtype isEqualToString:REMINDTYPE_WEEKEND]) {
                    item.content = [NSString stringWithFormat:@"周末 %@",item.content];
                }
                
                [dataArr addObject:item];
            }

        }
        
        if (dataArr.count) {
          NSArray *recentlyDataArr = [dataArr sortedArrayUsingComparator:^NSComparisonResult(RemindItem *obj1, RemindItem *obj2) {
              NSLog(@"obj1: %@",obj1.recentlyRemindDate);
                return [obj1.recentlyRemindDate compare:obj2.recentlyRemindDate];
            }];
            
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:recentlyDataArr];
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

-(NSDate *)dateTimeWithRemindType:(NSString *)remindType andRemindTime:(NSString *)remindTime {
    
    NSString *dateTime = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateDD = [dateFormatter stringFromDate:[NSDate date]];
    NSString *remindDateMM = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,remindTime];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *remindDate = [dateFormatter dateFromString:remindDateMM];
    
    NSString *weekDay = [Utility getDayWeek];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if ([remindType isEqualToString:REMINDTYPE_ONLYONCE]) {
        dateTime = currentDateDD;
    } else if ([remindType isEqualToString:REMINDTYPE_WEEKEND]){
        
        if ([weekDay isEqualToString:MONDAY]) {
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:5*24*60*60]];
        } else if([weekDay isEqualToString:TUESDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:4*24*60*60]];
        } else if([weekDay isEqualToString:WEDNESDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:3*24*60*60]];
        } else if([weekDay isEqualToString:THURSDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
        } else if([weekDay isEqualToString:FRIDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
        } else if([weekDay isEqualToString:SATURDAY]){
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
                dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
            }else {
                dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
            }
        } else if([weekDay isEqualToString:SUNDAY]){
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
                dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
            }else {
                dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
            }
        }
        
    } else if ([remindType isEqualToString:REMINDTYPE_WORKDAY]){
        
        if ([weekDay isEqualToString:SATURDAY]) {
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
        } else if([weekDay isEqualToString:SUNDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
        } else {
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
               dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
            }else {
                dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
            }
        }
        
    } else {
        
        if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
        }else {
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
        }
        
    }
    
    NSLog(@"dateTime: %@", dateTime);
    
    dateTime = [NSString stringWithFormat:@"%@ %@:00",dateTime,remindTime];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *recentlyRemindDate = [dateFormatter dateFromString:dateTime];
    
    return recentlyRemindDate;
}

-(NSString *)showDateTimeWithRemindType:(NSString *)remindType andRemindTime:(NSString *)remindTime {
    
    NSString *dateTime = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateDD = [dateFormatter stringFromDate:[NSDate date]];
    NSString *remindDateMM = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,remindTime];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *remindDate = [dateFormatter dateFromString:remindDateMM];
    
    NSString *weekDay = [Utility getDayWeek];
    
    if ([remindType isEqualToString:REMINDTYPE_ONLYONCE]) {
        dateTime = @"今天";
    } else if ([remindType isEqualToString:REMINDTYPE_WEEKEND]){
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        if ([weekDay isEqualToString:MONDAY]) {
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:5*24*60*60]];
        } else if([weekDay isEqualToString:TUESDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:4*24*60*60]];
        } else if([weekDay isEqualToString:WEDNESDAY]){
            dateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:3*24*60*60]];
        } else if([weekDay isEqualToString:THURSDAY]){
            dateTime = @"后天";
        } else if([weekDay isEqualToString:FRIDAY]){
            dateTime = @"明天";
        } else if([weekDay isEqualToString:SATURDAY]){
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
                dateTime = @"明天";
            }else {
                dateTime = @"今天";
            }
        } else if([weekDay isEqualToString:SUNDAY]){
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
                dateTime = @"明天";
            }else {
                dateTime = @"今天";
            }
        }
        
    } else if ([remindType isEqualToString:REMINDTYPE_WORKDAY]){
        
        if ([weekDay isEqualToString:SATURDAY]) {
            dateTime = @"后天";
        } else if([weekDay isEqualToString:SUNDAY]){
            dateTime = @"明天";
        } else {
            if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
                dateTime = @"明天";
            }else {
                dateTime = @"今天";
            }
        }
    
    } else {
        
        if ([remindDate compare:[NSDate date]] == NSOrderedAscending){
            dateTime = @"明天";
        }else {
            dateTime = @"今天";
        }
        
    }
    
    return dateTime;
}

#pragma mark - database event
- (void)insertRemindWithData:(NSDictionary *)data{
    NSLog(@"data = %@",data);
    
    if ([_db open]) {
        
        NSDictionary *itemDic = data[@"semantic"][@"slots"];
        NSString *dateString = itemDic[@"datetime"][@"date"];
        NSString *timeString = itemDic[@"datetime"][@"time"];
        
        NSString *remindTime = [timeString substringToIndex:5];
        NSString *content = itemDic[@"content"];
        
        
        NSString* timeStr = [NSString stringWithFormat:@"%@ %@",dateString,timeString];
        NSLog(@"timeStr = %@",timeStr);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
        NSDate* date = [formatter dateFromString:timeStr];
        NSInteger timeSp_f = [date timeIntervalSince1970];
        NSLog(@"timeSp_f = %ld",timeSp_f);
        
        NSInteger nowSp_f = [[NSDate date] timeIntervalSince1970];
        NSLog(@"date = %@",[NSDate date]);
        
        NSLog(@"nowSp_f = %ld",nowSp_f);
        if (nowSp_f > timeSp_f) {
            [MBProgressHUD hideHUD];
            [self showAlertViewWithTitle:@"提示" message:@"设置提醒时间应大于当前时间!" buttonTitle:@"知道了" clickBtn:^{
                
            }];
            return;
        }
        
        
        //        NSString *sql = [NSString stringWithFormat:@"insert into %@ (remindtype,remindtime,content,createtimestamp) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",self.databaseTableName,dateString,timeString,timeInterval,content,timeSp,data[@"text"],dateOrig,remindID,@"0",@"0",@"0",@"0",@"0",@"0",@"0"];
        //        NSLog(@"sql = %@",sql);
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (remindtype,remindtime,content,createtimestamp) values ('%@','%@','%@','%ld')",self.databaseTableName,REMINDTYPE_ONLYONCE,remindTime,content,timeSp_f];
        BOOL isCreate = [_db executeUpdate:sql];
        if (isCreate) {
            [MBProgressHUD showSuccess:@"创建成功"];
            [self getDataFromDatabase];
            
            //            //创建闹钟
            //            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            //            dispatch_async(queue, ^{
            //                [AlarmClockItem addAlarmClockWithAlarmClockID:timeSp AlarmClockContent:[content substringToIndex:content.length - 1]  AlarmClockDate:timeStr  AlarmClockType:AlarmTypeOnce];
            //                NSLog(@"timeSp:%@ \n content:%@ \n timeStr:%@",timeSp,content,timeStr);
            //            });
            
            
            
        }else{
            [MBProgressHUD showSuccess:@"创建失败"];
        }
    }
}

//#pragma -mark 从数据库获取提醒数据
//- (NSMutableArray *)getRemindList {
//
//    NSInteger nowSp = [[NSDate date] timeIntervalSince1970];
//    NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindType != onlyonce or createtimestamp > %ld",self.databaseTableName,nowSp];
//    NSLog(@"sql = %@",sql);
//
//    NSMutableArray *allDataArr = [[NSMutableArray alloc] init];
//    if ([self.db open]) {
//        FMResultSet * res = [_db executeQuery:sql];
//
//        while ([res next]) {
//            RemindItem *item = [[RemindItem alloc] init];
//            item.remindtype = [res stringForColumn:@"remindtype"];
//            item.remindtime = [res stringForColumn:@"remindtime"];
//            item.content = [res stringForColumn:@"content"];
//            item.createtimestamp = [res stringForColumn:@"createtimestamp"];
//            [allDataArr addObject:item];
//        }
//        NSLog(@"arr = %@",allDataArr);
//    }
//
//    return allDataArr;
//}




 #pragma mark - 设置识别参数

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

#pragma -mark 点击录音
- (IBAction)beginRecording:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        if ([self isReachable]) {
            if ([self isRecord]) {
                
                if (!self.speakingView) {
                    self.speakingView = [[NSBundle mainBundle] loadNibNamed:@"SpeakingView" owner:self options:nil][0];
                    [self.speakingView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                }
                [self.myApp.window addSubview:self.speakingView];
                [self.speakingView startAction];
                
                [self beginDistinguish];
                
            }else{
                
                [self showAlertViewWithTitle:@"提示" message:@"请在“设置-隐私-麦克风”选项中允许我爱我家访问你的麦克风" buttonTitle:@"我知道了" clickBtn:^{
                }];
                
                return;
            }
            
        }else{
            
            [self showAlertViewWithTitle:@"提示" message:@"网络中断，无法语音添加提醒" buttonTitle:@"我知道了" clickBtn:^{
                
            }];
            return;
            
        }
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (![self isReachable]) {
            return;
        }
        
        [self.speakingView endSpeak];
        [self.iFlySpeechUnderstander stopListening];
        if (self.iFlySpeechUnderstander.isUnderstanding) {
            [MBProgressHUD showMessage:@"正在创建..."];
        }
        
        
    }
    
}

#pragma -mark 是否允许访问麦克风
- (BOOL)isRecord{
    
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    switch (permissionStatus) {
        case AVAudioSessionRecordPermissionDenied:
            return NO;
            break;
        case AVAudioSessionRecordPermissionGranted:
            return YES;
            break;
        default:
            // this should not happen.. maybe throw an exception.
            break;
    }
    
    return NO;
}

#pragma -mark 开始录音
- (void)beginDistinguish {
    
    if (self.isSpeechUnderstander){
        return;
    }
    
    //设置为麦克风输入语音
    [self.iFlySpeechUnderstander setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    bool ret = [self.iFlySpeechUnderstander startListening];
    
    if (ret) {
        
        self.isSpeechUnderstander = YES;
        self.isCanceled = NO;
        
    } else {
        
    }
    
}


#pragma mark - table data source and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifiter = @"remindCell";
    RemindCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiter];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"RemindCell" owner:self options:nil][0];
        cell.delegate = self;
    }
    
    
    RemindItem *remindItem = [self.dataArr objectAtIndex:indexPath.row];
    cell.contentLab.text = remindItem.content;
    cell.remindTimeLab.text = remindItem.remindtime;
    cell.remindDateLab.text = remindItem.remindDate;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EditRemindViewController *vc = [[EditRemindViewController alloc] initWithNibName:@"EditRemindViewController" bundle:nil];
    vc.eventType = EdRemind;
    vc.remindItem = [self.dataArr objectAtIndex:indexPath.row];
    vc.database = self.db;
//    vc.delegate = self;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    __weak __typeof__(self) weakSelf = self;
    vc.editRemindViewControllerWithEditRemind = ^(RemindItem *remindItem) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
        [strongSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        [strongSelf addRemindItem:remindItem];
    };
    
    vc.editRemindViewControllerWithDelRemind = ^(RemindItem *remindItem) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
        [strongSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    };
    
}

-(void)addRemindItem:(RemindItem *)remindItem {
    
    remindItem.recentlyRemindDate = [self dateTimeWithRemindType:remindItem.remindtype andRemindTime:remindItem.remindtime];
    
    if ([remindItem.remindtype isEqualToString:REMINDTYPE_EVERYDAY]) {
        remindItem.content = [NSString stringWithFormat:@"每天 %@",remindItem.content];
    } else  if ([remindItem.remindtype isEqualToString:REMINDTYPE_WORKDAY]) {
        remindItem.content = [NSString stringWithFormat:@"工作日 %@",remindItem.content];
    } else  if ([remindItem.remindtype isEqualToString:REMINDTYPE_WEEKEND]) {
        remindItem.content = [NSString stringWithFormat:@"周末 %@",remindItem.content];
    }
    
    NSIndexPath *indexPath;
    NSMutableArray *oriDataArr = [[NSMutableArray alloc] initWithArray:self.dataArr];
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        RemindItem *oriRemindItem = oriDataArr[i];
        if ([oriRemindItem.recentlyRemindDate compare:remindItem.recentlyRemindDate] == NSOrderedDescending) {
            [oriDataArr insertObject:remindItem atIndex:i];
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        } else if (i == oriDataArr.count-1) {
            [oriDataArr addObject:remindItem];
            indexPath = [NSIndexPath indexPathForRow:i+1 inSection:0];
            
        }
    }
    
    if (!self.dataArr.count) {
        [oriDataArr addObject:remindItem];
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:oriDataArr];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView layoutIfNeeded];
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        //刷新完成
        [strongSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
    
}


#pragma mark - RemindCell delegate
- (void)RemindCell:(UITableViewCell *)cell AndIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isReachable]) {
        
        NSString *readText = @"hahah";//self.dataArr[indexPath.row][@"content"];
        [self readTextWithString:readText];
        
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




//判断当前网络状态
- (BOOL)isReachable {
    AFNetworkReachabilityManager*manager = [AFNetworkReachabilityManager sharedManager];
    return manager.isReachable;
}


@end








