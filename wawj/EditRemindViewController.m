//
//  EditRemindViewController.m
//  wawj
//
//  Created by ruiyou on 2017/10/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "EditRemindViewController.h"

@interface EditRemindViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *btnsView;
@property (weak, nonatomic) IBOutlet UIButton *btnOne;
@property (weak, nonatomic) IBOutlet UIButton *btnTwo;
@property (weak, nonatomic) IBOutlet UIButton *btnThree;
@property (weak, nonatomic) IBOutlet UIButton *btnFour;

@property (nonatomic, strong)NSString *adviceType;

@end

@implementation EditRemindViewController

- (void)viewWillAppear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if ([self.textView.text isEqualToString:@"请输入您要提醒的事情"]) {
        self.textView.text = @"";
        self.textView.textColor = [UIColor blackColor];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    if ([self.textView.text isEqualToString:@""]) {
        self.textView.text = @"请输入您要提醒的事情";
        self.textView.textColor = [UIColor lightGrayColor];
    }
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = @"添加提醒";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    self.datePicker.locale = locale;
    self.datePicker.minimumDate = [NSDate date]; // 最小时间
    
//    [self.datePicker setValue:HEX_COLOR(0x219ce0) forKey:@"textColor"];
//    for (UIView *view in self.datePicker.subviews) {
//
//        if ([view isKindOfClass:[UIView class]]) {
//
//            for (UIView *subView in view.subviews) {
//
//                if (subView.frame.size.height < 1) {
//
//                    subView.backgroundColor = HEX_COLOR(0x219ce0);
//
//                }
//
//            }
//
//        }
//    }
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
    
    self.adviceType = @"仅一次";
    
}

- (IBAction)clickSubmitBtn:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    if ([self.textView.text isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"" message:@"反馈内容不能为空" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
}

- (IBAction)clickBtnOne:(UIButton *)sender {
    
    self.adviceType = @"仅一次";
    
    sender.backgroundColor = HEX_COLOR(0xfaa41c);
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    for (UIView *view in self.btnsView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag != sender.tag) {
            UIButton *btn = (UIButton *)view;
            btn.backgroundColor = HEX_COLOR(0xd1d1d8);
            [btn setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
        }
    }

    
}

- (IBAction)clickBtnTwo:(UIButton *)sender {

    self.adviceType = @"每天";
    
    sender.backgroundColor = HEX_COLOR(0xfaa41c);
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    for (UIView *view in self.btnsView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag != sender.tag) {
            UIButton *btn = (UIButton *)view;
            btn.backgroundColor = HEX_COLOR(0xd1d1d8);
            [btn setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
        }
    }
}

- (IBAction)clickBtnThree:(UIButton *)sender {

    self.adviceType = @"周末";
    
    sender.backgroundColor = HEX_COLOR(0xfaa41c);
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    for (UIView *view in self.btnsView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag != sender.tag) {
            UIButton *btn = (UIButton *)view;
            btn.backgroundColor = HEX_COLOR(0xd1d1d8);
            [btn setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
        }
    }
}

- (IBAction)clickBtnFour:(UIButton *)sender {

    self.adviceType = @"工作日";
    
    sender.backgroundColor = HEX_COLOR(0xfaa41c);
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    for (UIView *view in self.btnsView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag != sender.tag) {
            UIButton *btn = (UIButton *)view;
            btn.backgroundColor = HEX_COLOR(0xd1d1d8);
            [btn setTitleColor:HEX_COLOR(0x666666) forState:UIControlStateNormal];
        }
    }
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        
        [self.textView resignFirstResponder];
        //在这里做你响应return键的代码
        return YES; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
        
        
    }
    
    return YES;
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
