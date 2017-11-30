//
//  WAApplyRemindViewController.m
//  wawj
//
//  Created by ruiyou on 2017/11/7.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAApplyRemindViewController.h"
#import "ApplyItem.h"
#import "WAAddContactTableViewCell.h"
#import <UIImageView+WebCache.h>

@interface WAApplyRemindViewController ()<UITableViewDelegate,UITableViewDataSource,WAAddContactTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong)NSMutableArray *applyArrs;

@end

@implementation WAApplyRemindViewController

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initView {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.title = @"我的消息";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.applyArrs = [@[] mutableCopy];
    [self initView];
    
    [self getCloseFamilyApplyListData];
}

#pragma -mark 亲密家人申请列表
-(void)getCloseFamilyApplyListData {
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1105" andModel:nil];
    
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            if ([data[@"body"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dict in data[@"body"]) {
                    
                    ApplyItem *item = [[ApplyItem alloc] init];
                    item.applyId = dict[@"applyId"];
                    item.applyName = dict[@"applyName"];
                    item.applyPhone = dict[@"applyPhone"];
                    item.applyRole = dict[@"applyRole"];
                    item.headUrl = dict[@"headUrl"];
                    
                    [self.applyArrs addObject:item];
                    
                    [self.tableView reloadData];
                }
                
            }
            
        } else {
            
            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
                
            }];
            
        }
        
    } fail:^(NSError *error) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
    }];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.applyArrs.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"WAAddContactTableViewCell";
    
    WAAddContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WAAddContactTableViewCell" owner:self options:nil] lastObject];
    }
    
    ApplyItem *item = [self.applyArrs objectAtIndex:indexPath.row];
    
    cell.applyItem = item;
    cell.delegate = self;
    
    return cell;
    
}


-(void)clickAddContactWithCell:(WAAddContactTableViewCell *)cell {
    
    
    [self addApplyWithApplyItem:cell.applyItem];
}


-(void)addApplyWithApplyItem:(ApplyItem *)item {
    
    NSDictionary *model = @{@"apply_id":item.applyId,@"applyPhone":item.applyPhone};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1106" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [MBProgressHUD showMessage:nil];
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            
            if (data[@"body"]) {
                
                NSMutableArray *qimiArr = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_QIMI_ARR]];
                 NSDictionary *dict = [data[@"body"] transforeNullValueToEmptyStringInSimpleDictionary];
                [qimiArr addObject:dict];
               
                [CoreArchive setArr:qimiArr key:USER_QIMI_ARR];
                
                [MBProgressHUD showSuccess:@"添加成功"];
                [strongSelf.navigationController popViewControllerAnimated:YES];
                
            }
            
        } else {
            
            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
                
            }];
            
        }
        
    } fail:^(NSError *error) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
    }];
    
    
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
