

#import <Foundation/Foundation.h>

@interface EWModelParse : NSObject<NSCoding>

/* init instance with dic */
- (instancetype)initWithData:(NSDictionary *)data;

/* attribute map dic, subclasses override this method */
- (NSDictionary *)attributeMapDictionary;

/* print data info */
- (NSString *)description;

/* class archive */
- (NSData *)getArchiveData;

@end
