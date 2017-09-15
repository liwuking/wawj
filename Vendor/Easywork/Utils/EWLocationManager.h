

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#define  CCLastLongitude @"CCLastLongitude"
#define  CCLastLatitude  @"CCLastLatitude"
#define  CCLastCity      @"CCLastCity"
#define  CCLastAddress   @"CCLastAddress"

typedef void (^LocationBlock)(CLLocationCoordinate2D locationCorrrdinate);
typedef void (^LocationErrorBlock)(NSError *error);
typedef void (^NSStringBlock)(NSString *cityString);
typedef void (^NSStringBlock)(NSString *addressString);


@interface EWLocationManager : NSObject<CLLocationManagerDelegate>
@property (nonatomic) CLLocationCoordinate2D lastCoordinate;
@property (nonatomic, strong) NSString *lastCity;
@property (nonatomic, strong) NSString *lastAddress;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;

+ (EWLocationManager *)shareLocation;

/**
 *  获取坐标
 */
- (void) getLocationCoordinate:(LocationBlock) locaiontBlock ;

/**
 *  获取坐标和详细地址
 */
- (void) getLocationCoordinate:(LocationBlock) locaiontBlock  withAddress:(NSStringBlock) addressBlock;

/**
 *  获取详细地址
 */
- (void) getAddress:(NSStringBlock)addressBlock;

/**
 *  获取城市
 */
- (void) getCity:(NSStringBlock)cityBlock;

@end
