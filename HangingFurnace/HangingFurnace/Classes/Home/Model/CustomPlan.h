//
//  CustomPlan.h
//  HangingFurnace
//
//  Created by ybyao07 on 15/9/28.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomPlan : NSObject

//@property (nonatomic,strong) NSMutableArray *arrPlanWeek;
@property (nonatomic,strong) NSString *cmd; //拼接指令（开关机+供暖模式）0x10 0x21
@property (nonatomic,strong) NSString *id;//创建成功的计划任务的id
@property (nonatomic,strong) NSString *plan;// 重复时间
@property (nonatomic,strong) NSString *hour;
@property (nonatomic,strong) NSString *min;


@end
