//
//  AppItem.h
//  wawj
//
//  Created by ruiyou on 2017/10/27.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppItem : NSObject

@property(nonatomic, strong)NSString *appDownloadUrl;
@property(nonatomic, strong)NSString *appIcoUrl;
@property(nonatomic, strong)NSString *appName;
@property(nonatomic, strong)NSString *channel;
@property(nonatomic, strong)NSString *createTime;
@property(nonatomic, strong)NSString *mId;
@property(nonatomic, assign)BOOL isAdd;

@end
