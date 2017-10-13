

#import <UIKit/UIKit.h>

@protocol RemindCellDelegate <NSObject>

- (void)RemindCell:(UITableViewCell *)cell AndIndexPath:(NSIndexPath*)indexPath;
@end


@interface RemindCell : UITableViewCell


@property (assign, nonatomic) id<RemindCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel *contentLab;
@property (strong, nonatomic) IBOutlet UILabel *remindTimeLab;
@property (strong, nonatomic) IBOutlet UILabel *remindDateLab;
@property (assign, nonatomic) NSIndexPath *cellIndexPath;


@end


