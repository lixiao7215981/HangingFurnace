//
//  HCHttpManager.m
//  YNTProject
//
//  Created by 钱海超 on 14/12/15.
//  Copyright (c) 2014年 土耳其大骗子. All rights reserved.
//

#import "HCHttpManager.h"
#import "HCHttpProject.h"

@interface HCHttpManager ()
//@property (nonatomic,strong) NSString *fileName; //文件名
@end

@implementation HCHttpManager
/**
 *  单例
 */
+ (instancetype)sharedManager
{
    static HCHttpManager *manager=nil;
    static dispatch_once_t onceToken;
    //一次只允许一个线程访问
    dispatch_once(&onceToken, ^{
        if(manager==nil){
            manager=[[HCHttpManager alloc] init];
        }
    });
    return manager;
}

/**
 *  类方法封装post请求，方便外部调用
 *
 *  @param urlString     请求头
 *  @param dic           请求体的参数字典
 *  @param finishedBlock 请求完成的block
 *  @param failedBlock   请求失败的block
 */
+ (void)postRequestWithUrlString:(NSString *)urlString params:(NSDictionary *)dic finishedBlock:(AFFinishedBlock)finishedBlock failedBlock:(AFFailedBlock)failedBlock
{    
    NSMutableURLRequest *request=[[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:dic error:nil];
    AFHTTPRequestOperation *op=[[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:finishedBlock failure:failedBlock];
    [[NSOperationQueue mainQueue] addOperation:op];
}

+ (void)postRequestWithUrlStringEqual:(NSString *)urlString params:(NSDictionary *)dic finishedBlock:(AFFinishedBlock)finishedBlock failedBlock:(AFFailedBlock)failedBlock
{
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    //设置 接收的服务器数据格式
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json",@"text/xml", nil];
    
    //改变数据请求时间为30秒
    manager.requestSerializer.timeoutInterval=30;
    //数据不会被自动解析
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    
    [manager POST:urlString parameters:dic success:finishedBlock failure:failedBlock];
}


/**
 *  上传请求的类封装
 */
+ (void)uploadRequestWithUrlString:(NSString *)urlString params:(NSDictionary *)dic fileName:(NSString *)fileName finishedBlock:(AFFinishedBlock)finishedBlock failedBlock:(AFFailedBlock)failedBlock uploadBlock:(AFUploadProgress)uploadProgress
{
    [[self alloc] UploadTaskWithUrlString:urlString params:dic fileName:fileName finishedBlock:finishedBlock failedBlock:failedBlock uploadBlock:uploadProgress];
}

- (void)UploadTaskWithUrlString:(NSString *)urlString params:(NSDictionary *)dic fileName:(NSString *)fileName finishedBlock:(AFFinishedBlock)finishedBlock failedBlock:(AFFailedBlock)failedBlock uploadBlock:(AFUploadProgress)uploadProgress
{
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    //管理类的维护
   // _fileName=fileName;
    [[HCHttpProject sharedRequestManager] addReqeustObj:manager andKey:fileName];
    AFHTTPRequestOperation *op=nil;
    NSData *data=[NSData dataWithContentsOfFile:fileName];
    op=[manager POST:urlString parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"ynt" fileName:[fileName lastPathComponent] mimeType:@"application/octet-stream"];
    } success:finishedBlock failure:failedBlock];
    
    //监听进度
    [op setUploadProgressBlock:uploadProgress];
}

+ (void)getRequestWithUrlString:(NSString *)urlString params:(NSDictionary *)dic finishedBlock:(AFFinishedBlock)finishedBlock failedBlock:(AFFailedBlock)failedBlock
{
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    //设置 接收的服务器数据格式
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json",@"text/xml", nil];
    
    //改变数据请求时间为30秒
//    manager.requestSerializer.timeoutInterval=30;
    manager.requestSerializer.timeoutInterval=30;

    //数据不会被自动解析
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:dic success:finishedBlock failure:failedBlock];
}
/**
 *  上传作品+上传头像
 */
+ (void)uploadProductionWithUrlString:(NSString *)urlString params:(NSDictionary *)dic images:(NSArray *)images finishedBlock:(AFFinishedBlock)finishedBlock failedBlock:(AFFailedBlock)failBlock
{
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
  //  manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"text/html", nil];
    [manager POST:urlString parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSData *data=UIImageJPEGRepresentation(images[0], 0.5);
           [formData appendPartWithFileData:data name:@"photo" fileName:@"xixi" mimeType:@"text/html"];
            [formData appendPartWithFormData:data name:@"proImg"];
        }];
    } success:finishedBlock failure:failBlock];
}


/**
 *  取消当前多有请求, 在vc的dealloc中调用，防止数据请求下来之前，vc已经销毁而造成崩溃
 */
- (void)cancelAllRequest:(NSString *)fileName
{
    AFHTTPRequestOperationManager *manager=[[HCHttpProject sharedRequestManager] getRequestObj:fileName];
    if(manager.operationQueue.operationCount){
    //通过queue取消请求
        [manager.operationQueue cancelAllOperations];
        [[HCHttpProject sharedRequestManager] removeRequest:fileName];
    }
}
/**
 *  判断网络环境，传递过来一个block
 *
 *  @param statusBlock 网络状态的回调block
 */
- (void)AFNetStatus:(void (^)(AFNetworkReachabilityStatus status))statusBlock
{
   // AFNetworkReachabilityManager 能够检测到网络环境和状态
   //开启检测
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //检测网络环境和状态 调用网路状态方法,传递block参数,网络状态的判断是异步的
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:statusBlock];
}





@end
