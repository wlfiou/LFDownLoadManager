//
//  LFConst.h
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/11/25.
//  Copyright © 2018年 hero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/************************* 下载 *************************/
UIKIT_EXTERN NSString * const LFDownloadProgressNotification;                   // 进度回调通知
UIKIT_EXTERN NSString * const LFDownloadStateChangeNotification;                // 状态改变通知
UIKIT_EXTERN NSString * const LFDownloadMaxConcurrentCountKey;                  // 最大同时下载数量key
UIKIT_EXTERN NSString * const LFDownloadMaxConcurrentCountChangeNotification;   // 最大同时下载数量改变通知
UIKIT_EXTERN NSString * const LFDownloadAllowsCellularAccessKey;                // 是否允许蜂窝网络下载key
UIKIT_EXTERN NSString * const LFDownloadAllowsCellularAccessChangeNotification; // 是否允许蜂窝网络下载改变通知

/************************* 网络 *************************/
UIKIT_EXTERN NSString * const LFNetworkingReachabilityDidChangeNotification;    // 网络改变改变通知
