//
//  LFDownLoadManager.h
//  HWDownloadDemo
//
//  Created by 王鹭飞 on 2018/11/23.
//  Copyright © 2018年 hero. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LFDownLoadModel;

typedef NS_ENUM(NSInteger, LFDownloadState) {
    LFDownloadStateDefault = 0,  // 默认
    LFDownloadStateDownloading,  // 正在下载
    LFDownloadStateWaiting,      // 等待
    LFDownloadStatePaused,       // 暂停
    LFDownloadStateFinish,       // 完成
    LFDownloadStateError,        // 错误
};

@interface LFDownLoadManager : NSObject
+(instancetype)manager;
//开始下载任务
-(void)startDownLoadTask:(LFDownLoadModel *)model;
//暂停下载任务
-(void)pauseDownLoadTast:(LFDownLoadModel *)model;
//删除任务及本地缓存
-(void)deleteTastAndCache:(LFDownLoadModel *)model;

// 下载时，杀死进程，更新所有正在下载的任务为等待
- (void)updateDownloadingTaskState;
@end
