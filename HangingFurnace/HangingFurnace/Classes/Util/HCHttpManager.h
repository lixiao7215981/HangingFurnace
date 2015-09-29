//
//  HCHttpManager.h
//  YNTProject
//
//  Created by 钱海超 on 14/12/15.
//  Copyright (c) 2014年 土耳其大骗子. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
/**
 *  数据请求完成block
 *
 *  @param oper         请求队列
 *  @param responseObj  请求结果
 */
typedef void (^AFFinishedBlock)(AFHTTPRequestOperation *oper,id responseObj);
/**
 *  数据请求失败的block
 *
 *  @param oper          请求队列
 *  @param error         请求失败信息
 */
typedef void (^AFFailedBlock)(AFHTTPRequestOperation *oper,NSError *error);
/**
 *  上传进度监听
 */
typedef void (^AFUploadProgress)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);


//封装AFNetWorking操作
@interface HCHttpManager : NSObject

/**
 *  单例
 */
+ (instancetype)sharedManager;
/**
 *  类方法封装post请求，方便外部调用(Json格式)
 *
 *  @param urlString     请求头
 *  @param dic           请求体的参数字典
 *  @param finishedBlock 请求完成的block
 *  @param failedBlock   请求失败的block
 */
+ (void)postRequestWithUrlString:(NSString *)urlString params:(NSDictionary *)dic finishedBlock:(AFFinishedBlock)finishedBlock failedBlock:(AFFailedBlock)failedBlock;

/**
 *  类方法封装post请求，方便外部调用（普通格式）
 *
 *  @param urlString     请求头
 *  @param dic           请求体的参数字典
 *  @param finishedBlock 请求完成的block
 *  @param failedBlock   请求失败的block
 */
+ (void)postRequestWithUrlStringEqual:(NSString *)urlString params:(NSDictionary *)dic finishedBlock:(AFFinishedBlock)finishedBlock failedBlock:(AFFailedBlock)failedBlock;
/**
 *  类方法封装上传请求，方便外部调用
 *
 *  @param urlString     请求头
 *  @param dic           请求体参数
 *  @param fileName      上传的文件名
 *  @param finishedBlock 请求完成的block
 *  @param failedBlock   请求失败的block
 */
+ (void)uploadRequestWithUrlString:(NSString *)urlString params:(NSDictionary *)dic fileName:(NSString *)fileName finishedBlock:(AFFinishedBlock)finishedBlock failedBlock:(AFFailedBlock)failedBlock uploadBlock:(AFUploadProgress)uploadProgress;
/**
 *  类方法封装get请求，方便外部调用
 *
 *  @param urlString   请求路径
 *  @param dic         请求参数
 *  @param finishBlock 请求完成调用的block
 *  @param failBlock   请求失败的block
 */
+ (void)getRequestWithUrlString:(NSString *)urlString params:(NSDictionary *)dic finishedBlock:(AFFinishedBlock)finishedBlock failedBlock:(AFFailedBlock)failedBlock;

/**
 *  发布作品+上传头像
 *
 *  @param urlString     请求路径
 *  @param dic           请求参数字典
 *  @param images        上传图片
 *  @param finishedBlock 请求完成调用的block
 *  @param failBlock     请求失败的调用的block
 */
+ (void)uploadProductionWithUrlString:(NSString *)urlString params:(NSDictionary *)dic images:(NSArray *)images finishedBlock:(AFFinishedBlock)finishedBlock failedBlock:(AFFailedBlock)failBlock;

/**
 *  取消所有请求
 */
- (void)cancelAllRequest:(NSString *)fileName;
/**
 *  判断网络环境，传递过来一个block
 *
 *  @param statusBlock 网络状态的回调block
 */
- (void)AFNetStatus:(void (^)(AFNetworkReachabilityStatus status))statusBlock;


@end
