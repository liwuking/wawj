//
//  OverdueRemindCell.h
//  wawj
//
//  Created by ruiyou on 2017/10/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OverdueRemindCell;

@protocol OverdueRemindCellDelegate <NSObject>

- (void)OverdueRemindCell:(OverdueRemindCell *)cell AndClickAudioIndexPath:(NSIndexPath*)indexPath;

@end


@interface OverdueRemindCell : UITableViewCell

@property (assign, nonatomic) id<OverdueRemindCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel *contentLab;
@property (strong, nonatomic) IBOutlet UILabel *remindTimeLab;
@property (strong, nonatomic) IBOutlet UILabel *remindDateLab;

@property (assign, nonatomic) NSIndexPath *cellIndexPath;


@end
