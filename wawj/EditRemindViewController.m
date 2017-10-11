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
@interface EditRemindViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *btnsView;
@property (weak, nonatomic) IBOutlet UIButton *btnOne;
@property (weak, nonatomic) IBOutlet UIButton *btnTwo;
@property (weak, nonatomic) IBOutlet UIButton *btnThree;
@property (weak, nonatomic) IBOutlet UIButton *btnFour;

@property (nonatomic, assign)AlarmType alarmType;

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

-(void)deleteRemind {
    
    
}

- (void)loadInputAccessoryView {
    UIView *inputBGView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    inputBGView.opaque = NO;
    inputBGView.backgroundColor = [UIColor whiteColor];
    
    UIButton * closeButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 50, 44)];
    [closeButton setTitle:@"隐藏" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [closeButton addTarget:self action:@selector(closeKeybord) forControlEvents:UIControlEventTouchUpInside];
    [inputBGView addSubview:closeButton];
    self.textView.inputAccessoryView = inputBGView;
}

-(void)closeKeybord {
    
    [self.view endEditing:YES];
}

-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = @"添加提醒";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    self.datePicker.locale = locale;
    self.datePicker.minimumDate = [NSDate date]; // 最小时间
    
    switch (self.eventType) {
        case NRemind:
            self.title = @"新建提醒";
            break;
        case EdRemind:
        case ExpRemind:
        {
            self.title = @"编辑提醒";
            //right items
            UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"remind_delete.png"] style:UIBarButtonItemStyleDone target:self action:@selector(deleteRemind)];
            deleteItem.tintColor = [UIColor whiteColor];
            self.navigationItem.rightBarButtonItem = deleteItem;
            
            //[self loadEidtData];
        }
            break;
        default:
            break;
    }
    
    
    [self loadInputAccessoryView];
    
//    [self.datePicker setValue:HEX_COLOR(0x219ce0) forKey:@"textColor"];
//    for (UIView *view in self.datePicker.subviews) {
//
//        if ([view isKindOfClass:[UIView class]]) {
//
//            for (UIView *subView in view.subviews) {
//
//                if (subView.frame.size.height < 1) {
//
//                    subView.backgroundColor = HEX_COLOR(0x219ce0);
//
//                }
//
//            }
//
//        }
//    }
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.alarmType = AlarmTypeOnce;
    [self initViews];
    
   
    [self createDatabaseTable];//创建数据库表
  
}

- (void)createDatabaseTable {
    
    NSString  *dataTableName = @"remindList";
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *userID = userInfo? userInfo[@"userId"] : @"";
    dataTableName = [dataTableName stringByAppendingFormat:@"_%@",userID];
    
    
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
    
    
    __weak __typeof__(self) weakSelf = self;
    
    [[DBManager defaultManager] createTableWithName:dataTableName AndKeys:keys Result:^(BOOL isOK) {
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


- (IBAction)clickSubmitBtn:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    NSString *remindContent = [self.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([remindContent isEqualToString:@"请输入您要提醒的事情"]) {
        [self showAlertViewWithTitle:@"" message:@"请输入提醒的事情" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
    format.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *timeStrMM = [format stringFromDate:self.datePicker.date];
    
    format.dateFormat = @"yyyy-MM-dd";
    NSString *dateStrDD = [format stringFromDate:self.datePicker.date];
    
    format.dateFormat = @"HH:mm";
    NSString *dateStrHourMinite = [format stringFromDate:self.datePicker.date];
    
    NSInteger timeStamp = [[format dateFromString:timeStrMM] timeIntervalSince1970];
    NSString *timeStampStr = [NSString stringWithFormat:@"%ld",timeStamp];
    

    
    
    //dateOrig(暂无意义，现写死)
    NSString *dateOrig = @"今天";
    
    //remind_ID
    NSString *remind_ID = [NSString stringWithFormat:@"rd_%@",timeStampStr];
    NSString *timeInterval = @"timeInterval";
    NSString *event = @"event";
    
    NSString *stateString = [NSString stringWithFormat:@"%ld",self.alarmType];
    
    NSString  *dataTableName = @"remindList";
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *userID = userInfo? userInfo[@"userId"] : @"";
    dataTableName = [dataTableName stringByAppendingFormat:@"_%@",userID];
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (date,time,time_interval,event,time_stamp,content,dateOrig,remind_ID,state,reserved_parameter_1,reserved_parameter_2,reserved_parameter_3,reserved_parameter_4,reserved_parameter_5,reserved_parameter_6) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",dataTableName,dateStrDD,dateStrHourMinite,timeInterval,event,timeStampStr,remindContent,dateOrig,remind_ID,stateString,@"0",@"0",@"0",@"0",@"0",@"0"];
    NSLog(@"sql = %@",sql);
    
    
    
    BOOL isCreate = [self.database executeUpdate:sql];
    if (isCreate) {
        
        //添加一个新的闹钟
        [AlarmClockItem addAlarmClockWithAlarmClockID:timeStampStr AlarmClockContent:remindContent AlarmClockDate:timeStrMM AlarmClockType:AlarmTypeOnce];
        NSLog(@"timeSp:%@ \n content:%@ \n timeStr:%@",timeStampStr,remindContent,timeStrMM);
        
        
        if (NRemind == self.eventType) {
            [MBProgressHUD showSuccess:@"创建成功"];
            [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
        }
        
    }else{
        [MBProgressHUD showSuccess:@"由于数据库问题，创建失败"];
        [self performSelector:@selector(backAction) withObject:nil afterDelay:1];
    }
}


- (IBAction)clickBtnOne:(UIButton *)sender {
    
    self.alarmType = AlarmTypeOnce;
    
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

    self.alarmType = AlarmTypeEveryDay;
    
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

    self.alarmType = AlarmTypeOverWeekend;
    
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

    self.alarmType = AlarmTypeWorkDay;
    
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
