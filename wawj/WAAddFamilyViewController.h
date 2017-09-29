//
//  WAAddFamilyViewController.h
//  wawj
//
//  Created by ruiyou on 2017/9/7.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CloseFamilyItem.h"

@protocol WAAddFamilyViewControllerDelegate <NSObject>

//-(void)waAddFamilyViewControllerWithFamilyItem:(CloseFamilyItem *)item;

@end

@interface WAAddFamilyViewController : UIViewController

@property(nonatomic, weak)id<WAAddFamilyViewControllerDelegate> delegate;

@end
