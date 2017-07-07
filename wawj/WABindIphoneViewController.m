//
//  WABindIphoneViewController.m
//  wawj
//
//  Created by ruiyou on 2017/7/7.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WABindIphoneViewController.h"

#import <MBProgressHUD.h>

@interface WABindIphoneViewController ()
    @property (weak, nonatomic) IBOutlet UITextField *iphoneTextField;
    @property (weak, nonatomic) IBOutlet UITextField *msgTextField;
    @property (weak, nonatomic) IBOutlet UILabel *timeLab;
    @property (weak, nonatomic) IBOutlet UILabel *msgStatusLab;

@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, assign)NSInteger fixedTime;

@end

@implementation WABindIphoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self startTime];
    
}

-(void)initView {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
}

-(void)startTime {
    
    self.fixedTime = 60;
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerReponse) userInfo:nil repeats:YES];
    }
    
}

-(void)timerReponse {
    
    if (self.fixedTime > 0) {
        self.msgStatusLab.text = [NSString stringWithFormat:@"%ldS", --self.fixedTime];
    } else {
        self.msgStatusLab.text = @"获取验证码";
    }
    
    
    
}

-(void)backAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)clickNext:(id)sender {
    
    [self performSegueWithIdentifier:@"WAOldInterfaceViewController" sender:nil];
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
