
//
//  WAContactDetailViewController.m
//  wawj
//
//  Created by ruiyou on 2017/11/1.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAContactDetailViewController.h"
#import "WAContactEditViewController.h"
@interface WAContactDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIStackView *photoStackView;

@end

@implementation WAContactDetailViewController

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initView {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
     self.title = self.contactItem.name;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(clickEdit)];
    [rightItem setTintColor:HEX_COLOR(0x666666)];
    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
     NSString *contactPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyContact/%@",self.contactItem.phoneArr[0]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:contactPath]) {
        [self.headImageView setImage:[UIImage imageWithContentsOfFile:contactPath]];
    }else {
        [self.headImageView setImage:[UIImage imageNamed:@"oldFather"]];
    }
    
    for (NSInteger i = 0; i < self.contactItem.phoneArr.count; i++) {
        
        NSString *phone = self.contactItem.phoneArr[i];
        UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        phoneBtn.tag = i;
        [phoneBtn setTitle:phone forState:UIControlStateNormal];
        [phoneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [phoneBtn setImage:[UIImage imageNamed:@"phone_x"] forState:UIControlStateNormal];
        [phoneBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
        [phoneBtn addTarget:self action:@selector(clickPhone:) forControlEvents:UIControlEventTouchUpInside];
        [self.photoStackView addArrangedSubview:phoneBtn];
        
    }
    
}

-(void)clickPhone:(UIButton *)phoneBtn {
    
    [self showAlertViewWithTitle:[NSString stringWithFormat:@"是否拨打%@",self.contactItem.phoneArr[phoneBtn.tag]] message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
        
    } otherButtonTitles:@"确定" clickOtherBtn:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.contactItem.phoneArr[phoneBtn.tag]]];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initView];
    
}

-(void)clickEdit {
    WAContactEditViewController *vc = [[WAContactEditViewController alloc] initWithNibName:@"WAContactEditViewController" bundle:nil];
    vc.contactItem = self.contactItem;
    [self.navigationController pushViewController:vc animated:YES];
    
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
