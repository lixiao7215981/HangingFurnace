//
//  CustomModelTableViewCell.m
//  HangingFurnace
//
//  Created by 李晓 on 15/9/9.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "CustomModelTableViewCell.h"

@interface CustomModelTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *openTime;
@property (weak, nonatomic) IBOutlet UILabel *closeTime;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UISwitch *switchOpen;

@end

@implementation CustomModelTableViewCell

- (void)setCustom:(CustomModel *)custom
{
    _custom = custom;
    self.openTime.text = custom.openTime;
    self.closeTime.text = custom.closeTime;
    self.temperature.text = custom.temperature;
    self.switchOpen.on = custom.isOpen;
}

+ (instancetype)createCustomCellWithTableView:(UITableView *) tableView reuseIdentifier:(NSString *) reuseIdentifier
{
    CustomModelTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomModelTableViewCell" owner:nil options:nil]lastObject];
    return cell;
}

@end
