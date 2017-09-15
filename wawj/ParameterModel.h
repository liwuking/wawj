//
//  ParameterModel.h
//  wawj
//
//  Created by ruiyou on 2017/9/6.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParameterModel : NSObject

+(NSDictionary *)formatteNetParameterWithapiCode:(NSString *)apiCode andModel:(NSDictionary *)model;
@end
