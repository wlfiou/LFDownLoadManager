//
//  LFDataBase.m
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/18.
//  Copyright © 2018 王鹭飞. All rights reserved.
//

#import "LFDataBase.h"
#import "LFUtil.h"
@interface LFDataBase()

@end

@implementation LFDataBase
+(RLMRealmConfiguration *)config{
    static RLMRealmConfiguration *_config ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _config = [[RLMRealmConfiguration alloc]init];
        //path    NSPathStore2 *    @"/Users/wanglufei/Library/Developer/CoreSimulator/Devices/EE58BB00-B9B5-4286-BAC7-D3AB0B3167D1/data/Containers/Data/Application/7DD91664-498F-4B5E-8FBE-DD0DCA361F6D/Documents"    0x00007faf5540deb0
//        path    NSPathStore2 *    @"/Users/wanglufei/Library/Developer/CoreSimulator/Devices/EE58BB00-B9B5-4286-BAC7-D3AB0B3167D1/data/Containers/Data/Application/3114023D-0A3B-4085-AE08-499CDFC83AC5/Documents"    0x00007fae0bd0a530
        NSString *path = [LFUtil DocumentDirectory];
        _config.deleteRealmIfMigrationNeeded = YES;
        NSString *loadPath = [path stringByAppendingPathComponent:@"LFDownload"];
        BOOL isRE = [[NSFileManager defaultManager] fileExistsAtPath:loadPath];
        if (!isRE) {
            [[NSFileManager defaultManager] createDirectoryAtPath:loadPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *downloadDB = [loadPath stringByAppendingPathComponent:@"downloadDB.realm"];
        _config.fileURL = [NSURL URLWithString:downloadDB];
    });
   return _config ;
}
+(RLMRealm *)db{
    RLMRealm *realm = [RLMRealm realmWithConfiguration:self.config error:nil];
    return realm;
}
+ (void)dataBaseMigration {
    RLMRealmConfiguration *config = self.config;
    // 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果您之前从未设置过架构版本，那么这个版本号设置为 0）
    config.schemaVersion = 1;
    
    // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
            
        }
    };
    
    // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
//    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    // 现在我们已经告诉了 Realm 如何处理架构的变化，打开文件之后将会自动执行迁移
    [RLMRealm realmWithConfiguration:self.config error:nil];
    
}
+ (BOOL)dropRealmIfNeed {
    return [[NSFileManager defaultManager] removeItemAtPath:self.config.fileURL.path error:nil];
}
@end
