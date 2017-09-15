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
@interface WAAddFamilyViewController ()<UITableViewDelegate,UITableViewDataSource>

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
    
    
    _titleArr = @[@"爸爸",@"妈妈",@"爷爷",
                          @"奶奶",@"姥姥",@"姥爷",
                          @"老公",@"老婆",@"其他"];
    
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIStackView class]]) {
            UIStackView *stackView = (UIStackView *)view;
            for (UIView *view in stackView.subviews) {
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)view;
                    
                    [btn setTitle:_titleArr[btn.tag] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
                    
                }
            }
        }
    }
    
    
    _subTitleArr = @[@[@"儿子", @"女儿", @"孙子", @"孙女"],
                     @[@"哥哥", @"姐姐", @"弟弟", @"妹妹"],
                     @[@"岳父", @"岳母", @"公公", @"婆婆"],
                     @[@"干妈", @"干爸", @"儿媳", @"女婿"],
                     @[@"外孙", @"外孙女"]];
    
    _contactPersonView = [[[NSBundle mainBundle] loadNibNamed:@"ContactPersonView" owner:self options:nil] lastObject];
    _contactPersonView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7f];
    for (NSInteger i = 0; i < _subTitleArr.count; i++) {
        NSArray *titleArr = _subTitleArr[i];
        
        for (NSInteger j = 0; j < titleArr.count; j++) {
            
            NSInteger width = (SCREEN_WIDTH-45)/4;
            NSString *title = titleArr[j];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(5*(j+1) + j* width, 5*(i+1) + 30*i, width, 30);
            [btn setTitle:title forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clickSubTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
            //btn.backgroundColor = HEX_COLOR(0xFAA41C);
            [btn setBackgroundImage:[UIImage imageNamed:@"borrow"] forState:UIControlStateNormal];
            [_contactPersonView.btnViews addSubview:btn];
            
        }
        
    }
    _contactPersonView.hidden = YES;
    [self.view addSubview:_contactPersonView];
    
}

-(void)clickSubTitleBtn:(UIButton *)btn {
    
    NSLog(@"%@", btn.titleLabel.text);
    WAContactViewController *vc = [[WAContactViewController alloc] initWithNibName:@"WAContactViewController" bundle:nil];
    vc.contacts = btn.titleLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)clickSelectBtn:(UIButton *)btn {
    
    NSLog(@"%@", btn.titleLabel.text);
    _contactPersonView.hidden = YES;
    if ([btn.titleLabel.text isEqualToString:@"其他"]) {
        return ;
    }
    
    WAContactViewController *vc = [[WAContactViewController alloc] initWithNibName:@"WAContactViewController" bundle:nil];
    vc.contacts = btn.titleLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initView];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.applyArrs.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *identifier = @"WAAddContactTableViewCell";
    
    WAAddContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WAAddContactTableViewCell" owner:self options:nil] lastObject];
    }
    cell.textLabel.text = self.applyArrs[indexPath.row];
    return cell;
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
