//
//  WANewPhotosViewController.h
//  wawj
//
//  Created by ruiyou on 2017/9/18.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotosItem.h"

@protocol WANewPhotosViewControllerDelegate <NSObject>

//-(void)waNewPhotosViewControllerWithAlbumId:(NSString *)albumId;
-(void)waNewPhotosViewControllerWithNewPhotosAlbumId:(NSString *)albumId AndTitle:(NSString *)title ;

@optional
-(void)waNewPhotosViewControllerWithAlbumId:(NSString *)albumId AndRefreshTitle:(NSString *)title ;

@end

@interface WANewPhotosViewController : UIViewController

@property(nonatomic, weak)id<WANewPhotosViewControllerDelegate> delegate;

@property(nonatomic, strong)PhotosItem *photosItem;
@property(nonatomic, strong)NSString *albumId;



@end
