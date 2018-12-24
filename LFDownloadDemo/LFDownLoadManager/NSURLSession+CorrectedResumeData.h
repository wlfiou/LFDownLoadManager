//
//  NSURLSession+CorrectedResumeData.h
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/11.
//  Copyright © 2018 王鹭飞. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (CorrectedResumeData)
- (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData;
@end

NS_ASSUME_NONNULL_END
