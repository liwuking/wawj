


#import "NewRemindOrEditRmindViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD+Extension.h"
#import "AlarmClockItem.h"
#import "CoreArchive.h"
#import "UIAlertView+Extension.h"
#import "DBManager.h"
@interface NewRemindOrEditRmindViewController ()
{
    IBOutlet UITextView  *_remindTextView;
    IBOutlet UIButton    *_saveButton;
    IBOutlet UIButton    *_remindTimeButton;
    UIDatePicker         *_remindDatePicker;
    UILabel              *_onDatePickerLabel;
    IBOutlet UISwitch    *_advanceSwitch;
    BOOL                 isAdvance;//是否提前
    IBOutlet UILabel     *_tagLabel;
    NSString             *_event;
    NSString             *_dateAndTime;
    
}

@property(nonatomic,assign)NSString             *dataTableName;


@end

@implementation NewRemindOrEditRmindViewController
@synthesize type;
//@synthesize database;
@synthesize editDataDic;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;

    self.dataTableName = @"remindList";
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *userID = userInfo? userInfo[@"userId"] : @"";
    self.dataTableName = [self.dataTableName stringByAppendingFormat:@"_%@",userID];
    
    switch (self.type) {
        case NewRemind:
            self.title = @"新建提醒";
            break;
        case EditRemind:
        case ExpireRemind:
        {
            self.title = @"编辑提醒";
            //right items
            UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"remind_delete.png"] style:UIBarButtonItemStyleDone target:self action:@selector(deleteRemind)];
            deleteItem.tintColor = [UIColor whiteColor];
            self.navigationItem.rightBarButtonItem = deleteItem;
            
            [self loadEidtData];
        }
            break;
        default:
            break;
    }
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _remindTextView.layer.cornerRadius = 4;
    _remindTextView.layer.borderWidth = 0.5;
    _remindTextView.layer.borderColor = RGB_COLOR(211, 211, 211).CGColor;
    
    _saveButton.layer.cornerRadius = 4;
    
    //add switch kvo
    [_advanceSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    //add inputAccessoryView
    [self loadInputAccessoryView];
    
    
    
    
    [self createDatabaseTable];//创建数据库表
    
    
    
}


- (void)createDatabaseTable {
    
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
                           @"c" : @"string",
                           @"reserved_parameter_3" : @"string",
                           @"reserved_parameter_4" : @"string",
                           @"reserved_parameter_5" : @"string",
                           @"reserved_parameter_6" : @"string"};

    
    __weak __typeof__(self) weakSelf = self;
   
    [[DBManager defaultManager] createTableWithName:self.dataTableName AndKeys:keys Result:^(BOOL isOK) {
        if (!isOK) {
            //建表失败！
//            [MBProgressHUD hideHUD];
//            [self showNoRemindView];
            return ;
        }
    } FMDatabase:^(FMDatabase *database) {
         __strong __typeof__(weakSelf) strongSelf = weakSelf;
        strongSelf.database = database;
//        [self loadData];
    }];
    
}

- (void)loadEidtData {
    
    NSString *time = self.editDataDic[@"time"];
    NSString *event = self.editDataDic[@"event"];
    NSString *dateAndTime = [NSString stringWithFormat:@"%@ %@",self.editDataDic[@"date"], [time substringToIndex:time.length-3]];
    _remindTimeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_remindTimeButton setTitleColor:RGBA_COLOR(50, 50, 50, 1) forState:UIControlStateNormal];
    [_remindTimeButton setTitle:dateAndTime forState:UIControlStateNormal];
    _remindTextView.text = [event substringToIndex:event.length - 1];
    _event = _remindTextView.text;
    _dateAndTime = dateAndTime;
    
    if ([self.editDataDic[@"state"] isEqualToString:@"advance"]) {
        [_advanceSwitch setOn:YES];
        isAdvance = YES;
    }
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backRootController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loadInputAccessoryView {
    UIView *inputBGView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    inputBGView.opaque = NO;
    inputBGView.backgroundColor = RGBA_COLOR(0, 0, 0, 0.6);
    
    UIButton * closeButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 50, 44)];
    [closeButton setTitle:@"隐藏" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [closeButton addTarget:self action:@selector(closeKeybord) forControlEvents:UIControlEventTouchUpInside];
    [inputBGView addSubview:closeButton];
    _remindTextView.inputAccessoryView = inputBGView;
}

- (void)closeKeybord {
    [_remindTextView resignFirstResponder];
}

- (void)deleteRemind{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                   message:@"是否确定删除该条提醒"
                                                  delegate:nil
                                         cancelButtonTitle:@"返回"
                                         otherButtonTitles:@"删除", nil];
    
    [alert showAlertWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            //delete
            NSString *time_stamp = self.editDataDic[@"time_stamp"];
            NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where time_stamp = %@",self.dataTableName,time_stamp];
            NSLog(@"deleteSql = %@",deleteSql);
            BOOL isDelete = [self.database executeUpdate:deleteSql];
            if (isDelete) {
                [MBProgressHUD showSuccess:@"删除成功！"];
                [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
            }else{
                [MBProgressHUD showSuccess:@"由于网络问题，删除失败！"];
                return ;
            }
        }
    }];
    
}

- (IBAction)selectTime:(UIButton *)sender {
    
    if ([_remindTextView canResignFirstResponder]) {
        [_remindTextView resignFirstResponder];
    }
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    UIView *allBGView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    allBGView.opaque = NO;
    allBGView.tag = 600;
    allBGView.backgroundColor = RGBA_COLOR(0, 0, 0, 0.5);
    [app.window addSubview:allBGView];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-270, SCREEN_WIDTH, 270)];
    bgView.backgroundColor = RGB_COLOR(240, 240, 240);
    [allBGView addSubview:bgView];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 49.5, SCREEN_WIDTH, 0.5)];
    lineView.backgroundColor = RGB_COLOR(220, 220, 220);
    [bgView addSubview:lineView];
    
    //取消按钮
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 50)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:RGB_COLOR(6, 122, 218) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [bgView addSubview:cancelButton];
    
    //确定按钮
    UIButton *determineButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-70, 0, 70, 50)];
    [determineButton setTitle:@"确定" forState:UIControlStateNormal];
    [determineButton setTitleColor:RGB_COLOR(6, 122, 218) forState:UIControlStateNormal];
    [determineButton addTarget:self action:@selector(determineButtonAction) forControlEvents:UIControlEventTouchUpInside];
    determineButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [bgView addSubview:determineButton];
    
    
    //time label
    _onDatePickerLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, SCREEN_WIDTH-140, 50)];
    _onDatePickerLabel.font = [UIFont systemFontOfSize:20];
    _onDatePickerLabel.textColor = RGB_COLOR(50, 50, 50);
    _onDatePickerLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:_onDatePickerLabel];
    
    _remindDatePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 220)];
    _remindDatePicker.minimumDate = [[NSDate date] dateByAddingTimeInterval:5*60];
    _remindDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [bgView addSubview:_remindDatePicker];
    
    [_remindDatePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged ];
}

- (void)cancelButtonAction {
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [[app.window viewWithTag:600] removeFromSuperview];
}
- (void)determineButtonAction {
    [self cancelButtonAction];
    NSDate *select = [_remindDatePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    NSLog(@"dateAndTime = %@",dateAndTime);
    _remindTimeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_remindTimeButton setTitleColor:RGBA_COLOR(50, 50, 50, 1) forState:UIControlStateNormal];
    [_remindTimeButton setTitle:dateAndTime forState:UIControlStateNormal];
}

- (void)dateChanged:(id)dataPicker {
    NSLog(@"dataPicker = %@",dataPicker);
    UIDatePicker* control = (UIDatePicker*)dataPicker;
    NSDate *select = [control date];
    NSLog(@"select = %@",select);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    NSLog(@"dateAndTime = %@",dateAndTime);
    _onDatePickerLabel.text = dateAndTime;
}

- (void)switchAction:(id)sender {
    _advanceSwitch = (UISwitch*)sender;
    BOOL isButtonOn = [_advanceSwitch isOn];
    if (isButtonOn) {
        _tagLabel.hidden = NO;
        isAdvance = YES;
    }else {
        _tagLabel.hidden = YES;
        isAdvance = NO;
    }
}

- (IBAction)saveAction:(UIButton *)sender {
    
    self.dataTableName = @"remindList";
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *userID = userInfo? userInfo[@"userId"] : @"";
    self.dataTableName = [self.dataTableName stringByAppendingFormat:@"_%@",userID];
    
    
  
    
    //判断是否填写事件
    if (_remindTextView.text.length ==0) {
        [MBProgressHUD showSuccess:@"请填写提醒事件"];
        return;
    }
    
    //判断是否选择时间
    if ([_remindTimeButton.titleLabel.text isEqualToString:@"请选择"]) {
        [MBProgressHUD showSuccess:@"请选择提醒时间"];
        return;
        
    }
    
    //判断是否编辑过
    if (self.type == EditRemind || self.type == ExpireRemind) {
        
        NSLog(@"_event = %@",_event);
        NSLog(@"_remindTextView.text = %@",_remindTextView.text);
        NSLog(@"_dateAndTime = %@",_dateAndTime);
        NSLog(@"_remindTimeButton.text = %@",_remindTimeButton.titleLabel.text);
        
        
        if ([_event isEqualToString:_remindTextView.text] && [_dateAndTime isEqualToString:_remindTimeButton.titleLabel.text] ) {
            
            if ([self.editDataDic[@"state"] isEqualToString:@"advance"]) {
                if (isAdvance) {
                    //未编辑
                    [MBProgressHUD showSuccess:@"未编辑提醒"];
                    [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
                }else{
                    //取消提前提醒
                    if (self.type == ExpireRemind) {
                        [MBProgressHUD showSuccess:@"未编辑时间"];
                        return;
                    }else{
                        [self updateRemindToDatabaseWithType:CloseAdvance];
                    }
                    
                }
            }else{
                if (!isAdvance) {
                    //未编辑
                    [MBProgressHUD showSuccess:@"未编辑提醒"];
                    [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
                    
                }else{
                    //开启提前提醒
                    if (self.type == ExpireRemind) {
                        [MBProgressHUD showSuccess:@"未编辑时间"];
                        return;
                    }else{
                        [self updateRemindToDatabaseWithType:OpenAdvance];
                    }
                    
                }
            }
            
        }else{
            //已编辑
            if ([self canEditOrNewRemind]) {
                
                if ([self.editDataDic[@"state"] isEqualToString:@"advance"]) {
                    if (isAdvance) {
                        //只编辑了事件
                        if (![_event isEqualToString:_remindTextView.text] && [_dateAndTime isEqualToString:_remindTimeButton.titleLabel.text]){
                            if (self.type == ExpireRemind) {
                                [MBProgressHUD showSuccess:@"未编辑时间"];
                                return;
                            }else{
                                [self updateRemindToDatabaseWithType:EditEvent];
                            }
                        }else{//编辑了时间和事件
                            [self updateRemindToDatabaseWithType:EditEventAndDate];
                        }
                    }else{
                        //编辑了event和提前提醒
                        if (![_event isEqualToString:_remindTextView.text] && [_dateAndTime isEqualToString:_remindTimeButton.titleLabel.text]) {
                            
                            if (self.type == ExpireRemind) {
                                [MBProgressHUD showSuccess:@"未编辑时间"];
                                return;
                            }else{
                                [self updateRemindToDatabaseWithType:EditEventAndAdvance];
                            }
                        }else{
                            //编辑了时间和advance
                            if ([_event isEqualToString:_remindTextView.text] && ![_dateAndTime isEqualToString:_remindTimeButton.titleLabel.text]) {
                                [self updateRemindToDatabaseWithType:EditDateAndAdvance];
                            }else{//3个元素都编辑了
                                [self updateRemindToDatabaseWithType:EditAll];
                            }
                        }
                        
                    }
                }else{
                    if (!isAdvance) {
                        //只编辑了事件
                        if (![_event isEqualToString:_remindTextView.text] && [_dateAndTime isEqualToString:_remindTimeButton.titleLabel.text]){
                            if (self.type == ExpireRemind) {
                                [MBProgressHUD showSuccess:@"未编辑时间"];
                                return;
                            }else{
                                [self updateRemindToDatabaseWithType:EditEvent];
                            }
                            
                        }else{//编辑了时间和事件
                            [self updateRemindToDatabaseWithType:EditEventAndDate];
                        }
                        
                        
                    }else{
                        //编辑了event和提前提醒
                        if (![_event isEqualToString:_remindTextView.text] && [_dateAndTime isEqualToString:_remindTimeButton.titleLabel.text]){
                            if (self.type == ExpireRemind) {
                                [MBProgressHUD showSuccess:@"未编辑时间"];
                                return;
                            }else{
                                [self updateRemindToDatabaseWithType:EditEventAndAdvance];
                            }
                            
                        }else{
                            //编辑了时间和advance
                            if ([_event isEqualToString:_remindTextView.text] && ![_dateAndTime isEqualToString:_remindTimeButton.titleLabel.text]) {
                                [self updateRemindToDatabaseWithType:EditDateAndAdvance];
                            }else{//3个元素都编辑了
                                [self updateRemindToDatabaseWithType:EditAll];
                            }
                        }
                    }
                }
                
            }
        }
    }else{
        //新建
        if ([self canEditOrNewRemind]) {
            [self createRemindToDatebaseWithType:nil];
        }
    }
}

- (void)updateRemindToDatabaseWithType:(EditRemindType)types {
    
    
    //event
    NSString *event = [_remindTextView.text stringByAppendingString:@"。"];
    
    //content
    NSString *dateAndTimeStr = _remindTimeButton.titleLabel.text;
    //date
    NSString *dateString = [dateAndTimeStr substringToIndex:10];
    
    //time
    NSString *timeString = [[dateAndTimeStr substringWithRange:NSMakeRange(dateAndTimeStr.length-5, 5)] stringByAppendingFormat:@":00"];
    
    //timeInterval
    NSString *timeInterval = [timeString substringToIndex:2];
    if ([timeInterval intValue] < 12) {
        timeInterval = @"上午";
    }else{
        timeInterval = @"下午";
    }
    
    NSString *content = [NSString stringWithFormat:@"%@%@%@%@",dateString,timeInterval,[dateAndTimeStr substringWithRange:NSMakeRange(dateAndTimeStr.length-5, 5)],event];
    
    
    
    
    switch (types) {
        case OpenAdvance:
        {
            NSLog(@"open");
            //state改变  刷新数据
            NSString *updateSql = @"update remindList set state = ? where time_stamp = ?";
            BOOL isUpdate = [self.database executeUpdate:updateSql,@"advance",self.editDataDic[@"time_stamp"]];
            if (isUpdate) {
                [MBProgressHUD showSuccess:@"编辑成功"];
                //添加一个提前闹钟，被编辑提醒闹钟不动
                NSDate *nowDate = [self dateFromDateStr:_remindTimeButton.titleLabel.text];
                NSDate *advanceDate = [nowDate dateByAddingTimeInterval:-5*60];
                int advanceDateSp = [advanceDate timeIntervalSince1970];
                NSString * advanceStr = [dateAndTimeStr ew_timestampWithString:[NSString stringWithFormat:@"%d",advanceDateSp] WithIndex:16];
                
                [AlarmClockItem addAlarmClockWithAlarmClockID:[NSString stringWithFormat:@"%d",advanceDateSp] AlarmClockContent:_remindTextView.text AlarmClockDate:advanceStr];
                [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
            }else{
                [MBProgressHUD showSuccess:@"由于数据库问题，编辑失败"];
                [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
            }
            
            
        }
            break;
            
        case CloseAdvance:
        {
            
            NSLog(@"close");
            //state改变  刷新数据
            NSString *updateSql = @"update remindList set state = ? where time_stamp = ?";
            BOOL isUpdate = [self.database executeUpdate:updateSql,@"normal",self.editDataDic[@"time_stamp"]];
            if (isUpdate) {
                [MBProgressHUD showSuccess:@"编辑成功"];
                //删除提前闹钟，被编辑提醒闹钟不动
                NSDate *nowDate = [self dateFromDateStr:_remindTimeButton.titleLabel.text];
                NSDate *advanceDate = [nowDate dateByAddingTimeInterval:-5*60];
                int advanceDateSp = [advanceDate timeIntervalSince1970];
                [AlarmClockItem cancleAlarmClockWithValue:[NSString stringWithFormat:@"%d",advanceDateSp]];
                [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
            }else{
                [MBProgressHUD showSuccess:@"由于数据库问题，编辑失败"];
                [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
            }
        }
            
            break;
        case EditEvent:
        {
            NSLog(@"event");
            //判断若只编辑了事件，则只需要更新数据库中的event字段就可以了
            
            NSString *updateSql = @"update remindList set event = ? , content = ? where time_stamp = ?";
            NSLog(@"updateSql = %@",updateSql);
            BOOL isUpdate = [self.database executeUpdate:updateSql,event,content,self.editDataDic[@"time_stamp"]];
            
            //判断是否编辑成功
            if (isUpdate) {
                [MBProgressHUD showSuccess:@"编辑成功"];
                [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
            }else{
                [MBProgressHUD showSuccess:@"由于数据库问题，编辑失败"];
                [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
            }
            
            
        }
            
            break;
            
        case EditEventAndAdvance:
        {
            NSString *state = @"normal";
            if (isAdvance) {
                state = @"advance";
            }
            
            NSLog(@"enent and advance");
            //update该条数据    +  state change
            NSString *updateSql = @"update remindList set event = ? , content = ? , state = ? where time_stamp = ?";
            NSLog(@"updateSql = %@",updateSql);
            BOOL isUpdate = [self.database executeUpdate:updateSql,event,content,state,self.editDataDic[@"time_stamp"]];
            
            //判断是否编辑成功
            if (isUpdate) {
                [MBProgressHUD showSuccess:@"编辑成功"];
                if (isAdvance) {
                    state = @"advance";
                    //添加提前闹钟
                    //添加一个提前闹钟，被编辑提醒闹钟不动
                    NSDate *nowDate = [self dateFromDateStr:_remindTimeButton.titleLabel.text];
                    NSDate *advanceDate = [nowDate dateByAddingTimeInterval:-5*60];
                    int advanceDateSp = [advanceDate timeIntervalSince1970];
                    NSString * advanceStr = [dateAndTimeStr ew_timestampWithString:[NSString stringWithFormat:@"%d",advanceDateSp] WithIndex:16];
                    
                    [AlarmClockItem addAlarmClockWithAlarmClockID:[NSString stringWithFormat:@"%d",advanceDateSp] AlarmClockContent:_remindTextView.text AlarmClockDate:advanceStr];
                }else{
                    state = @"normal";
                    //删除提前闹钟
                    //删除提前闹钟，被编辑提醒闹钟不动
                    NSDate *nowDate = [self dateFromDateStr:_remindTimeButton.titleLabel.text];
                    NSDate *advanceDate = [nowDate dateByAddingTimeInterval:-5*60];
                    int advanceDateSp = [advanceDate timeIntervalSince1970];
                    [AlarmClockItem cancleAlarmClockWithValue:[NSString stringWithFormat:@"%d",advanceDateSp]];
                    
                }
                
                [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
            }else{
                [MBProgressHUD showSuccess:@"由于数据库问题，编辑失败"];
                [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
            }
            
        }
            break;
        case EditEventAndDate:
        {
            NSLog(@"enent and date");
            //update该条数据  更改所有字段
            //删除之前提醒在数据库中的数据
            NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where time_stamp = %@",self.dataTableName,self.editDataDic[@"time_stamp"]];
            NSLog(@"deleteSql = %@",deleteSql);
            BOOL isDelete = [self.database executeUpdate:deleteSql];
            if (isDelete) {
                //删除被编辑之前时间的提醒闹钟
                [AlarmClockItem cancleAlarmClockWithValue:self.editDataDic[@"time_stamp"]];
                
                
                if ([self createRemindToDatebaseWithType:@"edit"]) {
                    
                    if (isAdvance) {
                        //删除之前的提前闹钟
                        NSDate *nowDate = [self dateFromDateStr:[NSString stringWithFormat:@"%@ %@",self.editDataDic[@"date"],self.editDataDic[@"time"]]];
                        NSDate *advanceDate = [nowDate dateByAddingTimeInterval:-5*60];
                        int advanceDateSp = [advanceDate timeIntervalSince1970];
                        [AlarmClockItem cancleAlarmClockWithValue:[NSString stringWithFormat:@"%d",advanceDateSp]];
                        
                    }
                    
                    [MBProgressHUD showSuccess:@"编辑成功"];
                    if (self.type == ExpireRemind) {
                        [self performSelector:@selector(backRootController) withObject:nil afterDelay:1];
                    }else{
                        [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
                    }
                    
                }else{
                    [MBProgressHUD showSuccess:@"编辑提醒失败"];
                    [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
                }
            }else{
                [MBProgressHUD showSuccess:@"编辑提醒失败"];
                [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
            }
        }
            break;
            
        case EditDateAndAdvance:
        case EditAll:
        {
            NSLog(@"Advane and date    or    edit all ");
            
            //update该条数据  更改所有字段(content需要重新配置)
            NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where time_stamp = %@",self.dataTableName,self.editDataDic[@"time_stamp"]];
            NSLog(@"deleteSql = %@",deleteSql);
            BOOL isDelete = [self.database executeUpdate:deleteSql];
            if (isDelete) {
                //删除被编辑之前时间的提醒闹钟
                [AlarmClockItem cancleAlarmClockWithValue:self.editDataDic[@"time_stamp"]];
                
                if ([self createRemindToDatebaseWithType:@"edit"]) {
                    
                    if ([self.editDataDic[@"state"] isEqualToString:@"advance"]) {
                        //删除之前的提前闹钟
                        NSDate *nowDate = [self dateFromDateStr:[NSString stringWithFormat:@"%@ %@",self.editDataDic[@"date"],self.editDataDic[@"time"]]];
                        NSDate *advanceDate = [nowDate dateByAddingTimeInterval:-5*60];
                        int advanceDateSp = [advanceDate timeIntervalSince1970];
                        [AlarmClockItem cancleAlarmClockWithValue:[NSString stringWithFormat:@"%d",advanceDateSp]];
                    }
                    //                    else{
                    //                        //添加编辑后时间的提前闹钟
                    //                        NSDate *nowDate = [self dateFromDateStr:_remindTimeButton.titleLabel.text];
                    //                        NSDate *advanceDate = [nowDate dateByAddingTimeInterval:-5*60];
                    //                        int advanceDateSp = [advanceDate timeIntervalSince1970];
                    //                        NSString * advanceStr = [dateAndTimeStr ew_timestampWithString:[NSString stringWithFormat:@"%d",advanceDateSp] WithIndex:16];
                    //
                    //                        [AlarmClockItem addAlarmClockWithAlarmClockID:[NSString stringWithFormat:@"%d",advanceDateSp] AlarmClockContent:_remindTextView.text AlarmClockDate:advanceStr];
                    //                    }
                    
                    [MBProgressHUD showSuccess:@"编辑成功"];
                    if (self.type == ExpireRemind) {
                        [self performSelector:@selector(backRootController) withObject:nil afterDelay:1];
                    }else{
                        [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
                    }
                    
                }else{
                    [MBProgressHUD showSuccess:@"编辑提醒失败"];
                    [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
                }
            }else{
                [MBProgressHUD showSuccess:@"编辑提醒失败"];
                [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
            }
            
        }
            break;
            
        default:
            break;
    }
    
}

- (BOOL)createRemindToDatebaseWithType:(NSString *)types {
    
    NSString *dateAndTimeStr = _remindTimeButton.titleLabel.text;
    NSString *state = @"normal";
    if (isAdvance) {
        state = @"advance";
    }
    
    
    //date
    NSString *dateString = [dateAndTimeStr substringToIndex:10];
    
    //time
    NSString *timeString = [[dateAndTimeStr substringWithRange:NSMakeRange(dateAndTimeStr.length-5, 5)] stringByAppendingFormat:@":00"];
    
    //timeInterval
    NSString *timeInterval = [timeString substringToIndex:2];
    if ([timeInterval intValue] < 12) {
        timeInterval = @"上午";
    }else{
        timeInterval = @"下午";
    }
    
    //event
    NSString *event = [_remindTextView.text stringByAppendingString:@"。"];
    
    //time_stamp
    NSString *timeSp = [self timeStampFromDateStr:dateAndTimeStr];
    
    //content
    NSString *content = [NSString stringWithFormat:@"%@%@%@%@",dateString,timeInterval,[dateAndTimeStr substringWithRange:NSMakeRange(dateAndTimeStr.length-5, 5)],event];
    
    //dateOrig(暂无意义，现写死)
    NSString *dateOrig = @"今天";
    
    //remind_ID
    NSString *remind_ID = [NSString stringWithFormat:@"rd_%@",timeSp];
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (date,time,time_interval,event,time_stamp,content,dateOrig,remind_ID,state,reserved_parameter_1,reserved_parameter_2,reserved_parameter_3,reserved_parameter_4,reserved_parameter_5,reserved_parameter_6) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",self.dataTableName,dateString,timeString,timeInterval,event,timeSp,content,dateOrig,remind_ID,state,@"0",@"0",@"0",@"0",@"0",@"0"];
    NSLog(@"sql = %@",sql);
    BOOL isCreate = [self.database executeUpdate:sql];
    if (isCreate) {
        
        //添加一个新的闹钟
        [AlarmClockItem addAlarmClockWithAlarmClockID:timeSp AlarmClockContent:_remindTextView.text AlarmClockDate:dateAndTimeStr];
        
        if (isAdvance) {
            //添加一个提前闹钟
            NSDate *nowDate = [self dateFromDateStr:_remindTimeButton.titleLabel.text];
            NSDate *advanceDate = [nowDate dateByAddingTimeInterval:-5*60];
            int advanceDateSp = [advanceDate timeIntervalSince1970];
            NSString * advanceStr = [dateAndTimeStr ew_timestampWithString:[NSString stringWithFormat:@"%d",advanceDateSp] WithIndex:16];
            
            [AlarmClockItem addAlarmClockWithAlarmClockID:[NSString stringWithFormat:@"%d",advanceDateSp] AlarmClockContent:_remindTextView.text AlarmClockDate:advanceStr];
        }
        
        
        if (!types) {
            [MBProgressHUD showSuccess:@"创建成功"];
            [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
        }
        
        return YES;
        
    }else{
        [MBProgressHUD showSuccess:@"由于数据库问题，创建失败"];
        [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
        return NO;
    }
}

- (BOOL)canEditOrNewRemind {
    //获取所有未过期提醒的时间
    NSArray *arr =  [self selectAllRemindTime];
    NSLog(@"arr = %@",arr);
    NSString *createSp = [self timeStampFromDateStr:_remindTimeButton.titleLabel.text];
    NSLog(@"createSp = %@",createSp);
    
    //判断新建的时间是否与之前的提醒冲突
    for (NSString *itemtime in arr) {
        if ([createSp isEqualToString:itemtime]) {
            [MBProgressHUD showSuccess:@"设置提醒的时间，与之前提醒冲突"];
            return NO;
        }
    }
    
    //若设置提前提醒，判断提前的时间是否与之前时间冲突
    if (isAdvance) {
        NSDate *nowDate = [self dateFromDateStr:_remindTimeButton.titleLabel.text];
        NSDate *advanceDate = [nowDate dateByAddingTimeInterval:-5*60];
        int advanceSp = [advanceDate timeIntervalSince1970];
        NSString *advanceStr = [NSString stringWithFormat:@"%d",advanceSp];
        for (NSString *itemtime in arr) {
            if ([advanceStr isEqualToString:itemtime]) {
                [MBProgressHUD showSuccess:@"设置提醒的时间，与之前提醒冲突"];
                return NO;;
            }
        }
        
    }
    
    return YES;
    
}
- (NSString *)timeStampFromDateStr:(NSString *)dateStr {
    
    int stamp = [[self dateFromDateStr:dateStr] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%d",stamp];
    
}

- (NSDate *)dateFromDateStr:(NSString *)dateStr {
    NSString* timeStr = [NSString stringWithFormat:@"%@",dateStr];
    NSLog(@"timeStr = %@",timeStr);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setTimeZone: [NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    return [formatter dateFromString:timeStr];
}

- (NSMutableArray *)selectAllRemindTime {
//    NSDate *nowDate = [NSDate dateWithTimeIntervalSinceNow:8*60*60];
    int nowSp = [[NSDate date] timeIntervalSince1970];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where time_stamp > %d order by time_stamp",self.dataTableName,nowSp];
    NSLog(@"sql = %@",sql);
    
    NSMutableArray *allDataArr = [[NSMutableArray alloc] init];
    if ([self.database open]) {
        FMResultSet * res = [self.database executeQuery:sql];
        
        while ([res next]) {
            NSDictionary *itemDic = @{@"time_stamp"    : [res stringForColumn:@"time_stamp"],
                                      @"state"         : [res stringForColumn:@"state"]};
            [allDataArr addObject:itemDic];
        }
        NSLog(@"arr = %@",allDataArr);
    }
    
    //筛选出时间
    NSMutableArray *allTimeArr = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDic in allDataArr) {
        
        //若为编辑提醒，不把该时间戳放入判断数组中
        if (self.type == EditRemind || self.type == ExpireRemind) {
            if ([self.editDataDic[@"time_stamp"] isEqualToString:itemDic[@"time_stamp"]]) {
                continue;
            }
        }
        
        [allTimeArr addObject:itemDic[@"time_stamp"]];
        if ([itemDic[@"state"] isEqualToString:@"advance"]) {
            int newSp = [itemDic[@"time_stamp"] intValue] - 5*60;
            [allTimeArr addObject:[NSString stringWithFormat:@"%d",newSp]];
        }
    }
    
    NSLog(@"all = %@",allTimeArr);
    
    return allTimeArr;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
