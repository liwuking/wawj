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

-(void)waNewPhotosViewControllerWithAlbumId:(NSString *)albumId;
-(void)waPhotosUploadViewController:(WAPhotosUploadViewController *)vc andEditName:(NSString *)albumName;

@end

@interface WAPhotosUploadViewController : UIViewController

@property(nonatomic, strong)PhotosItem *photosItem;
@property(nonatomic, weak)id<WAPhotosUploadViewControllerDelegate> delegate;
@end
