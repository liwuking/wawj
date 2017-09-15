

#import "UIAlertView+Extension.h"
#import <objc/runtime.h>

@implementation UIAlertView (Extension)
static char key;

- (void)showAlertWithBlock:(FinishBlock)block
{
    if (block) {
        
        objc_removeAssociatedObjects(self);
        
        objc_setAssociatedObject(self, &key, block, OBJC_ASSOCIATION_COPY);
        
        self.delegate = self;
    }
    
    [self show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    FinishBlock block = objc_getAssociatedObject(self, &key);
    
    if (block) {
        block(buttonIndex);
    }
}


@end
