//
//  NewRemindOrEditRmindViewController.h
//  aFanJia
//
//  Created by 焦庆峰 on 2016/12/12.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
typedef enum : NSUInteger{
    NewRemind = 0,
    EditRemind,
    ExpireRemind,
} CurrentRemindType;


typedef enum : NSUInteger{
    OpenAdvance = 0,
    CloseAdvance,
    EditEvent,
    EditEventAndAdvance,
    EditEventAndDate,
    EditDateAndAdvance,
    EditAll,
} EditRemindType;

@interface NewRemindOrEditRmindViewController : UIViewController
@property (nonatomic , assign)CurrentRemindType  type;
@property (nonatomic , strong)FMDatabase         *database;
@property (nonatomic , strong)NSDictionary       *editDataDic;
@end
