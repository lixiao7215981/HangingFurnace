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
+(void)sendModeCmd:(SkywareDeviceInfoModel *)skywareInfo
{
    //只修改模式时，发送的指令
    [self setDeviceId:skywareInfo];
    DeviceData *deviceData = (DeviceData *)skywareInfo.device_data;
    HFInstance *instance = deviceData.totalInstance;
    if (instance.deviceFunState == heating_fun) { //采暖
        if (instance.heating_select_model == ceaseless_run) { //无定时模式
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:@"0x210xFF"];
        }else if (instance.heating_select_model == business_one){ //商务模式1
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:@"0x220xFF"];
        }else if (instance.heating_select_model == business_two){ //商务模式2
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:@"0x230xFF"];
        }else if (instance.heating_select_model == economy){ //经济模式
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:@"0x240xFF"];
        }else if (instance.heating_select_model == custom){ //自定义模式
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:@"0x250xFF"];
        }
    }else{ //热水
        if (instance.hotwater_select_model == convention) { //常规模式
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:@"0x110xFF"];
        }else if (instance.hotwater_select_model == comfortable){ //舒适模式
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:@"0x120xFF"];
        }
    }
}

//发送温度设置指令（还要发送模式的值(低字节）
+(void)sendSettingTempretureCmd:(SkywareDeviceInfoModel *)skywareInfo
{
    [self setDeviceId:skywareInfo];
    DeviceData *deviceData = (DeviceData *)skywareInfo.device_data;
    HFInstance *instance = deviceData.totalInstance;
    if (instance.deviceFunState == heating_fun) { //采暖
        if (instance.heating_select_model == ceaseless_run) { //无定时模式
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"0x210x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.heating_select_model == business_one){ //商务模式1
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"0x220x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.heating_select_model == business_two){ //商务模式2
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"0x230x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.heating_select_model == economy){ //经济模式
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"0x240x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }
    }else{ //热水
        if (instance.hotwater_select_model == convention) { //常规模式
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"0x110x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.hotwater_select_model == comfortable){ //舒适模式
            [SkywareDeviceManagement DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"0x120x%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }
    }
}

+(void)sendDeviceOpenCloseCmd:(SkywareDeviceInfoModel *)skywareInfo
{
    [self setDeviceId:skywareInfo];
    DeviceData *data = skywareInfo.device_data;
    if(data.btnPower.boolValue){ //设备开机，发送关机指令
        [SkywareDeviceManagement DevicePushCMDWithEncodeData:@"0x100x00"];
    }else{//设备关机，发送开机指令
        [SkywareDeviceManagement DevicePushCMDWithEncodeData:@"0x100x01"];
    }
}


+(void)sendSeasonChangeCmd:(SkywareDeviceInfoModel *)skywareInfo
{
    [self setDeviceId:skywareInfo];
    DeviceData *data = skywareInfo.device_data;
    if (data.seasonWinter) { //冬季
        NSLog(@"冬季0x200x01");
        [SkywareDeviceManagement DevicePushCMDWithEncodeData:@"0x200x01"];
    }else{//夏季
        NSLog(@"夏季0x200x01");
        [SkywareDeviceManagement DevicePushCMDWithEncodeData:@"0x200x02"];
    }

}


+(void)sendSettingTimeCmd:(SkywareDeviceInfoModel *)skywareInfo
{
    [self setDeviceId:skywareInfo]; 
    
}
+(void)setDeviceId:(SkywareDeviceInfoModel *)skywareInfo
{
    [SkywareInstanceModel sharedSkywareInstanceModel].device_id = skywareInfo.device_id;
}

@end
