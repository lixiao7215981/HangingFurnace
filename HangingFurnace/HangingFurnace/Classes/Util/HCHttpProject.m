//
//  HCHttpProject.m
//  YNTProject
//
//  Created by 钱海超 on 15/1/7.
//  Copyright (c) 2015年 土耳其大骗子. All rights reserved.
//

#import "HCHttpProject.h"

@interface HCHttpProject ()
{
    //用来维护request对象,因为每个request的地址唯一,所以用地址作为key值
    NSMutableDictionary *_requestDic;
}
@end

@implementation HCHttpProject


//创建单例
static HCHttpProject *manager=nil;

+ (instancetype)sharedRequestManager
{
    @synchronized(self){
        
        if(manager==nil){
            
            manager=[[HCHttpProject alloc] init];
        }
        return manager;
    }
}
- (id)init
{
    self = [super init];
    if (self) {
        _requestDic=[NSMutableDictionary dictionary];
    }
    return self;
}

/**
 *  添加request对象
 */
- (void)addReqeustObj:(id)obj andKey:(NSString *)key
{
    [_requestDic setObject:obj forKey:key];
}
/**
 *  移除对象
 */
- (void)removeRequest:(NSString *)key
{
    [_requestDic removeObjectForKey:key];
}
//获取request对象
- (id)getRequestObj:(NSString *)key
{
    return [_requestDic objectForKey:key];
}


@end
