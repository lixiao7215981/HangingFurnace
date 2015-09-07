//
//  TempretureSetModel.h
//  HangingFurnace
//
//  Created by ybyao07 on 15/9/6.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempretureSetModel : NSObject

@property (nonatomic,strong) NSNumber *hangTemp;//壁挂炉的温度
@property (nonatomic,strong) NSNumber *hotWaterTemp;//热水器的设置温度

@end
