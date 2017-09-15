

#import "EWModelParse.h"

#define IgnorPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@implementation EWModelParse

//init
- (instancetype)initWithData:(NSDictionary *)data
{
    if (self = [super init]) {
        [self setAttributes:data];
    }
    return self;
}



//setAttributes
- (void)setAttributes:(NSDictionary *)data
{
    if (![data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSDictionary *attrMapDic = [self attributeMapDictionary];
    
    if (attrMapDic == nil) {
        return;
    }
    
    [attrMapDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        SEL sel = [self getSetterSelWithAttributeName:key];
        
        if ([self respondsToSelector:sel]) {
            
            NSString *value = [NSString stringWithFormat:@"%@",data[obj]];
            IgnorPerformSelectorLeakWarning([self performSelectorOnMainThread:sel withObject:value waitUntilDone:YES]);
        }
        
    }];
    
}

//map attribute
- (NSDictionary *)attributeMapDictionary
{
    return nil;
}

//get sel name
- (SEL)getSetterSelWithAttributeName:(NSString *)attributeName
{
    NSString *capital = [[attributeName substringToIndex:1] uppercaseString];
    
	NSString *setterSelStr = [NSString stringWithFormat:@"set%@%@:",capital,[attributeName substringFromIndex:1]];
    
	return NSSelectorFromString(setterSelStr);
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if( self = [super init] ){
		NSDictionary *attrMapDic = [self attributeMapDictionary];
        
		if (attrMapDic == nil) {
			return self;
		}
        
        [attrMapDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            SEL sel = [self getSetterSelWithAttributeName:key];
            if ([self respondsToSelector:sel]) {
                id value = [aDecoder decodeObjectForKey:key];
                IgnorPerformSelectorLeakWarning([self performSelectorOnMainThread:sel withObject:value waitUntilDone:YES]);
                
            }
            
        }];
	}
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSDictionary *attrMapDic = [self attributeMapDictionary];
	if (attrMapDic == nil) {
		return;
	}
    
    [attrMapDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        SEL getSel = NSSelectorFromString(key);
        
        if ([self respondsToSelector:getSel]) {
            
            id value;
            IgnorPerformSelectorLeakWarning(value = [self performSelector:getSel]);
            
            if (value) {
                [aCoder encodeObject:value forKey:key];
            }
            
        }
    }];
    
}

- (NSData*)getArchiveData
{
	return [NSKeyedArchiver archivedDataWithRootObject:self];
}


- (NSString *)description
{
    NSMutableString *attrsDesc = [NSMutableString stringWithCapacity:100];
   
	NSDictionary *attrMapDic = [self attributeMapDictionary];
    
    [attrMapDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        SEL sel = NSSelectorFromString(key);
        
        if ([self respondsToSelector:sel]) {
            
            id value;
            IgnorPerformSelectorLeakWarning(value = [self performSelector:sel]);
            if (![value isEqualToString:@""]) {
                [attrsDesc appendFormat:@" [%@=%@] ",key,value];
            }else{
                [attrsDesc appendFormat:@" [%@=nil] ",key];
            }
        
        }
        
    }];

    return [NSString stringWithFormat:@"%@:{%@}",[self class],attrsDesc];
}


@end
