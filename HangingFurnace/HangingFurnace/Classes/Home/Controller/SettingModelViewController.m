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
#import "SendCommandManager.h"
@interface SettingModelViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableViewCell *_selectCell;
}
@property (nonatomic,strong) HFInstance *currentInstance;
@end

@implementation SettingModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"模式设定"];
    [self addDataList];
}


- (void) addDataList
{
    if (_skywareInfo) {
        DeviceData *deviceData = _skywareInfo.device_data;
        _currentInstance = deviceData.totalInstance;
        if (_currentInstance.deviceFunState == heating_fun) {
            self.dataList = [NSMutableArray arrayWithArray: _currentInstance.deviceHeatingModelArray];
        }else if (_currentInstance.deviceFunState == hotwater_fun){
            self.dataList = [NSMutableArray arrayWithArray: _currentInstance.deviceHotwaterModelArray];
        }
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
    NSString *cellID = @"settingModelCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    if (_currentInstance.deviceFunState == heating_fun) {
        if (_currentInstance.heating_select_model == indexPath.row) {
            cell.imageView.image = [UIImage imageNamed:@"modeSet_access"];
            _selectCell = cell;
        }
    }else if (_currentInstance.deviceFunState == hotwater_fun){
        if (_currentInstance.hotwater_select_model == indexPath.row) {
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
    
    if (_currentInstance.deviceFunState == heating_fun) {
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
    if (_currentInstance.deviceFunState == heating_fun) {
        _currentInstance.heating_select_model = (heatingDeviceModel)indexPath.row ;
    }else if (_currentInstance.deviceFunState == hotwater_fun){
        _currentInstance.hotwater_select_model = (hotwaterDeviceModel)indexPath.row;
    }
    [tableView reloadData];
    //发送指令
    [SendCommandManager sendModeCmd:_skywareInfo];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.dataList.count - 1 && _currentInstance.deviceFunState == heating_fun) {
        CustomModelViewController *custom = [[CustomModelViewController alloc] init];
        custom.navtext = self.dataList[indexPath.row];
        custom.skywareInfo = _skywareInfo;
        [self.navigationController pushViewController:custom animated:YES];
    }else{
        ModelEditViewController *modelEditVC = [[ModelEditViewController alloc]init];
        modelEditVC.navtext = self.dataList[indexPath.row];
        modelEditVC.dateArray = _currentInstance.deviceHeatingDateArray[indexPath.row];
        modelEditVC.isEdit = NO; // 禁止点击
        [self.navigationController pushViewController:modelEditVC animated:YES];
    }
}

-(void)sendHotWaterMode
{
    
}




@end
