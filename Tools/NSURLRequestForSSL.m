//
//  NSURLRequestForSSL.m
//  unionlife
//
//  Created by 曾勇兵 on 15/9/30.
//  Copyright © 2015年 allinfinance. All rights reserved.
//

#import "NSURLRequestForSSL.h"

@implementation NSURLRequest(ForSSL)
+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    return YES;
}

+(void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host
{
    
}
@end
