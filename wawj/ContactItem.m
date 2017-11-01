//
//  ContactItem.m
//  wawj
//
//  Created by ruiyou on 2017/8/4.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "ContactItem.h"

@implementation ContactItem

-(id)init {
    
    self = [super init];
    if (self) {
        _phoneArr = [@[] mutableCopy];
    }
    
    return self;
}

@end
