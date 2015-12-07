//
//  DeviceData.m
//  HangingFurnace
//
//  Created by ybyao07 on 15/9/24.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "DeviceData.h"
#import "UtilConversion.h"
@implementation DeviceData

static const long  kLength = 2;
static const long  valueLengthStep = 2;

-(instancetype)initWithBase64String:(NSString *)base64String
{
        self = [super init];
        if (self ) {
            [self initObject];
            NSString *cmdKey;
            NSString *cmdValue;
            long loctionStar=0; //命令值的起始位置
            long lengthValue=2; //命令值的长度
            for (loctionStar =0; loctionStar < base64String.length; ) {
                cmdKey = [base64String substringWithRange:NSMakeRange(loctionStar, kLength)]; //所有的key都是2个字符
                if ([cmdKey isEqualToString:@"10"]) {//开关机  -1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                    [self setCmdPower:cmdValue];
                }else if ([cmdKey isEqualToString:@"20"]){ //季节切换 -1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                    [self setCmdSeasonWinter:cmdValue];
                }else if ([cmdKey isEqualToString:@"21"]){ //热水/供暖模式状态 -2 字节
                    lengthValue = valueLengthStep*2;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                    [self setCmdHeatHotMode:cmdValue];
                }else if ([cmdKey isEqualToString:@"22"]){ //自定义模式的 时间表 与 温度表 -(3+x) 字节
//                    lengthValue = valueLengthStep*2;
//                    loctionStar+=kLength;
//                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
//                    [self setCmdSeasonWinter:cmdValue];
                }else if ([cmdKey isEqualToString:@"30"]){ //当前机型标识（可选） -1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                }else if ([cmdKey isEqualToString:@"31"]){ //当前系统时间 - 3 字节
                    lengthValue = valueLengthStep*3;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                }else if ([cmdKey isEqualToString:@"32"]){ //采暖方式 - 1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                    [self setCmdHeatingMode:cmdValue];
                }else if ([cmdKey isEqualToString:@"33"]){ //机型功能区别标识 - 1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                }else if ([cmdKey isEqualToString:@"41"]){ //温度状态 - 1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                    [self setCmdCurrentTempreture:cmdValue];
                }else if ([cmdKey isEqualToString:@"42"]){ //水压状态 - 1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                    [self setCmdCurrentPressure:cmdValue];
                }else if ([cmdKey isEqualToString:@"43"]){ //火焰状态 - 1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                    [self setCmdFlameState:cmdValue];
                }else if ([cmdKey isEqualToString:@"44"]){ //风机状态 - 1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                    [self setCmdFanState:cmdValue];
                }else if ([cmdKey isEqualToString:@"45"]){ //水泵状态 - 1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                    [self setCmdPumpState:cmdValue];
                }else if ([cmdKey isEqualToString:@"46"]){ //防冻状态 - 1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                    [self setCmdAntifreezeState:cmdValue];
                }else if ([cmdKey isEqualToString:@"0F"]){ //故障状态 - 1 字节
                    lengthValue = valueLengthStep;
                    loctionStar+=kLength;
                    cmdValue = [base64String substringWithRange:NSMakeRange(loctionStar, lengthValue)];
                    [self setCmdSeasonWinter:cmdValue];
                }
                loctionStar+=lengthValue;
            }
    }
    return self;
}

-(void)initObject{
    _totalInstance = [[HFInstance alloc] init];
}

-(void)setCmdPower:(NSString *)cmdString //开关机
{
    if ([cmdString isEqualToString:@"01"]) { //开机
        _btnPower = @"1";
    }else{
        _btnPower = @"0";
    }
}


-(void)setCmdSeasonWinter:(NSString *)cmdString //季节
{
    if ([cmdString isEqualToString:@"01"]) { //冬季
        _seasonWinter = YES;
    }else if([cmdString isEqualToString:@"02"]) {
        _seasonWinter = NO;
    }
}

-(void)setCmdHeatHotMode:(NSString *)cmdString { //热水和供暖模式 -- 温度设置
    //1字节 模式 2字节  温度设置
    NSString *valueLow = [cmdString substringWithRange:NSMakeRange(0, 2)];
    if ([valueLow isEqualToString:@"10"]) { //无模式
        _totalInstance.deviceFunState = hotwater_fun;
    }else if ([valueLow isEqualToString:@"11"]) { //常规模式
        _totalInstance.deviceFunState = hotwater_fun;
        _totalInstance.hotwater_select_model = convention;
    }else if ([valueLow isEqualToString:@"12"]) { //舒适模式
        _totalInstance.deviceFunState = hotwater_fun;
        _totalInstance.hotwater_select_model = comfortable;
    }else if ([valueLow isEqualToString:@"21"]) { //无定时模式
        _totalInstance.deviceFunState = heating_fun;
        _totalInstance.heating_select_model = ceaseless_run;
    }else if ([valueLow isEqualToString:@"22"]) { //商务模式1
        _totalInstance.deviceFunState = heating_fun;
        _totalInstance.heating_select_model = business_one;
    }else if ([valueLow isEqualToString:@"23"]) { //商务模式2
        _totalInstance.deviceFunState = heating_fun;
        _totalInstance.heating_select_model = business_two;
    }else if ([valueLow isEqualToString:@"24"]) { //经济模式
        _totalInstance.deviceFunState = economy;
        _totalInstance.heating_select_model = ceaseless_run;
    }else if ([valueLow isEqualToString:@"25"]) { //自定义模式(手机App设置）
        _totalInstance.deviceFunState = heating_fun;
        _totalInstance.heating_select_model = custom;
    }else if ([valueLow isEqualToString:@"26"]) { //自定义模式(机器面板上设置)
        _totalInstance.deviceFunState = heating_fun;
        _totalInstance.heating_select_model = custom;
    }
    NSString *valueHigh = [cmdString substringWithRange:NSMakeRange(2, 2)]; //设置的温度
    long setTempreture = [UtilConversion toDecimalFromHex:valueHigh];
    _totalInstance.defaultTem = setTempreture;
}

-(void)setCmdHeatingMode:(NSString *)cmdString //当前采暖方式
{
    if ([cmdString isEqualToString:@"01"]) { //暖气片
        _totalInstance.heatingState = heating_radiator;
    }else if ([cmdString isEqualToString:@"02"]){ //地暖
        _totalInstance.heatingState = heating_floor;
    }
}


-(void)setCmdCurrentTempreture:(NSString *)cmdString //当前水温
{
    if (cmdString.length) {
        long tempreture = [UtilConversion toDecimalFromHex:cmdString];
        _currentTempreture = tempreture;
    }
}
-(void)setCmdCurrentPressure:(NSString *)cmdString //当前水压
{
    if (cmdString.length) {
        long pressure = [UtilConversion toDecimalFromHex:cmdString];
        _currentPressure = pressure/10.0;
    }
}

-(void)setCmdFlameState:(NSString *)cmdString //火焰状态
{
    if (cmdString.length) {
        NSInteger level = [UtilConversion toDecimalFromHex:cmdString];
        _flameLevel = level;
    }
}
-(void)setCmdFanState:(NSString *)cmdString //风机状态
{
    if ([cmdString isEqualToString:@"01"]) { //开机
        _isFanOpen =YES;
    }else{
        _isFanOpen = NO;
    }
    
}
-(void)setCmdPumpState:(NSString *)cmdString //水泵状态
{
    if ([cmdString isEqualToString:@"01"]) { //开机
        _isPumpOpen =YES;
    }else{
        _isPumpOpen = NO;
    }
}
-(void)setCmdAntifreezeState:(NSString *)cmdString //防冻状态
{
    if ([cmdString isEqualToString:@"01"]) { //开机
        _isAntifreezeOpen =YES;
    }else{
        _isAntifreezeOpen = NO;
    }
}


@end
