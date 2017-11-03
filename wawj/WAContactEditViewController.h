//
//  WAContactEditViewController.h
//  wawj
//
//  Created by ruiyou on 2017/11/1.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactItem.h"

typedef NS_ENUM(NSInteger, WAContactEditType) {
    WAContactEditAdd,
    WAContactEditEdit
};

typedef void (^WAContactEditAddChange) (ContactItem *contactItem);
typedef void (^WAContactEditChange) (ContactItem *contactItem);
typedef void (^WAContactDelChange) (ContactItem *contactItem);

@interface WAContactEditViewController : UIViewController
@property(nonatomic,strong)ContactItem *contactItem;
@property(nonatomic,copy)WAContactEditChange waContactEditChange;
@property(nonatomic,copy)WAContactDelChange waContactDelChange;
@property(nonatomic,copy)WAContactEditAddChange waContactEditAddChange;

@property(nonatomic,assign)WAContactEditType waContactEditType;

@end
