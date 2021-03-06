//
//  WANewPhotosViewController.m
//  wawj
//
//  Created by ruiyou on 2017/9/18.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WANewPhotosViewController.h"

@interface WANewPhotosViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTF;

@end

@implementation WANewPhotosViewController

-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;

    if (self.photosItem) {
        self.titleTF.placeholder = self.photosItem.title;
        self.title = @"编辑相册";
    } else {
        self.title = @"新建相册";
    }
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

//#pragma -mark 新建相册
- (IBAction)clickFanish:(UIButton *)sender {

    [self.view endEditing:YES];
    
    if ([self.titleTF.text isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"" message:@"相册名称不能为空" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if ([self.titleTF.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 24) {
        [self showAlertViewWithTitle:@"相册名称太长" message:@"英文为24个字符，汉字为8个" buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if (self.photosItem) {
        NSDictionary *model = @{@"album_id":     self.photosItem.albumId,
                                @"title":        self.titleTF.text,
                                @"album_style":  @""};
        NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2102" andModel:model];
        __weak __typeof__(self) weakSelf = self;
        [MBProgressHUD showMessage:nil];
        [CLNetworkingManager postNetworkRequestWithUrlString:ALBUM_URL parameters:params isCache:NO succeed:^(id data) {
            
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            [MBProgressHUD hideHUD];
            
            NSString *code = data[@"code"];
            NSString *desc = data[@"desc"];
            if ([code isEqualToString:@"0000"]) {
                
                [strongSelf.delegate waNewPhotosViewControllerWithAlbumId:strongSelf.albumId AndRefreshTitle:strongSelf.titleTF.text];
                
                [strongSelf.navigationController popViewControllerAnimated:YES];
                
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

    } else {
        NSDictionary *model = @{@"album_id":     @"",
                                @"title":        self.titleTF.text,
                                @"album_style":  @""};
        NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2102" andModel:model];
        __weak __typeof__(self) weakSelf = self;
        [MBProgressHUD showMessage:nil];
        [CLNetworkingManager postNetworkRequestWithUrlString:ALBUM_URL parameters:params isCache:NO succeed:^(id data) {
            
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            [MBProgressHUD hideHUD];
            
            NSString *code = data[@"code"];
            NSString *desc = data[@"desc"];
            if ([code isEqualToString:@"0000"]) {
                
                [strongSelf.delegate waNewPhotosViewControllerWithNewPhotosAlbumId:data[@"body"][@"albumId"] AndTitle:strongSelf.titleTF.text];
                [strongSelf.navigationController popViewControllerAnimated:YES];
                
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
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
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
