

#import <Foundation/Foundation.h>

@interface NSTimer (Extension)

+ (NSTimer *)ew_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)(void))block
                                       repeats:(BOOL)repeats;

@end
