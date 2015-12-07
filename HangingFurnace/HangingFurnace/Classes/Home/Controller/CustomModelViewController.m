
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
#import "NSString+NSStringHexToBytes.h"
#import "SendCommandManager.h"

@interface CustomModelViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSMutableArray *arrPlanWeek;

//@property (nonatomic,strong) CustomPlan *planModel;
@property (nonatomic,strong) NSMutableArray *planArray;

@end

@implementation CustomModelViewController

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
#warning test ---删除数据
    CustomModel *model = [[CustomModel alloc] init];
    model.ids = @"27,28";
//    [self deletePlan:model];
#warning test--- end
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
    SkywareInstanceModel *instance = [SkywareInstanceModel sharedSkywareInstanceModel];
    [SkywareHttpTool HttpToolGetWithUrl:kSearchPlan(_skywareInfo.device_id) paramesers:nil requestHeaderField:@{@"token":instance.token} SuccessJson:^(id json) {
        if ([json[@"message"] intValue] == 200) { //获取成功 -- 有计划任务
            NSArray *resultArray = json[@"result"];
            [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dic = obj;
                CustomPlan *plan = [CustomPlan objectWithKeyValues:dic];//其中 cmd 里面包含 开/关，温度信息
                [self.planArray addObject:plan];
            }];
            //两个Plan构成开关机
            for ( int i = 0; i < self.planArray.count; ) {
                CustomPlan *planOpen = [self.planArray objectAtIndex:i];
                CustomPlan *planClose = [self.planArray objectAtIndex:i+1];
                CustomModel *model = [CustomModel createCustomModelWithOpenTime:[NSString stringWithFormat:@"%@ 时",planOpen.hour]  CloseTime:[NSString stringWithFormat:@"%@ 时",planClose.hour] Temperature:[self tempretureEncodeToCustomModelWighString:planOpen.cmd] isOpen:YES];
                model.ids = [NSString stringWithFormat:@"%@,%@",planOpen.id,planClose.id];
                [self.dataList addObject:model];
                i+=2;
            }
            //重复周期  //* * * * 1,2,3
            if (resultArray.count) {
                NSString *weekString = [resultArray.firstObject objectForKey:@"plan"];
                NSString *weeks =[weekString componentsSeparatedByString:@" "].lastObject;
                NSArray *weedNumbers = [weeks componentsSeparatedByString:@","];
                [weedNumbers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [self.arrPlanWeek addObject:obj];
                }];
            }
          [self.tableView reloadData];
        } else if([json[@"message"] intValue] == 404) //没有计划任务
        {
            
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"获取信息失败"];
        NSLog(@"the error is %@",error.description);
    }];
}

//解析 接口cmd字段里面的温度信息
static const long  kLength = 2;
static const long  valueLengthStep = 2;
-(NSString *)tempretureEncodeToCustomModelWighString:(NSString *)encodeString
{
    NSString *temp=@"";
    NSData* dataFromString = [[NSData alloc] initWithBase64EncodedString:encodeString options:0];//base64解码
    Byte *bytes = (Byte *)[dataFromString bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[dataFromString length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    NSString *cmdKey;
    NSString *cmdValue;
    long loctionStar=0; //命令值的起始位置
    long lengthValue=2; //命令值的长度
    for (loctionStar = 0 ; loctionStar < hexStr.length; ) {
        cmdKey = [hexStr substringWithRange:NSMakeRange(loctionStar, kLength)]; //所有的key都是2个字符
        if ([cmdKey isEqualToString:@"10"]) {//开关机  -1 字节
            lengthValue = valueLengthStep;
            loctionStar+=kLength;
            cmdValue = [hexStr substringWithRange:NSMakeRange(loctionStar, lengthValue)];
        }
        else if ([cmdKey isEqualToString:@"21"]){ //热水/供暖模式状态 -2 字节 包含温度信息
            lengthValue = valueLengthStep*2;
            loctionStar+=kLength;
            cmdValue = [hexStr substringWithRange:NSMakeRange(loctionStar, lengthValue)];
            NSString *valueHigh = [cmdValue substringWithRange:NSMakeRange(2, 2)]; //设置的温度
            long setTempreture = [UtilConversion toDecimalFromHex:valueHigh];
            temp = [NSString stringWithFormat:@"%ld°C",setTempreture];
          }
        loctionStar+=lengthValue;
    }
    return temp;
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
    customModel.isAdd = YES;
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
        [self.arrPlanWeek enumerateObjectsUsingBlock:^(NSNumber  *obj, NSUInteger idx, BOOL *stop) {
             [week appendString:[NSString stringWithFormat:@"%@、",[dic valueForKey:[NSString stringWithFormat:@"%d",[obj intValue]]]]];
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
        CustomModel *timeModel = [self.dataList objectAtIndex:indexPath.row];
        [self deletePlan:timeModel];//发送删除计划任务到服务器
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

- (void)clickSelectDate
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

#pragma mark 发送添加任务或者修改任务到服务器   -- 这里需要区分是“添加” 还是 “更改”（只有第一次没有计划的情况下为添加，其它都为修改）
-(void)sendCmdToServer
{
    NSMutableArray *cmdAddPlanArray = [NSMutableArray new];//新添加的计划任务
    NSMutableArray *cmdPutPlanArray = [NSMutableArray new];//更新已经存在的计划任务
    NSMutableString *tempkNumbers = [NSMutableString new];
    NSString *weekNumbers;
    [self.arrPlanWeek enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [tempkNumbers appendString:[NSString stringWithFormat:@"%ld,",[obj integerValue]]];
    }];
    if (tempkNumbers.length) {
        weekNumbers =  [tempkNumbers substringToIndex:tempkNumbers.length - 1];
    }
    [self.dataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CustomModel *model = obj;
        NSDictionary *dicOpen,*dicClose;
        if (model.ids.length) { //存在id，则说明计划已经存在
            NSArray *planIDs = [model.ids componentsSeparatedByString:@","];
            //一个model相当于两个指令----指令需要base64编码
            dicOpen = @{
                        @"hour":[model.openTime substringToIndex:model.openTime.length-2],
                        @"min":@"00",
                        @"cmd":model.isOpen?[self encodeBase64String:[NSString stringWithFormat:@"10012125%@",[UtilConversion decimalToHex:[[model.temperature  substringToIndex:model.temperature.length-2] intValue]]]]:@"", //开机
                        @"plan":[NSString stringWithFormat:@"* * %@",weekNumbers],
                        @"id":[planIDs objectAtIndex:0]
                        };
            dicClose = @{
                         @"hour":[model.closeTime substringToIndex:model.closeTime.length -2],
                         @"min":@"00",
                         @"cmd":model.isOpen?[self encodeBase64String:[NSString stringWithFormat:@"10002125%@",[UtilConversion decimalToHex:[[model.temperature substringToIndex:model.temperature.length -2] intValue]]]]:@"", //关机
                         @"plan":[NSString stringWithFormat:@"* * %@",weekNumbers],
                         @"id":[planIDs objectAtIndex:1]
                         };
        }else{
            //一个model相当于两个指令----指令需要base64编码
            dicOpen = @{
                        @"hour":[model.openTime substringToIndex:model.openTime.length-2],
                        @"min":@"00",
                        @"cmd":model.isOpen?[self encodeBase64String:[NSString stringWithFormat:@"10012125%@",[UtilConversion decimalToHex:[[model.temperature  substringToIndex:model.temperature.length-2] intValue]]]]:@"", //开机
                        @"plan":[NSString stringWithFormat:@"* * %@",weekNumbers]
                        };
            dicClose = @{
                         @"hour":[model.closeTime substringToIndex:model.closeTime.length -2],
                         @"min":@"00",
                         @"cmd":model.isOpen?[self encodeBase64String:[NSString stringWithFormat:@"10002125%@",[UtilConversion decimalToHex:[[model.temperature substringToIndex:model.temperature.length -2] intValue]]]]:@"", //关机
                         @"plan":[NSString stringWithFormat:@"* * %@",weekNumbers]
                         };
        }
        if (model.isAdd) {
            [cmdAddPlanArray addObject:dicOpen];
            [cmdAddPlanArray addObject:dicClose];
        }else{
            [cmdPutPlanArray addObject:dicOpen];
            [cmdPutPlanArray addObject:dicClose];
        }
    }];
    //提交添加计划任务，和更新计划任务到服务器
    if (cmdAddPlanArray.count) { //添加计划任务
        NSData *timerData = [NSJSONSerialization dataWithJSONObject:cmdAddPlanArray options:NSJSONWritingPrettyPrinted error:nil];
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
        } isAddPlan:YES];
    }
    if (cmdPutPlanArray.count) { //更新计划任务
        NSData *timerData = [NSJSONSerialization dataWithJSONObject:cmdPutPlanArray options:NSJSONWritingPrettyPrinted error:nil];
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
        } isAddPlan:NO];
    }
    
//    //将时间段整合成3个字节
//    NSMutableArray *tempratures = [NSMutableArray new];
//    NSMutableString *timeString =[NSMutableString stringWithString:@"000000000000000000000000"] ;
//    [self.dataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        CustomModel *model = obj;
//        NSInteger start,end,tempture,length;
//        if (model.isOpen) {
//        start =  [model.openTime intValue];
//        end = [model.closeTime intValue];
//        length = end - start;
//        tempture = [[[NSMutableString stringWithString:model.temperature] stringByReplacingOccurrencesOfString:@"°C" withString:@""] intValue];
//        NSMutableString *times = [NSMutableString new];
//        //添加温度设置
//        for (int j= 0; j< end-start; j++) {
//            NSString *tem = [NSString stringWithFormat:@"0x%@",[UtilConversion decimalToHex:tempture]];
//            [tempratures addObject:tem];
//            [times appendString:@"1"];
//        }
//        [timeString replaceCharactersInRange:NSMakeRange(start, end-start) withString:times];
//        }
//    }];
////    if (!times.length) {
////        [[[UIAlertView alloc ]initWithTitle:@"" message:@"请添加时间信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
////        return;
////    }
//    if (!self.arrPlanWeek.count) {
//        [[[UIAlertView alloc ]initWithTitle:@"" message:@"请添加重复日期" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
//        return;
//    }
//    NSLog(@"the time binary is %@,the hex is %@",timeString,[UtilConversion convertBin:timeString]);
//    NSMutableString *timeDataString =[NSMutableString stringWithString:[NSString stringWithFormat:@"%@",[UtilConversion convertBin:timeString]]] ;
//    [tempratures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [timeDataString appendString:obj];
//    }];
//    NSData* sampleData = [timeDataString dataUsingEncoding:NSUTF8StringEncoding];
//    NSString * encodeStr = [sampleData base64EncodedStringWithOptions:0]; //进行base64位编码
//    
//    NSMutableString *tempkNumbers = [NSMutableString new];
//    NSString *weekNumbers;
//    [_planModel.arrPlanWeek enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [tempkNumbers appendString:[NSString stringWithFormat:@"%ld,",[obj integerValue]]];
//    }];
//    if (tempkNumbers.length) {
//       weekNumbers =  [tempkNumbers substringToIndex:tempkNumbers.length - 1];
//    }
//    NSDictionary *dic;
////    if (_planModel.planId.length) {//已经有计划，修改计划
////        dic =    @{@"id":_planModel.planId,@"hour":@"12",@"min":@"12",@"cmd":encodeStr,@"plan":[NSString stringWithFormat:@"* * %@",weekNumbers]};
////    }else{ //添加计划
//        dic =  @{@"hour":@(11),@"min":@(12),@"cmd":@"test",@"plan":[NSString stringWithFormat:@"* * %@",@"1"]};
////    }
//    
//    NSMutableArray *arrDic = [[NSMutableArray alloc] initWithObjects:dic, nil];
//    NSData *timerData = [NSJSONSerialization dataWithJSONObject:arrDic options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *stepString = [[NSString alloc] initWithData:timerData encoding:NSUTF8StringEncoding];
//    NSMutableDictionary *dicTimers = [NSMutableDictionary new];
//    [dicTimers setObject:stepString forKey:@"job"];
//    [self DeviceCustomMode:dicTimers Success:^(SkywareResult *result) {
//        if ([result.message intValue] == 200) {
//            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    } failure:^(SkywareResult *errResult) {
//        NSLog(@"the error is %@",errResult.description);
//        [SVProgressHUD showErrorWithStatus:@"上传失败"];
//    }];
}

-(NSString *)encodeBase64String:(NSString *)waitedForEncodeStr
{
    NSData *sampleData = [waitedForEncodeStr hexToBytes];
    NSString * encodeStr = [sampleData base64EncodedStringWithOptions:0]; //进行base64位编码
    return encodeStr;
}

- (void)DeviceCustomMode:(NSDictionary *)parameser Success:(void (^)(SkywareResult *))success failure:(void (^)(SkywareResult *))failure isAddPlan:(BOOL)isAdd
{
    //这里需要判断是修改还是添加 --如果是添加则调用post方法，如果是修改则调用put方法
    SkywareInstanceModel *instance = [SkywareInstanceModel sharedSkywareInstanceModel];
    if (isAdd) { //添加计划
        [SkywareHttpTool HttpToolPostWithUrl:kSearchPlan(_skywareInfo.device_id) paramesers:parameser requestHeaderField:@{@"token":instance.token} SuccessJson:^(id json) {
            [SkywareHttpTool responseHttpToolWithJson:json Success:success failure:failure];
        } failure:^(NSError *error) {
            NSLog(@"其它错误：%@",error.description);
        }];
    }else{//修改计划 -- 根据计划 id
        [SkywareHttpTool HttpToolPutWithUrl:kSearchPlan(_skywareInfo.device_id) paramesers:parameser requestHeaderField:@{@"token":instance.token} SuccessJson:^(id json) {
            [SkywareHttpTool responseHttpToolWithJson:json Success:success failure:failure];
        } failure:^(NSError *error) {
            NSLog(@"其它错误：%@",error.description);
        }];
    }
}
-(void)deletePlan:(CustomModel *)timeModel
{
    NSArray *planIDs = [timeModel.ids componentsSeparatedByString:@","];
    NSMutableString *urlString = [NSMutableString new];
    [planIDs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [urlString appendString:[NSString stringWithFormat:@"%@_",obj]];
    }];
    NSString *requestString = [NSString stringWithFormat:@"%@/%@",kSearchPlan(_skywareInfo.device_id),[urlString substringToIndex:urlString.length -1]];
    SkywareInstanceModel *instance = [SkywareInstanceModel sharedSkywareInstanceModel];
    [SkywareHttpTool HttpToolDeleteWithUrl:requestString paramesers:nil requestHeaderField:@{@"token":instance.token} SuccessJson:^(id json) {
        if ([json[@"message"] intValue] == 200) {
            NSLog(@"删除成功");
        }else{
           NSLog(@"删除失败");
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
         NSLog(@"删除失败");
        [SVProgressHUD dismiss];
    }];
}


#pragma mark - NotificationCenter
- (void)selectWeekViewCenterBtnClick:(NSNotification *) nsf
{
    NSString *selectWeekStr = nsf.userInfo[@"selectWeekStr"];
    self.arrPlanWeek = nsf.userInfo[@"selectedNumber"];
    UITableViewCell *section_0_cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    section_0_cell.detailTextLabel.text = selectWeekStr;
}

-(NSMutableArray *)planArray{
    if (_planArray==nil) {
        _planArray = [NSMutableArray new];
    }
    return _planArray;
}

-(NSMutableArray *)arrPlanWeek
{
    if (_arrPlanWeek ==nil) {
        _arrPlanWeek = [NSMutableArray new];
    }
    return _arrPlanWeek;
}
@end
