//
//  WAAddContactTableViewCell.h
//  wawj
//
//  Created by ruiyou on 2017/9/8.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplyItem.h"
@class WAAddContactTableViewCell;

@protocol WAAddContactTableViewCellDelegate <NSObject>

-(void)clickAddContactWithCell:(WAAddContactTableViewCell *)cell;

@end

@interface WAAddContactTableViewCell : UITableViewCell

@property(nonatomic, weak)id<WAAddContactTableViewCellDelegate> delegate;

@property(nonatomic, strong)ApplyItem *applyItem;

@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@end
