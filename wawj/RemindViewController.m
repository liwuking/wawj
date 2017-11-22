
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
#import <UIImageView+WebCache.h>
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
#import "OverdueRemindCell.h"
#import "RemindItem.h"
#import <AVFoundation/AVFoundation.h>
#import "WAPreviewRecordViewController.h"

typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,//普通合成
    UriType             = 6, //uri合成
};

typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2, //高异常分析需要的级别
    Paused              = 4,
};

@interface RemindViewController ()<UITableViewDelegate,UITableViewDataSource,IFlySpeechRecognizerDelegate,IFlySpeechSynthesizerDelegate,RemindCellDelegate,BuildRemindViewDelegate,OverdueRemindCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *longGesLab;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *microphoneBGView;
@property (weak, nonatomic) IBOutlet UIView *voiceSearchView;

//语音语义理解对象
@property (nonatomic,strong) IFlySpeechUnderstander *iFlySpeechUnderstander;
//文本语义理解对象
//@property (nonatomic,strong) IFlyTextUnderstander *iFlyUnderStand;

@property (nonatomic, copy)  NSString * defaultText;
@property (nonatomic) BOOL isCanceled;@property (nonatomic,strong) NSString *result;
@property (nonatomic) BOOL isSpeechUnderstander;//当前状态是否是语音语义理解
@property (nonatomic) BOOL isTextUnderstander;//当前状态是否是文本语义理解

//语音合成对象
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
//@property (nonatomic, assign) BOOL isSpeechCanceled;
//@property (nonatomic, assign) BOOL hasError;
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

@property (nonatomic,strong) AVAudioPlayer *audioFilePlayer;//音频播放器，用于播放录音文件


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
    }else {
        [self.buildRemindView removeFromSuperview];
        self.buildRemindView = nil;
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
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)BuildRemindViewWithHiddenBuildRemind {
    [self.buildRemindView removeFromSuperview];
    self.buildRemindView = nil;
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

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
//    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing),dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    __weak __typeof__(self) weakSelf = self;
    // The drop-down refresh
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (strongSelf.db) {
            [strongSelf getDataFromDatabase];
        }else {
            [MBProgressHUD showMessage:nil];
            [strongSelf createDatabaseTable];
        }
        
    }];
    
//    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
//    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//         __strong __typeof__(weakSelf) strongSelf = weakSelf;
//    }];
    
}

-(BOOL)checkNoticePermission {
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (settings.types >= 6) {
        return YES;
    }
    
    return NO;
}

-(BOOL)checkMicPhonePermission
{
   
    BOOL micPhonePermission = NO;
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
        return NO;
        
    } else  if (permissionStatus == AVAudioSessionRecordPermissionGranted) {
        
        micPhonePermission = YES;

    }
    
    
    BOOL noticePermission = NO;
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (settings.types >= 6) {
        noticePermission = YES;
    }
    if (!noticePermission && !micPhonePermission) {
        //设置-隐私-麦克风
        [self showAlertViewWithTitle:@"\n需开启 \"麦克风\" 和 \"通知\" 权限 \n\n" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"去开启" clickOtherBtn:^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:url];
                });
                
                
            }
        }];
        return NO;

    } else if(!micPhonePermission){
        
        //设置-隐私-麦克风
        [self showAlertViewWithTitle:@"\n需开启 \"麦克风\" 权限 \n\n" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"去开启" clickOtherBtn:^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:url];
                });
            }
        }];
        return NO;
        
    } else if(!noticePermission){
        
        //设置-隐私-麦克风
        [self showAlertViewWithTitle:@"\n需开启 \"通知\" 权限 \n\n" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"去开启" clickOtherBtn:^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:url];
                });
            }
        }];
        return NO;
        
    }
    
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.isSpeechUnderstander = NO;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.iFlySpeechUnderstander cancel];//终止语义
    [self.iFlySpeechUnderstander setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    [self.iFlySpeechSynthesizer stopSpeaking];
    
    [super viewWillDisappear:animated];
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
    _iFlySpeechUnderstander = [IFlySpeechUnderstander sharedInstance];
    _iFlySpeechUnderstander.delegate = self;
    [self initRecognizer];
    
    [self initSynthesizer];
    //pcm播放器初始化
    self.audioPlayer = [[PcmPlayer alloc] init];
    
    //检查麦克风
    [self checkMicPhonePermission];
    
    //判断是否开起推送权限
//    [self isOpenNotificationJurisdiction];
    
    
    //创建数据库表
//    [MBProgressHUD showMessage:nil];
    [self createDatabaseTable];
    
    __weak __typeof__(self) weakSelf = self;
    self.remindViewControllerWithAddRemind = ^(RemindItem *remindItem) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf addRemindItem:remindItem];
    };

}

//-(void)insertRemoteRemindDate:(NSArray *)remindArr {
//
//    for (RemindItem *remindItem in remindArr) {
//
//        NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindorigintype = '%@' and remindid = %@",self.databaseTableName,REMINDORIGINTYPE_REMOTE,remindItem.remindid];
//        NSLog(@"sql = %@",sql);
//
//        if ([self.db open]) {
//            FMResultSet * res = [self.db executeQuery:sql];
//            if (![res next]) {
//                NSString *sql = [NSString stringWithFormat:@"insert into %@ (remindorigintype,remindid,remindtype,remindtime,content,audiourl,headurl,createtimestamp) values ('%@','%@','%@','%@','%@','%@','%@','%@')",self.databaseTableName,REMINDORIGINTYPE_REMOTE,remindItem.remindid,REMINDTYPE_ONLYONCE,remindItem.remindtime,@"",remindItem.audiourl,remindItem.headurl,remindItem.createtimestamp];
//                NSLog(@"语音提醒sql: %@",sql);
//                BOOL isCreate = [_db executeUpdate:sql];
//                if (isCreate) {
//                    NSLog(@"插入成功");
//                    //添加一个新的闹钟
//                    NSString *clockIdentifier = [NSString stringWithFormat:@"%@%@",REMINDTYPE_ONLYONCE,remindItem.remindtime];
//                    [AlarmClockItem addAlarmClockWithAlarmClockContent:@"" AlarmClockDateTime:remindItem.remindtime AlarmClockType:REMINDTYPE_ONLYONCE AlarmClockIdentifier:clockIdentifier isOhters:YES];
//
//                }else {
//                    NSLog(@"插入失败");
//                }
//
//            } else {
//                NSLog(@"已存在");
//            }
//        }
//    }
//
//
//
//}
//
//-(void)getRemoteRemindData {
//
//    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2005" andModel:nil];
//    __weak __typeof__(self) weakSelf = self;
//    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
//
//        [MBProgressHUD hideHUD];
//
//        __strong __typeof__(weakSelf) strongSelf = weakSelf;
//
//        if ([data[@"code"] isEqualToString:@"0000"]) {
//
//            if (![data[@"body"] isKindOfClass:[NSNull class]]) {
//
//                if ([data[@"body"][@"interactiveRemindList"] isKindOfClass:[NSNull class]]) return ;
//
//                NSDictionary *bodyDict = data[@"body"][@"interactiveRemindList"];
//                NSMutableArray *tempArr = [@[] mutableCopy];
//                for (NSDictionary *subDict in bodyDict) {
//
//                    NSDictionary *dictTrans = [subDict transforeNullValueToEmptyStringInSimpleDictionary];
//                    RemindItem *item = [[RemindItem alloc] init];
//                    item.remindtype = REMINDTYPE_ONLYONCE;
//                    item.content = dictTrans[@"remindContent"];
//                    item.createtimestamp = [NSString stringWithFormat:@"%ld",[dictTrans[@"remindTime"] integerValue]/1000];
//                    item.audiourl = dictTrans[@"remindAudio"];
//                    item.remindid = dictTrans[@"id"];
//                    NSInteger remindTimeStamp = [ item.createtimestamp integerValue];
//                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                    dateFormatter.timeZone = [NSTimeZone localTimeZone];
//                    [dateFormatter setDateFormat:@"HH:mm"];
//                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:remindTimeStamp];
//                    item.remindtime = [dateFormatter stringFromDate:date];
//
//                    NSInteger createUser = [dictTrans[@"createUser"] integerValue];
//                    NSString *headUrl = @"";
//                    NSMutableArray *arr = [CoreArchive arrForKey:USER_QIMI_ARR];
//                    for (NSDictionary *dict in arr) {
//                        if ([dict[@"qinmiUser"] isEqualToString:[NSString stringWithFormat:@"%ld",createUser]]) {
//                            headUrl = dict[@"headUrl"];
//                            break;
//                        }
//                    }
//                    item.headurl = headUrl;
//                    [tempArr addObject:item];
//                }
//
//                if(tempArr.count) {
//                    [strongSelf insertRemoteRemindDate:tempArr];
//                }
//            }
//
//
//        } else {
//
//            [strongSelf showAlertViewWithTitle:@"提示" message:data[@"desc"] buttonTitle:@"确定" clickBtn:^{
//
//            }];
//
//        }
//
//        [strongSelf getDataFromDatabase];
//
//    } fail:^(NSError *error) {
//
//        __strong __typeof__(weakSelf) strongSelf = weakSelf;
//        [MBProgressHUD hideHUD];
//
//        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
//
//        }];
//
//        [strongSelf getDataFromDatabase];
//
//    }];
//
//}

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
    
    remindItem.recentlyRemindDate = [self dateTimeWithRemindType:remindItem.remindtype andRemindTime:remindItem.remindtime andCreatetimestamp:remindItem.createtimestamp isOhter:NO];
    
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
    
    remindItem.recentlyRemindDate = [self dateTimeWithRemindType:remindItem.remindtype andRemindTime:remindItem.remindtime andCreatetimestamp:remindItem.createtimestamp isOhter:NO];
    
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
//        [strongSelf getRemoteRemindData];
        [strongSelf getDataFromDatabase];
    }];
    
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



#pragma -mark
#pragma -mark 从数据库获取过期数据
- (void)getOverdueDataFromDatabase {
    if ([self.db open]) {
        
        NSInteger nowSp = [[NSDate date] timeIntervalSince1970];
        NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindtype == 'onlyonce' and createtimestamp < %ld order by createtimestamp desc",self.databaseTableName,nowSp];
        NSLog(@"sql = %@",sql);
        
        NSMutableArray *dataArr = [[NSMutableArray alloc] init];
        FMResultSet * res = [self.db executeQuery:sql];
        NSMutableDictionary *remoteDict = [[NSMutableDictionary alloc] initWithDictionary:[CoreArchive dicForKey:REMOTE_REMIND_ARR]];
        while ([res next]) {
            
            RemindItem *item = [[RemindItem alloc] init];
            item.remindorigintype = [res stringForColumn:@"remindorigintype"];
            item.remindtype = [res stringForColumn:@"remindtype"];
            item.remindtime = [res stringForColumn:@"remindtime"];
            item.content = [res stringForColumn:@"content"];
            item.remindid = [res stringForColumn:@"remindid"];
            item.createtimestamp = [res stringForColumn:@"createtimestamp"];
            if ([item.remindorigintype isEqualToString:REMINDORIGINTYPE_REMOTE]) {
                item.headurl = [res stringForColumn:@"headurl"];
                item.audiourl = [res stringForColumn:@"audiourl"];
                NSString *qinmiName = remoteDict[item.remindid][@"qinmiName"];
                item.content = [NSString stringWithFormat:@"%@的提醒",qinmiName];
            }
            
            item.remindDate = [self showDateTimeWithCreateTimeStamp:item.createtimestamp];
            item.recentlyRemindDate = [self dateTimeWithCreateTimeStamp:item.createtimestamp];
            NSLog(@"item.recentlyRemindDate = %@",item.recentlyRemindDate);
            item.isOverdue = YES;
            [dataArr addObject:item];
        }
        
        
        if (dataArr.count) {
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:dataArr];
            [self.tableView reloadData];
        } else {
            [self.dataArr removeAllObjects];
            [self.tableView reloadData];
            
//            [self insertOneAdditionalRemindData];
//            if ([CoreArchive boolForKey:USERNAME]) {
//
//            }
            
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
            NSMutableDictionary *remoteDict = [[NSMutableDictionary alloc] initWithDictionary:[CoreArchive dicForKey:REMOTE_REMIND_ARR]];
            while ([res next]) {
                RemindItem *item = [[RemindItem alloc] init];
                item.remindid = [res stringForColumn:@"remindid"];
                item.remindorigintype = [res stringForColumn:@"remindorigintype"];
                NSLog(@"[res stringForColumn:%@", [res stringForColumn:@"remindorigintype"]);
                item.remindtype = [res stringForColumn:@"remindtype"];
                item.remindtime = [res stringForColumn:@"remindtime"];
                item.content = [res stringForColumn:@"content"];
                item.createtimestamp = [res stringForColumn:@"createtimestamp"];
                if ([item.remindorigintype isEqualToString:REMINDORIGINTYPE_REMOTE]) {
                    item.headurl = [res stringForColumn:@"headurl"];
                    item.audiourl = [res stringForColumn:@"audiourl"];
                    NSString *qinmiName = remoteDict[item.remindid][@"qinmiName"];
                    item.content = [NSString stringWithFormat:@"%@的提醒",qinmiName];
                }
                item.remindDate = [self showDateTimeWithRemindType:item.remindtype andRemindTime:item.remindtime andCreatetimestamp:item.createtimestamp];
                item.recentlyRemindDate = [self dateTimeWithRemindType:item.remindtype andRemindTime:item.remindtime andCreatetimestamp:item.createtimestamp isOhter:![item.audiourl isEqualToString:@""]];

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
        } else if(self.dataArr){
//            [self.dataArr removeAllObjects];
//            [self.tableView reloadData];
            [self getOverdueDataFromDatabase];
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

-(NSDate *)dateTimeWithRemindType:(NSString *)remindType andRemindTime:(NSString *)remindTime andCreatetimestamp:(NSString *)createtimestamp isOhter:(BOOL)isOther{
    
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
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *createDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[createtimestamp integerValue]]];
        
        NSString *today = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
        NSString *tomorrow = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
        NSString *afterday = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
        
        if ([createDateStr isEqualToString:today]) {
            dateTime = today;
        } else if ([createDateStr isEqualToString:tomorrow]) {
            dateTime = tomorrow;
        } else {
            dateTime = afterday;
        }
    
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
    
    if (isOther) {
        dateTime = [NSString stringWithFormat:@"%@ %@:30",dateTime,remindTime];
    } else {
        dateTime = [NSString stringWithFormat:@"%@ %@:00",dateTime,remindTime];
    }
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *recentlyRemindDate = [dateFormatter dateFromString:dateTime];
    
    return recentlyRemindDate;
}

-(NSString *)showDateTimeWithRemindType:(NSString *)remindType andRemindTime:(NSString *)remindTime andCreatetimestamp:(NSString *)createtimestamp {
    
    NSString *dateTime = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateDD = [dateFormatter stringFromDate:[NSDate date]];
    NSString *remindDateMM = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,remindTime];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *remindDate = [dateFormatter dateFromString:remindDateMM];
    
    NSString *weekDay = [Utility getDayWeek];
    
    if ([remindType isEqualToString:REMINDTYPE_ONLYONCE]) {
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *createDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[createtimestamp integerValue]]];
        
        NSString *today = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
        NSString *tomorrow = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
//        NSString *afterday = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
        
        if ([createDateStr isEqualToString:today]) {
            dateTime = @"今天";
        } else if ([createDateStr isEqualToString:tomorrow]) {
            dateTime = @"明天";
        } else {
            dateTime = @"后天";
        }
        
        
        
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
        
        NSDate* remindDate = [formatter dateFromString:timeStr];
        NSInteger timeSp_f = [remindDate timeIntervalSince1970];
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
        
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (remindorigintype,remindid,remindtype,remindtime,content,audiourl,headurl,createtimestamp) values ('%@','%@','%@','%@','%@','%@','%@','%ld')",self.databaseTableName,REMINDORIGINTYPE_LOCAL,@"",REMINDTYPE_ONLYONCE,remindTime,content,@"",@"",timeSp_f];
        NSLog(@"语音提醒sql: %@",sql);
        BOOL isCreate = [_db executeUpdate:sql];
        if (isCreate) {
            [MBProgressHUD showSuccess:@"创建成功"];
            [self getDataFromDatabase];
            
             NSString *clockIdentifier = [NSString stringWithFormat:@"%@%@",REMINDTYPE_ONLYONCE,remindTime];
//            [AlarmClockItem addAlarmClockWithAlarmClockContent:content AlarmClockDateTime:remindTime AlarmClockType:REMINDTYPE_ONLYONCE AlarmClockIdentifier:clockIdentifier isOhters:NO];
            [AlarmClockItem addAlarmClockWithAlarmClockContent:content fireDate:remindDate AlarmClockType:REMINDTYPE_ONLYONCE AlarmClockIdentifier:clockIdentifier isOhters:NO];
            
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
    if (self.iFlySpeechSynthesizer == nil) {
        self.iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    self.iFlySpeechSynthesizer.delegate = self;
    
    //设置语速1-100
    [self.iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
    
    //设置音量1-100
    [self.iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
    
    //设置音调1-100
    [self.iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
    
    //设置采样率
    [self.iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //设置发音人
    [self.iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    
    //设置文本编码格式
    [self.iFlySpeechSynthesizer setParameter:@"unicode" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    
    
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
    
   
    NSLog(@"%s  %ld", __func__, sender.state);
    if (sender.state == UIGestureRecognizerStateBegan) {
         self.microphoneBGView.alpha = 0.5;
        self.longGesLab.alpha = 0.5;
        if ([self isReachable] && [self checkMicPhonePermission]) {
            
            if (!self.speakingView) {
                self.speakingView = [[NSBundle mainBundle] loadNibNamed:@"SpeakingView" owner:self options:nil][0];
                [self.speakingView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            } 
            [self.myApp.window addSubview:self.speakingView];
            [self.speakingView startAction];
            
            [self beginDistinguish];
            
        }else{
            
            [self showAlertViewWithTitle:@"提示" message:@"网络中断，无法语音添加提醒" buttonTitle:@"我知道了" clickBtn:^{
                
            }];
            return;
            
        }
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
         self.microphoneBGView.alpha = 1;
        self.longGesLab.alpha = 1;
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
    
    //设置为麦克风输入语音
    [self.iFlySpeechUnderstander setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    BOOL ret = [self.iFlySpeechUnderstander startListening];
    
    if (ret) {

        self.isSpeechUnderstander = YES;
        self.isCanceled = NO;

    } else {
        
        [MBProgressHUD showError:@"启动服务失败"];
        
    }
    
}


#pragma mark - table data source and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RemindItem *remindItem = [self.dataArr objectAtIndex:indexPath.row];
    if (remindItem.isOverdue) {

        static NSString *identifiter = @"OverdueRemindCell";
        OverdueRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiter];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"OverdueRemindCell" owner:self options:nil][0];
            cell.delegate = self;
        }

        cell.contentLab.text = remindItem.content;
        cell.remindTimeLab.text = remindItem.remindtime;
        cell.remindDateLab.text = remindItem.remindDate;
        cell.cellIndexPath = indexPath;
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:remindItem.headurl] placeholderImage:[UIImage imageNamed:@"alarmClocked"]];

        return cell;
    } else {
    
        static NSString *identifiter = @"remindCell";
        RemindCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiter];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"RemindCell" owner:self options:nil][0];
            cell.delegate = self;
        }
        
        cell.contentLab.text = remindItem.content;
        cell.remindTimeLab.text = remindItem.remindtime;
        cell.remindDateLab.text = remindItem.remindDate;
        cell.cellIndexPath = indexPath;
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:remindItem.headurl] placeholderImage:[UIImage imageNamed:@"alarmClock"]];
        
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RemindItem *remindItem = [self.dataArr objectAtIndex:indexPath.row];
    
    if ([remindItem.remindorigintype isEqualToString:REMINDORIGINTYPE_REMOTE]) {
//        [self showAlertViewWithTitle:@"互动提醒不允许编辑" message:nil buttonTitle:@"确定" clickBtn:^{
//
//        }];
        
        NSMutableDictionary *remoteDict = [[NSMutableDictionary alloc] initWithDictionary:[CoreArchive dicForKey:REMOTE_REMIND_ARR]];
        NSString *createUser = remoteDict[remindItem.remindid][@"createUser"];
        NSString *headUrl = remoteDict[remindItem.remindid][@"headUrl"];
        NSString *qinmiName = remoteDict[remindItem.remindid][@"qinmiName"];
        
        WAPreviewRecordViewController *vc = [[WAPreviewRecordViewController alloc] initWithNibName:@"WAPreviewRecordViewController" bundle:nil];
        vc.audioUrl = remindItem.audiourl;
        vc.recordedTime = [remoteDict[remindItem.remindid][@"remindSeconds"] integerValue];
        vc.headUrl = headUrl;
        vc.qinmiName = qinmiName;
        vc.recordedDate = remindItem.remindtime;
        
        vc.isFromRemindVC = YES;
        vc.createUser = createUser;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        
        return;
    }
    
    EditRemindViewController *vc = [[EditRemindViewController alloc] initWithNibName:@"EditRemindViewController" bundle:nil];
    vc.eventType = EdRemind;
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
        [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
        [strongSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        [strongSelf addRemindItem:remindItem];
    };
    
}

-(void)addRemindItem:(RemindItem *)remindItem {
    
    remindItem.recentlyRemindDate = [self dateTimeWithRemindType:remindItem.remindtype andRemindTime:remindItem.remindtime andCreatetimestamp:remindItem.createtimestamp isOhter:NO];
    
    if ([remindItem.remindtype isEqualToString:REMINDTYPE_EVERYDAY]) {
        remindItem.content = [NSString stringWithFormat:@"每天 %@",remindItem.content];
    } else  if ([remindItem.remindtype isEqualToString:REMINDTYPE_WORKDAY]) {
        remindItem.content = [NSString stringWithFormat:@"工作日 %@",remindItem.content];
    } else  if ([remindItem.remindtype isEqualToString:REMINDTYPE_WEEKEND]) {
        remindItem.content = [NSString stringWithFormat:@"周末 %@",remindItem.content];
    }
    
    remindItem.remindDate = [self showDateTimeWithRemindType:remindItem.remindtype andRemindTime:remindItem.remindtime andCreatetimestamp:remindItem.createtimestamp];
    
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
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:audioFilePath];
    
    NSError *error=nil;
    self.audioFilePlayer=[[AVAudioPlayer alloc] initWithData:data error:&error];
    self.audioFilePlayer.numberOfLoops=0;
    self.audioFilePlayer.volume = 1;
    [self.audioFilePlayer prepareToPlay];
    if (error) {
        NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
        [MBProgressHUD showError:@"播放失败"];
        return ;
    }
    
    [self.audioFilePlayer play];
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    
}


#pragma mark - RemindCell delegate
- (void)RemindCell:(RemindCell *)cell clickedIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.audioFilePlayer isPlaying]) {
        [MBProgressHUD showSuccess:@"正在播音"];
        return;
    }
    
    if ([self isReachable]) {
    
        NSString *readText = [NSString stringWithFormat:@"%@%@%@",cell.remindDateLab.text,cell.remindTimeLab.text,cell.contentLab.text];
        [self readTextWithString:readText];

    }else{

        [self showAlertViewWithTitle:@"提醒" message:@"网络中断，无法朗读提醒" buttonTitle:@"我知道了" clickBtn:^{
            
        }];
    }
    
}



#pragma mark - iFly 语义理解 delegate
- (void) onBeginOfSpeech
{
    NSLog(@"%s",__func__);
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    [MBProgressHUD hideHUD];
    NSLog(@"%s",__func__);
}

/**
 音量变化回调
 volume 录音的音量，音量范围0~30
 ****/
- (void) onVolumeChanged: (int)volume
{
    NSLog(@"%s",__func__);
}

/**
 语义理解服务结束回调（注：无论是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s %d %@ %@",__func__,error.errorCode,error.errorDesc,_result);
    
    NSString *text ;
    if (error.errorCode ==0 ) {
        if (_result.length == 0) {
            text = @"无识别结果";
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"说话时间过短或不太清晰"];
        }
    }else {
        [MBProgressHUD hideHUD];
        if (_result.length == 0) {
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc]];
        }
    }

    self.isSpeechUnderstander = NO;
    
    [_listeningView removeFromSuperview];
    _listeningView = nil;
}


/**
 语义理解结果回调
 result 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSLog(@"%s",__func__);
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
    NSLog(@"%s",__func__);
    NSLog(@"识别取消");
}

#pragma -mark 读出文字
- (void)readTextWithString:(NSString *)str {
    if ([str isEqualToString:@""]) {
        return;
    }
    
    if (self.audioPlayer != nil && self.audioPlayer.isPlaying == YES) {
        [self.audioPlayer stop];
    }

    self.iFlySpeechSynthesizer.delegate = self;
    
    [MBProgressHUD showMessage:@"正在合成..."];
    [self.iFlySpeechSynthesizer startSpeaking:str];
    
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
    NSLog(@"%s",__func__);
    [self.listeningView setFrame:[UIScreen mainScreen].bounds];
    [self.myApp.window addSubview:self.listeningView];
    
    [MBProgressHUD hideHUD];
    
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
    NSLog(@"%s",__func__);
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
    NSLog(@"%s",__func__);
    self.listeningView.progressLabel.text = [NSString stringWithFormat:@"%2d%%",progress];
    
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
    NSLog(@"%s",__func__);
//    _state = Paused;
}



/**
 恢复合成回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakResumed
{
    NSLog(@"%s",__func__);
//    _state = Playing;
}

/**
 合成结束（完成）回调
 
 对uri合成添加播放的功能
 ****/
- (void)onCompleted:(IFlySpeechError *) error
{
    NSLog(@"%s,error=%d",__func__,error.errorCode);
    
    if (error.errorCode != 0) {
        NSString *mes = [NSString stringWithFormat:@"错误码: %i\n错误描述: %@",error.errorCode,error.errorDesc];
        [self showAlertViewWithTitle:@"语音播放出错" message:mes buttonTitle:@"确定" clickBtn:^{
            
        }];
    }
    
    [MBProgressHUD hideHUD];
    [self.iFlySpeechSynthesizer stopSpeaking];
    if (self.listeningView) {
        [self.listeningView removeFromSuperview];
        self.listeningView = nil;
    }
    
    
}




/**
 取消合成回调
 ****/
- (void)onSpeakCancel
{
    NSLog(@"%s",__func__);
    
}




//判断当前网络状态
- (BOOL)isReachable {
    AFNetworkReachabilityManager*manager = [AFNetworkReachabilityManager sharedManager];
    return manager.isReachable;
}


@end








