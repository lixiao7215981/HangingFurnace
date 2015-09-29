//
//  HCHttpProject.h
//  YNTProject
//
//  Created by 钱海超 on 15/1/7.
//  Copyright (c) 2015年 土耳其大骗子. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCHttpProject : NSObject
/**
 *  用于管理request对象 避免提前释放
 */
//创建单例
+ (instancetype)sharedRequestManager;
/**
 *  添加request对象
 */
- (void)addReqeustObj:(id)obj andKey:(NSString *)key;

- (id)getRequestObj:(NSString *)key;
/**
 *  移除对象
 */
- (void)removeRequest:(NSString *)key;

@end
