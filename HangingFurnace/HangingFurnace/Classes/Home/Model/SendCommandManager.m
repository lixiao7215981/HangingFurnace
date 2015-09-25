//
//  SendCommandManager.m
//  HangingFurnace
//
//  Created by ybyao07 on 15/9/25.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "SendCommandManager.h"
#import "UtilConversion.h"

@implementation SendCommandManager


//发送指令(只切换模式）
+(void)sendModeCmd
{
    //只修改模式时，发送的指令
    HFInstance *instance = [HFInstance sharedHFInstance];
    if (instance.deviceFunState == heating_fun) { //采暖
        if (instance.heating_select_model == ceaseless_run) { //无定时模式
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:@"0x210xFF"];
        }else if (instance.heating_select_model == business_one){ //商务模式1
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:@"0x220xFF"];
        }else if (instance.heating_select_model == business_two){ //商务模式2
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:@"0x230xFF"];
        }else if (instance.heating_select_model == economy){ //经济模式
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:@"0x240xFF"];
        }
    }else{ //热水
        if (instance.hotwater_select_model == convention) { //常规模式
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:@"0x110xFF"];
        }else if (instance.hotwater_select_model == comfortable){ //舒适模式
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:@"0x120xFF"];
        }
    }
}

//发送温度设置指令（还要发送模式的值(低字节）
+(void)sendSettingTempretureCmd
{
    HFInstance *instance = [HFInstance sharedHFInstance];
    if (instance.deviceFunState == heating_fun) { //采暖
        if (instance.heating_select_model == ceaseless_run) { //无定时模式
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:[NSString stringWithFormat:@"0x210x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.heating_select_model == business_one){ //商务模式1
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:[NSString stringWithFormat:@"0x220x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.heating_select_model == business_two){ //商务模式2
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:[NSString stringWithFormat:@"0x230x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.heating_select_model == economy){ //经济模式
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:[NSString stringWithFormat:@"0x240x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }
    }else{ //热水
        if (instance.hotwater_select_model == convention) { //常规模式
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:[NSString stringWithFormat:@"0x110x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.hotwater_select_model == comfortable){ //舒适模式
            [SkywareDeviceManagement DevicePushcmdWithWillEncodeData:[NSString stringWithFormat:@"0x120x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }
    }
}

@end
