//
//  CustomModel.h
//  HangingFurnace
//
//  Created by 李晓 on 15/9/9.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomModel : NSObject

/***  开启时间 */
@property (nonatomic,copy) NSString *openTime;
/***  关闭时间 */
@property (nonatomic,copy) NSString *closeTime;
/***  温度 */
@property (nonatomic,copy) NSString *temperature;
/***  是否开启 */
@property (nonatomic,assign) BOOL isOpen;

@property (nonatomic,copy) NSString *ids;
@property (nonatomic,assign) BOOL isAdd;//是否是添加的新计划

+ (instancetype) createCustomModelWithOpenTime:(NSString *) openTime CloseTime:(NSString *)closeTime Temperature:(NSString *)temperature isOpen:(BOOL)isOpen;


@end
