//
//  ImagePicker.m
//  ReplaceThePicture
//
//  Created by apple on 16/1/25.
//  Copyright © 2016年 DeveYang. All rights reserved.
//

#import "ImagePicker.h"
#import <AVFoundation/AVFoundation.h>
@interface ImagePicker()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic, weak)UIViewController  *viewController;
@property(nonatomic, copy)ImagePickerFinishAction  finishAction;
@property(nonatomic, assign)BOOL  allowsEditing;
@end

//用到此类的时候初始化
static ImagePicker *imagePickerInstance = nil;
@implementation ImagePicker
+ (void)showImagePickerFromViewController:(UIViewController *)viewController
                            allowsEditing:(BOOL)allowsEditing
                             finishAction:(ImagePickerFinishAction)finishAction{
    if (imagePickerInstance == nil) {
        imagePickerInstance = [[ImagePicker alloc] init];
    }
    
    [imagePickerInstance showImagePickerFromViewController:viewController
                                               allowsEditing:allowsEditing
                                                finishAction:finishAction];

}
- (void)showImagePickerFromViewController:(UIViewController *)viewController
                            allowsEditing:(BOOL)allowsEditing
                             finishAction:(ImagePickerFinishAction)finishAction {
    _viewController = viewController;
    _finishAction = finishAction;
    _allowsEditing = allowsEditing;
    
    UIActionSheet *sheet = nil;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sheet = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"拍照", @"从相册选择", nil];
    }else {
        sheet = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"从相册选择", nil];
    }
    
    UIView *window = [UIApplication sharedApplication].keyWindow;
    [sheet showInView:window];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"拍照"]) {
        
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"不能访问您的相机" message:@"请在设备的'设置-隐私-相机'中允许访问相机" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
//            [alert show];
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied ){
                //无权限
                [_viewController showAlertViewWithTitle:@"\n需开启 \"相机\" 权限 \n\n" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
                    
                } otherButtonTitles:@"去开启" clickOtherBtn:^{
                    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if([[UIApplication sharedApplication] canOpenURL:url]) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] openURL:url];
                        });
                    }
                }];
                
//                return NO;
                
            } else if (status == AVAuthorizationStatusNotDetermined) {
                
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if(granted){//点击允许访问时调用
                        //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                        NSLog(@"Granted access to %@", AVMediaTypeVideo);
                    }
                    else {
                        NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                    }
                    
                }];
                
//                return NO;
            }
            
            return;
        }else{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.allowsEditing = _allowsEditing;
            [_viewController presentViewController:picker animated:YES completion:nil];

        }
    }else if ([title isEqualToString:@"从相册选择"]) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"不能访问您的相册" message:@"请在设备的'设置-隐私-相册'中允许访问相机" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
//            [alert show];
            
            //无权限
            [_viewController showAlertViewWithTitle:@"\n需开启 \"照片\" 权限 \n\n" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
                
            } otherButtonTitles:@"去开启" clickOtherBtn:^{
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] openURL:url];
                    });
                }
            }];
            
            return;

        }else{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            [_viewController presentViewController:picker animated:YES completion:nil];
        }
    }else {
        imagePickerInstance = nil;
    }
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = info[UIImagePickerControllerOriginalImage];
    }

    if (_finishAction) {
        _finishAction(image);
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    imagePickerInstance = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (_finishAction) {
        _finishAction(nil);
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    imagePickerInstance = nil;
}

@end
