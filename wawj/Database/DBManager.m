//
//  DBManager.m
//  SQList Test
//
//  Created by 焦庆峰 on 16/8/22.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import "DBManager.h"
@implementation DBManager
@synthesize database;
@synthesize databaseQueue;


static DBManager *defaultManager = nil;

+(DBManager *)defaultManager {
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        
        if (!defaultManager) {
            defaultManager = [[DBManager alloc]init];
        }
    });
    
    return defaultManager;
}

- (void)createTableWithName:(NSString *)tableName
                    AndKeys:(NSDictionary *)keys
                     Result:(void (^)(BOOL))result
                 FMDatabase:(void(^)(FMDatabase * database))dataBase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // 获取document目录
    NSString*documentDirectory = [paths objectAtIndex: 0];
    // 追加文件系统路径
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"wawj.sqlite"];
    
//    NSLog(@"dbPath__%@",dbPath);
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        self.database = db;
        
        NSArray *allkeys = [keys allKeys];
        NSMutableArray *values = [[NSMutableArray alloc] init];
        for (NSString *indexKey in allkeys) {
            NSString *indexStr = [[NSString alloc]initWithFormat:@"%@ %@",indexKey,keys[indexKey]];
            [values addObject:indexStr];
        }
        
        
        NSString *executeString = [NSString stringWithFormat:@"create table %@ (%@)",tableName,[values componentsJoinedByString:@","]];
        NSLog(@"executeString = %@",executeString);
        
        
        BOOL res =  [self.database executeUpdate:executeString];
        result(res);
        dataBase(db);
    }];

}

@end
