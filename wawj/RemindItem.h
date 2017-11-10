//
//  RemindItem.h
//  wawj
//
//  Created by ruiyou on 2017/10/13.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemindItem : NSObject

@property(nonatomic, assign)BOOL isOverdue;


@property(nonatomic, strong)NSString *remindorigintype;

@property(nonatomic, strong)NSString *remindid;
@property(nonatomic, strong)NSString *headurl;
@property(nonatomic, strong)NSString *audiourl;
@property(nonatomic, strong)NSString *remindtype;
@property(nonatomic, strong)NSString *remindtime;
@property(nonatomic, strong)NSString *content;
@property(nonatomic, strong)NSString *createtimestamp;
@property(nonatomic, strong)NSString *remindDate;
@property(nonatomic, strong)NSDate *recentlyRemindDate;




@end
