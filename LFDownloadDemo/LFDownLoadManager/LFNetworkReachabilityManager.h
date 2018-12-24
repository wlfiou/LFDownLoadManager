//
//  LFNetworkReachabilityManager.h
//  HWDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/3.
//  Copyright © 2018 hero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworkReachabilityManager.h>
NS_ASSUME_NONNULL_BEGIN

@interface LFNetworkReachabilityManager : NSObject
// 当前网络状态
@property (nonatomic, assign, readonly) AFNetworkReachabilityStatus networkReachabilityStatus;

// 获取单例
+ (instancetype)shareManager;

// 监听网络状态
- (void)monitorNetworkStatus;
@end

NS_ASSUME_NONNULL_END
