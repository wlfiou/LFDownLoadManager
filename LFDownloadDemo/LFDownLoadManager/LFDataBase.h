//
//  LFDataBase.h
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/18.
//  Copyright © 2018 王鹭飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
NS_ASSUME_NONNULL_BEGIN

@interface LFDataBase : NSObject
+(RLMRealm *)db;
+ (void)dataBaseMigration;
+ (BOOL)dropRealmIfNeed;
@end

NS_ASSUME_NONNULL_END
