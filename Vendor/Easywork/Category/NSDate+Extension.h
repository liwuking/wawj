
#import <Foundation/Foundation.h>

@interface NSDate (Extension)

/** Time stamp */
+ (NSString *)ew_timeStamp;

/** current time - service time = ? */
+ (NSString *)ew_timeStringWithInterval:(NSTimeInterval) time;

/** time year-month-day */
+ (NSString *)ew_formatTimeWithInterval:(NSTimeInterval) time;

/** time year-month-dat hh mm*/
+ (NSString *)ew_formatAbsTimeWithInterval:(NSTimeInterval) time;

/**  */
- (NSDate *)ew_relativedDateWithInterval:(NSInteger)interval;

@end
