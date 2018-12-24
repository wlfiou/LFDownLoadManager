//
//  LFUtil.h
//  HWDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/3.
//  Copyright © 2018 hero. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFUtil : NSObject
// 根据字节大小返回文件大小字符KB、MB
+ (NSString *)stringFromByteCount:(long long)byteCount;

// 时间转换为时间戳
+ (NSInteger)getTimeStampWithDate:(NSDate *)date;

// 时间戳转换为时间
+ (NSDate *)getDateWithTimeStamp:(NSInteger)timeStamp;

// 一个时间戳与当前时间的间隔（s）
+ (NSInteger)getIntervalsWithTimeStamp:(NSInteger)timeStamp;

//获得当前设备型号
+ (NSString *)getCurrentDeviceModel;

//通过view获取控制器
+ (UIViewController *)findViewController:(UIView *)view;

//获取当前控制器
+ (UIViewController *)getCurrentVC;

//删除path路径下的文件
+ (void)clearCachesWithFilePath:(NSString *)path;

//获取沙盒Library的文件目录
+ (NSString *)LibraryDirectory;

//获取沙盒Document的文件目录
+ (NSString *)DocumentDirectory;

//获取沙盒Preference的文件目录
+ (NSString *)PreferencePanesDirectory;

// 获取沙盒Caches的文件目录
+ (NSString *)CachesDirectory;
//download文件目录
+(NSString *)downloadPathDirectory;
//resumeData文件目录 (断点下载时每次存储状态数据包)
+(NSString *)downloadResumeDataDirectory;
//验证是否是纯数字
+ (BOOL)isAllNumber:(NSString *)number;

//验证手机号码
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

//验证身份证号码
+ (BOOL)isIdentityCardNumber:(NSString *)number;

//验证香港身份证号码
+ (BOOL)isIdentityHKCardNumber:(NSString *)number;

//验证密码格式（包含大写、小写、数字）
+ (BOOL)isConformSXPassword:(NSString *)password;

//验证护照
+ (BOOL)isPassportNumber:(NSString *)number;

//计算文字的长度
+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize;

//去掉小数点后无效的零
+ (NSString *)deleteFailureZero:(NSString *)string;

//得到中英文混合字符串长度
+ (int)lengthForText:(NSString *)text;

//提示弹窗
+ (void)showAlertWithTitle:(NSString *)title sureMessage:(NSString *)sureMessage cancelMessage:(NSString *)cancelMessage warningMessage:(NSString *)warningMessage style:(UIAlertControllerStyle)UIAlertControllerStyle target:(id)target sureHandler:(void(^)(UIAlertAction *action))sureHandler cancelHandler:(void(^)(UIAlertAction *action))cancelHandler warningHandler:(void(^)(UIAlertAction *action))warningHandler;

//获取当前时间
+ (NSString *)currentTime;

//编码文件名

+ (NSString *)encodeFilename:(NSString *)filename;

// 解码文件名

+ (NSString *)decodeFilename:(NSString *)filename;
//图片去背景
+ (UIImage*) imageToTransparent:(UIImage*) image;

@end

NS_ASSUME_NONNULL_END
