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
#import "WAMyFamilyPhotosViewController.h"
#import "WACloseFamilyDetailViewController.h"
#import "UserCenterViewController.h"
#import "contactView.h"
#import "HomeCell.h"
#import "HomeCellTwo.h"

@interface WAHomeViewController ()<WAAddFamilyViewControllerDelegate,contactViewDelegate,UITableViewDelegate,UITableViewDataSource>

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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
    
    
}


-(void)viewDidAppear:(BOOL)animated {
    
    NSMutableArray *arr = [CoreArchive arrForKey:USER_QIMI_ARR];
    NSMutableArray *datas = [@[] mutableCopy];
    for (NSDictionary *dict in arr) {
        CloseFamilyItem *item = [[CloseFamilyItem alloc] init];
        item.headUrl = dict[@"headUrl"];
        item.qinmiName = dict[@"qinmiName"];
        item.qinmiPhone = dict[@"qinmiPhone"];
        item.qinmiUser = dict[@"qinmiUser"];
        item.qinmiRole = dict[@"qinmiRole"];
        [datas addObject:item];
        
    }
    
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:datas];
    
    [self.tableView reloadData];
}

-(void)initViews {
    
    self.dataArr = [@[] mutableCopy];
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    
}

//-(void)waAddFamilyViewControllerWithFamilyItem:(CloseFamilyItem *)item {
//    
//    [self.dataArr addObject:item];
//    [self.tableView reloadData];
//    
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.dataArr.count < 6) {
        return self.dataArr.count + 1;
    } else {
        return self.dataArr.count;
    }
    

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 135;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataArr.count != indexPath.row) {
        static NSString *identifier = @"HomeCell";
        
        CloseFamilyItem *item = self.dataArr[indexPath.row];
        HomeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:nil options:nil] lastObject];
        }
        cell.transform = CGAffineTransformMakeRotation(M_PI / 2);
        cell.closeFamilyItem = item;
        return cell;
        
    } else {
        static NSString *identifier = @"HomeCellTwo";
        
        HomeCellTwo *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeCellTwo" owner:nil options:nil] lastObject];
        }
        cell.transform = CGAffineTransformMakeRotation(M_PI / 2);
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == self.dataArr.count) {
        
        __weak __typeof__(self) weakSelf = self;
        if (![CoreArchive dicForKey:USERINFO][@"userName"]) {
            
            [self showAlertViewWithTitle:@"提示" message:@"请先完善个人信息" cancelButtonTitle:@"取消" clickCancelBtn:^{
                
            } otherButtonTitles:@"确定" clickOtherBtn:^{
                
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                UserCenterViewController *vc = [[UserCenterViewController alloc] initWithNibName:@"UserCenterViewController" bundle:nil];
                [strongSelf.navigationController pushViewController:vc animated:YES];
                
            }];
            
            return;
        }
        
        if (![CoreArchive dicForKey:USERINFO][@"headUrl"]) {
            
            [self showAlertViewWithTitle:@"提示" message:@"请先上传个人头像" cancelButtonTitle:@"取消" clickCancelBtn:^{
                
            } otherButtonTitles:@"确定" clickOtherBtn:^{
                
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                UserCenterViewController *vc = [[UserCenterViewController alloc] initWithNibName:@"UserCenterViewController" bundle:nil];
                [strongSelf.navigationController pushViewController:vc animated:YES];
                
            }];
            
            return;
        }
        
        
        
        WAAddFamilyViewController *vc = [[WAAddFamilyViewController alloc] initWithNibName:@"WAAddFamilyViewController" bundle:nil];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        
        CloseFamilyItem *item = self.dataArr[indexPath.row];
        WACloseFamilyDetailViewController *vc = [[WACloseFamilyDetailViewController alloc] initWithNibName:@"WACloseFamilyDetailViewController" bundle:nil];
        vc.closeFamilyItem = item;
        [self.navigationController pushViewController:vc animated:YES];
        
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
    WAMyFamilyPhotosViewController *vc = [[WAMyFamilyPhotosViewController alloc] initWithNibName:@"WAMyFamilyPhotosViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
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
