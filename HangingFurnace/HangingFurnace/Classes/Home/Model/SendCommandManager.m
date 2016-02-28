//
//  SendCommandManager.m
//  HangingFurnace
//
//  Created by ybyao07 on 15/9/25.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "SendCommandManager.h"
#import "UtilConversion.h"
#import "NSString+Extension.h"

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
            [SkywareDeviceManager DevicePushCMDWithEncodeData:@"21FF"];
        }else if (instance.heating_select_model == business_one){ //商务模式1
            [SkywareDeviceManager DevicePushCMDWithEncodeData:@"22FF"];
        }else if (instance.heating_select_model == business_two){ //商务模式2
            [SkywareDeviceManager DevicePushCMDWithEncodeData:@"23FF"];
        }else if (instance.heating_select_model == economy){ //经济模式
            [SkywareDeviceManager DevicePushCMDWithEncodeData:@"24FF"];
        }else if (instance.heating_select_model == custom){ //自定义模式
            [SkywareDeviceManager DevicePushCMDWithEncodeData:@"25FF"];
        }
    }else{ //热水
        if (instance.hotwater_select_model == convention) { //常规模式
            [SkywareDeviceManager DevicePushCMDWithEncodeData:@"11FF"];
        }else if (instance.hotwater_select_model == comfortable){ //舒适模式
            [SkywareDeviceManager DevicePushCMDWithEncodeData:@"12FF"];
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
            [SkywareDeviceManager DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"21%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.heating_select_model == business_one){ //商务模式1
            [SkywareDeviceManager DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"22%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.heating_select_model == business_two){ //商务模式2
            [SkywareDeviceManager DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"23%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.heating_select_model == economy){ //经济模式
            [SkywareDeviceManager DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"24%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }
    }else{ //热水
        if (instance.hotwater_select_model == convention) { //常规模式
            [SkywareDeviceManager DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"11%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }else if (instance.hotwater_select_model == comfortable){ //舒适模式
            [SkywareDeviceManager DevicePushCMDWithEncodeData:[NSString stringWithFormat:@"12%@",[UtilConversion decimalToHex:instance.defaultTem]]];
        }
    }
}

+(void)sendDeviceOpenCloseCmd:(SkywareDeviceInfoModel *)skywareInfo
{
    [self setDeviceId:skywareInfo];
    DeviceData *data = skywareInfo.device_data;
    if(data.btnPower.boolValue){ //设备开机，发送关机指令
        [SkywareDeviceManager DevicePushCMDWithEncodeData:@"1000"];
    }else{//设备关机，发送开机指令
        [SkywareDeviceManager DevicePushCMDWithEncodeData:@"1001"];
    }
}


+(void)sendSeasonChangeCmd:(SkywareDeviceInfoModel *)skywareInfo
{
    [self setDeviceId:skywareInfo];
    DeviceData *data = skywareInfo.device_data;
    if (data.seasonWinter) { //冬季
        NSLog(@"冬季2001");
        [SkywareDeviceManager DevicePushCMDWithEncodeData:@"2001"];
    }else{//夏季
        NSLog(@"夏季2001");
        [SkywareDeviceManager DevicePushCMDWithEncodeData:@"2002"];
    }
}


+(void)sendSettingTimeCmd:(SkywareDeviceInfoModel *)skywareInfo withCmdString:(NSString *)cmdString
{
    [self setDeviceId:skywareInfo];
    [SkywareDeviceManager DevicePushCMDWithEncodeData:cmdString];
}
+(void)setDeviceId:(SkywareDeviceInfoModel *)skywareInfo
{
    if (skywareInfo==nil) { //如果没有设备信息
//        [SkywareInstanceModel sharedSkywareInstanceModel].device_id = @"";
        NSLog(@"没有设备。。。。");
        return;
    }
//    [SkywareInstanceModel sharedSkywareInstanceModel].device_id = skywareInfo.device_id;
}

@end
