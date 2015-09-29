//
//  CustomModelViewController.h
//  HangingFurnace
//
//  Created by 李晓 on 15/9/9.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "BaseTableViewController.h"
#import <SkywareDeviceInfoModel.h>
@interface CustomModelViewController : BaseTableViewController

/**
 *  NavBar Title
 */
@property (nonatomic,copy) NSString *navtext;

@property (nonatomic,strong) SkywareDeviceInfoModel *skywareInfo;//当前设备信息

@end
