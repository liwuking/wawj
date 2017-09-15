//
//  WAEditRemindViewController.m
//  wawj
//
//  Created by ruiyou on 2017/8/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAEditRemindViewController.h"

#import "WAEditRemindOneCell.h"
#import "WAEditRemindTwoCell.h"
#import "WADatePicker.h"

@interface WAEditRemindViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,WADatePickerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property(nonatomic,strong) WADatePicker *datePicker;
@property(nonatomic,strong) NSString *dateText;
@property(nonatomic,assign) BOOL swithStatus;
@property(nonatomic,strong) NSDate *date;

@property(nonatomic,strong)UILocalNotification *localNotification;
@end

@implementation WAEditRemindViewController

-(void)initView {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delegate"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [rightItem setTintColor:HEX_COLOR(0x666666)];
    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.title = @"编辑提醒";
    self.swithStatus = YES;
    [self setDatePicker];
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setDatePicker {
    
    self.datePicker = [[[NSBundle mainBundle] loadNibNamed:@"WADatePicker" owner:self options:nil] lastObject];
    self.datePicker.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.datePicker.hidden = YES;
    self.datePicker.datePicker.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];;
    [self.datePicker.datePicker addTarget:self action:@selector(pickerChange:) forControlEvents:UIControlEventValueChanged];
    self.datePicker.delegate = self;
    [self.view addSubview:self.datePicker];
    
}

//将时间戳转换为NSDate类型
-(NSDate *)getDateTimeFromMilliSeconds:(long long) miliSeconds
{
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;//这里的.0一定要加上，不然除下来的数据会被截断导致时间不一致
    NSLog(@"传入的时间戳=%f",seconds);
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

//将NSDate类型的时间转换为时间戳,从1970/1/1开始
-(long long)getDateTimeTOMilliSeconds:(NSDate *)datetime
{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    NSLog(@"转换的时间戳=%f",interval);
    long long totalMilliseconds = interval*1000 ;
    NSLog(@"totalMilliseconds=%llu",totalMilliseconds);
    return totalMilliseconds;
}

//通知
- (void)scheduleLocalNotificationWithDate:(NSDate *)fireDate
{
    
    if (self.localNotification) {
        [[UIApplication sharedApplication] cancelLocalNotification:self.localNotification];
        self.localNotification = nil;
    }
    
    //0.创建推送
    self.localNotification = [[UILocalNotification alloc] init];
    //1.设置推送类型
    UIUserNotificationType type = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    //2.设置setting
    UIUserNotificationSettings *setting  = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    //3.主动授权
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    //4.设置推送时间
    [self.localNotification setFireDate:fireDate];
    //5.设置时区
    self.localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //6.推送内容
    [self.localNotification setAlertBody:self.textView.text];
    //7.推送声音
    [self.localNotification setSoundName:@"Thunder Song.m4r"];
    //8.添加推送到UIApplication
    [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotification];
    
}


-(void)pickerChange:(UIDatePicker *)datePicker {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //时区
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH点:mm分"];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    NSString *dateTimeString = [dateFormatter stringFromDate:self.datePicker.datePicker.date];
    
    
    [dateFormatter setDateFormat:@"MM-dd HH点:mm分"];
    self.dateText = [dateFormatter stringFromDate:self.datePicker.datePicker.date];
    self.datePicker.timeText.text = dateTimeString;
    
    
}

-(void)setAlarmClock {
    
    long long time;
    if (self.swithStatus) {
        time = [self getDateTimeTOMilliSeconds:self.datePicker.datePicker.date] + 5000;
    } else {
        time = [self getDateTimeTOMilliSeconds:self.datePicker.datePicker.date] - 5000;
    }
    
    NSDate *date = [self getDateTimeFromMilliSeconds:time];
    [self scheduleLocalNotificationWithDate:date];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self initView];
}

#pragma -mark WADatePickerDelegate

-(void)WADatePickerWithSure:(WADatePicker *)datePicker{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    self.datePicker.hidden = YES;
    
    [self setAlarmClock];
    
}

-(void)WADatePickerWithCancel:(WADatePicker *)datePicker {
    self.datePicker.hidden = YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.row) {
        
        WAEditRemindOneCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"WAEditRemindOneCell" owner:nil options:nil] lastObject];
        cell.timeLab.text = self.dateText;
        
        return cell;
        
    } else {
        
        WAEditRemindTwoCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"WAEditRemindTwoCell" owner:nil options:nil] lastObject];
        __weak __typeof(&*self)weakSelf =self;
        cell.waSwitchStatus = ^(UISwitch *waSwitch) {
            __strong typeof(weakSelf)strongSelf=weakSelf;
            
            strongSelf.swithStatus = waSwitch.on;
            
            if (strongSelf.localNotification) {
                [strongSelf setAlarmClock];
            }
            
            
        };
        return cell;
        
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.row) {
        self.datePicker.hidden = !self.datePicker.hidden;
    } else {
        
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
