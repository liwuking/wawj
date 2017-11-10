
#import <UIKit/UIKit.h>
#import "RemindItem.h"

typedef void(^RemindViewControllerWithAddRemind)(RemindItem *remindItem);


@interface RemindViewController : UIViewController

@property (nonatomic , strong)RemindViewControllerWithAddRemind   remindViewControllerWithAddRemind;


@end
