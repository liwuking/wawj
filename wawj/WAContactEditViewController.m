//
//  WAContactEditViewController.m
//  wawj
//
//  Created by ruiyou on 2017/11/1.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAContactEditViewController.h"
#import "EditAddTableViewCell.h"
#import "EditNameTableViewCell.h"
#import "EditPhoneTableViewCell.h"
#import "EditHeadImageTableViewCell.h"
@interface WAContactEditViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstant;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@end

@implementation WAContactEditViewController

-(void)clickCancel {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickSave {
    
}

-(void)initView {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = self.contactItem.name;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(clickCancel)];
    [leftItem setTintColor:HEX_COLOR(0x666666)];
    [leftItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(clickSave)];
    [rightItem setTintColor:HEX_COLOR(0x666666)];
    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.headView.layer.borderWidth = 1;
    self.headView.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [UIColor grayColor].CGColor;
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initView];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (IBAction)clickChangeHead:(UITapGestureRecognizer *)sender {
    // UIImagePickerControllerCameraDeviceRear 后置摄像头
    // UIImagePickerControllerCameraDeviceFront 前置摄像头

    //初始化图片选择控制器
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.allowsEditing = YES; //设置拍照时的下方的工具栏是否显示，如果需要自定义拍摄界面，则可把该工具栏隐藏
    imagePicker.delegate = self;
   
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击取消");
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"选择现有照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //判断摄像头是否可用
        BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        if (!isCamera) {
            NSLog(@"没有摄像头");
            return;
        }
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }]];
    
    // 由于它是一个控制器 直接modal出来就好了
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

//得到图片或者视频后, 调用该代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *images = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.headImageView.image = images;
    //    CGFloat fixelW = CGImageGetWidth(images.CGImage);
    //    CGFloat fixelH = CGImageGetHeight(images.CGImage);
    //    NSLog(@"fixelW: %f %f", fixelH,fixelW);
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//当用户取消相册时, 调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)clickDel:(UIButton *)sender {
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (2 == indexPath.row && 1 == self.contactItem.phoneArr.count) {
        [self.contactItem.phoneArr addObject:@""];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(0 == indexPath.row){
        EditNameTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"EditNameTableViewCell" owner:self options:nil] lastObject];
         return cell;
    }
    
    if(1 == indexPath.row){
        EditPhoneTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"EditPhoneTableViewCell" owner:self options:nil] lastObject];
        return cell;
    }
    
    if(2 == self.contactItem.phoneArr.count && 2 == indexPath.row){
       EditPhoneTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"EditPhoneTableViewCell" owner:self options:nil] lastObject];
        return cell;
    } else {
        EditAddTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"EditAddTableViewCell" owner:self options:nil] lastObject];
         return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  3;
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
