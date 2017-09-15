//
//  WAHomeViewController.m
//  wawj
//
//  Created by ruiyou on 2017/7/31.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAHomeViewController.h"
#import "WAFuctionSetViewController.h"
#import "RemindViewController.h"
#import "WAFeedbackViewController.h"
#import "WAAddFamilyViewController.h"
#import "contactView.h"
#import "HomeCell.h"
#import "HomeCellTwo.h"

@interface WAHomeViewController ()<contactViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic) NSMutableArray *dataArr;
@end

@implementation WAHomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

//-(void)getPersonData {
//    
//    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1003" andModel:nil];
//    __weak __typeof__(self) weakSelf = self;
//    [MBProgressHUD showMessage:nil];
//    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
//        
////        __strong __typeof__(weakSelf) strongSelf = weakSelf;
////        [MBProgressHUD hideHUD];
//        
//        [CoreArchive setDic:data[@"body"][@"userInfo"] key:USERINFO];
////        NSString *code = data[@"code"];
////        NSString *desc = data[@"desc"];
////        if ([code isEqualToString:@"0000"]) {
////            
////            [strongSelf.navigationController popViewControllerAnimated:YES];
////            
////        } else {
////            
////            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
////                
////            }];
////            
////        }
//        
//    } fail:^(NSError *error) {
//        
////        __strong __typeof__(weakSelf) strongSelf = weakSelf;
////        [MBProgressHUD hideHUD];
////        
////        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
////            
////        }];
//        
//    }];
//    
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
//    [self getPersonData];
}

-(void)initViews {
    
    self.dataArr = [@[] mutableCopy];
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArr.count + 1;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 135;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataArr.count != indexPath.row) {
        static NSString *identifier = @"HomeCell";
        
        HomeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:nil options:nil] lastObject];
        }
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        return cell;
        
    } else {
        static NSString *identifier = @"HomeCellTwo";
        
        HomeCellTwo *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeCellTwo" owner:nil options:nil] lastObject];
        }
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == self.dataArr.count) {
        
        WAAddFamilyViewController *vc = [[WAAddFamilyViewController alloc] initWithNibName:@"WAAddFamilyViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        
    }

}


-(void)clickContactViewWith:(NSString *)str {

}

- (IBAction)clickYiJianBtn:(UIButton *)sender {
    
    WAFeedbackViewController *vc = [[WAFeedbackViewController alloc] initWithNibName:@"WAFeedbackViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)clickAddBtn:(UIButton *)sender {
    
    WAAddFamilyViewController *vc = [[WAAddFamilyViewController alloc] initWithNibName:@"WAAddFamilyViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickMyTiXingBtn:(UIButton *)sender {
    
    RemindViewController *vc = [[RemindViewController alloc] initWithNibName:@"RemindViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)clickFamilyPhotos:(UIButton *)sender {
}

- (IBAction)clickFuctionSetBtn:(UIButton *)sender {
    
    WAFuctionSetViewController *vc = [[WAFuctionSetViewController alloc] initWithNibName:@"WAFuctionSetViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)clickPhotoBtns:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
