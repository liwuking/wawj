

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^SelectBlock)(BOOL selected);

@interface EWPhotoViewer : NSObject

+(instancetype)instance;

- (void)showImage:(UIImage *)image imageURL:(NSString *)imageURL isShow:(BOOL)isShow block:(SelectBlock)block;

- (void)showImages:(NSArray *)images index:(NSInteger)index block:(SelectBlock)block;

@end
