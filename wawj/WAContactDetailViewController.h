//
//  WAContactDetailViewController.h
//  wawj
//
//  Created by ruiyou on 2017/11/1.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactItem.h"

typedef void (^WAContactDetailChange) (ContactItem *contactItem);
typedef void (^WAContactDetailDel) (ContactItem *contactItem);


@interface WAContactDetailViewController : UIViewController
@property(nonatomic,strong)ContactItem *contactItem;
@property(nonatomic,copy)WAContactDetailChange waContactDetailChange;
@property(nonatomic,copy)WAContactDetailDel waContactDetailDel;

@end
