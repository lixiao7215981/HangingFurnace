//
//  SendCommandManager.h
//  HangingFurnace
//
//  Created by ybyao07 on 15/9/25.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendCommandManager : NSObject
/**
 *  发送模式切换指令(只切换模式，不带温度)
 */
+(void)sendModeCmd;

/**
 *  发送温度设置指令(包含模式)
 */
+(void)sendSettingTempretureCmd;

@end
