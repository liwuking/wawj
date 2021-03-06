//
//  WAContactViewController.m
//  wawj
//
//  Created by ruiyou on 2017/9/8.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAContactViewController.h"
#import "LJContactManager.h"
#import "ContactItem.h"
#import "ImagePicker.h"
#import "WAHomeViewController.h"
#import "CloseFamilyItem.h"
#import <Contacts/Contacts.h>

@interface WAContactViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *picImage;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;

@property (strong, nonatomic)  NSDictionary *roleDict;


@end

@implementation WAContactViewController


-(void)initViews {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    self.title = [NSString stringWithFormat:@"添加%@", self.contacts];
    
    self.roleDict = @{@"爸爸":@"21",@"妈妈":@"20",
                           @"爷爷":@"11",@"奶奶":@"10",
                           @"姥姥":@"12",@"姥爷":@"13",
                           @"老公":@"31",@"老婆":@"30",
                           @"儿子":@"41", @"女儿":@"40",
                           @"孙子":@"51", @"孙女":@"50",
                           @"哥哥":@"33", @"姐姐":@"32",
                           @"弟弟":@"35", @"妹妹":@"34",
                           @"岳父":@"23", @"岳母":@"22",
                           @"公公":@"25", @"婆婆":@"24",
                           @"干妈":@"26", @"干爸":@"27",
                           @"儿媳":@"42", @"女婿":@"43",
                           @"外孙":@"53", @"外孙女":@"52"};
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
    
    [self requestAuthorizationAddressBook];
}


- (BOOL)requestAuthorizationAddressBook {
    // 判断是否授权
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (authorizationStatus == CNAuthorizationStatusNotDetermined) {
        // 请求授权
        CNContactStore * store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) { // 授权成功
                NSLog(@"授权成功！");
                
            } else {  // 授权失败
                NSLog(@"授权失败！");
                
            }
            
        }];
        return NO;
    } else if(authorizationStatus == CNAuthorizationStatusDenied || authorizationStatus == CNAuthorizationStatusRestricted){
        //设置-隐私-通讯录
        
        [self showAlertViewWithTitle:@"\n需开启 \"通讯录\" 权限 \n\n" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"去开启" clickOtherBtn:^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:url];
                });
            }
        }];
        return NO;
        
    }
    
    return YES;
}

- (IBAction)clickHead:(UITapGestureRecognizer *)sender {
    
    [self.view endEditing:YES];
    
//    __weak __typeof__(self) weakSelf = self;
//    [ImagePicker showImagePickerFromViewController:self allowsEditing:YES finishAction:^(UIImage *image) {
//        __strong __typeof__(weakSelf) strongSelf = weakSelf;
//        if (image)
//        {
//            [strongSelf.picImage setImage:image];
//        }
//    }];

}


- (IBAction)clickPhone:(UIButton *)sender {
    if (![self requestAuthorizationAddressBook]) {
        return;
    }
    
    __weak WAContactViewController *weakObject = self;
    [[LJContactManager sharedInstance] selectContactAtController:self complection:^(NSString *name, NSString *phone,NSData *imageData) {
        __strong WAContactViewController *strongObject = weakObject;
        
        phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phone = [[phone componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
        
        ContactItem *item = [[ContactItem alloc] init];
        item.name = name;
        [item.phoneArr addObject:phone];
        
        strongObject.phoneTF.text = phone;
        strongObject.nameTF.text = name;
        
        
    }];

}

#pragma -mark 添加亲密家人
- (IBAction)clickAddCloseFamily:(UIButton *)sender {
    
    if ([self.phoneTF.text isEqualToString:@""]) {
     
        [self showAlertViewWithTitle:@"提示" message:@"请输入电话号码" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if (self.phoneTF.text.length > 11) {
        
        [self showAlertViewWithTitle:@"请输入正确的电话号码" message:@"电话号码为11位" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if ([self.nameTF.text isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入姓名" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if ([self.nameTF.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 12) {
        [self showAlertViewWithTitle:@"姓名太长" message:@"姓名英文为12个字符，汉字为4个" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    
    NSDictionary *userinfo = [CoreArchive dicForKey:USERINFO];
    if ([self.phoneTF.text isEqualToString:userinfo[@"phoneNo"]]) {
        [self showAlertViewWithTitle:@"提示" message:@"不能添加本人" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    for (NSDictionary *dict in [CoreArchive arrForKey:USER_QIMI_ARR]) {
        
        if ([dict[@"qinmiPhone"] isEqualToString:self.phoneTF.text]) {
            [self showAlertViewWithTitle:@"提示" message:@"此人已经添加" buttonTitle:@"确定" clickBtn:^{
                
            }];
            return;
        }
        
    }
    

    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSDictionary *model = @{@"applyUser":   userInfo[@"userId"],
                            @"applyGender": userInfo[@"gender"],
                            @"acceptName":  self.nameTF.text,
                            @"acceptRole":  self.roleDict[self.contacts],
                            @"acceptPhone": self.phoneTF.text};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1104" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [MBProgressHUD showMessage:@"正在请求"];
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            NSDictionary *subDict = @{@"headUrl":@"",
                                      @"qinmiName":strongSelf.nameTF.text,
                                      @"qinmiPhone":strongSelf.phoneTF.text,
                                      @"qinmiUser":@"",
                                      @"qinmiRole":model[@"acceptRole"],
                                      @"qinmiRoleName":strongSelf.contacts
                                      };
            NSMutableArray *qimiArr = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_QIMI_ARR]];
            
            [qimiArr addObject:subDict];
            [CoreArchive setArr:qimiArr key:USER_QIMI_ARR];
            
            
            for (UIViewController *temp in strongSelf.navigationController.viewControllers) {
                if ([temp isKindOfClass:[WAHomeViewController class]]) {
                    [strongSelf.navigationController popToViewController:temp animated:YES];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldFrame      = [textField convertRect:textField.bounds toView:self.view];
    //当前输入框的Y
    CGFloat textField_Y        = textFieldFrame.origin.y;
    //当前输入框的高度
    CGFloat textFieldHight     = textFieldFrame.size.height;
    //屏幕高度
    CGFloat screenHight        = self.view.frame.size.height;
    //键盘高度
    CGFloat keyBordHight       = 216;
    //键盘tabbar高度
    CGFloat keyBordTabbarHight = 35;
    //计算输入框向上移动的偏移量
    int offset = 64+textField_Y + textFieldHight - (screenHight - keyBordHight - keyBordTabbarHight);
    
    //根据键盘遮挡的高度开始移动动画
    [UIView animateWithDuration:0.3 animations:^{
        if (offset > 0) {
            
            float width = self.view.frame.size.width;
            float hight = self.view.frame.size.height;
            
            CGRect rect = CGRectMake(0, -offset, width, hight);
            self.view.frame = rect;
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    //键盘收回后视图移动回原位的动画
    [UIView animateWithDuration:0.3 animations:^{
        
        float width = self.view.frame.size.width;
        float hight = self.view.frame.size.height;
        
        CGRect rect = CGRectMake(0, 0, width, hight);
        self.view.frame = rect;
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    //点击Return,键盘收回后视图移动回原位的动画
    [UIView animateWithDuration:0.3 animations:^{
        
        float width = self.view.frame.size.width;
        float hight = self.view.frame.size.height;
        
        CGRect rect = CGRectMake(0, 0, width, hight);
        self.view.frame = rect;
    }];
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
