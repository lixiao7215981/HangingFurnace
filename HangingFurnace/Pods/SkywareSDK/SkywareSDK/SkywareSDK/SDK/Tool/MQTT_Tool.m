//
//  MQTT_Tool.m
//  WebIntegration
//
//  Created by 李晓 on 15/9/2.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "MQTT_Tool.h"
#import "SkywareSDK.h"
@interface MQTT_Tool ()<MQTTSessionDelegate>

@end

@implementation MQTT_Tool

LXSingletonM(MQTT_Tool)

/**
 *  MQTT_Session
 */
static MQTTSession *_secction;

+ (void)initialize
{
    // 创建 MQTT
    SkywareInstanceModel *instance = [SkywareInstanceModel sharedSkywareInstanceModel];
    NSString *clintId = [NSString stringWithFormat:@"%ld",instance.app_id];
    _secction = [[MQTTSession alloc] initWithClientId: clintId];
    [_secction setDelegate:[MQTT_Tool sharedMQTT_Tool]];
    [_secction connectAndWaitToHost:kMQTTServerHost port:1883 usingSSL:NO];
}

+ (void) subscribeToTopicWithMAC:(NSString *)mac atLevel:(MQTTQosLevel)qosLevel
{
    if (qosLevel == 0) {
        [_secction subscribeToTopic:kTopic(mac) atLevel:MQTTQosLevelAtLeastOnce];
    }else{
        [_secction subscribeToTopic:kTopic(mac) atLevel:qosLevel];
    }
}

+ (void) unbscribeToTopicWithMAC:(NSString *)mac
{
    [_secction unsubscribeTopic:mac];
}


#pragma mark - MQTT_ToolDelegate

- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    // 调用代理方法接受推送
    if ([self.delegate respondsToSelector:@selector(MQTTnewMessage:data:onTopic:qos:)]) {
        [self.delegate MQTTnewMessage:session data:data onTopic:topic qos:qos];
    }
    // 发送通知到个别Controller推送消息
    [[NSNotificationCenter defaultCenter] postNotificationName:topic object:nil userInfo:@{@"data":data}];
}

@end
