//
//  LFDownLoadDatabaseManager.h
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/11/23.
//  Copyright © 2018年 hero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFDataBase.h"
@class LFDownLoadModel;
typedef NS_OPTIONS(NSUInteger, LFDBUpdateOption) {
    LFDBUpdateOptionState         = 1 << 0,  // 更新状态
    LFDBUpdateOptionLastStateTime = 1 << 1,  // 更新状态最后改变的时间
    LFDBUpdateOptionResumeData    = 1 << 2,  // 更新下载的数据
    LFDBUpdateOptionProgressData  = 1 << 3,  // 更新进度数据（包含tmpFileSize、totalFileSize、progress、intervalFileSize、lastSpeedTime）
    LFDBUpdateOptionAllParam      = 1 << 4   // 更新全部数据
};
@interface LFDownLoadDatabaseManager : NSObject
// 获取单例
+ (instancetype)shareManager;

// 插入数据
- (void)insertModel:(LFDownLoadModel *)model;

// 获取数据
- (LFDownLoadModel *)getModelWithUrl:(NSString *)url;    // 根据url获取数据
- (LFDownLoadModel *)getWaitingModel;                    // 获取第一条等待的数据
- (LFDownLoadModel *)getLastDownloadingModel;            // 获取最后一条正在下载的数据
- (NSArray<LFDownLoadModel *> *)getAllCacheData;         // 获取所有数据
- (NSArray<LFDownLoadModel *> *)getAllDownloadingData;   // 根据lastStateTime倒叙获取所有正在下载的数据
- (NSArray<LFDownLoadModel *> *)getAllDownloadedData;    // 获取所有下载完成的数据
- (NSArray<LFDownLoadModel *> *)getAllUnDownloadedData;  // 获取所有未下载完成的数据（包含正在下载、等待、暂停、错误）
- (NSArray<LFDownLoadModel *> *)getAllWaitingData;       // 获取所有等待下载的数据

// 更新数据
- (void)updateWithModel:(LFDownLoadModel *)model option:(LFDBUpdateOption)option;

// 删除数据
- (void)deleteModelWithUrl:(NSString *)url;

////执行block数据 事务提交
- (void)transactionWithBlock:(void(^)(void))block;
@end

