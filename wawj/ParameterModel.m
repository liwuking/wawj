//
//  ParameterModel.m
//  wawj
//
//  Created by ruiyou on 2017/9/6.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "ParameterModel.h"
@implementation ParameterModel

+(NSDictionary *)formatteNetParameterWithapiCode:(NSString *)apiCode andModel:(NSDictionary *)model {
    
//    {
//        "app": "WAWJ",
//        "apiCode": "P1001",
//        "version": "1.0.0",
//        "time": "1501220194",
//        "userId": "6688",
//        "platform": "iOS",
//        "model": {
//            
//        }
//    }
    
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    NSString *userID = userInfo? userInfo[@"userId"] : @"";
    NSString *timeStamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970]*1000)/1000];
    
    NSDictionary *params = @{@"app":      @"WAWJ",
                             @"apiCode":  apiCode,
                             @"version":  APP_VERSION,
                             @"time":     timeStamp,
                             @"userId":   userID,
                             @"platform": @"iOS",
                             @"model":     model ? model: @""};
    return @{@"data":[NSDictionary convertToJSONData:params]};
}

@end
