//
//  LFDownLoadModel.m
//  HWDownloadDemo
//
//  Created by 王鹭飞 on 2018/11/23.
//  Copyright © 2018年 hero. All rights reserved.
//

#import "LFDownLoadModel.h"
#import "LFUtil.h"
#import <objc/runtime.h>
@implementation LFDownLoadModel
-(instancetype)initWith:(LFDownLoadModel *)model{
    if (self = [super init]) {
        self = [model copy];
    }
    return self;
}
-(instancetype)initVid:(NSString *)vid fileName:(NSString *)fileName url:(NSString *)url{
    if (self = [super init]) {
        self.vid = vid;
        self.fileName = fileName;
        self.url = url;
    }
    return self;
}
+(NSString *)primaryKey{
    return @"url";
}
+ (NSArray *)ignoredProperties {
    return @[@"resumeData",@"outputStream"];
}

-(void)writeDataToLocalPath:(NSData *)resumeData{
    if (!_resumeDataPath) {
        [self localResumeDataPath];
    }
    //dirpath    NSPathStore2 *    @"/Users/wanglufei/Library/Developer/CoreSimulator/Devices/EE58BB00-B9B5-4286-BAC7-D3AB0B3167D1/data/Containers/Data/Application/40CB690A-DDED-4C1B-9130-488F6E11F6DF/Library/Caches/LFResumeDataDownload"    0x00007fa06ed1bca0
    ///Users/wanglufei/Library/Developer/CoreSimulator/Devices/EE58BB00-B9B5-4286-BAC7-D3AB0B3167D1/data/Containers/Data/Application/EED244D7-7067-4291-812C-5F4970766096/Library/Caches
    if (resumeData) {
        [self openOutputStream];
        NSInteger length = [self.outputStream write:resumeData.bytes maxLength:resumeData.length];
        [self closeOutputStream];
    }
}
-(void)localResumeDataPath{
    NSString *fileName = [_url substringFromIndex:[_url rangeOfString:@"/" options:NSBackwardsSearch].location + 1];
    NSArray *files = [fileName componentsSeparatedByString:@"."];
    NSString *saveFileName = [LFUtil encodeFilename:files.firstObject];
    NSString *dirpath = [LFUtil downloadResumeDataDirectory];
    BOOL ise = [[NSFileManager defaultManager] fileExistsAtPath:dirpath];
    if (!ise) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //存储相对地址
    _resumeDataPath = saveFileName;
}
-(void)localDownloadPath{
    NSString *fileName = [_url substringFromIndex:[_url rangeOfString:@"/" options:NSBackwardsSearch].location + 1];
    NSArray *files = [fileName componentsSeparatedByString:@"."];
    NSString *saveFileName = [[LFUtil encodeFilename:files.firstObject] stringByAppendingFormat:@".%@",files.lastObject];
    NSString *dirpath = [LFUtil downloadPathDirectory];
    BOOL ise = [[NSFileManager defaultManager] fileExistsAtPath:dirpath];
    if (!ise) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //存储相对地址
    _localPath = saveFileName;
    
}
-(instancetype)copyWithZone:(NSZone *)zone{
    LFDownLoadModel *model = [[LFDownLoadModel alloc]init];
    unsigned int count ;
    objc_property_t *propertys = class_copyPropertyList(NSClassFromString(@"LFDownLoadModel"), &count);
    for (int i = 0; i<count; i++) {
        objc_property_t property = propertys[i];
        const char *key = property_getName(property);
        NSString *keyName = [NSString stringWithUTF8String:key];
        [model setValue:[[self valueForKeyPath:keyName] copyWithZone:zone] forKey:keyName];
    }
    free(propertys);
    return model;
}
- (void)closeOutputStream {
    if (!_outputStream) {
        _outputStream = [[NSOutputStream alloc]initToFileAtPath:[[LFUtil downloadResumeDataDirectory] stringByAppendingPathComponent:self.resumeDataPath]  append:NO];
    }
    if (NSStreamStatusNotOpen < _outputStream.streamStatus && _outputStream.streamStatus < NSStreamStatusClosed) {
        [_outputStream close];
    }
    _outputStream = nil;
}
- (void)openOutputStream {
    if (!_outputStream) {
        _outputStream = _outputStream = [[NSOutputStream alloc]initToFileAtPath:[[LFUtil downloadResumeDataDirectory] stringByAppendingPathComponent:self.resumeDataPath]  append:NO];
    }
    [_outputStream open];
}
@end
