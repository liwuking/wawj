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


@protocol EditRemindViewControllerDelegate <NSObject>

@optional
-(void)editRemindViewControllerWithNewAddRemind;
-(void)editRemindViewControllerWithEditRemind;

@end



@interface EditRemindViewController : UIViewController

@property(nonatomic,weak) id<EditRemindViewControllerDelegate> delegate;

@property (nonatomic , assign)RemindEventType  eventType;
@property (nonatomic , strong)FMDatabase         *database;
@property (nonatomic , strong)RemindItem         *remindItem;

@end
