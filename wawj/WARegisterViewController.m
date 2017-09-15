//
//  WARegisterViewController.m
//  wawj
//
//  Created by ruiyou on 2017/7/6.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WARegisterViewController.h"

#import "UIViewController+AlertUtil.h"

@interface WARegisterViewController ()
    @property (weak, nonatomic) IBOutlet UITextField *textFiled;

@end

@implementation WARegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    
}

-(void)initView {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
}

-(void)backAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)clickNextBtn:(UIButton *)sender {
    
//    if (![Utility isValidatePhone:self.textFiled.text]) {
//        
//        [self showAlertViewWithTitle:@"提示" message:@"手机号输入有误" buttonTitle:@"确定" clickBtn:^{
//            
//        }];
//    
//    } else {
//        
//        [self performSegueWithIdentifier:@"WABindIphoneViewController" sender:nil];
//        
//    }
    [self performSegueWithIdentifier:@"WABindIphoneViewController" sender:nil];
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
