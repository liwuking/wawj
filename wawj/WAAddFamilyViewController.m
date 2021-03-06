//
//  WAAddFamilyViewController.m
//  wawj
//
//  Created by ruiyou on 2017/9/7.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAAddFamilyViewController.h"
#import "ContactPersonView.h"
#import "WAAddContactTableViewCell.h"
#import "WAContactViewController.h"
#import "ApplyItem.h"
#import "CloseFamilyItem.h"
#import <UIImageView+WebCache.h>
@interface WAAddFamilyViewController ()<UITableViewDelegate,UITableViewDataSource,WAAddContactTableViewCellDelegate>

@property(nonatomic, strong)NSArray *titleArr;
@property(nonatomic, strong)NSArray *subTitleArr;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong)ContactPersonView *contactPersonView;

@property(nonatomic, strong)NSMutableArray *applyArrs;

@end

@implementation WAAddFamilyViewController

-(void)initView {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.title = @"添加亲密人";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    if ([userInfo[@"gender"] isEqualToString:@"1"]) {
        //女
        _titleArr = @[@"爸爸",@"妈妈",@"爷爷",
                      @"奶奶",@"姥姥",@"姥爷",
                      @"老公",@"儿子",@"其他"];
        
        _subTitleArr = @[@[@"女婿", @"女儿", @"孙子", @"孙女"],
                         @[@"哥哥", @"姐姐", @"弟弟", @"妹妹"],
                         @[@"外孙", @"外孙女", @"公公", @"婆婆"],
                         @[@"干妈", @"干爸", @"儿媳"]];
        
    } else {
        //男
        _titleArr = @[@"爸爸",@"妈妈",@"爷爷",
                      @"奶奶",@"姥姥",@"姥爷",
                      @"儿子",@"老婆",@"其他"];
        
//        _subTitleArr = @[@[@"女婿", @"女儿", @"孙子", @"孙女"],
//                         @[@"哥哥", @"姐姐", @"弟弟", @"妹妹"],
//                         @[@"岳父", @"岳母", @"外孙", @"外孙女"],
//                         @[@"干妈", @"干爸", @"儿媳"]];
        _subTitleArr = @[@[@"女婿", @"女儿", @"孙子", @"孙女"],
                         @[@"哥哥", @"姐姐", @"弟弟", @"妹妹"],
                         @[@"岳父", @"岳母", @"外孙", @"外孙女"],
                         @[ @"儿媳"]];
    }
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIStackView class]]) {
            UIStackView *stackView = (UIStackView *)view;
            for (UIView *view in stackView.subviews) {
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)view;
                    
                    [btn setTitle:_titleArr[btn.tag] forState:UIControlStateNormal];
                    btn.clipsToBounds = YES;
                    btn.layer.cornerRadius = 5;
                    [btn addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
                    
                }
            }
        }
    }
    
    _contactPersonView = [[[NSBundle mainBundle] loadNibNamed:@"ContactPersonView" owner:self options:nil] lastObject];
    _contactPersonView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7f];
    for (NSInteger i = 0; i < _subTitleArr.count; i++) {
        NSArray *titleArr = _subTitleArr[i];
        
        for (NSInteger j = 0; j < titleArr.count; j++) {
            
            NSInteger width = (300-50)/4;
            NSString *title = titleArr[j];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(10*(j+1) + j* width, 10*(i+1) + 40*i, width, 40);
            [btn setTitle:title forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clickSubTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
            [btn setBackgroundImage:[UIImage imageNamed:@"borrow"] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:20];
            btn.clipsToBounds = YES;
            btn.layer.cornerRadius = 5;
            [_contactPersonView.btnViews addSubview:btn];
            
        }
        
    }
    _contactPersonView.hidden = YES;
    [self.view addSubview:_contactPersonView];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
}

-(void)clickSubTitleBtn:(UIButton *)btn {
    
    
    NSLog(@"%@", btn.titleLabel.text);
    WAContactViewController *vc = [[WAContactViewController alloc] initWithNibName:@"WAContactViewController" bundle:nil];
    vc.contacts = btn.titleLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
    _contactPersonView.hidden = YES;
    
}

- (void)clickSelectBtn:(UIButton *)btn {
    
    NSLog(@"%@", btn.titleLabel.text);
    if ([btn.titleLabel.text isEqualToString:@"其他"]) {
        _contactPersonView.hidden = NO;
        return ;
    }
    
    WAContactViewController *vc = [[WAContactViewController alloc] initWithNibName:@"WAContactViewController" bundle:nil];
    vc.contacts = btn.titleLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
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
                [qimiArr addObject:data[@"body"]];
                
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

-(void)backAction {
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
