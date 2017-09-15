//
//  ExpiredRemindViewController.m
//  AFanJia
//
//  Created by 焦庆峰 on 2016/12/5.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import "ExpiredRemindViewController.h"
#import "ExpiredRemindCell.h"
#import "MJRefresh.h"
#import "MBProgressHUD+Extension.h"
#import "NewRemindOrEditRmindViewController.h"
@interface ExpiredRemindViewController ()<UITableViewDelegate,UITableViewDataSource,ExpiredRemindCellDelegate>
{
    IBOutlet UIView        *_noExpirdRemindView;
    IBOutlet UITableView   *_expiredRemindTableView;
    NSMutableArray         *_allDataArr;
    BOOL                   isHeaderFresh;
    NSString               *_tableName;
}
@end

@implementation ExpiredRemindViewController
@synthesize database;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"过期提醒";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    _tableName = @"remindList";
    if ([CoreArchive strForKey:@"userID"]) {
        _tableName = [_tableName stringByAppendingFormat:@"_%@",[CoreArchive strForKey:@"userID"]];
    }
    [self setupRefresh];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    //    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [_expiredRemindTableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"investment"];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [self loadData];
}

- (void)loadData {
    
    if (!_allDataArr) {
        _allDataArr = [[NSMutableArray alloc] init];
    }
    [_allDataArr removeAllObjects];
    
    if ([self.database open]) {
        
        if (isHeaderFresh) {
            [_expiredRemindTableView headerEndRefreshing];
            isHeaderFresh = NO;
        }
        [_allDataArr addObjectsFromArray:[self getRemindList]];
        [_expiredRemindTableView reloadData];
        
        if (![_allDataArr count]) {
            [self showNoRemindView];
        }else{
            [_noExpirdRemindView removeFromSuperview];
        }
        
        [MBProgressHUD hideHUD];
        
    }else{
        [self showNoRemindView];
        [MBProgressHUD showSuccess:@"获取提醒数据失败"];
    }
}

- (NSMutableArray *)getRemindList {
    NSDate *nowDate = [NSDate dateWithTimeIntervalSinceNow:8*60*60];
    int nowSp = [nowDate timeIntervalSince1970];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where time_stamp < %d order by time_stamp desc",_tableName,nowSp];
    NSLog(@"sql = %@",sql);
    
    NSMutableArray *allDataArr = [[NSMutableArray alloc] init];
    if ([self.database open]) {
        FMResultSet * res = [self.database executeQuery:sql];
        
        while ([res next]) {
            NSDictionary *itemDic = @{@"date":[res stringForColumn:@"date"],
                                      @"time":[res stringForColumn:@"time"],
                                      @"time_interval":[res stringForColumn:@"time_interval"],
                                      @"event" : [res stringForColumn:@"event"],
                                      @"time_stamp" : [res stringForColumn:@"time_stamp"],
                                      @"content":[res stringForColumn:@"content"],
                                      @"dateOrig":[res stringForColumn:@"dateOrig"],
                                      @"remind_ID":[res stringForColumn:@"remind_ID"]};
            [allDataArr addObject:itemDic];
        }
        NSLog(@"arr = %@",allDataArr);
    }
    
    
    return allDataArr;
}

- (void)showNoRemindView {
    [_noExpirdRemindView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
    [self.view addSubview:_noExpirdRemindView];
}

#pragma mark - table view data source and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_allDataArr count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifiter = @"remindCell";
    ExpiredRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiter];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ExpiredRemindCell" owner:self options:nil][0];
        cell.delegate = self;
    }
    
    NSDictionary *itemDic = _allDataArr[indexPath.row];
    NSString *contentStr = itemDic[@"event"];
    cell.eventLabel.text = [contentStr substringToIndex:contentStr.length-1];
    NSString *eventTime = itemDic[@"time"];
    cell.timeLabel.text = [eventTime substringToIndex:eventTime.length-3];
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
    
    ExpiredRemindCell *shotCell = (ExpiredRemindCell *) cell;
    
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
    vc.type = ExpireRemind;
    vc.editDataDic = [[NSDictionary alloc]initWithDictionary:_allDataArr[indexPath.row]];
    vc.database = self.database;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    isHeaderFresh = YES;
    [self loadData];
}

#pragma mark - cell delegate
- (void)tableViewCell:(UITableViewCell *)cell AndIndexPath:(NSIndexPath *)indexPath {
    
    NSString *remindID = _allDataArr[indexPath.row][@"time_stamp"];
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where time_stamp = %@",_tableName,remindID];
        NSLog(@"deleteSql = %@",deleteSql);
        [self.database executeUpdate:deleteSql];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
        });
    });
    [_allDataArr removeObjectAtIndex:indexPath.row];
    NSArray * indexPaths = [NSArray arrayWithObject:indexPath];
    [_expiredRemindTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
    [_expiredRemindTableView reloadData];
    
    if (![_allDataArr count]) {
        [self showNoRemindView];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
