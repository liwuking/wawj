//
//  LameTool.h
//  wawj
//
//  Created by ruiyou on 2017/11/14.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^LameToolWithSourcePath)(NSString *sourcePath);

@interface LameTool : NSObject
+ (NSString *)audioToMP3: (NSString *)sourcePath isDeleteSourchFile: (BOOL)isDelete andSourcePath:(LameToolWithSourcePath)sourthPath;

@end
