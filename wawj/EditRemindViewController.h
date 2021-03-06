//
//  EditRemindViewController.h
//  wawj
//
//  Created by ruiyou on 2017/10/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FMDatabase.h"
#import "RemindItem.h"

typedef enum : NSUInteger{
    NRemind,
    EdRemind,
    ExpRemind
} RemindEventType;





typedef void(^EditRemindViewControllerWithAddRemind)(RemindItem *remindItem);
typedef void(^EditRemindViewControllerWithEditRemind)(RemindItem *remindItem);
typedef void(^EditRemindViewControllerWithDelRemind)(RemindItem *remindItem);



@interface EditRemindViewController : UIViewController

@property(nonatomic,assign)BOOL isFromOver;
@property (nonatomic , assign)RemindEventType  eventType;
@property (nonatomic , strong)FMDatabase         *database;
@property (nonatomic , strong)RemindItem         *remindItem;

@property (nonatomic , strong)EditRemindViewControllerWithAddRemind         editRemindViewControllerWithAddRemind;
@property (nonatomic , strong)EditRemindViewControllerWithEditRemind        editRemindViewControllerWithEditRemind;
@property (nonatomic , strong)EditRemindViewControllerWithDelRemind         editRemindViewControllerWithDelRemind;

@end









