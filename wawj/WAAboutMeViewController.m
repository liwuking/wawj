//
//  WAAboutMeViewController.m
//  wawj
//
//  Created by ruiyou on 2017/10/25.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAAboutMeViewController.h"
#import "WAAboutOneCell.h"
#import "WAAboutTwoCell.h"
#import "WAAboutThreeCell.h"
#import "WAFeedbackViewController.h"
@interface WAAboutMeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong)NSArray *titleArr;
@end

@implementation WAAboutMeViewController

-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = @"关于我们";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.titleLab.text = [NSString stringWithFormat:@"我爱我家%@",APP_VERSION_DESC];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
    
    self.titleArr = @[@"意见反馈",@"新版检测",@"官方网站"];
}

-(void)checkAppVesion {
    
    NSDictionary *model = @{};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P0001" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [MBProgressHUD showMessage:@"正在请求"];
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {

            if (![data[@"body"] isKindOfClass:[NSNull class]]) {
                NSDictionary *bodyDict = [data[@"body"] transforeNullValueToEmptyStringInSimpleDictionary];
                NSString *versionDesc = bodyDict[@"versionDesc"];
                NSString *updateContent = bodyDict[@"updateContent"];
                NSString *downloadUrl = bodyDict[@"downloadUrl"];
                
                [CoreArchive setStr:versionDesc key:APP_VERSION_DESC];
                [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                
                if ([bodyDict[@"versionForce"] isEqualToString:@"0"]) {
                    
                    [strongSelf showAlertViewWithTitle:versionDesc message:updateContent buttonTitle:@"确定" clickBtn:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];
                    }];
                    
                } else {
                    [strongSelf showAlertViewWithTitle:versionDesc message:updateContent cancelButtonTitle:@"取消" clickCancelBtn:^{
                    } otherButtonTitles:@"确定" clickOtherBtn:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];
                    }];
                }
            } else {
                [CoreArchive removeStrForKey:APP_VERSION_DESC];
                [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.row) {
        WAFeedbackViewController *vc = [[WAFeedbackViewController alloc] initWithNibName:@"WAFeedbackViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    } else if(1 == indexPath.row) {
        [self checkAppVesion];
    } else {
        NSString*url =@"http://www.wawjapp.com";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.row) {
        
        static NSString *identifier = @"WAAboutOneCell";
        WAAboutOneCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WAAboutOneCell" owner:self options:nil] lastObject];
        }
        cell.titleLab.text = self.titleArr[indexPath.row];
        
        return cell;
        
    } else if(1 == indexPath.row) {
        
        static NSString *identifier = @"WAAboutTwoCell";
        WAAboutTwoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WAAboutTwoCell" owner:self options:nil] lastObject];
        }
        cell.titleLab.text = self.titleArr[indexPath.row];
        if ([CoreArchive strForKey:APP_VERSION_DESC]) {
            cell.detailLab.text = [CoreArchive strForKey:APP_VERSION_DESC];
        }
        
        return cell;
        
    } else {
        static NSString *identifier = @"WAAboutThreeCell";
        WAAboutThreeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WAAboutThreeCell" owner:self options:nil] lastObject];
        }
        cell.titleLab.text = self.titleArr[indexPath.row];
        cell.detailLab.text = @"www.wawjapp.com";
        return cell;
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
