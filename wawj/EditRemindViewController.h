//
//  EditRemindViewController.h
//  wawj
//
//  Created by ruiyou on 2017/10/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FMDatabase.h"

typedef enum : NSUInteger{
    NRemind = 0,
    EdRemind,
    ExpRemind,
} RemindEventType;

//typedef enum : NSUInteger{
//    RemindOnce = 0,
//    RemindEveryDay,
//    RemindWeekend,
//    RemindWorkDay
//} RemindType;


@interface EditRemindViewController : UIViewController

@property (nonatomic , assign)RemindEventType  eventType;
@property (nonatomic , strong)FMDatabase         *database;
@property (nonatomic , strong)NSDictionary       *editDataDic;

@end
