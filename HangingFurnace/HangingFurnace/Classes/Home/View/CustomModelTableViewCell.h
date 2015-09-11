//
//  CustomModelTableViewCell.h
//  HangingFurnace
//
//  Created by 李晓 on 15/9/9.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomModel.h"

@interface CustomModelTableViewCell : UITableViewCell

@property (nonatomic,strong) CustomModel *custom;


+ (instancetype)createCustomCellWithTableView:(UITableView *) tableView reuseIdentifier:(NSString *) reuseIdentifier;

@end