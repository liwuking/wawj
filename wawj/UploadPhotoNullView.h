//
//  UploadPhotoNullView.h
//  wawj
//
//  Created by ruiyou on 2017/9/30.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WAUploadPhotoNullViewDelegate <NSObject>

-(void)waUploadPhotoNullViewWithClickUploadNewPhotos;

@end

@interface UploadPhotoNullView : UIView

@property(nonatomic, weak)id<WAUploadPhotoNullViewDelegate> delegate;

@end
