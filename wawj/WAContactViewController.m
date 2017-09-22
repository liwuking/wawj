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
@interface WAContactViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *picImage;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;

@end

@implementation WAContactViewController


-(void)initViews {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    self.title = [NSString stringWithFormat:@"选择%@", self.contacts];
    
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
    
}
- (IBAction)clickHead:(UITapGestureRecognizer *)sender {
    
    __weak __typeof__(self) weakSelf = self;
    [ImagePicker showImagePickerFromViewController:self allowsEditing:YES finishAction:^(UIImage *image) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (image)
        {
            
            [strongSelf.picImage setImage:image];
            
//                        NSData *imgData =  UIImageJPEGRepresentation(image, 0.1);
//                        [userImage sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:image];
//            
//                        boundary = @"----------V2ymHFg03ehbqgZCaKO6jy";
//                        fileParam = @"file";
//                        baseUrl = [NSString stringWithFormat:@"%@yh/n/uploadHeadPortrait",BASE_URL];
//                        fileName = @"image.png";//此文件提前放在可读写区域
//                        //此处首先指定了图片存取路径（默认写到应用程序沙盒中）
//                        NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//            
//                        //并给文件起个文件名
//                        NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"image.png"];
//            
//                        BOOL result=[imgData writeToFile:uniquePath atomically:YES];
//                        if(result){
//                            
//                        }else{
//                            
//                        }
//                        [self method4];
        }
        
        
    }];

}


- (IBAction)clickPhone:(UIButton *)sender {
    
    __weak WAContactViewController *weakObject = self;
    [[LJContactManager sharedInstance] selectContactAtController:self complection:^(NSString *name, NSString *phone) {
        __strong WAContactViewController *strongObject = weakObject;
        
        ContactItem *item = [[ContactItem alloc] init];
        item.name = name;
        item.phone = phone;
        
        strongObject.phoneTF.text = phone;
        strongObject.nameTF.text = name;
        
    }];

}

#pragma -mark 添加亲密家人
- (IBAction)clickAddCloseFamily:(UIButton *)sender {
    
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSDictionary *model = @{@"apply_user":   [CoreArchive strForKey:USERID],
                            @"apply_gender": userInfo[@"gender"],
                            @"accept_name":  userInfo[@"userName"],
                            @"accept_role":  self.contacts,
                            @"accept_phone": userInfo[@"phoneNo"]};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P1105" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [MBProgressHUD showMessage:@"正在请求"];
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            for (UIViewController *temp in self.navigationController.viewControllers) {
                if ([temp isKindOfClass:[WAHomeViewController class]]) {
                    [self.navigationController popToViewController:temp animated:YES];
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
