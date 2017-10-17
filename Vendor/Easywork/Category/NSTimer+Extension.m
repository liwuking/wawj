

#import "NSTimer+Extension.h"

@implementation NSTimer (Extension)

+ (NSTimer *)ew_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(ew_blockInvoke:) userInfo:[block copy] repeats:repeats];
}

+ (void)ew_blockInvoke:(NSTimer *)timer
{
    void (^block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}

@end
