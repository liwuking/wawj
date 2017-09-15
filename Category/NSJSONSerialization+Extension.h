

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (Extension)

/** Json format an array */
+ (NSString *)ew_jsonStringFromArray:(NSArray *)array;

/** Json format a dictionary */
+ (NSString *)ew_jsonStringFromDictionary:(NSDictionary *)dictionary;

/** Json format an  object(nsarray or nsdictionary) */
+ (NSString*)ew_jsonStringFromObject:(id)object;


@end
