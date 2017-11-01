//
//  WAAppListViewController.m
//  wawj
//
//  Created by ruiyou on 2017/10/27.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAAppListViewController.h"
#import <MJRefresh.h>
#import "WAAppTableViewCell.h"
@interface WAAppListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong)NSMutableArray *dataArr;
@property(nonatomic, assign)NSInteger pageNum;

@end

@implementation WAAppListViewController


/**
 *  集成刷新控件
 */
- (void)setupHeaderRefresh
{
//    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing),dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    __weak __typeof__(self) weakSelf = self;
    // The drop-down refresh
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf getAppListData];
    }];
    
    
    
}

- (void)setupFooterRefresh {

    __weak __typeof__(self) weakSelf = self;
    self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf getAppListData];
    }];
}


-(void)initViews {
    
    self.title = @"应用列表";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self setupHeaderRefresh];
}

-(void)leftAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.pageNum = 1;
    self.dataArr = [@[] mutableCopy];
    [self initViews];
    
    [MBProgressHUD showMessage:nil];
    [self getAppListData];
    
}

-(BOOL)adjustAddedWithAppId:(NSString *)appId {
    
    for (AppItem *appItem in self.selectedAppItem) {
        if ([appItem.mId isEqualToString:appId]) {
            return NO;
        }
    }
    
    return YES;
}

-(void)getAppListData {
    
    NSString *pageNum = [NSString stringWithFormat:@"%ld",self.pageNum];
    NSDictionary *model  = @{
                             @"pageNum":pageNum,
                             @"pageSize":@"10",
                             };
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P0005" andModel:model];
    
    
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        [MBProgressHUD hideHUD];
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        if ([data[@"code"] isEqualToString:@"0000"]) {
            
            if (![data[@"body"] isKindOfClass:[NSNull class]]) {
                
                NSArray *bodyLists = data[@"body"][@"userCommonAppList"];
                NSMutableArray *tempArr = [@[] mutableCopy];
                for (NSDictionary *subDict in bodyLists) {
                    
                    NSDictionary *dictTrans = [subDict transforeNullValueToEmptyStringInSimpleDictionary];
                    NSLog(@"dictTrans: %@", dictTrans);
                    AppItem *item = [[AppItem alloc] init];
                    item.appDownloadUrl = dictTrans[@"appDownloadUrl"];
                    item.appIcoUrl = dictTrans[@"appIcoUrl"];
                    item.appName = dictTrans[@"appName"];
                    item.createTime = dictTrans[@"createTime"];
                    item.channel = dictTrans[@"channel"];
                    item.mId = dictTrans[@"id"];
                    item.isAdd = [self adjustAddedWithAppId:item.mId];
                    [tempArr addObject:item];
                }

                if (1 == strongSelf.pageNum) {
                    strongSelf.pageNum = strongSelf.pageNum+1;
                    [strongSelf.dataArr removeAllObjects];
                }
                [strongSelf.dataArr addObjectsFromArray:tempArr];
                [strongSelf.tableView reloadData];
                
                if (strongSelf.dataArr.count >= 10) {
                    [strongSelf setupFooterRefresh];
                }
                
                if ([strongSelf.tableView.mj_header isRefreshing]) {
                    [strongSelf.tableView.mj_header endRefreshing];
                } else if([strongSelf.tableView.mj_footer isRefreshing]){
                    if (tempArr.count < 10) {
                        [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    }else {
                        [strongSelf.tableView.mj_footer endRefreshing];
                    }
                }

            }

        } else {
            
            [strongSelf showAlertViewWithTitle:@"提示" message:data[@"desc"] buttonTitle:@"确定" clickBtn:^{
                
            }];
            
        }
        
    } fail:^(NSError *error) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
    }];

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"WAAppTableViewCell";
    
    WAAppTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WAAppTableViewCell" owner:self options:nil] lastObject];
    }
    
    AppItem *appItem = [self.dataArr objectAtIndex:indexPath.row];
    cell.appItem = appItem;
    
    __weak __typeof__(self) weakSelf = self;
    cell.wAAppTableViewCellWithAddApp = ^(AppItem *appItem) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.dataArr replaceObjectAtIndex:indexPath.row withObject:appItem];
        [strongSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        strongSelf.wAAppListViewControllerWithAddApp(appItem);
    };
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
