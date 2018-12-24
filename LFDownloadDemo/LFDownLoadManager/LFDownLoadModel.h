//
//  LFDownLoadModel.h
//  HWDownloadDemo
//
//  Created by 王鹭飞 on 2018/11/23.
//  Copyright © 2018年 hero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFDownLoadManager.h"
#import <Realm/Realm.h>
@interface LFDownLoadModel : RLMObject<NSCopying>
@property  NSString *resumeDataPath;        //断点下载所需文件目录
@property  NSString *localPath;            // 下载完成路径
@property  NSString *vid;                  // 唯一id标识
@property  NSString *fileName;             // 文件名
@property  NSString *url;                  // url
@property  (nonatomic,strong)NSData *resumeData;           // 下载的数据
@property  float progress;             // 下载进度
@property  LFDownloadState state;        // 下载状态
@property  long totalFileSize;     // 文件总大小
@property  long tmpFileSize;       // 下载大小
@property  long speed;             // 下载速度
@property  long lastSpeedTime;     // 上次计算速度时的时间戳
@property  long intervalFileSize;  // 计算速度时间内下载文件的大小
@property  int lastStateTime;     // 记录任务加入准备下载的时间（点击默认、暂停、失败状态），用于计算开始、停止任务的先后顺序
@property(nonatomic,strong)NSOutputStream *outputStream;
-(instancetype)initVid:(NSString *)vid fileName:(NSString *)fileName url:(NSString *)url;
//realm的数据不能跨线程使用，解决办法是生成新的model
-(instancetype)initWith:(LFDownLoadModel *)model;
-(void)localDownloadPath;
-(void)localResumeDataPath;
-(void)openOutputStream;
-(void)closeOutputStream;
//j将下载的数据写进沙盒，为断点做准备
-(void)writeDataToLocalPath:(NSData *)resumeData;
@end
RLM_ARRAY_TYPE(LFDownLoadModel)
