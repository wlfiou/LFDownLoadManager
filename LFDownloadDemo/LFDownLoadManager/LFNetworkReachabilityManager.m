//
//  LFNetworkReachabilityManager.m
//  HWDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/3.
//  Copyright © 2018 hero. All rights reserved.
//

#import "LFNetworkReachabilityManager.h"
#import "LFConst.h"
@interface LFNetworkReachabilityManager()
@property (nonatomic, assign, readwrite) AFNetworkReachabilityStatus networkReachabilityStatus;
@end

@implementation LFNetworkReachabilityManager
+ (instancetype)shareManager
{
    static LFNetworkReachabilityManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

// 监听网络状态
- (void)monitorNetworkStatus
{
    // 创建网络监听者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                // 未知网络
                NSLog(@"当前网络：未知网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                // 无网络
                NSLog(@"当前网络：无网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                // 蜂窝数据
                NSLog(@"当前网络：蜂窝数据");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                // 无线网络
                NSLog(@"当前网络：无线网络");
                break;
                
            default:
                break;
        }
        
        if (_networkReachabilityStatus != status) {
            _networkReachabilityStatus = status;
            // 网络改变通知
            [[NSNotificationCenter defaultCenter] postNotificationName:LFNetworkingReachabilityDidChangeNotification object:[NSNumber numberWithInteger:status]];
        }
    }];
    
    // 开始监听
    [manager startMonitoring];
}

@end
