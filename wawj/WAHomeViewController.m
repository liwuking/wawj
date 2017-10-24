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

@interface WAHomeViewController ()<WAAddFamilyViewControllerDelegate,contactViewDelegate,WACloseFamilyDetailViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstrain;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic) NSMutableArray *dataArr;

@end

@implementation WAHomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    [self refreshTableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

-(void)refreshTableView{
    
    NSMutableArray *arr = [CoreArchive arrForKey:USER_QIMI_ARR];
    if (arr.count == self.dataArr.count) {
        return;
    }
    
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
    
    //self.isReload = YES;
    [self.tableView reloadData];
}

-(void)waCloseFamilyDetailViewControllerRefreshIndex:(NSInteger)index {
   
    NSMutableArray *arr = [CoreArchive arrForKey:USER_QIMI_ARR];
    NSDictionary *dict = arr[index];
    
    CloseFamilyItem *item = [[CloseFamilyItem alloc] init];
    item.headUrl = dict[@"headUrl"];
    item.qinmiName = dict[@"qinmiName"];
    item.qinmiPhone = dict[@"qinmiPhone"];
    item.qinmiUser = dict[@"qinmiUser"];
    item.qinmiRole = dict[@"qinmiRole"];
    
    [self.dataArr replaceObjectAtIndex:index withObject:item];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:index]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)initViews {
    
    self.dataArr = [@[] mutableCopy];
    
    self.tableHeightConstrain.constant = SCREEN_WIDTH;
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];

}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.dataArr.count < 6) {
        return self.dataArr.count + 1;
    } else {
        return self.dataArr.count;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataArr.count == indexPath.section) {
        return 145;//section尾部高度
    } else {
        return 135;
    }
    
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == self.dataArr.count) {
        return (SCREEN_WIDTH - 135)/2;//section头部高度
    } else {
        return (SCREEN_WIDTH - 270)/3;//section头部高度
    }
    
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.dataArr.count < 6) {
        if (self.dataArr.count == section) {
            NSLog(@"section: %ld", section);
            if (0 == self.dataArr.count) {
                return (SCREEN_WIDTH - 135)/2;//section头部高度
            } else {
                return (SCREEN_WIDTH - 270)/3;//section头部高度
            }
        } else {
            
            return 1;
        }
    } else {
        if (self.dataArr.count == section+1) {
            NSLog(@"section: %ld", section);
            return (SCREEN_WIDTH - 270)/3;//section尾部高度
        } else {
            
            return 1;
        }
    }
    
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

    if(decelerate) return;

    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UITableView *)tableView {

    [tableView scrollToRowAtIndexPath:[tableView indexPathForRowAtPoint: CGPointMake(tableView.contentOffset.x, tableView.contentOffset.y+tableView.rowHeight/2)] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataArr.count != indexPath.section) {
        static NSString *identifier = @"HomeCell";
        
        CloseFamilyItem *item = self.dataArr[indexPath.section];
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

    if (indexPath.section == self.dataArr.count) {
        
        __weak __typeof__(self) weakSelf = self;
        NSString *userName = [CoreArchive dicForKey:USERINFO][@"userName"];
        if ([userName isEqualToString:@""]) {
            
            [self showAlertViewWithTitle:@"提示" message:@"您还没有设置个人信息，请先完善个人信息" cancelButtonTitle:@"取消" clickCancelBtn:^{
                
            } otherButtonTitles:@"确定" clickOtherBtn:^{
                
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                UserCenterViewController *vc = [[UserCenterViewController alloc] initWithNibName:@"UserCenterViewController" bundle:nil];
                [strongSelf.navigationController pushViewController:vc animated:YES];
                
            }];
            
            return;
        }
        
        NSString *headUrl = [CoreArchive dicForKey:USERINFO][@"headUrl"];
        if ([headUrl isEqualToString:@""]) {
            
            [self showAlertViewWithTitle:@"提示" message:@"请先上传个人头像" cancelButtonTitle:@"取消" clickCancelBtn:^{
                
            } otherButtonTitles:@"确定" clickOtherBtn:^{
                
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                UserCenterViewController *vc = [[UserCenterViewController alloc] initWithNibName:@"UserCenterViewController" bundle:nil];
                [strongSelf.navigationController pushViewController:vc animated:YES];
                
            }];
            
            return;
        }
        
        
        
        WAAddFamilyViewController *vc = [[WAAddFamilyViewController alloc] initWithNibName:@"WAAddFamilyViewController" bundle:nil];
        //vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        
        CloseFamilyItem *item = self.dataArr[indexPath.section];
        WACloseFamilyDetailViewController *vc = [[WACloseFamilyDetailViewController alloc] initWithNibName:@"WACloseFamilyDetailViewController" bundle:nil];
        vc.closeFamilyItem = item;
        vc.delegate = self;
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
