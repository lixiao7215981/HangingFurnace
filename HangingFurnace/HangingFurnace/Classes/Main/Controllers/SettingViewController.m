//
//  SettingViewController.m
//  HangingFurnace
//
//  Created by 李晓 on 15/9/14.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "SettingViewController.h"
#import <SVProgressHUD.h>
#import "UtilConversion.h"
#import "SendCommandManager.h"
@interface SettingViewController ()
@property (nonatomic,strong) NSMutableArray  *allDevices;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"设置"];
    [self addDataList];
    //获取设备列表，进行复位，校准
    
}

-(void)downloadDeviceList
{
    [SVProgressHUD showInfoWithStatus:@"加载中..."];
    [SkywareDeviceManager DeviceGetAllDevicesSuccess:^(SkywareResult *result) {
        [SVProgressHUD dismiss];
        
        if ([result.message intValue] == 200) {
            if (self.allDevices.count) {
                [self.allDevices removeAllObjects];
            }
            SkywareSDKManager *manager = [SkywareSDKManager sharedSkywareSDKManager];
            [manager.bind_Devices_Array enumerateObjectsUsingBlock:^(SkywareDeviceInfoModel* obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DeviceData *deviceM = [[DeviceData alloc] initWithBase64String: [obj.device_data[@"bin"] toHexStringFromBase64String]];
                obj.device_data = deviceM;
                [self.allDevices addObject:obj];
                }];
        }
    } failure:^(SkywareResult *result) {
        [SVProgressHUD dismiss];
        if([result.message intValue] == 404) {//没有设备
        }else{
            [SVProgressHUD showErrorWithStatus:@"获取设备列表失败"];
        }
    }];
}

- (void) addDataList
{
    BaseArrowCellItem *item1 = [BaseArrowCellItem  createBaseCellItemWithIcon:nil AndTitle:@"设备复位" SubTitle:nil ClickOption:^{
        [SVProgressHUD showSuccessWithStatus:@"敬请期待！"];
    }];
//    BaseArrowCellItem *item2 = [BaseArrowCellItem  createBaseCellItemWithIcon:nil AndTitle:@"位置校准" SubTitle:nil ClickOption:^{
//        [SVProgressHUD showSuccessWithStatus:@"敬请期待！"];
//    }];
    BaseArrowCellItem *item3 = [BaseArrowCellItem  createBaseCellItemWithIcon:nil AndTitle:@"时间校准" SubTitle:nil ClickOption:^{
        [SVProgressHUD showSuccessWithStatus:@"校准成功"];
        //所有的设备同时进行时间校准
        [self sendTimecalibrate:[[NSArray alloc] initWithArray:self.allDevices]];
    }];
    
    BaseCellItemGroup *group = [BaseCellItemGroup createGroupWithItem:@[item1,item3]];
    
    [self.dataList addObject:group];
}


/**
 *  发送指令 到所有绑定的设备
 */
-(void) pushCMDWithEncodeData:(NSString *)data
{
    [self.allDevices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SkywareDeviceInfoModel *info = obj;
        NSData *sampleData = [data stringHexToBytes];
        NSString * encodeStr = [sampleData base64EncodedStringWithOptions:0]; //进行base64位编码
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        if (!info) return;
        [params setObject: info.device_id forKey:@"device_id"];
        [params setObject:[SkywareDeviceManager controlCommandvWithEncodedString:encodeStr] forKey:@"commandv"];
        [SkywareDeviceManager DevicePushCMD:params Success:^(SkywareResult *result) {
            NSLog(@"指令发送成功---%@",params);
            [SVProgressHUD dismiss];
        } failure:^(SkywareResult *result) {
            NSLog(@"指令发送失败");
            [SVProgressHUD dismiss];
        }];
    }];
}

-(void)sendTimecalibrate:(NSArray *)bindedDeviceArray
{
    NSDate *curDate = [NSDate new];//第一个时间
    //    NSTimeInterval firstDate = [curDate timeIntervalSince1970]*1;
    //    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    //    [date setDateFormat:@"yyyy-MM-dd HH:mm"];
    //    DeviceData *deviceData = (DeviceData *)skywareInfo.device_data;
    //    NSDate *calibarateDate=[date dateFromString:deviceData.calibarateTime];
    //    NSTimeInterval secondDate = [calibarateDate timeIntervalSince1970]*1;
    //    if (fabs(firstDate - secondDate) > 1000) {
    //        NSLog(@"the different is %lf",fabs(firstDate - secondDate));
    //        //        Byte6  Minute [0,59]
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit| NSCalendarUnitWeekday;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:curDate];
    //        NSInteger year = [dateComponent year];
    //        NSInteger month = [dateComponent month];
    //        NSInteger day = [dateComponent day];
    NSInteger week = [dateComponent weekday]==0?7:[dateComponent weekday]-1;
    NSInteger hour = [dateComponent hour];
    NSInteger minute = [dateComponent minute];
    NSInteger second = [dateComponent second];
    NSString *cmd = [NSString stringWithFormat:@"31%@%@%@%@",
                     [UtilConversion decimalToHex:hour],
                     [UtilConversion decimalToHex:minute],
                     [UtilConversion decimalToHex:second],
                     [UtilConversion decimalToHex:week] //需要注意
                     ];
    [self pushCMDWithEncodeData:cmd];
    //    }
}

-(NSMutableArray *)allDevices{
    if (_allDevices==nil) {
        _allDevices = [NSMutableArray new];
    }
    return _allDevices;
}

@end
