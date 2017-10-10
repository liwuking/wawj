//
//  OverdueRemindCell.h
//  wawj
//
//  Created by ruiyou on 2017/10/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OverdueRemindCellDelegate <NSObject>

- (void)tableViewCell:(UITableViewCell *)cell AndClickAudioIndexPath:(NSIndexPath*)indexPath;

@end


@interface OverdueRemindCell : UITableViewCell

@property (assign, nonatomic) id<OverdueRemindCellDelegate>delegate;

@property (strong, nonatomic) IBOutlet UILabel *eventLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (assign, nonatomic) NSIndexPath *cellIndexPath;

@end
