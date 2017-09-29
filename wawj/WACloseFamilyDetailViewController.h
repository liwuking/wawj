//
//  WACloseFamilyDetailViewController.h
//  wawj
//
//  Created by ruiyou on 2017/9/19.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloseFamilyItem.h"

@protocol WACloseFamilyDetailViewControllerDelegate <NSObject>

-(void)waCloseFamilyDetailViewControllerRefreshIndex:(NSInteger)index;

@end

@interface WACloseFamilyDetailViewController : UIViewController

@property(nonatomic, weak)id<WACloseFamilyDetailViewControllerDelegate> delegate;

@property(nonatomic, strong)CloseFamilyItem *closeFamilyItem;
@end
