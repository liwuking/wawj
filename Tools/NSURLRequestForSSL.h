//
//  NSURLRequestForSSL.h
//  unionlife
//
//  Created by 曾勇兵 on 15/9/30.
//  Copyright © 2015年 allinfinance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest(ForSSL)

+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;

+(void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;

@end
