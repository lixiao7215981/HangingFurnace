//
//  CustomPlan.h
//  HangingFurnace
//
//  Created by ybyao07 on 15/9/28.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomPlan : NSObject

@property (nonatomic,strong) NSMutableArray *arrPlanWeek;
@property (nonatomic,strong) NSString *cmd;
@property (nonatomic,strong) NSString *planId;//创建成功的计划任务的id

@end
