
#import <UIKit/UIKit.h>
#import "RemindItem.h"

typedef void(^RemindViewControllerWithRefreshRemind)(RemindItem *remindItem);


@interface RemindViewController : UIViewController

@property (nonatomic , strong)RemindViewControllerWithRefreshRemind   remindViewControllerWithRefreshRemind;


@end
