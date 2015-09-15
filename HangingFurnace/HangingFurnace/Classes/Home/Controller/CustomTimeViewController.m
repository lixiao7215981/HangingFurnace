//
//  CustomTimeViewController.m
//  HangingFurnace
//
//  Created by 李晓 on 15/9/9.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "CustomTimeViewController.h"
#import "selectDataPickView.h"

@interface CustomTimeViewController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate>
{
    selectDataPickView *_pick;
    NSIndexPath *_indexPath; // 点击的Cell indexPath ，设置选中的时间以及温度
}

@property (nonatomic,strong) NSMutableArray *hourArray;
//@property (nonatomic,strong) NSMutableArray *minuteArray;
/**
 *  温度范围的数组
 */
@property (nonatomic,strong) NSMutableArray *tRangeArray;

@end

@implementation CustomTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"自定义时间"];
    [self.dataList addObjectsFromArray:@[@"开启",@"关闭",@"温度"]];
    [self addNavRightBtn];
    
    [kNotificationCenter addObserver:self selector:@selector(selectDatePickViewCenterBtnClick:) name:kSelectCustomDatePickNotification object:nil];
    
    
}

#pragma mark - Method
- (void) addNavRightBtn
{
    __weak typeof (self.dataList) data = self.dataList;
    __weak typeof (self.tableView) tableView = self.tableView;
    __weak typeof (self.navigationController) nav = self.navigationController;
    [self setRightBtnWithImage:nil orTitle:@"确定" ClickOption:^{
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            NSLog(@"%@",cell.detailTextLabel.text);
        }];
        [nav popViewControllerAnimated:YES];
    }];
}

#pragma mark - NotificationCenter
- (void)selectDatePickViewCenterBtnClick:(NSNotification *) nsf
{
    NSString *selectWeekStr = nsf.userInfo[@"selectPick"];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_indexPath];
    cell.detailTextLabel.text = selectWeekStr;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CustomTimeViewControllerCellID = @"CustomTimeViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomTimeViewControllerCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CustomTimeViewControllerCellID];
    }
    cell.textLabel.text = self.dataList[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        cell.detailTextLabel.text = self.customModel.openTime;
    }else if (indexPath.row == 1){
        cell.detailTextLabel.text = self.customModel.closeTime;
    }else if (indexPath.row == 2){
        cell.detailTextLabel.text = self.customModel.temperature;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _indexPath = indexPath;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_indexPath];
    NSString *selectWeekStr = cell.detailTextLabel.text;
    [self clickSelectDateWithDefine:selectWeekStr];
}

- (void) clickSelectDateWithDefine:(NSString *) define
{
    selectDataPickView *pick = [selectDataPickView createSelectDatePickView];
    _pick = pick;
    pick.pickView.delegate =self ;
    pick.pickView.dataSource = self;
    [self.view addSubview:pick];
    
    UIButton *cover = [UIButton newAutoLayoutView];
    [cover addTarget:pick action:@selector(cleanMethod) forControlEvents:UIControlEventTouchUpInside];
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0.4;
    [[UIWindow getCurrentWindow] addSubview:cover];
    [cover autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    pick.cleanClick = ^{
        [cover removeFromSuperview];
    };
    pick.frame = CGRectMake(0, kWindowHeight, kWindowWidth, 240);
    [[UIWindow getCurrentWindow] addSubview:pick];
    [UIView animateWithDuration:0.4f animations:^{
        pick.y = (kWindowHeight - pick.height);
    } completion:^(BOOL finished) {
        
    }];
    
    if (_indexPath.row ==2) { // 选择的是温度需要显示一列的温度Pick
        
    }else{
        NSArray *array = [define componentsSeparatedByString:@":"];
//        [array enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *stop) {
//            [pick.pickView selectRow:[[str getTheCorrect] integerValue] inComponent:idx animated:YES];
//        }];
        
        [pick.pickView selectRow:[[array.firstObject getTheCorrect] integerValue] inComponent:0 animated:YES];
    }
}

#pragma mark - UIPickerViewDataSource,UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
//    if (_indexPath.row ==2) { // 选择的是温度需要显示一列的温度Pick
//        return 1;
//    }else{
//        return 2;
//    }
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_indexPath.row ==2) { // 选择的是温度需要显示一列的温度Pick
        return self.tRangeArray.count;
    }else{
//        if (component == 0) { // 小时
            return self.hourArray.count;
//        }else{// 分钟
//            return self.minuteArray.count;
//        }
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName : kRGBColor(245, 31, 2, 1),NSFontAttributeName:[UIFont systemFontOfSize:18]};
    NSAttributedString *attributedString = nil;
    
    if (_indexPath.row ==2) { // 选择的是温度需要显示一列的温度Pick
        attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@°C",self.tRangeArray[row]] attributes:attributeDict];
    }else{
//        if (component == 0) {
            attributedString = [[NSAttributedString alloc] initWithString:self.hourArray[row] attributes:attributeDict];
//        }else{
//            attributedString = [[NSAttributedString alloc] initWithString:self.minuteArray[row] attributes:attributeDict];
//        }
    }
    
    UILabel *labelView = [[UILabel alloc] init];
    labelView.textAlignment = NSTextAlignmentCenter;
    labelView.attributedText = attributedString;
    return labelView;
}

#pragma mark - 懒加载

- (NSMutableArray *)tRangeArray
{
    if (!_tRangeArray) {
        _tRangeArray = [[NSMutableArray alloc] init];
        HFInstance *instance = [HFInstance sharedHFInstance];
        NSArray *tRange = instance.tRange;
        NSInteger min = [tRange.firstObject integerValue];
        NSInteger max = [tRange.lastObject integerValue];
        for (NSInteger i = min; i<=max ; i++) {
            [_tRangeArray addObject:@(i)];
        }
    }
    return _tRangeArray;
}

- (NSMutableArray *)hourArray
{
    if (!_hourArray) {
        _hourArray = [[NSMutableArray alloc] init];
        for (int i = 0; i<24; i++) {
            [_hourArray addObject:[NSString stringWithFormat:@"%.2d 时",i]];
        }
    }
    return _hourArray;
}

//- (NSMutableArray *)minuteArray
//{
//    if (!_minuteArray) {
//        _minuteArray = [[NSMutableArray alloc] init];
//        for (int i = 0; i < 60; i++) {
//            [_minuteArray addObject:[NSString stringWithFormat:@"%.2d 分",i]];
//        }
//    }
//    return _minuteArray;
//}

@end
