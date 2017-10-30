//
//  WAAppTableViewCell.h
//  wawj
//
//  Created by ruiyou on 2017/10/27.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppItem.h"

typedef void(^WAAppTableViewCellWithAddApp)(AppItem *appItem);

@interface WAAppTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headImageUrl;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property(nonatomic, strong)AppItem *appItem;
@property(nonatomic,copy)WAAppTableViewCellWithAddApp wAAppTableViewCellWithAddApp;

@end
