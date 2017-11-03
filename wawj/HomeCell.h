//
//  HomeCell.h
//  wawj
//
//  Created by ruiyou on 2017/9/13.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloseFamilyItem.h"

@interface HomeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *title;

@property (strong, nonatomic)  CloseFamilyItem *closeFamilyItem;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end
