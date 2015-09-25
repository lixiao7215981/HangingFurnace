//
//  DeviceStatusConst.h
//  AirPurifier
//
//  Created by bluE on 15-1-16.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceStatusConst : NSObject

typedef enum DeviceStatus
{
    DeviceLock = 0,//设备已经锁定
    DeviceUnLock = 1,//设备未锁定
    
    DevicePowerOff  = 0,
    DevicePowerOn  = 1,
    DeviceOnlineOff  = 0,
    DeviceOnlineOn = 1,
}DeviceStatus;



@end
