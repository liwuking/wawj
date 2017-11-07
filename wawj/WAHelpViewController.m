//
//  WAHelpViewController.m
//  wawj
//
//  Created by ruiyou on 2017/11/6.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAHelpViewController.h"
#import "HelpTableViewCell.h"
#import "HelpItem.h"
#import <MJRefresh.h>
#import "WAHelpDetailViewController.h"
@interface WAHelpViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)NSMutableArray *dataArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation WAHelpViewController

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = @"帮助中心";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    __weak __typeof__(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf getHelpListData];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataArr = [@[] mutableCopy];
    
    [self initViews];
    
    [MBProgressHUD showMessage:nil];
    [self getHelpListData];
    
   
}

-(void)getHelpListData {
    
    NSDictionary *model = @{@"pageSize":     @"100"};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P0004" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
         __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        if ([strongSelf.tableView.mj_header isRefreshing]) {
            [strongSelf.tableView.mj_header endRefreshing];
        }
        
        if (![data[@"body"] isKindOfClass:[NSNull class]]) {
            
            NSArray *dataList =  data[@"body"];
            NSMutableArray *cacheArr = [@[] mutableCopy];
            for (NSDictionary *dict in dataList) {
                
                NSDictionary *dictNull = [dict transforeNullValueToEmptyStringInSimpleDictionary];
                HelpItem *helpItem = [[HelpItem alloc] init];
                helpItem.title = dictNull[@"title"];
                helpItem.url = dictNull[@"url"];
                helpItem.content = dictNull[@"content"];
                
                [cacheArr addObject:helpItem];
            }
            
            [strongSelf.dataArr removeAllObjects];
            [strongSelf.dataArr addObjectsFromArray:cacheArr];
            [strongSelf.tableView reloadData];
            
        }
        
    } fail:^(NSError *error) {
         __strong __typeof__(weakSelf) strongSelf = weakSelf;
         [MBProgressHUD hideHUD];
        
        if ([strongSelf.tableView.mj_header isRefreshing]) {
            [strongSelf.tableView.mj_header endRefreshing];
        }
        
        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
            
        }];
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifer = @"HelpTableViewCell";
    HelpItem *helpItem = [self.dataArr objectAtIndex:indexPath.row];
    HelpTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HelpTableViewCell" owner:self options:nil] lastObject];
    }
    
    cell.titleLab.text = helpItem.title;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    HelpItem *helpItem = [self.dataArr objectAtIndex:indexPath.row];
   
    WAHelpDetailViewController *vc = [[WAHelpDetailViewController alloc] initWithNibName:@"WAHelpDetailViewController" bundle:nil];
    vc.helpItem = helpItem;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArr.count;
    
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
