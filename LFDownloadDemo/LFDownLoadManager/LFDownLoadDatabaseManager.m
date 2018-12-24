//
//  LFDownLoadDatabaseManager.m
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/11/23.
//  Copyright © 2018年 hero. All rights reserved.
//

#import "LFDownLoadDatabaseManager.h"
#import "LFDownLoadModel.h"
#import <Realm/Realm.h>
#import "LFUtil.h"
typedef NS_ENUM(NSInteger, LFDBGetDateOption) {
    LFDBGetDateOptionAllCacheData = 0,      // 所有缓存数据
    LFDBGetDateOptionAllDownloadingData,    // 所有正在下载的数据
    LFDBGetDateOptionAllDownloadedData,     // 所有下载完成的数据
    LFDBGetDateOptionAllUnDownloadedData,   // 所有未下载完成的数据
    LFDBGetDateOptionAllWaitingData,        // 所有等待下载的数据
    LFDBGetDateOptionModelWithUrl,          // 通过url获取单条数据
    LFDBGetDateOptionWaitingModel,          // 第一条等待的数据
    LFDBGetDateOptionLastDownloadingModel,  // 最后一条正在下载的数据
};
static LFDownLoadDatabaseManager *mananer ;

@implementation LFDownLoadDatabaseManager

// 获取单例
+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        mananer = [[self alloc]init];
    });
    return mananer;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken1;
    dispatch_once(&onceToken1, ^{
        if (mananer == nil) {
            mananer = [super allocWithZone:zone];
        }
    });
    return mananer;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return mananer;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    return mananer;
}
// 插入数据
- (void)insertModel:(LFDownLoadModel *)model{
    RLMRealm *realm = [LFDataBase db];
    [realm transactionWithBlock:^{
        [realm addOrUpdateObject:model];
    }];
}
 // 根据url获取数据
- (LFDownLoadModel *)getModelWithUrl:(NSString *)url{
     return [self getModelWithOption:LFDBGetDateOptionModelWithUrl url:url];
}

// 获取第一条等待的数据
- (LFDownLoadModel *)getWaitingModel
{
    return [self getModelWithOption:LFDBGetDateOptionWaitingModel url:nil];
}

// 获取最后一条正在下载的数据
- (LFDownLoadModel *)getLastDownloadingModel
{
    return [self getModelWithOption:LFDBGetDateOptionLastDownloadingModel url:nil];
}

// 获取所有数据
- (NSArray<LFDownLoadModel *> *)getAllCacheData
{
    return [self getDateWithOption:LFDBGetDateOptionAllCacheData];
}

// 根据lastStateTime倒叙获取所有正在下载的数据
- (NSArray<LFDownLoadModel *> *)getAllDownloadingData
{
    return [self getDateWithOption:LFDBGetDateOptionAllDownloadingData];
}

// 获取所有下载完成的数据
- (NSArray<LFDownLoadModel *> *)getAllDownloadedData
{
    return [self getDateWithOption:LFDBGetDateOptionAllDownloadedData];
}

// 获取所有未下载完成的数据
- (NSArray<LFDownLoadModel *> *)getAllUnDownloadedData
{
    return [self getDateWithOption:LFDBGetDateOptionAllUnDownloadedData];
}
// 获取所有等待下载的数据
- (NSArray<LFDownLoadModel *> *)getAllWaitingData{
    return [self getDateWithOption:LFDBGetDateOptionAllWaitingData];
}

// 更新数据
- (void)updateWithModel:(LFDownLoadModel *)model option:(LFDBUpdateOption)option{
    RLMRealm *realm = [LFDataBase db];
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:model];
    [realm commitWriteTransaction];
}
// 获取单条数据
- (LFDownLoadModel *)getModelWithOption:(LFDBGetDateOption)option url:(NSString *)url
{
     LFDownLoadModel *model = nil;
    RLMResults<LFDownLoadModel *> *results;
    RLMRealm *real = [LFDataBase db];
    switch (option) {
        case LFDBGetDateOptionModelWithUrl:
            {
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"url = %@",url];
                results = [LFDownLoadModel objectsInRealm:real withPredicate:pred];
//                results = [LFDownLoadModel objectsInRealm:real where:@"url = 'https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4'"];
            }
            break;
            
        case LFDBGetDateOptionWaitingModel:
        {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"state = %d",LFDownloadStateWaiting];
            results =  [[LFDownLoadModel objectsInRealm:real withPredicate:pred ] sortedResultsUsingKeyPath:@"lastStateTime" ascending:YES];//递增
            
        }
            break;
            
        case LFDBGetDateOptionLastDownloadingModel:{
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"state = %d",LFDownloadStateDownloading];
            results =  [[LFDownLoadModel objectsInRealm:real withPredicate:pred] sortedResultsUsingKeyPath:@"lastStateTime" ascending:YES];
        }
            
            break;
            
        default:
            break;
    }
    
    if (results.count) {
        model = results.firstObject;
    }
    
    
    return model;
}

// 获取数据集合
- (NSArray<LFDownLoadModel *> *)getDateWithOption:(LFDBGetDateOption)option
{
    NSArray<LFDownLoadModel *> *array = nil;
    RLMResults <LFDownLoadModel *>* results;
    RLMRealm *realm = [LFDataBase db];
    switch (option) {
        case LFDBGetDateOptionAllCacheData:
            results = [LFDownLoadModel allObjectsInRealm:realm];
            break;
            
        case LFDBGetDateOptionAllDownloadingData:
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state = %d",LFDownloadStateDownloading];
            results = [[LFDownLoadModel objectsInRealm:realm withPredicate:predicate] sortedResultsUsingKeyPath:@"lastStateTime" ascending:NO];
        }
          
            break;
            
        case LFDBGetDateOptionAllDownloadedData:
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state = %d",LFDownloadStateFinish];
            results = [LFDownLoadModel objectsInRealm:realm withPredicate:predicate];
        }
            break;
            
        case LFDBGetDateOptionAllUnDownloadedData:
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state != %d",LFDownloadStateFinish];
            results = [LFDownLoadModel objectsInRealm:realm withPredicate:predicate];
        }
            break;
            
        case LFDBGetDateOptionAllWaitingData:
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state = %d",LFDownloadStateWaiting];
            results = [LFDownLoadModel objectsInRealm:realm withPredicate:predicate];
        }
            break;
            
        default:
            break;
    }
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    for (int i = 0; i<results.count; i++) {
        LFDownLoadModel *model = [results objectAtIndex:i];
        [tmpArr addObject:model];
    }
    array = tmpArr;
    
    return array;
}
//执行block数据 事务提交
-(void)transactionWithBlock:(void (^)(void))block
{
    RLMRealm *realm = [LFDataBase db];
    [realm transactionWithBlock:^{
        block();
    }];
}
// 删除数据
- (void)deleteModelWithUrl:(NSString *)url{
    RLMRealm *realm = [LFDataBase db];
    LFDownLoadModel *model = [LFDownLoadModel objectForPrimaryKey:url];
    [realm beginWriteTransaction];
    [realm deleteObject:model];
    [realm commitWriteTransaction];
}
@end
