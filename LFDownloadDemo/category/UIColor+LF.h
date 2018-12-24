//
//  UIColor+LF.h
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/11.
//  Copyright © 2018 王鹭飞. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (LF)
//16进制转化RGB
+ (UIColor *)colorWithHexString:(NSString *)string;

//随即色
+ (UIColor *)randomColor;
@end

NS_ASSUME_NONNULL_END
