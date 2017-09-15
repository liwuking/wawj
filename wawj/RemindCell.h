//
//  RemindCell.h
//  aFanJia
//
//  Created by 焦庆峰 on 2016/12/7.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RemindCellDelegate;
@interface RemindCell : UITableViewCell
{
    
    IBOutlet UIView *_cellBgView;
    
}
@property (assign, nonatomic) id<RemindCellDelegate>delegate;
@property (strong, nonatomic) IBOutlet UILabel *eventLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (assign, nonatomic) NSIndexPath *cellIndexPath;
@end

@protocol RemindCellDelegate <NSObject>

- (void)tableViewCell:(UITableViewCell *)cell AndIndexPath:(NSIndexPath*)indexPath;
@end
