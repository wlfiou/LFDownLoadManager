//
//  UIImage+LF.h
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/11.
//  Copyright © 2018 王鹭飞. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (LF)
//根据颜色返回图片
+ (UIImage *)imageWithColor:(UIColor *)color;


//绘制图片圆角
- (UIImage *)drawCornerInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;
@end

NS_ASSUME_NONNULL_END
