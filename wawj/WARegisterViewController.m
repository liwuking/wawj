//
//  WARegisterViewController.m
//  wawj
//
//  Created by ruiyou on 2017/7/6.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WARegisterViewController.h"

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
    
    self.title = @"绑定手机卡";
    
}
- (IBAction)clickNextBtn:(UIButton *)sender {
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
