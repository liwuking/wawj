//
//  WANewInterfaceViewController.m
//  wawj
//
//  Created by ruiyou on 2017/8/15.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WANewInterfaceViewController.h"
#import "WANetViewController.h"
#import "WAHomeViewController.h"
#import "WAFuctionSetViewController.h"
#import "WACommonlyPhoneViewController.h"
#import "WACommonlyAPPViewController.h"
#import<AVFoundation/AVFoundation.h>

@interface WANewInterfaceViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;

@end

@implementation WANewInterfaceViewController
{
    BOOL LightOn;
    
    AVCaptureDevice *device;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [CoreArchive setBool:YES key:INTERFACE_NEW];
     device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}
- (IBAction)clickMyHome:(UIButton *)sender {
    
    WAHomeViewController *vc = [[WAHomeViewController alloc] initWithNibName:@"WAHomeViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)clickPhone:(UIButton *)sender {
    WACommonlyPhoneViewController *vc = [[WACommonlyPhoneViewController alloc] initWithNibName:@"WACommonlyPhoneViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickWebBtn:(UIButton *)sender {

    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self.navigationController pushViewController:[sb instantiateViewControllerWithIdentifier:@"WANetViewController"] animated:YES];
    
}

- (IBAction)clickCameraBtn:(UIButton *)sender {
    [self handlePhoto];
}

- (IBAction)clickLightBtn:(UIButton *)sender  {
    
    if (![device hasTorch]) {
        
        return;
        
    }
    
    LightOn = !LightOn;
    
    if (LightOn) {
        
        [self turnOn];
        
    }else{
        
        [self turnOff];
        
    }
    
}

-(void) turnOn

{
    
    //[self.backGroudImg setImage:[UIImage imageNamed:@"homeLightOn"]];
    
    [device lockForConfiguration:nil];
    
    [device setTorchMode:AVCaptureTorchModeOn];
    
    [device unlockForConfiguration];
    
}

-(void) turnOff

{
    //[self.backGroudImg setImage:[UIImage imageNamed:@"homeLightOff"]];
    
    [device lockForConfiguration:nil];
    
    [device setTorchMode: AVCaptureTorchModeOff];
    
    [device unlockForConfiguration];
    
}
- (IBAction)clickAppBtn:(UIButton *)sender {
    WACommonlyAPPViewController *vc = [[WACommonlyAPPViewController alloc] initWithNibName:@"WACommonlyAPPViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)handlePhoto {
    // UIImagePickerControllerCameraDeviceRear 后置摄像头
    //    UIImagePickerControllerCameraDeviceFront 前置摄像头
    
    //判断摄像头是否可用
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    
    if (!isCamera) {
        NSLog(@"没有摄像头");
        return;
    }
    //初始化图片选择控制器
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;//设置通过照相来选取照片
    
    imagePicker.allowsEditing = YES; //设置拍照时的下方的工具栏是否显示，如果需要自定义拍摄界面，则可把该工具栏隐藏
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

//得到图片或者视频后, 调用该代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //在这个方法里我们可以进行图片的修改, 保存, 或者视频的保存
    // UIImagePickerControllerOriginalImage 原始图片
    // UIImagePickerControllerEditedImage 编辑后图片
    //    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //    _imageView.image = image;
    
    
    NSString *imageDocPath = [self getImageSavePath];//保存
    //    _photoUrl = imageDocPath;
    NSLog(@"imageDocPath == %@", imageDocPath);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//当用户取消相册时, 调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
//在这里创建一个路径，用来在照相的代理方法里作为照片存储的路径
-(NSString *)getImageSavePath{
    //获取存放的照片
    //获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"PhotoFile"];
    return imageDocPath;
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
