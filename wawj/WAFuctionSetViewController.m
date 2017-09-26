//
//  WAFuctionSetViewController.m
//  wawj
//
//  Created by ruiyou on 2017/8/1.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAFuctionSetViewController.h"

#import "WASetOneCell.h"
#import "WASetTwoCell.h"
#import "WASetThreeCell.h"
#import "WAReplaceUIViewController.h"
#import "WAEditRemindViewController.h"
#import "UserCenterViewController.h"
#import "NewRemindOrEditRmindViewController.h"
#import "WAShareViewController.h"
#import <UIImageView+WebCache.h>
#import "DBManager.h"
#import "FMDatabase.h"
#import "CoreArchive.h"
#import "WABindIphoneViewController.h"
#import "AppDelegate.h"

@interface WAFuctionSetViewController ()<UITableViewDelegate,UITableViewDataSource,UserCenterViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *arrTitles;

@end

@implementation WAFuctionSetViewController
{
    NSString               *_tableName;
    NSMutableArray         *_allDataArr;
    FMDatabase             *_db;
}
-(void)initView {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.title = @"个人设置";
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createDatabaseTable {
    
    if (!_allDataArr) {
        _allDataArr = [[NSMutableArray alloc]init];
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
    
    if ([CoreArchive dicForKey:USERINFO]) {
        NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
        NSString *userID = userInfo? userInfo[@"userId"] : @"";
        _tableName = [_tableName stringByAppendingFormat:@"_%@",userID];
    }
    
    
    [[DBManager defaultManager] createTableWithName:_tableName AndKeys:keys Result:^(BOOL isOK) {
        if (!isOK) {
            //建表失败！
            //[MBProgressHUD hideHUD];
            //[self showNoRemindView];
            return ;
        }
    } FMDatabase:^(FMDatabase *database) {
        _db = database;
        //[self loadData];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *interFace = [CoreArchive boolForKey:INTERFACE_NEW]? @"拟物界面" : @"老年界面";
    
    self.arrTitles = @[@[@"我的头像"],@[@"整点报时",interFace],@[@"分享下载",@"关于我们"]];
    
    [self initView];
    
}

//#define USER_QIMI_ARR  @"user_qinmi_ARR"
//#define USERINFO  @"userINFO"
//
//#define USERNAME  @"userName"
//#define USERID  @"userID"
//#define ISZHENGDIAN_BAOSHI  @"zhengdianbaoshi"
//#define INTERFACE_NEW  @"interface_new"   //是否新界面    YES表示新界面，NO表示旧界面
//#define FIRST_ENTER  @"first_enter"       //是否第一次进入 YES表示是，NO表示否


- (IBAction)clickLoginOut:(UIButton *)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    __weak typeof(self) weakSelf = self;
    [self showAlertViewWithTitle:@"" message:@"是否退出登录" buttonTitle:@"确定" clickBtn:^{
        
//        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [CoreArchive removeStrForKey:USER_QIMI_ARR];
        [CoreArchive removeStrForKey:USERINFO];
//        [CoreArchive removeStrForKey:USERNAME];
//        [CoreArchive removeStrForKey:USERID];
        [CoreArchive removeStrForKey:ISZHENGDIAN_BAOSHI];
    
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WABindIphoneViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WABindIphoneViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        appDelegate.window.rootViewController = nav;
        
    }];
    
    
    
}

-(void)userCenterViewControllerWithHeadImgRefresh:(UIImage *)image {
    
    WASetOneCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.imageView.image = image;
    
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 9;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 9)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section) {
        return 138;
    } else {
        return 60;
    }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section) {
        
        WASetOneCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"WASetOneCell" owner:nil options:nil] lastObject];
        NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
        if (userInfo[@"headUrl"]) {

            [cell.imageView sd_setImageWithURL:userInfo[@"headUrl"] placeholderImage:[UIImage imageNamed:@"个人设置-我的头像"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
            }];
        }
        return cell;
        
    } else if(1 == indexPath.section && 0 == indexPath.row){
        
        
        WASetTwoCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"WASetTwoCell" owner:nil options:nil] lastObject];
        cell.waSwitch.on = [CoreArchive boolForKey:ISZHENGDIAN_BAOSHI];
        
        return cell;
        
    } else {
        
        WASetThreeCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"WASetThreeCell" owner:nil options:nil] lastObject];
        cell.titleLab.text = self.arrTitles[indexPath.section][indexPath.row];
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (0 == indexPath.section) {
        
        UserCenterViewController *vc = [[UserCenterViewController alloc] initWithNibName:@"UserCenterViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (1 == indexPath.section) {
        
        if (0 == indexPath.row) {
            
            WASetTwoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.waSwitch.on = !cell.waSwitch.on;
            
            [CoreArchive setBool:cell.waSwitch.on key:ISZHENGDIAN_BAOSHI];
            
        } else {
            
            WAReplaceUIViewController *vc = [[WAReplaceUIViewController alloc] initWithNibName:@"WAReplaceUIViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        
    } else if (2 == indexPath.section) {
        
        if (0 == indexPath.row) {
            
            WAShareViewController *vc = [[WAShareViewController alloc] initWithNibName:@"WAShareViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            
        }
        
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (0 == section) {
        return 1;
    } else if(1 == section){
        return 2;
    } else {
        return 1;
    }
    
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
