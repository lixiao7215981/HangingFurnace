//
//  HomeTopStateView.m
//  HangingFurnace
//
//  Created by 李晓 on 15/9/14.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "HomeTopStateView.h"

@interface HomeTopStateView()
{
    CoreLocationTool *locationTool;
}
@end

@implementation HomeTopStateView

-(void)awakeFromNib
{
    // 获取用户所在地的天气情况
    locationTool = [[CoreLocationTool alloc] init];
    [locationTool getLocation:^(CLLocation *location) {
        [locationTool reverseGeocodeLocation:location userAddress:^(UserAddressModel *userAddress) {
            SkywareWeatherModel *model = [[SkywareWeatherModel alloc] init];
            model.province = userAddress.State;
            model.city = userAddress.City;
            model.district = userAddress.SubLocality;
            [SkywareOthersManagement UserAddressWeatherParamesers:model Success:^(SkywareResult *result) {
                SkywareAddressWeatherModel *weath = [SkywareAddressWeatherModel objectWithKeyValues:result.result];
                self.wind.text = [NSString stringWithFormat:@"%@%@",weath.wind_direct,weath.wind_power];
                self.cityState.text = [NSString stringWithFormat:@"%@ %@",weath.area_name,weath.temperature];
            } failure:^(SkywareResult *result) {
                NSLog(@"%@",result);
            }];
        }];
    }];
}

-(void)setDeviceData:(DeviceData *)deviceData
{
    _deviceData = deviceData;
    if (_deviceData.isAntifreezeOpen) {//防冻
    }
    if (_deviceData.isPumpOpen) {//水泵
    }
    if (_deviceData.isFanOpen) {//风机
        _flabellum.hidden = NO;
    }else{
        _flabellum.hidden = YES;
    }
    if (_deviceData.flameLevel == 0) {//火焰
        _fire.hidden = YES;
    }else{
        _fire.hidden = NO;
        if (_deviceData.flameLevel == 1) {
            _fire.image =[UIImage imageNamed:@"fire_1"];
        }else if (_deviceData.flameLevel == 2){
            _fire.image =[UIImage imageNamed:@"fire_2"];
        }else if (_deviceData.flameLevel == 3){
            _fire.image =[UIImage imageNamed:@"fire_3"];
        }else if (_deviceData.flameLevel == 4){
            _fire.image =[UIImage imageNamed:@"fire_4"];
        }else if (_deviceData.flameLevel == 5){
            _fire.image =[UIImage imageNamed:@"fire_5"];
        }else if (_deviceData.flameLevel == 6){
            _fire.image =[UIImage imageNamed:@"fire_6"];
        }
    }

    if (deviceData.seasonWinter) { //冬季
        _snowflake.hidden = NO;
    }else{ //夏季
        _snowflake.hidden = YES;
    }
    HFInstance *instance = deviceData.totalInstance;
    if (instance.deviceFunState == heating_fun) { //只有采暖模式里面有定时模式
        if (instance.heating_select_model == ceaseless_run) { //无定时
            _timing.hidden = YES;
        }else {
            _timing.hidden = NO;
        }
    }else{
        _timing.hidden = YES;
    }
    
    
}



@end
