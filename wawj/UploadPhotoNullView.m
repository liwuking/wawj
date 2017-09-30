//
//  UploadPhotoNullView.m
//  wawj
//
//  Created by ruiyou on 2017/9/30.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "UploadPhotoNullView.h"

@implementation UploadPhotoNullView
- (IBAction)clickUploadPhotoBtn:(UIButton *)sender {
    
    [self.delegate waUploadPhotoNullViewWithClickUploadNewPhotos];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
