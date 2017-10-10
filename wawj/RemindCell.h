

#import <UIKit/UIKit.h>

@protocol RemindCellDelegate <NSObject>

- (void)tableViewCell:(UITableViewCell *)cell AndIndexPath:(NSIndexPath*)indexPath;
@end


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


