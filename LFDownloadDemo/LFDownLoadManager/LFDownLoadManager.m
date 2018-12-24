//
//  LFDownLoadManager.m
//  HWDownloadDemo
//
//  Created by 王鹭飞 on 2018/11/23.
//  Copyright © 2018年 hero. All rights reserved.
//

#import "LFDownLoadManager.h"
#import "LFConst.h"
#import "LFDownLoadDatabaseManager.h"
#import "LFDownLoadModel.h"
#import "AFNetworkReachabilityManager.h"
#import "NSURLSession+CorrectedResumeData.h"
#import "LFUtil.h"
#import "LFNetworkReachabilityManager.h"
#import <Realm.h>
#import "LFNetworkReachabilityManager.h"
#import "AppDelegate.h"
@interface LFDownLoadManager()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>
// NSURLSession
@property (nonatomic, strong) NSURLSession *session;
// 同时下载多个文件，需要创建多个NSURLSessionDownloadTask，用该字典来存储
@property (nonatomic, strong) NSMutableDictionary *dataTaskDic;
// 当前正在下载的个数
@property (nonatomic, assign) NSInteger currentCount;
// 最大同时下载数量
@property (nonatomic, assign) NSInteger maxConcurrentCount;
// 是否允许蜂窝网络下载
@property (nonatomic, assign) BOOL allowsCellularAccess;
//数据库数据改变的通知
@property (nonatomic,strong)RLMNotificationToken *token;
//存储下载数据的路径
@property (copy, nonatomic) NSString *directoryDataStr;
@end

@implementation LFDownLoadManager
//下载的数据都放在这里面
-(NSString *)directoryDataStr
{
    if (_directoryDataStr) {
        _directoryDataStr = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"LFDownloadData"];
    }
    return _directoryDataStr;
}
+(instancetype)manager{
    static dispatch_once_t onceToken;
    static LFDownLoadManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}
-(instancetype)init{
    if (self = [super init]) {
        _currentCount = 0;
        _maxConcurrentCount = 4;
        _allowsCellularAccess = [[NSUserDefaults standardUserDefaults] boolForKey:LFDownloadAllowsCellularAccessKey];
        _dataTaskDic = [NSMutableDictionary dictionary];
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        queue.maxConcurrentOperationCount = 1;
        NSURLSessionConfiguration *sectionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"LFDownloadBackgroundSessionIdentifier"];
        sectionConfiguration.allowsCellularAccess = YES;
        //若不指定queue 则系统默认为全局并发队列。
        _session = [NSURLSession sessionWithConfiguration:sectionConfiguration delegate:self delegateQueue:queue];
        
        // 最大下载并发数变更通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadMaxConcurrentCountChange:) name:LFDownloadMaxConcurrentCountChangeNotification object:nil];
        // 是否允许蜂窝网络下载改变通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadAllowsCellularAccessChange:) name:LFDownloadAllowsCellularAccessChangeNotification object:nil];
        // 网路改变通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkingReachabilityDidChange:) name:LFNetworkingReachabilityDidChangeNotification object:nil];
        _token = [[LFDownLoadModel allObjects] addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
            NSLog(@"%@",results.firstObject);
        }];
    }
    return self;
}
//开始下载任务
-(void)startDownLoadTask:(LFDownLoadModel *)model{
    LFDownLoadModel *downLoadModel = [[LFDownLoadDatabaseManager shareManager] getModelWithUrl:model.url];
    if (!downLoadModel) {
        downLoadModel = model;
        [downLoadModel localDownloadPath];
        [downLoadModel localResumeDataPath];
        [[LFDownLoadDatabaseManager shareManager] insertModel:downLoadModel];
    }
    [[LFDownLoadDatabaseManager shareManager] transactionWithBlock:^{
        downLoadModel.state = LFDownloadStateWaiting;
        model.lastStateTime = (int)[LFUtil getTimeStampWithDate:[NSDate date]];
    }];
    if (_currentCount<_maxConcurrentCount && [self networkingAllowsDownloadTask]) {
        [self downloadWithModel:downLoadModel];
    }
}

-(void)downloadWithModel:(LFDownLoadModel *)model{
    [[LFDownLoadDatabaseManager shareManager] transactionWithBlock:^{
         model.state = LFDownloadStateDownloading;
    }];
    _currentCount ++;
    NSURLSessionDownloadTask *downTask ;
    NSError *error = nil;
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
   BOOL ise = [[NSFileManager defaultManager] fileExistsAtPath:[[LFUtil downloadResumeDataDirectory] stringByAppendingPathComponent:model.resumeDataPath]];
    if (ise) {
        NSLog(@"%@",model.resumeDataPath);
    }
    NSData *resumeData = [NSData dataWithContentsOfFile:[[LFUtil downloadResumeDataDirectory] stringByAppendingPathComponent:model.resumeDataPath] options:NSDataReadingMappedIfSafe error:&error];
    if (resumeData) {
        if (version >10.0 && version<10.2) {
            downTask = [_session downloadTaskWithCorrectResumeData:resumeData];
        }else{
            downTask = [_session downloadTaskWithResumeData:resumeData];
        }
    }else{
        downTask = [_session downloadTaskWithURL:[NSURL URLWithString:model.url]];
    }
    //添加描述的标签 这里作为传值使用
    downTask.taskDescription = model.url;
    _dataTaskDic[model.url] = downTask;
    //开始下载
    [downTask resume];
    
}
-(BOOL)networkingAllowsDownloadTask{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager manager];
    AFNetworkReachabilityStatus status =  manager.networkReachabilityStatus;
    if (status == AFNetworkReachabilityStatusNotReachable ||(status == AFNetworkReachabilityStatusReachableViaWWAN && !_allowsCellularAccess)) {
        return NO ;
    }
    return YES;
}
//暂停下载任务
-(void)pauseDownLoadTast:(LFDownLoadModel *)model{
    LFDownLoadModel *downModel = [[LFDownLoadDatabaseManager shareManager] getModelWithUrl:model.url];
    if (downModel) {
        
        LFDownLoadModel *tempModel = [[LFDownLoadModel alloc]initWith:downModel];
        [self cancelTaskWithModel:tempModel delete:NO];
        [[LFDownLoadDatabaseManager shareManager] transactionWithBlock:^{
            downModel.state = LFDownloadStatePaused;
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:LFDownloadStateChangeNotification object:downModel];
    }
    
    
}
//删除任务及本地缓存
-(void)deleteTastAndCache:(LFDownLoadModel *)model{
    //取消正在下载的任务
    [self cancelTaskWithModel:model delete:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSFileManager defaultManager] removeItemAtPath:model.localPath error:nil];
        [[LFDownLoadDatabaseManager shareManager] deleteModelWithUrl:model.url];
    });
}
//取消任务
- (void)cancelTaskWithModel:(LFDownLoadModel *)model delete:(BOOL)delete{
    if(model.state == LFDownloadStateDownloading){
        NSURLSessionDownloadTask *task = self.dataTaskDic[model.url];
        __weak __typeof(self) weakself = self;
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            __strong __typeof(self) self = weakself ;
            model.resumeData = resumeData;
//            LFDownLoadModel *writeModel = [[LFDownLoadModel alloc]initWith:model];
            [model writeDataToLocalPath:resumeData];
            
//            });
            if (self.currentCount) {
                self.currentCount--;
            }
             // 开启等待下载的其他任务
            [self startDownloadWaitingTask];
        }];
        
    }
    // 移除字典存储的对象
    if (delete) [_dataTaskDic removeObjectForKey:model.url];
}
//重启下载任务
- (void)openDownloadTask
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startDownloadWaitingTask];
    });
}
// 开启等待下载的其他任务
- (void)startDownloadWaitingTask{
    if (_currentCount<_maxConcurrentCount &&[self networkingAllowsDownloadTask]) {
         // 获取下一条等待的数据
        LFDownLoadModel *model = [[LFDownLoadDatabaseManager shareManager] getWaitingModel];
        if (model) {
            [self downloadWithModel:model];
            //查询后续所有符合条件的等待下载的任务
            [self startDownloadWaitingTask];
        }
    }
}
// 下载时，杀死进程，更新所有正在下载的任务为等待
- (void)updateDownloadingTaskState{
    NSArray<LFDownLoadModel *> *downloadingArray = [[LFDownLoadDatabaseManager shareManager] getAllDownloadingData];
    [[LFDownLoadDatabaseManager shareManager] transactionWithBlock:^{
        [downloadingArray enumerateObjectsUsingBlock:^(LFDownLoadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.state = LFDownloadStateWaiting;
        }];
    }];
    
}
// 停止正在下载任务为等待状态
-(void)pauseDownloadingTaskWithAll:(BOOL)all{
    NSArray<LFDownLoadModel *> *downloads = [[LFDownLoadDatabaseManager shareManager] getAllDownloadingData];
    NSInteger count = all?downloads.count:downloads.count-_maxConcurrentCount;
    for (int i = 0; i<count; i++) {
        LFDownLoadModel *model = downloads[i];
        [self cancelTaskWithModel:model delete:NO];
        [[LFDownLoadDatabaseManager shareManager] transactionWithBlock:^{
             model.state = LFDownloadStateWaiting;
        }];
    }
}
//最大同时下载数量变化
-(void)downloadMaxConcurrentCountChange:(NSNotification *)nofity{
    _maxConcurrentCount = [nofity.object integerValue];
    if (_currentCount<_maxConcurrentCount) {
        [self startDownloadWaitingTask];
    }
    if (_currentCount>_maxConcurrentCount) {
        [self pauseDownloadingTaskWithAll:NO];
    }
}

//是否可以蜂窝下载
-(void)downloadAllowsCellularAccessChange:(NSNotification *)nofity{
    _allowsCellularAccess = [nofity.object boolValue];
    [self allowsCellularAccessOrNetworkingReachabilityDidChangeAction];
}
//网络情况变更
-(void)networkingReachabilityDidChange:(NSNotification *)nofity{
    [self allowsCellularAccessOrNetworkingReachabilityDidChangeAction];
}
// 是否允许蜂窝网络下载或网络状态变更事件
- (void)allowsCellularAccessOrNetworkingReachabilityDidChangeAction
{
    if ([[LFNetworkReachabilityManager shareManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
        // 无网络，暂停正在下载任务
        [self pauseDownloadingTaskWithAll:YES];
        
    }else {
        if ([self networkingAllowsDownloadTask]) {
            // 开启等待任务
            [self startDownloadWaitingTask];
            
        }else {
            // 增加一个友善的提示，蜂窝网络情况下如果有正在下载，提示已暂停
            if ([[LFDownLoadDatabaseManager shareManager] getLastDownloadingModel]) {
               NSLog(@"当前为蜂窝网络，已停止下载任务，可在设置中开启") ;
            }
            
            // 当前为蜂窝网络，不允许下载，暂停正在下载任务
            [self pauseDownloadingTaskWithAll:YES];
        }
    }
}
#pragma mark - NSURLSessionDownloadDelegate
// 接收到服务器返回数据，会被调用多次
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    LFDownLoadModel *downloadModel = [[LFDownLoadDatabaseManager shareManager] getModelWithUrl:downloadTask.taskDescription];
    NSAssert(downloadModel!=nil, @"数据库里面没有该下载项");
    [[LFDownLoadDatabaseManager shareManager] transactionWithBlock:^{
        //当前x下载数据大小
        downloadModel.tmpFileSize = totalBytesWritten;
        //   数据总大小
        downloadModel.totalFileSize = totalBytesExpectedToWrite;
        // 计算速度时间内下载文件的大小
        downloadModel.intervalFileSize += bytesWritten;
        
        NSInteger intervals = [LFUtil getIntervalsWithTimeStamp:downloadModel.lastSpeedTime];
        if (intervals>1) {
            // 计算速度
            downloadModel.speed = downloadModel.intervalFileSize / intervals;
            
            // 重置变量
            downloadModel.intervalFileSize = 0;
            downloadModel.lastSpeedTime = [LFUtil getTimeStampWithDate:[NSDate date]];
        }
        downloadModel.progress = 1.0 * downloadModel.tmpFileSize/downloadModel.totalFileSize;
    }];
     LFDownLoadModel *model = [[LFDownLoadModel alloc]initWith:downloadModel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LFDownloadProgressNotification object:model];
    });
    
}
/*
   urisession 的下载文件的方式为 下载中的数据会先缓存到temp下面 CFNetworkDownload_aoWRyU.tmp，完成后系统会自动把数据保存到Library/Caches/com.apple.nsurlsessiond/Downloads CFNetworkDownload_aoWRyU.tmp下面 即此时的location 然后我们再将文件转移到自己定义的文件中
 */
//下载完成
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    
    LFDownLoadModel *model = [[LFDownLoadDatabaseManager shareManager] getModelWithUrl:downloadTask.taskDescription];
    NSError*error = nil;
    //location    NSURL *    @"file:///Users/wanglufei/Library/Developer/CoreSimulator/Devices/EE58BB00-B9B5-4286-BAC7-D3AB0B3167D1/data/Containers/Data/Application/9F99D667-E002-4A23-81FE-D0FA43B4C0A2/Library/Caches/com.apple.nsurlsessiond/Downloads/cn.gr.LFDownloadDemo/CFNetworkDownload_Y0yyNr.tmp"    0x00006000029dcfc0
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:[[LFUtil downloadPathDirectory] stringByAppendingPathComponent:model.localPath ] error:&error];
    [[NSNotificationCenter defaultCenter] postNotificationName:LFDownloadStateChangeNotification object:model];
    [[LFDownLoadDatabaseManager shareManager] transactionWithBlock:^{
        model.state = LFDownloadStateFinish;
    }];
    
}
#pragma mark - NSURLSessionTaskDelegate
//请求完成
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error && [error.localizedDescription isEqualToString:@"cancelled"]) {
        return;
    }
    LFDownLoadModel *model = [[LFDownLoadDatabaseManager shareManager] getModelWithUrl:task.taskDescription];
    // 下载时，进程杀死，重新启动，回调错误
    if (error && [error.userInfo objectForKey:NSURLErrorBackgroundTaskCancelledReasonKey]) {
        [[LFDownLoadDatabaseManager shareManager] transactionWithBlock:^{
            model.state = LFDownloadStateWaiting;
        }];
        
        model.resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        [model writeDataToLocalPath:model.resumeData];
        return ;
    }
    if (error) {
        [[LFDownLoadDatabaseManager shareManager] transactionWithBlock:^{
            model.state = LFDownloadStateError;
        }];
        model.resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        [model writeDataToLocalPath:model.resumeData];
        return ;
    }else{
        [[LFDownLoadDatabaseManager shareManager] transactionWithBlock:^{
            model.state = LFDownloadStateFinish;
        }];
        
    }
    if (_currentCount) {
        _currentCount--;
        [self.dataTaskDic removeObjectForKey:model.url];
    }
    [self startDownloadWaitingTask];
    NSLog(@"\n    文件：%@，下载完成 \n    本地路径：%@ \n    错误：%@ \n", model.fileName, model.localPath, error);
    
}
#pragma mark - NSURLSessionDelegate
// 应用处于后台，所有下载任务完成及NSURLSession协议调用之后调用

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (delegate.backgroundSessionCompletionHandler) {
            void(^completionHandler)(void) = delegate.backgroundSessionCompletionHandler;
            delegate.backgroundSessionCompletionHandler = nil;
            completionHandler();
        }
    });
}
- (void)dealloc
{
    [_session invalidateAndCancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
