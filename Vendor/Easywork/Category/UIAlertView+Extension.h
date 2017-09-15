

#import <UIKit/UIKit.h>
typedef  void(^FinishBlock)(NSInteger buttonIndex);

@interface UIAlertView (Extension)

- (void)showAlertWithBlock:(FinishBlock)block;

@end
