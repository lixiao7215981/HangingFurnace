//
//  DeviceData.h
//  HangingFurnace
//
//  Created by ybyao07 on 15/9/24.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomModel.h"
#import "HFInstance.h"
#import "TempretureSetModel.h"
@interface DeviceData : NSObject

@property (nonatomic,strong) NSString *btnPower;// 按钮状态开机
//@property (nonatomic,strong) NSString *calibarateTime;// 系统校准时间
@property (nonatomic,strong) TempretureSetModel *tempretureModel;

//@property (nonatomic,strong) CustomModel *timeOne;
//@property (nonatomic,strong) CustomModel *timeTwo;
//@property (nonatomic,strong) CustomModel *timeThree;

@property (nonatomic,assign) BOOL seasonWinter;//夏季还是冬季
@property (nonatomic,assign) double currentTempreture;//当前水温
@property (nonatomic,assign) double currentPressure;//当前水压

@property (nonatomic,strong) HFInstance *totalInstance;

@property (nonatomic,assign) BOOL isAntifreezeOpen;//防冻状态
@property (nonatomic,assign) BOOL isPumpOpen;//水泵状态
@property (nonatomic,assign) BOOL isFanOpen;//风机状态
@property (nonatomic,assign) NSInteger flameLevel;//火焰状态

-(instancetype)initWithBase64String:(NSString *)base64String;

@end

