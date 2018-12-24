//
//  LFDownloadBtn.h
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/11.
//  Copyright © 2018 王鹭飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFDownLoadManager/LFDownLoadModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFDownloadBtn : UIView
@property (nonatomic, strong) LFDownLoadModel *model;  // 数据模型
@property (nonatomic, assign) LFDownloadState state;   //状态
@property (nonatomic,assign)CGFloat progress;

-(void)addTarget:(id)target anction:(SEL)action;
@end
NS_ASSUME_NONNULL_END
