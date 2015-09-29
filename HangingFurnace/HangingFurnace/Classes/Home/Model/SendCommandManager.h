//
//  SendCommandManager.h
//  HangingFurnace
//
//  Created by ybyao07 on 15/9/25.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkywareDeviceInfoModel.h>
#import "DeviceData.h"
@interface SendCommandManager : NSObject
/**
 *  发送模式切换指令(只切换模式，不带温度)
 */
+(void)sendModeCmd:(SkywareDeviceInfoModel *)skywareInfo;
/**
 *  发送温度设置指令(包含模式)
 */
+(void)sendSettingTempretureCmd:(SkywareDeviceInfoModel *)skywareInfo;
/**
 *  发送开关机指令
 *
 *  @param skywareInfo <#skywareInfo description#>
 */
+(void)sendDeviceOpenCloseCmd:(SkywareDeviceInfoModel *)skywareInfo;
/**
 *  发送季节切换指令
 *
 *  @param skywareInfo <#skywareInfo description#>
 */
+(void)sendSeasonChangeCmd:(SkywareDeviceInfoModel *)skywareInfo;

/**
 *  发送自定义时间模式 --需要服务器端处理
 *
 *  @param skywareInfo <#skywareInfo description#>
 */
+(void)sendSettingTimeCmd:(SkywareDeviceInfoModel *)skywareInfo;


@end
