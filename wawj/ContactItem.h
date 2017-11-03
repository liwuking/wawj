//
//  ContactItem.h
//  wawj
//
//  Created by ruiyou on 2017/8/4.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactItem : NSObject

@property(nonatomic, strong)NSString *imageName;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSMutableArray <NSString *>*phoneArr;

@end
