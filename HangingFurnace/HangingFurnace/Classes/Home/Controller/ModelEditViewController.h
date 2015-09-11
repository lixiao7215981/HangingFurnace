//
//  ModelEditViewController.h
//  HangingFurnace
//
//  Created by 李晓 on 15/9/8.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "BaseViewController.h"

@interface ModelEditViewController : BaseViewController

/**
 *  NavBar Title
 */
@property (nonatomic,copy) NSString *navtext;

/**
 *  时间展示
 */
@property (nonatomic,strong) NSArray *dateArray;

/**
 *  是否可以编辑
 */
@property (nonatomic,assign) BOOL isEdit;

@end
