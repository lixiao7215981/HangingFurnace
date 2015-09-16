//
//  SettingModelViewController.m
//  HangingFurnace
//
//  Created by 李晓 on 15/9/8.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "SettingModelViewController.h"
#import "CustomModelViewController.h"
#import "ModelEditViewController.h"

@interface SettingModelViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableViewCell *_selectCell;
}
@end

@implementation SettingModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"模式设定"];
    [self addDataList];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (void) addDataList
{
    HFInstance *instance = [HFInstance sharedHFInstance];
    if (instance.deviceFunState == heating_fun) {
        self.dataList = [NSMutableArray arrayWithArray: instance.deviceHeatingModelArray];
    }else if (instance.deviceFunState == hotwater_fun){
        self.dataList = [NSMutableArray arrayWithArray: instance.deviceHotwaterModelArray];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HFInstance *instance = [HFInstance sharedHFInstance];
    NSString *cellID = @"settingModelCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    if (instance.deviceFunState == heating_fun) {
        if (instance.heating_select_model == indexPath.row) {
            cell.imageView.image = [UIImage imageNamed:@"modeSet_access"];
            _selectCell = cell;
        }
    }else if (instance.deviceFunState == hotwater_fun){
        if (instance.hotwater_select_model == indexPath.row) {
            cell.imageView.image = [UIImage imageNamed:@"modeSet_access"];
            _selectCell = cell;
        }
    }
    
    UILabel *modelName = [UILabel newAutoLayoutView];
    [cell.contentView addSubview:modelName];
    modelName.textColor = kRGBColor(82, 82, 82, 1);
    modelName.font = [UIFont systemFontOfSize:17];
    modelName.textAlignment = NSTextAlignmentCenter;
    modelName.text = self.dataList[indexPath.row];
    [modelName autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [modelName autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:40];
    
//    UIView *line = [UIView newAutoLayoutView];
//    line.backgroundColor = [UIColor lightGrayColor];
//    [cell.contentView addSubview:line];
//    [line autoSetDimension:ALDimensionHeight toSize:0.5];
//    [line autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    
    if (instance.deviceFunState == heating_fun) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectCell.imageView.image = nil;
    _selectCell = [tableView cellForRowAtIndexPath:indexPath];
    _selectCell.imageView.image = [UIImage imageNamed:@"modeSet_access"];
    HFInstance *instance = [HFInstance sharedHFInstance];
    if (instance.deviceFunState == heating_fun) {
        instance.heating_select_model = (heatingDeviceModel)indexPath.row ;
    }else if (instance.deviceFunState == hotwater_fun){
        instance.hotwater_select_model = (hotwaterDeviceModel)indexPath.row;
    }
    [tableView reloadData];
    //    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    HFInstance *instance = [HFInstance sharedHFInstance];
    if (indexPath.row == self.dataList.count - 1 && instance.deviceFunState == heating_fun) {
        CustomModelViewController *custom = [[CustomModelViewController alloc] init];
        custom.navtext = self.dataList[indexPath.row];
        [self.navigationController pushViewController:custom animated:YES];
    }else{
        ModelEditViewController *modelEditVC = [[ModelEditViewController alloc]init];
        modelEditVC.navtext = self.dataList[indexPath.row];
        modelEditVC.dateArray = instance.deviceHeatingDateArray[indexPath.row];
        modelEditVC.isEdit = NO; // 禁止点击
        [self.navigationController pushViewController:modelEditVC animated:YES];
    }
}


@end
