//
//  ExpiredRemindCell.h
//  aFanJia
//
//  Created by 焦庆峰 on 2016/12/12.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ExpiredRemindCellDelegate;
@interface ExpiredRemindCell : UITableViewCell
{
    IBOutlet UIView   *_cellBgView;
    IBOutlet UIButton *_deleteButton;
}
@property (assign, nonatomic) id<ExpiredRemindCellDelegate>delegate;
@property (strong, nonatomic) IBOutlet UILabel *eventLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (assign, nonatomic) NSIndexPath *cellIndexPath;
@end

@protocol ExpiredRemindCellDelegate <NSObject>

- (void)tableViewCell:(UITableViewCell *)cell AndIndexPath:(NSIndexPath*)indexPath;
@end
