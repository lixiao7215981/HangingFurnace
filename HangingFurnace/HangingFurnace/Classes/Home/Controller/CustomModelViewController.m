
//
//  CustomModelViewController.m
//  HangingFurnace
//
//  Created by 李晓 on 15/9/9.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "CustomModelViewController.h"
#import "CustomModelTableViewCell.h"
#import "CustomTimeViewController.h"
#import "SelectWeekView.h"
#import <UIWindow+Extension.h>
#import "CustomModel.h"
#import "HCHttpManager.h"
#import "UtilConversion.h"
#import "CustomPlan.h"
#import "SendCommandManager.h"

@interface CustomModelViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSMutableArray *selectedWeekNumbers;
@property (nonatomic,strong) CustomPlan *planModel;
@end

@implementation CustomModelViewController

static int lengthTimerTempreture;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:self.navtext];
    __weak __typeof(self) _weakSelf = self;
    [self setRightBtnWithImage:nil orTitle:@"确定" ClickOption:^{
        //发送指令
        [_weakSelf sendCmdToServer];
    }];
    
    self.tableView.separatorStyle = UITableViewScrollPositionNone;
    
    [self addTableFootView];
    [kNotificationCenter addObserver:self selector:@selector(selectWeekViewCenterBtnClick:) name:kSelectCustomWeekDateNotification object:nil];
    
    [kNotificationCenter addObserver:self selector:@selector(updateTimeTableView:) name:@"TimeSetingNotification" object:nil];
    //获取数据
    [self downloadCustomData];
}

-(void)updateTimeTableView:(NSNotification *)nofify
{
    NSMutableDictionary *dic = (NSMutableDictionary *)nofify.userInfo;
    CustomModel *model =  dic[@"timeModel"];
    int index = [dic[@"index"] intValue];
    if (index < self.dataList.count) {
        [self.dataList replaceObjectAtIndex:index withObject:model];
    }else{
        [self.dataList addObject:model];
    }
    [self.tableView reloadData];
}

-(void)downloadCustomData
{
    self.planModel = [[CustomPlan alloc] init];
    self.planModel.arrPlanWeek = [NSMutableArray arrayWithObjects:@"1",@"3",nil];
    [self.tableView reloadData];
    
    SkywareInstanceModel *instance = [SkywareInstanceModel sharedSkywareInstanceModel];
    [SkywareHttpTool HttpToolGetWithUrl:kSearchPlan(_skywareInfo.device_id) paramesers:nil requestHeaderField:@{@"token":instance.token} SuccessJson:^(id json) {
        //        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableLeaves error:nil];
        if ([json[@"message"] intValue] == 200) { //获取成功
            _planModel = [[CustomPlan alloc] init];
            NSArray *resultArray = json[@"result"];
            //* * * * 1,2,3
            NSString *weekString = [resultArray.firstObject objectForKey:@"plan"];
            NSString *weeks =[weekString componentsSeparatedByString:@" "].lastObject;
            NSArray *weedNumbers = [weeks componentsSeparatedByString:@","];
            [weedNumbers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [_planModel.arrPlanWeek addObject:obj];
            }];
            //解析时间段和温度
            NSString *test = [resultArray.firstObject objectForKey:@"cmd"];
            NSData* dataFromString = [[NSData alloc] initWithBase64EncodedString:[resultArray.firstObject objectForKey:@"cmd"] options:0];//base64解码
            if (dataFromString) {
                NSString *result = [NSString stringWithUTF8String:[dataFromString bytes]];
                _planModel.cmd = result;
                [self encodeToCustomModel];
            }
            [self.tableView reloadData];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"获取信息失败"];
        NSLog(@"the error is %@",error.description);
    }];
    
#warning test
//    _planModel = [[CustomPlan alloc] init];
//    _planModel.cmd = @"0x0108060x040x160x050x05";//@"0000 0001 0000 1000 0000 0000   4 22 5 5"
//       [self.tableView reloadData];
}
-(void)encodeToCustomModel
{
    NSString *stepTime = [UtilConversion toBinaryFromHex:[_planModel.cmd substringWithRange:NSMakeRange(2, 6)]];
    NSLog(@"the binary is %@",[UtilConversion toBinaryFromHex:stepTime]) ;
    NSString *tempretures = [_planModel.cmd substringFromIndex:8];
    NSArray *tempArrays =  [tempretures componentsSeparatedByString:@"0x"];
    NSMutableArray *decimalTempretureArrays = [NSMutableArray new];//10进制温度存储
    for (NSString *string in tempArrays) {
        if (string.length) {
            [decimalTempretureArrays addObject:@([UtilConversion numFromString:string])];
        }
    }
    //找到开启的时间
    NSMutableArray *openTimes = [NSMutableArray new];
    NSMutableArray *closeTimes = [NSMutableArray new];
    //@"0000 0001 0000 1000 0000 0000   4    22"
    //先找到开始时间 -0变到1或者 最开始就为1
    for (int i = 0; i < stepTime.length-1; i++) {
        NSString *theStep = [stepTime substringWithRange:NSMakeRange(i, 1)];
        NSString *theNextStep = [stepTime substringWithRange:NSMakeRange(i+1, 1)];
        if (([theStep isEqualToString:@"0"]&&[theNextStep isEqualToString:@"1"])||(i==0&&[theStep isEqualToString:@"1"])) {//开启
            [openTimes addObject:@(i)];
        }
    }
    //找到关闭时间 从1变到0 --找对应温度
    for (int i = 0; i < stepTime.length-1; i++) {
        NSString *theStep = [stepTime substringWithRange:NSMakeRange(i, 1)];
        NSString *theNextStep = [stepTime substringWithRange:NSMakeRange(i+1, 1)];
        if ([theStep isEqualToString:@"1"]&&[theNextStep isEqualToString:@"0"]) {
            [closeTimes addObject:@(i)];
        }
    }
    //设置温度 结束时间-开始时间
    NSMutableArray *tempDatalist = [NSMutableArray new];
    [openTimes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CustomModel *modelTime
        = [CustomModel createCustomModelWithOpenTime:[NSString stringWithFormat:@"%d",[obj intValue]] CloseTime:[NSString stringWithFormat:@"%d",[[closeTimes objectAtIndex:idx] intValue]] Temperature:[decimalTempretureArrays objectAtIndex:0] isOpen:YES];
        //设置温度
        [tempDatalist addObject:modelTime];
    }];
    [tempDatalist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CustomModel *model = obj;
        int start,end,length;
        start =  [model.openTime intValue];
        end = [model.closeTime intValue];
        length = end - start;
        lengthTimerTempreture +=length;
        model.temperature =[NSString stringWithFormat:@"%d",[[decimalTempretureArrays objectAtIndex:lengthTimerTempreture-1] intValue]];
        [self.dataList addObject:model];
    }];
}



- (void) addTableFootView
{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 130)];
    self.tableView.tableFooterView = footView;
    UIButton *addTime = [UIButton newAutoLayoutView];
    [addTime addTarget:self action:@selector(addTimer) forControlEvents:UIControlEventTouchUpInside];
    addTime.backgroundColor = kRGBColor(95, 194, 6, 1);
    [addTime setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addTime setTitle:@"增加定时段" forState:UIControlStateNormal];
    [footView addSubview:addTime];
    [addTime autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [addTime autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [addTime autoSetDimensionsToSize:CGSizeMake(self.view.width - 150, 35)];
}

#pragma mark - Method

- (void)addTimer
{
    if (self.dataList.count >= 8) {
        [SVProgressHUD showErrorWithStatus:@"最多只能添加8个时间段"];
        return;
    }
    CustomTimeViewController *timeVC = [[CustomTimeViewController alloc] init];
    CustomModel *customModel = [CustomModel createCustomModelWithOpenTime:@"--:--" CloseTime:@"--:--" Temperature:@"-" isOpen:NO];
    timeVC.customModel = customModel;
    timeVC.skywareInfo =_skywareInfo;
    timeVC.indexOfTimer = self.dataList.count;
    [self.navigationController pushViewController:timeVC animated:YES];
}


#pragma mark - UITableDelegate-UItableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!section) {
        return 1;
    }else{
        return self.dataList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (!section) {
        return 10;
    }
    return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = @{
            @"1":@"周一",
            @"2":@"周二",
            @"3":@"周三",
            @"4":@"周四",
            @"5":@"周五",
            @"6":@"周六",
            @"0":@"周日"};
    
    if (!indexPath.section) {
        UITableViewCell *section_0_cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"section_0"];
        section_0_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        section_0_cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        section_0_cell.textLabel.text = @"重复:";
        NSMutableString *week=[NSMutableString new];
        [_planModel.arrPlanWeek enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             [week appendString:[NSString stringWithFormat:@"%@、",[dic valueForKey:obj]]];
        }];
//        section_0_cell.detailTextLabel.text = @"周一、周二、周三、周四、周五、周六、周日";
        if (week.length>0) {
            section_0_cell.detailTextLabel.text = [week substringToIndex:week.length -1];
        }else{
            section_0_cell.detailTextLabel.text = @"无";
        }
        return section_0_cell;
    }else{
        NSString *customCellID = @"CustomModelTableViewCell";
        CustomModelTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:customCellID];
        if (customCell == nil) {
            customCell = [CustomModelTableViewCell createCustomCellWithTableView:tableView reuseIdentifier:customCellID];
        }
        customCell.custom = self.dataList[indexPath.row];
        __weak __typeof(customCell) _weakCustomCell = customCell;
        customCell.switchBlock = ^(UISwitch *openSwitch){
            _weakCustomCell.custom.isOpen =  openSwitch.isOn;
        };
        return customCell;
    }
    
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section) {
        return UITableViewCellEditingStyleNone;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataList removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!indexPath.section) {
        [self clickSelectDate];
    }else{
        CustomTimeViewController *timeVC = [[CustomTimeViewController alloc] init];
        timeVC.customModel = self.dataList[indexPath.row];
        timeVC.skywareInfo = _skywareInfo;
        timeVC.indexOfTimer = indexPath.row;
        [self.navigationController pushViewController:timeVC animated:YES];
    }
}

- (void) clickSelectDate
{
    SelectWeekView *weekView = [SelectWeekView createSelectWeekView];
    
    CustomModelTableViewCell *customCell = (CustomModelTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0 ]];
    weekView.defineStr = customCell.detailTextLabel.text;
    
    UIButton *cover = [UIButton newAutoLayoutView];
    [cover addTarget:weekView action:@selector(cleanMethod) forControlEvents:UIControlEventTouchUpInside];
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0.4;
    [[UIWindow getCurrentWindow] addSubview:cover];
    [cover autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    weekView.cleanClick = ^{
        [cover removeFromSuperview];
    };
    weekView.frame = CGRectMake(0, kWindowHeight, kWindowWidth, 352);
    [[UIWindow getCurrentWindow] addSubview:weekView];
    [UIView animateWithDuration:0.4f animations:^{
        weekView.y = (kWindowHeight - weekView.height);
    } completion:^(BOOL finished) {
        
    }];
}


-(void)sendCmdToServer
{
    //将时间段整合成3个字节
    NSMutableArray *tempratures = [NSMutableArray new];
    NSMutableString *timeString =[NSMutableString stringWithString:@"000000000000000000000000"] ;
    [self.dataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CustomModel *model = obj;
        NSInteger start,end,tempture,length;
        if (model.isOpen) {
        start =  [model.openTime intValue];
        end = [model.closeTime intValue];
        length = end - start;
        tempture = [[[NSMutableString stringWithString:model.temperature] stringByReplacingOccurrencesOfString:@"°C" withString:@""] intValue];
        NSMutableString *times = [NSMutableString new];
        //添加温度设置
        for (int j= 0; j< end-start; j++) {
            NSString *tem = [NSString stringWithFormat:@"0x%@",[UtilConversion decimalToHex:tempture]];
            [tempratures addObject:tem];
            [times appendString:@"1"];
        }
        [timeString replaceCharactersInRange:NSMakeRange(start, end-start) withString:times];
        }
    }];
//    if (!times.length) {
//        [[[UIAlertView alloc ]initWithTitle:@"" message:@"请添加时间信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
//        return;
//    }
    if (!_selectedWeekNumbers.count) {
        [[[UIAlertView alloc ]initWithTitle:@"" message:@"请添加重复日期" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        return;
    }
    NSLog(@"the time binary is %@,the hex is 0x%@",timeString,[UtilConversion convertBin:timeString]);
    NSMutableString *timeDataString =[NSMutableString stringWithString:[NSString stringWithFormat:@"0x%@",[UtilConversion convertBin:timeString]]] ;
    [tempratures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [timeDataString appendString:obj];
    }];
    NSData* sampleData = [timeDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString * encodeStr = [sampleData base64EncodedStringWithOptions:0]; //进行base64位编码
    
    NSMutableString *tempkNumbers = [NSMutableString new];
    NSString *weekNumbers;
    [_selectedWeekNumbers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [tempkNumbers appendString:[NSString stringWithFormat:@"%ld,",[obj integerValue]]];
    }];
    if (tempkNumbers.length) {
       weekNumbers =  [tempkNumbers substringToIndex:tempkNumbers.length - 1];
    }
    NSDictionary *dic = @{@"hour":@"12",@"min":@"12",@"cmd":encodeStr,@"plan":[NSString stringWithFormat:@"* * %@",weekNumbers]};
    NSData *timerData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *stepString = [[NSString alloc] initWithData:timerData encoding:NSUTF8StringEncoding];
    NSMutableDictionary *dicTimers = [NSMutableDictionary new];
    [dicTimers setObject:stepString forKey:@"job"];
    [self DeviceCustomMode:dicTimers Success:^(SkywareResult *result) {
        if ([result.message intValue] == 200) {
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(SkywareResult *errResult) {
        NSLog(@"the error is %@",errResult.description);
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
    }];
}


- (void)DeviceCustomMode:(NSDictionary *)parameser Success:(void (^)(SkywareResult *))success failure:(void (^)(SkywareResult *))failure
{
    SkywareInstanceModel *instance = [SkywareInstanceModel sharedSkywareInstanceModel];
    [SkywareHttpTool HttpToolPostWithUrl:kSearchPlan(_skywareInfo.device_id) paramesers:parameser requestHeaderField:@{@"token":instance.token} SuccessJson:^(id json) {
        [SkywareHttpTool responseHttpToolWithJson:json Success:success failure:failure];
        NSLog(@"hello");
        
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark - NotificationCenter
- (void)selectWeekViewCenterBtnClick:(NSNotification *) nsf
{
    NSString *selectWeekStr = nsf.userInfo[@"selectWeekStr"];
    _selectedWeekNumbers = nsf.userInfo[@"selectedNumber"];
    UITableViewCell *section_0_cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    section_0_cell.detailTextLabel.text = selectWeekStr;
}

-(NSMutableArray *)selectedWeekNumbers
{
    if (_selectedWeekNumbers) {
        _selectedWeekNumbers = [NSMutableArray new];
    }
    return _selectedWeekNumbers;
}

@end
