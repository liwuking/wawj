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
#import "WAApplyRemindViewController.h"
@interface WAHomeViewController ()<WAAddFamilyViewControllerDelegate,contactViewDelegate,WACloseFamilyDetailViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTop;
@property (weak, nonatomic) IBOutlet UIButton *remindBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstrain;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic) NSMutableArray *dataArr;

@end

@implementation WAHomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    if (SCREEN_HEIGHT >= 667) {
        self.viewTop.constant = 220;
    }
    
    [self refreshTableView];
    
    if ([CoreArchive dicForKey:USERINFO]) {
        [self getCloseFamilyApplyListData];
    }
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
         item.qinmiRoleName = dict[@"qinmiRoleName"];
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
     item.qinmiRoleName = dict[@"qinmiRoleName"];
    
    [self.dataArr replaceObjectAtIndex:index withObject:item];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:index]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
   
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


#pragma -mark 亲密家人申请列表
-(void)getCloseFamilyApplyListData {
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1105" andModel:nil];
    
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        NSString *code = data[@"code"];
        if ([code isEqualToString:@"0000"]) {
            
            if ([data[@"body"] isKindOfClass:[NSArray class]]) {
                
                NSArray *dataArr = [[NSArray alloc] initWithArray: data[@"body"]];
                if (dataArr.count > 0) {
                    [strongSelf.remindBtn setImage:[UIImage imageNamed:@"remindLight"] forState:UIControlStateNormal];
                }
                
            }
            
        }
        
    } fail:^(NSError *error) {
        
    }];
    
}

- (IBAction)cllickContactRemindBtn:(UIButton *)sender {
    WAApplyRemindViewController *vc = [[WAApplyRemindViewController alloc] initWithNibName:@"WAApplyRemindViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
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
        
        
//        CGFloat fixelW = CGImageGetWidth(cell.headImageView.image.CGImage);
//        CGFloat fixelH = CGImageGetHeight(cell.headImageView.image.CGImage);
//        NSLog(@"fixelW: %f %f", fixelW,fixelH);
        
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
        if (!userName || [userName isEqualToString:@""]) {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            [strongSelf showAlertViewWithTitle:@"添加亲密家人" message:@"请先设置头像、姓名和生日" cancelButtonTitle:@"取消" clickCancelBtn:^{
                
            } otherButtonTitles:@"确定" clickOtherBtn:^{
                
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                UserCenterViewController *vc = [[UserCenterViewController alloc] initWithNibName:@"UserCenterViewController" bundle:nil];
                [strongSelf.navigationController pushViewController:vc animated:YES];
                
            }];
            
            return;
        }
        
        NSString *headUrl = [CoreArchive dicForKey:USERINFO][@"headUrl"];
        if (!headUrl || [headUrl isEqualToString:@""]) {
            
            [self showAlertViewWithTitle:@"添加亲密家人" message:@"请先设置头像、姓名和生日" cancelButtonTitle:@"取消" clickCancelBtn:^{
                
            } otherButtonTitles:@"确定" clickOtherBtn:^{
                
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                UserCenterViewController *vc = [[UserCenterViewController alloc] initWithNibName:@"UserCenterViewController" bundle:nil];
                [strongSelf.navigationController pushViewController:vc animated:YES];
                
            }];
            
            return;
        }
        
        WAAddFamilyViewController *vc = [[WAAddFamilyViewController alloc] initWithNibName:@"WAAddFamilyViewController" bundle:nil];
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
