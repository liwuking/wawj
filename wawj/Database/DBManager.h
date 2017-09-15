//
//  DBManager.h
//  SQList Test
//
//  Created by 焦庆峰 on 16/8/22.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@interface DBManager : NSObject

// 用于数据操作的管理队列
@property (nonatomic, retain) FMDatabaseQueue *databaseQueue;

// 用于获取数据的数据库
@property (nonatomic, retain) FMDatabase *database;

// 获取默认的静态的局部类
+ (DBManager*)defaultManager;

// 创建表
// tableName:表名称
// keys:表中的字段 （key为字段名 ，value为字段类型）
// result:建表是否成功
- (void)createTableWithName:(NSString *)tableName
                    AndKeys:(NSDictionary *)keys
                     Result:(void(^)(BOOL isOK))result
                 FMDatabase:(void(^)(FMDatabase * database))dataBase;




@end
