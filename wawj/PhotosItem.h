//
//  PhotosItem.h
//  wawj
//
//  Created by ruiyou on 2017/9/20.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotosItem : NSObject

@property(nonatomic, strong)NSString *albumId;
@property(nonatomic, strong)NSString *albumStyle;
@property(nonatomic, strong)NSString *author;
@property(nonatomic, strong)NSString *coverUrl;
@property(nonatomic, strong)NSString *nums;
@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *updateTime;
@property(nonatomic, assign)BOOL isNew;
@property(nonatomic, assign)BOOL isSelf;

@end
