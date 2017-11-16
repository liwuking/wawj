//
//  EditRemindViewController.m
//  wawj
//
//  Created by ruiyou on 2017/10/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "EditRemindViewController.h"

#import "DBManager.h"
#import "AlarmClockItem.h"
#import "TimePickerView.h"
#import "RemindViewController.h"
@interface EditRemindViewController ()

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (strong, nonatomic) TimePickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *btnsView;
@property (weak, nonatomic) IBOutlet UIButton *btnOne;
@property (weak, nonatomic) IBOutlet UIButton *btnTwo;
@property (weak, nonatomic) IBOutlet UIButton *btnThree;
@property (weak, nonatomic) IBOutlet UIButton *btnFour;
@property(nonatomic, strong)NSString     *databaseTableName;

@property (nonatomic, strong)NSString *alarmType;

@end

@implementation EditRemindViewController

- (void)viewWillAppear:(BOOL)animated {

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

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if ([self.textView.text isEqualToString:@"请输入您要提醒的事情"]) {
        self.textView.text = @"";
        self.textView.textColor = [UIColor blackColor];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    if ([self.textView.text isEqualToString:@""]) {
        self.textView.text = @"请输入您要提醒的事情";
        self.textView.textColor = [UIColor lightGrayColor];
    }
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)loadInputAccessoryView {
    UIView *inputBGView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    inputBGView.opaque = NO;
    inputBGView.backgroundColor = [UIColor whiteColor];
    
    UIButton * closeButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 50, 44)];
    [closeButton setTitle:@"隐藏" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [closeButton addTarget:self action:@selector(closeKeybord) forControlEvents:UIControlEventTouchUpInside];
    [inputBGView addSubview:closeButton];
    
    inputBGView.layer.masksToBounds = NO;
    inputBGView.layer.shadowColor = RGB_COLOR(220, 220, 200).CGColor;
    inputBGView.layer.shadowOffset = CGSizeMake(0.0f, -1.0f);
    inputBGView.layer.shadowOpacity = 0.9f;
    
    self.textView.inputAccessoryView = inputBGView;
}

-(void)closeKeybord {
    
    [self.view endEditing:YES];
}

-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
//    self.datePicker.datePickerMode = UIDatePickerModeTime;
//    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
//    self.datePicker.locale = locale;
//     self.datePicker.minimumDate = nil;
//
    self.pickerView = [[[NSBundle mainBundle] loadNibNamed:@"TimePickerView" owner:nil options:nil] lastObject];
    self.pickerView.frame = CGRectMake(0, 0, self.timeView.frame.size.width, self.timeView.frame.size.height);
    [self.timeView addSubview:self.pickerView];
    
    switch (self.eventType) {
        case NRemind:
        {
            self.title = @"新建提醒";
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *currentDateMM = [dateFormatter stringFromDate:[NSDate date]];
            self.pickerView.currentTime = currentDateMM;
//            self.datePicker.minimumDate = [NSDate date]; // 最小时间
            
        }
            break;
        case EdRemind:
        case ExpRemind:
        {
            self.title = @"编辑提醒";
//            self.datePicker.enabled = NO;
//            self.pickerView.isEnble = NO;
            //right items
            UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delegate"] style:UIBarButtonItemStyleDone target:self action:@selector(deleteRemind)];
            deleteItem.tintColor = HEX_COLOR(0x666666);
            self.navigationItem.rightBarButtonItem = deleteItem;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *currentDateDD = [dateFormatter stringFromDate:[NSDate date]];
            NSString *remindDateMM = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,self.remindItem.remindtime];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *remindDate = [dateFormatter dateFromString:remindDateMM];
            
            
            self.textView.textColor = [UIColor blackColor];
            if ([self.remindItem.remindtype isEqualToString:REMINDTYPE_ONLYONCE]) {
                self.textView.text = self.remindItem.content;
                [self clickBtnOne:self.btnOne];
            } else if ([self.remindItem.remindtype isEqualToString:REMINDTYPE_EVERYDAY]) {
                self.textView.text = [self.remindItem.content substringFromIndex:3];
                [self clickBtnTwo:self.btnTwo];
            } else if ([self.remindItem.remindtype isEqualToString:REMINDTYPE_WEEKEND]) {
                self.textView.text = [self.remindItem.content substringFromIndex:3];
                [self clickBtnThree:self.btnThree];
            } else {
                self.textView.text = [self.remindItem.content substringFromIndex:4];
                [self clickBtnFour:self.btnFour];
            }
            
//            self.datePicker.minimumDate = nil; // 最小时间
//            self.datePicker.date = remindDate;
            
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *currentDateMM = [dateFormatter stringFromDate:remindDate];
            self.pickerView.currentTime = currentDateMM;
            
        }
            break;
        default:
            break;
    }
    
    
    [self loadInputAccessoryView];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.alarmType = REMINDTYPE_ONLYONCE;
    
    self.databaseTableName = @"remindList";
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *userID = userInfo? userInfo[@"userId"] : @"";
    self.databaseTableName = [self.databaseTableName stringByAppendingFormat:@"_%@",userID];
    [self initViews];
    
    [self createDatabaseTable];//创建数据库表
  
    [self checkNoticePersimission];
}

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
//        if (!isOK) {
//            return ;
//        }
    } FMDatabase:^(FMDatabase *database) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        strongSelf.database = database;
    }];
    
}


-(BOOL)checkNoticePersimission {
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (settings.types < 6) {
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

- (IBAction)clickSubmitBtn:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    if (![self checkNoticePersimission]) {
        return;
    }
    
    NSString *remindContent = [self.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([remindContent isEqualToString:@"请输入您要提醒的事情"]) {
        [self showAlertViewWithTitle:@"" message:@"请输入提醒的事情" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *dateStrHourMinite = self.pickerView.selectedTime;
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateDD = [dateFormatter stringFromDate:[NSDate date]];
    NSString *remindDateMM = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,dateStrHourMinite];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *remindDate = [dateFormatter dateFromString:remindDateMM];
    
    NSInteger createtimestamp = [remindDate timeIntervalSince1970];
//    if (self.eventType == NRemind || self.eventType == ExpRemind) {
//        createtimestamp = [remindDate timeIntervalSince1970];
//    } else {
//
//        if ([self.alarmType isEqualToString:REMINDTYPE_ONLYONCE] && [self.remindItem.remindtype isEqualToString:REMINDTYPE_ONLYONCE]) {
//             createtimestamp = [self.remindItem.createtimestamp integerValue];
//        } else {
//             createtimestamp = [remindDate timeIntervalSince1970];
//        }
//
//    }
    
    
    NSString *currentDateStr;
    if ([self.alarmType isEqualToString:REMINDTYPE_ONLYONCE]) {
        
        //语音可以创建仅一次提醒的非当天的提醒，需要区别对待
        if ([self.remindItem.remindtype isEqualToString:REMINDTYPE_ONLYONCE]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSString *currentDateDD;
            [formatter setDateFormat:@"yyyy-MM-dd"];
            if ([self.remindItem.remindDate isEqualToString:@"今天"]) {
                currentDateDD = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0*24*60*60]];
            } else if ([self.remindItem.remindDate isEqualToString:@"明天"]) {
                currentDateDD = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1*24*60*60]];
            } else {
                currentDateDD = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
            }
            
            currentDateStr = [NSString stringWithFormat:@"%@ %@:00",currentDateDD,dateStrHourMinite];
            
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *createDate = [formatter dateFromString:currentDateStr];
            createtimestamp = [createDate timeIntervalSince1970];
            
            NSInteger currentDateStamp = [[NSDate dateWithTimeIntervalSinceNow:60] timeIntervalSince1970];
        
            if (createtimestamp < currentDateStamp) {
                [self showAlertViewWithTitle:@"提示" message:@"设置提醒时间应大于当前时间!" buttonTitle:@"知道了" clickBtn:^{
                    
                }];
                return;
            }
        } else {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            currentDateStr = remindDateMM;
            
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSInteger currentDateStamp = [[NSDate date] timeIntervalSince1970];
            
            if (createtimestamp < currentDateStamp) {
                [self showAlertViewWithTitle:@"提示" message:@"设置提醒时间应大于当前时间!" buttonTitle:@"知道了" clickBtn:^{
                    
                }];
                return;
            }
        }

    }
   
    RemindItem *remindItem = [[RemindItem alloc] init];
    NSString *sql;
    if (self.eventType == NRemind) {
        
        BOOL isRepet = [self adjustRemindRepeatWithRemindType:self.alarmType andRemindTime:dateStrHourMinite];
        if (!isRepet) {
            [self showAlertViewWithTitle:@"提示" message:@"存在重复提醒" buttonTitle:@"知道了" clickBtn:^{
                
            }];
            return;
        }
        
        sql = [NSString stringWithFormat:@"insert into %@ (remindorigintype,remindid, remindtype,remindtime,content,audiourl,headurl,createtimestamp) values ('%@','%@','%@','%@','%@','%@','%@','%ld')",self.databaseTableName,REMINDORIGINTYPE_LOCAL,@"",self.alarmType,dateStrHourMinite,remindContent,@"",@"",createtimestamp];
        NSLog(@"");
        remindItem.remindtype = self.alarmType;
        remindItem.remindtime = dateStrHourMinite;
        remindItem.content = remindContent;
        remindItem.createtimestamp = [NSString stringWithFormat:@"%ld",createtimestamp];
        remindItem.remindorigintype = REMINDORIGINTYPE_LOCAL;
        
        if ([self.database executeUpdate:sql]) {
            
            //添加一个新的闹钟
            NSString *clockIdentifier = [NSString stringWithFormat:@"%@%@",self.alarmType,dateStrHourMinite];
            [AlarmClockItem addAlarmClockWithAlarmClockContent:remindContent AlarmClockDateTime:dateStrHourMinite AlarmClockType:self.alarmType AlarmClockIdentifier:clockIdentifier isOhters:NO];
            
            NSLog(@"timeSp:%@ \n content:%@ \n timeStr:%@",remindContent,dateStrHourMinite,self.alarmType);
            [MBProgressHUD showSuccess:@"创建成功"];
            [self performSelector:@selector(backActionWithAddRemindItem:) withObject:remindItem afterDelay:0];
            
            
        } else {
            [MBProgressHUD showSuccess:@"由于数据库问题，创建失败"];
            [self performSelector:@selector(backAction) withObject:nil afterDelay:0];
        }
        
        
    } else {

        if ([self.alarmType isEqualToString:REMINDTYPE_ONLYONCE]) {
            BOOL isRepet = [self adjustRemindRepeatWithCreatetimestamp:[NSString stringWithFormat:@"%ld",createtimestamp]];
            if (!isRepet) {
                [self showAlertViewWithTitle:@"提示" message:@"存在重复提醒" buttonTitle:@"知道了" clickBtn:^{

                }];
                
                return;
            } 
            
        } else {
            BOOL isRepet = [self adjustRemindRepeatWithRemindType:self.alarmType andRemindTime:dateStrHourMinite];
            if (!isRepet) {
                [self showAlertViewWithTitle:@"提示" message:@"存在重复提醒" buttonTitle:@"知道了" clickBtn:^{

                }];
                return;
            }
        }
        
        sql =  [NSString stringWithFormat:
                @"update %@ set remindtype='%@', remindtime='%@', content='%@', createtimestamp='%ld' where remindorigintype = '%@' and remindtype = '%@' and remindtime = '%@'",self.databaseTableName,self.alarmType,dateStrHourMinite,remindContent,createtimestamp,self.remindItem.remindorigintype,self.remindItem.remindtype,self.remindItem.remindtime];
        NSLog(@"sql: %@", sql);
         if ([self.database executeUpdate:sql]) {
             [MBProgressHUD showSuccess:@"编辑成功"];
             
             [AlarmClockItem cancelAlarmClockWithRemindItem:self.remindItem];
             
             
             NSString *clockIdentifier = [NSString stringWithFormat:@"%@%@",self.alarmType,dateStrHourMinite];
             if ([self.alarmType isEqualToString:REMINDTYPE_ONLYONCE]) {
                 
                 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                 [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                 NSDate *fireDate = [formatter dateFromString:currentDateStr];
                 [AlarmClockItem addAlarmClockWithAlarmClockContent:remindContent fireDate:fireDate AlarmClockType:self.alarmType AlarmClockIdentifier:clockIdentifier isOhters:NO];
                 
             } else {
                 [AlarmClockItem addAlarmClockWithAlarmClockContent:remindContent AlarmClockDateTime:dateStrHourMinite AlarmClockType:self.alarmType AlarmClockIdentifier:clockIdentifier isOhters:NO];
             }
             
             remindItem.remindtype = self.alarmType;
             remindItem.remindorigintype = REMINDORIGINTYPE_LOCAL;
             remindItem.remindtime = dateStrHourMinite;
             remindItem.content = remindContent;
             remindItem.createtimestamp = [NSString stringWithFormat:@"%ld",createtimestamp];
             
            
             [self performSelector:@selector(backActionWithEditRefresh:) withObject:remindItem afterDelay:0];
             
         }else {
             [MBProgressHUD showSuccess:@"由于数据库问题，编辑失败"];
             [self performSelector:@selector(backAction) withObject:nil afterDelay:0];
         }
    }

    
//    NSLog(@"sql = %@",sql);
 
    if (SYSTEM_VERSION < 10) {
        NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *notification in array) {
            NSDictionary *info = notification.userInfo;
            
            NSLog(@"本地存在的推送: %@", info[@"requestIdentifier"]);
        }
    }
    
    
    
}


-(void)backActionWithEditRefresh:(RemindItem *)remindItem {
    
    if (self.isFromOver) {
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[RemindViewController class]]) {
                
                RemindViewController *vc = (RemindViewController *)temp;
                vc.remindViewControllerWithAddRemind(remindItem);
                [self.navigationController popToViewController:vc animated:YES];
                
            }
        }
    } else {
        self.editRemindViewControllerWithEditRemind(remindItem);
        [self.navigationController popViewControllerAnimated:YES];
    }
   
   
}

-(void)backActionWithAddRemindItem:(RemindItem *)remindItem {
    
    if (self.isFromOver) {
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[RemindViewController class]]) {
                
                RemindViewController *vc = (RemindViewController *)temp;
                vc.remindViewControllerWithAddRemind(remindItem);
                [self.navigationController popToViewController:vc animated:YES];
                
            }
        }
    } else {
        self.editRemindViewControllerWithAddRemind(remindItem);
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)backActionWithDelRefresh:(RemindItem *)remindItem {
    //    [self.delegate editRemindViewControllerWithNewAddRemind:remindItem];
    self.editRemindViewControllerWithDelRemind(remindItem);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)deleteRemind {
    
    if (self.eventType != ExpRemind) {
        __weak __typeof__(self) weakSelf = self;
        [self showAlertViewWithTitle:@"是否删除" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"确定" clickOtherBtn:^{
            
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            NSString *sql =  [NSString stringWithFormat:
                              @"delete from %@ where remindtype = '%@' and remindtime = '%@' and remindorigintype = '%@'",self.databaseTableName,self.remindItem.remindtype,self.remindItem.remindtime,self.remindItem.remindorigintype];
            
            NSLog(@"sql = %@",sql);
            BOOL isCreate = [strongSelf.database executeUpdate:sql];
            if (isCreate) {
                //删除本地通知
                [AlarmClockItem cancelAlarmClockWithRemindItem:self.remindItem];
                [MBProgressHUD showSuccess:@"删除成功"];
                [self performSelector:@selector(backActionWithDelRefresh:) withObject:self.remindItem afterDelay:0];
                
            } else {
                [MBProgressHUD showSuccess:@"删除失败"];
            }
        }];
    }else {
        NSString *sql =  [NSString stringWithFormat:
                          @"delete from %@ where remindtype = '%@' and remindtime = '%@' and remindorigintype = '%@'",self.databaseTableName,self.remindItem.remindtype,self.remindItem.remindtime,self.remindItem.remindorigintype];
        
        NSLog(@"sql = %@",sql);
        BOOL isCreate = [self.database executeUpdate:sql];
        if (isCreate) {
            //删除本地通知
            [AlarmClockItem cancelAlarmClockWithRemindItem:self.remindItem];
            [MBProgressHUD showSuccess:@"删除成功"];
            [self performSelector:@selector(backActionWithDelRefresh:) withObject:self.remindItem afterDelay:0];
            
        } else {
            [MBProgressHUD showSuccess:@"删除失败"];
        }
    }
    
}

-(BOOL)adjustRemindRepeatWithCreatetimestamp:(NSString *)createtimestamp {

    if ([self.database open]) {
        
//        NSInteger nowSp = [[NSDate date] timeIntervalSince1970];
        NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindtype = 'onlyonce' and createtimestamp != %@",self.databaseTableName,self.remindItem.createtimestamp];
        NSLog(@"sql = %@",sql);
        
        FMResultSet * res = [self.database executeQuery:sql];
        
        NSMutableArray *dataArrOnlyOnce = [@[] mutableCopy];
        while ([res next]) {
            RemindItem *item = [[RemindItem alloc] init];
            item.remindtype = [res stringForColumn:@"remindtype"];
            item.remindtime = [res stringForColumn:@"remindtime"];
            item.content = [res stringForColumn:@"content"];
            item.createtimestamp = [res stringForColumn:@"createtimestamp"];
            [dataArrOnlyOnce addObject:item.createtimestamp];
        }
        
        for (NSString *timestamp in dataArrOnlyOnce) {
            if ([createtimestamp isEqualToString:timestamp]) {
                return NO;
            }
        }
        
    }
    return YES;
}

-(BOOL)adjustRemindRepeatWithRemindType:(NSString *)remindType andRemindTime:(NSString *)remindTime {
    
    NSInteger remindTimeHash = [remindTime hash];
    
    if ([self.database open]) {
        
        NSInteger nowSp = [[NSDate date] timeIntervalSince1970];
        NSString *sql = [NSString stringWithFormat:@"select * from %@  where remindtype != 'onlyonce' or createtimestamp > %ld",self.databaseTableName,nowSp];
        NSLog(@"sql = %@",sql);
        
        FMResultSet * res = [self.database executeQuery:sql];
        
//        NSLog(@"----01  res.columnCount: %d",res.columnCount);
        sql = [NSString stringWithFormat:@"select * from %@  where remindtype != '%@' and remindtime != '%@'",self.databaseTableName,self.remindItem.remindtype,self.remindItem.remindtime];
         NSLog(@"sql = %@",sql);
        res = [self.database executeQuery:sql];
//        NSLog(@"-----02  res.columnCount: %d",res.columnCount);
//        if (!res.columnCount) {
//            return YES;
//        }
        
        
        NSMutableArray *dataArrOnlyOnce = [@[] mutableCopy];
        NSMutableArray *dataArrEveryDay = [@[] mutableCopy];
        NSMutableArray *dataArrWeekend = [@[] mutableCopy];
        NSMutableArray *dataArrWorkDay = [@[] mutableCopy];
        
        while ([res next]) {
            RemindItem *item = [[RemindItem alloc] init];
            item.remindtype = [res stringForColumn:@"remindtype"];
            item.remindtime = [res stringForColumn:@"remindtime"];
            item.content = [res stringForColumn:@"content"];
            item.createtimestamp = [res stringForColumn:@"createtimestamp"];
            
            if ([item.remindtype isEqualToString:REMINDTYPE_ONLYONCE]) {
                [dataArrOnlyOnce addObject:item.remindtime];
            } else if ([item.remindtype isEqualToString:REMINDTYPE_EVERYDAY]) {
                [dataArrEveryDay addObject:item.remindtime];
            } else if ([item.remindtype isEqualToString:REMINDTYPE_WEEKEND]) {
                [dataArrWeekend addObject:item.remindtime];
            } else if ([item.remindtype isEqualToString:REMINDTYPE_WORKDAY]) {
                [dataArrWorkDay addObject:item.remindtime];
            }
        }
        
        NSString *weekDay = [Utility getDayWeek];
        BOOL isWeekend =
        [weekDay isEqualToString:SATURDAY] ||
        [weekDay isEqualToString:SUNDAY];
        
        //比较是否有重复
        if ([remindType isEqualToString:REMINDTYPE_ONLYONCE]) {
            
            for (NSString *remindtimeStr in dataArrOnlyOnce) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            if (isWeekend) {
                
                for (NSString *remindtimeStr in dataArrWeekend) {
                    if ([remindtimeStr hash] == remindTimeHash) {
                        return NO;
                    }
                }
                
            } else {
                
                for (NSString *remindtimeStr in dataArrWorkDay) {
                    if ([remindtimeStr hash] == remindTimeHash) {
                        return NO;
                    }
                }
                
            }
            
            
            
        } else if ([remindType isEqualToString:REMINDTYPE_EVERYDAY]) {
            
            for (NSString *remindtimeStr in dataArrOnlyOnce) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            for (NSString *remindtimeStr in dataArrWeekend) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            for (NSString *remindtimeStr in dataArrWorkDay) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            
        } else if ([remindType isEqualToString:REMINDTYPE_WEEKEND]) {
            
            for (NSString *remindtimeStr in dataArrWeekend) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            if (isWeekend) {
                for (NSString *remindtimeStr in dataArrOnlyOnce) {
                    if ([remindtimeStr hash] == remindTimeHash) {
                        return NO;
                    }
                }
            }
            
        } else if ([remindType isEqualToString:REMINDTYPE_WORKDAY]) {
            
            for (NSString *remindtimeStr in dataArrWorkDay) {
                if ([remindtimeStr hash] == remindTimeHash) {
                    return NO;
                }
            }
            
            if (!isWeekend) {
                for (NSString *remindtimeStr in dataArrOnlyOnce) {
                    if ([remindtimeStr hash] == remindTimeHash) {
                        return NO;
                    }
                }
            }
            
        }
        
        
        for (NSString *remindtimeStr in dataArrEveryDay) {
            if ([remindtimeStr hash] == remindTimeHash) {
                return NO;
            }
        }
        
        return YES;
    }
    
    return YES;
    
}



- (IBAction)clickBtnOne:(UIButton *)sender {
    
//    self.datePicker.minimumDate = [NSDate date];
    self.alarmType = REMINDTYPE_ONLYONCE;
    
    sender.backgroundColor = HEX_COLOR(0xfaa41c);
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    for (UIView *view in self.btnsView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag != sender.tag) {
            UIButton *btn = (UIButton *)view;
            btn.backgroundColor = HEX_COLOR(0xd1d1d8);
            [btn setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
        }
    }

    
}

- (IBAction)clickBtnTwo:(UIButton *)sender {

//     self.datePicker.minimumDate = nil;
    self.alarmType = REMINDTYPE_EVERYDAY;
    
    sender.backgroundColor = HEX_COLOR(0xfaa41c);
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    for (UIView *view in self.btnsView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag != sender.tag) {
            UIButton *btn = (UIButton *)view;
            btn.backgroundColor = HEX_COLOR(0xd1d1d8);
            [btn setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
        }
    }
}

- (IBAction)clickBtnThree:(UIButton *)sender {

//    self.datePicker.minimumDate = nil;
    self.alarmType = REMINDTYPE_WEEKEND;
    
    sender.backgroundColor = HEX_COLOR(0xfaa41c);
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    for (UIView *view in self.btnsView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag != sender.tag) {
            UIButton *btn = (UIButton *)view;
            btn.backgroundColor = HEX_COLOR(0xd1d1d8);
            [btn setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
        }
    }
}

- (IBAction)clickBtnFour:(UIButton *)sender {

//    self.datePicker.minimumDate = nil;
    self.alarmType = REMINDTYPE_WORKDAY;
    
    sender.backgroundColor = HEX_COLOR(0xfaa41c);
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    for (UIView *view in self.btnsView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag != sender.tag) {
            UIButton *btn = (UIButton *)view;
            btn.backgroundColor = HEX_COLOR(0xd1d1d8);
            [btn setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
        }
    }
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        
        [self.textView resignFirstResponder];
        //在这里做你响应return键的代码
        return YES; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
        
        
    }
    
    return YES;
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
