
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

@interface CustomModelViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@end

@implementation CustomModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:self.navtext];
    self.tableView.separatorStyle = UITableViewScrollPositionNone;
    [self addDataList];
    [self addTableFootView];
    
    [kNotificationCenter addObserver:self selector:@selector(selectWeekViewCenterBtnClick:) name:kSelectCustomWeekDateNotification object:nil];
}

- (void)addDataList
{
    CustomModel *custom1 = [CustomModel createCustomModelWithOpenTime:@"--:--" CloseTime:@"--:--" Temperature:@"-" isOpen:NO];
    CustomModel *custom2 = [CustomModel createCustomModelWithOpenTime:@"--:--" CloseTime:@"--:--" Temperature:@"-" isOpen:NO];
    CustomModel *custom3 = [CustomModel createCustomModelWithOpenTime:@"--:--" CloseTime:@"--:--" Temperature:@"-" isOpen:NO];
    CustomModel *custom4 = [CustomModel createCustomModelWithOpenTime:@"--:--" CloseTime:@"--:--" Temperature:@"-" isOpen:NO];
    [self.dataList addObjectsFromArray:@[custom1,custom2,custom3,custom4]];
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
    if (!indexPath.section) {
        UITableViewCell *section_0_cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"section_0"];
        section_0_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        section_0_cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        section_0_cell.textLabel.text = @"重复:";
        section_0_cell.detailTextLabel.text = @"周一、周二、周三、周四、周五、周六、周日";
        return section_0_cell;
    }else{
        NSString *customCellID = @"CustomModelTableViewCell";
        CustomModelTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:customCellID];
        if (customCell == nil) {
            customCell = [CustomModelTableViewCell createCustomCellWithTableView:tableView reuseIdentifier:customCellID];
        }
        customCell.custom = self.dataList[indexPath.row];
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

#pragma mark - NotificationCenter
- (void)selectWeekViewCenterBtnClick:(NSNotification *) nsf
{
    NSString *selectWeekStr = nsf.userInfo[@"selectWeekStr"];
    UITableViewCell *section_0_cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    section_0_cell.detailTextLabel.text = selectWeekStr;
}

@end
