//
//  WAPhotosUploadViewController.h
//  wawj
//
//  Created by ruiyou on 2017/9/20.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotosItem.h"

@class WAPhotosUploadViewController;
@protocol WAPhotosUploadViewControllerDelegate <NSObject>

-(void)waNewPhotosViewControllerWithPhotosItem:(PhotosItem *)photosItem andRefreshPhotoNum:(NSInteger)photoNum;
-(void)waPhotosUploadViewController:(WAPhotosUploadViewController *)vc andRefreshName:(PhotosItem *)photosItem;

@end

@interface WAPhotosUploadViewController : UIViewController

@property(nonatomic, strong)PhotosItem *photosItem;
@property(nonatomic, weak)id<WAPhotosUploadViewControllerDelegate> delegate;
@end
