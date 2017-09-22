//
//  WAPhotosShowViewController.h
//  wawj
//
//  Created by ruiyou on 2017/9/20.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItem.h"
@protocol WAPhotosShowViewControllerDelegate <NSObject>

-(void)waPhotosShowViewControllerWithDelPhotoIndex:(NSInteger)photoIndex;

@end

@interface WAPhotosShowViewController : UIViewController

@property(nonatomic,weak)id<WAPhotosShowViewControllerDelegate> delegate;

@property(nonatomic, strong)NSArray *photoItemArr;
@property(nonatomic, strong)NSString *photosTitle;
@property(nonatomic, assign)NSInteger photoIndex;

@end
