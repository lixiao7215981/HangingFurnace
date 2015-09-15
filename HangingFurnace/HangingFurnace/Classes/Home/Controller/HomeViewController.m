//
//  HomeViewController.m
//  HangingFurnace
//
//  Created by 李晓 on 15/9/1.
//  Copyright (c) 2015年 skyware. All rights reserved.
//
#import "HomeViewController.h"
#import "HomeCollectionView.h"
#import "HomeCollectionViewCell.h"
#import "ASValueTrackingSlider.h"
#import "TempretureSetModel.h"
#import "UserMenuViewController.h"
#import "SettingModelViewController.h"
#import <AddDeviceViewController.h>

@interface HomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,ASValueTrackingSliderDelegate>

// ----------------屏幕适配---------------
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *homeBtnH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *T_setH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *S_setH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *F_setH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *State_setH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewH;

/*** 取暖按钮 */
@property (weak, nonatomic) IBOutlet UIButton *warmOneselfBtn;
/*** 热水按钮 */
@property (weak, nonatomic) IBOutlet UIButton *hotWaterBtn;
/*** 首页的温度指示Slider */
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *tempretureSliderView;
/***  温度颜色图片的高度 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *T_colorImgViewH;
/***  模式设定Label */
@property (weak, nonatomic) IBOutlet UILabel *modelSettingLabel;
/***  当前模式 */
@property (weak, nonatomic) IBOutlet UILabel *deviceModelLabel;
/***  温度设定Label */
@property (weak, nonatomic) IBOutlet UILabel *settingTlabel;
/*** 首页的CollectionView */
@property (weak, nonatomic) IBOutlet HomeCollectionView *CollectionView;
/***  首页的分页展示 */
@property (weak, nonatomic) IBOutlet UIPageControl *pageVC;

/**
 *  Slider 温度数值
 */
@property (weak, nonatomic) IBOutlet UILabel *sliderMin;
@property (weak, nonatomic) IBOutlet UILabel *sliderMax;


/*** 用户所有设备的Array */
@property (nonatomic,strong) NSMutableArray *dataList;

@end

@implementation HomeViewController

static NSString *CollectionViewCellID = @"HomeCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBarBtn];
    
    // 冬季模式下默认为采暖 测试默认是地暖
    HFInstance *instance = [HFInstance sharedHFInstance];
    instance.heatingState = heating_floor;
    [self warmOneselfBtnClick:nil];
    
    // 注册CollectionViewCell
    [self registerCollectionNib];
    //设置温度指示
    [self setTSliderView];
    // 适配
    [self setScreenDisplay];
    
    
    [self.dataList addObject:@(1)];
    [self.dataList addObject:@(2)];
    
    
    self.pageVC.numberOfPages= self.dataList.count;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 改变设备工作的模式
    [self deviceModelChange];
    [self updateByMode];
}

- (void)deviceModelChange
{
    HFInstance *instance = [HFInstance sharedHFInstance];
    if (instance.deviceFunState == heating_fun) {
        self.deviceModelLabel.text = [instance.deviceHeatingModelArray objectAtIndex:instance.heating_select_model];
    }else if (instance.deviceFunState == hotwater_fun){
        self.deviceModelLabel.text = [instance.deviceHotwaterModelArray objectAtIndex:instance.hotwater_select_model];
    }
}

- (void) setNavBarBtn
{
    [self setCenterView:^UIView *{
        return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kefeng"]];
    }];
    
    [self setLeftBtnWithImage:[UIImage imageNamed:@"menu"] orTitle:nil ClickOption:^{
        UserMenuViewController *menu = [[UserMenuViewController alloc] init];
        [MainDelegate.navigationController pushViewController:menu animated:YES];
    }];
    
    [self setRightBtnWithImage:[UIImage imageNamed:@"addDevice"] orTitle:nil ClickOption:^{
        AddDeviceViewController *add = [[AddDeviceViewController alloc] init];
        add.isAddDevice = YES;
        [MainDelegate.navigationController pushViewController:add animated:YES];
    }];
}

#pragma mark -----------温度指示
-(void)setTSliderView
{
    self.tempretureSliderView.delegate = self;
    [self.tempretureSliderView customeSliderView];
    [self updateByMode];
}

-(void)updateByMode
{
    //    NSArray *colorHang = [NSArray arrayWithObjects:kRGBColor(113, 173, 197, 0.8),kRGBColor(144, 180, 91, 0.8),[UIColor colorWithHue:0.15 saturation:0.9 brightness:0.9 alpha:1.0], kRGBColor(164, 80, 5, 0.9),[UIColor colorWithHue:0.0 saturation:0.8 brightness:1.0 alpha:1.0], nil];//蓝,绿，黄，浅红，红
    //    NSArray *positionHang = @[@20, @30, @40, @50, @70];
    //
    //    NSArray *colorsWarmer = [NSArray arrayWithObjects:kRGBColor(113, 173, 197, 0.8),[UIColor colorWithHue:0.0 saturation:0.8 brightness:1.0 alpha:1.0], nil];
    //    NSArray *positionWarmer = @[@20,  @70];
    //        [self.tempretureSliderView setPopUpViewAnimatedColors:colorsWarmer withPositions:positionWarmer];
    
    HFInstance *instance = [HFInstance sharedHFInstance];
    NSInteger min = [instance.tRange.firstObject integerValue];
    NSInteger max = [instance.tRange.lastObject integerValue];
    
    self.tempretureSliderView.minimumValue = min;
    self.tempretureSliderView.maximumValue = max;
    self.tempretureSliderView.value = instance.defaultTem;
    
    self.sliderMin.text = [NSString stringWithFormat:@"%ld°C",min];
    self.sliderMax.text = [NSString stringWithFormat:@"%ld°C",max];
    
    //    NSLog(@"%ld---%ld---%ld",[instance.tRange.firstObject integerValue],[instance.tRange.lastObject integerValue],instance.defaultTem);
    
}


#pragma mark -ASValueTrackingSliderDelegate
-(void)sliderDidHidePopUpView:(ASValueTrackingSlider *)slider
{
    //存储设定的值
    HFInstance *instance = [HFInstance sharedHFInstance];
    instance.defaultTem = (NSInteger)slider.value;
}

-(void)sliderWillDisplayPopUpView:(ASValueTrackingSlider *)slider
{
    NSLog(@"the slider value is %lf",slider.value);
}

/**
 *  适配屏幕大小
 */
- (void)setScreenDisplay
{
    if (IS_IPHONE_5_OR_LESS) {
        _homeBtnH.constant = HomeiPhone5s_or_less_3;
        _T_setH.constant = HomeiPhone5s_or_less_1;
        _S_setH.constant = HomeiPhone5s_or_less_3;
        _F_setH.constant = HomeiPhone5s_or_less_3;
        _State_setH.constant = HomeiPhone5s_or_less_State;
        _bottomViewH.constant = HomeiPhone5s_or_less_1 + HomeiPhone5s_or_less_3*3;
        _T_colorImgViewH.constant = HomeiPhone5s_or_less_T_colorsettingimg;
    }else if (IS_IPHONE_6){
        _homeBtnH.constant = HomeiPhone6_3;
        _T_setH.constant = HomeiPhone6_1;
        _S_setH.constant = HomeiPhone6_3;
        _F_setH.constant = HomeiPhone6_3;
        _State_setH.constant = HomeiPhone6_State;
        _bottomViewH.constant = HomeiPhone6_1 + HomeiPhone6_3*3;
        _T_colorImgViewH.constant = HomeiPhone6_T_colorsettingimg;
        self.warmOneselfBtn.titleLabel.font = [UIFont systemFontOfSize:19];
        self.hotWaterBtn.titleLabel.font = [UIFont systemFontOfSize:19];
        self.modelSettingLabel.font = [UIFont systemFontOfSize:16];
        self.deviceModelLabel.font = [UIFont systemFontOfSize:15];
        self.settingTlabel.font = [UIFont systemFontOfSize:16];
    }else if (IS_IPHONE_6P){
        _homeBtnH.constant = HomeiPhone6plus_3;
        _T_setH.constant = HomeiPhone6plus_1;
        _S_setH.constant = HomeiPhone6plus_3;
        _F_setH.constant = HomeiPhone6plus_3;
        _State_setH.constant = HomeiPhone6plus_State;
        _bottomViewH.constant = HomeiPhone6plus_1 + HomeiPhone6plus_3*3;
        _T_colorImgViewH.constant = HomeiPhone6plus_T_colorsettingimg;
        self.warmOneselfBtn.titleLabel.font = [UIFont systemFontOfSize:19];
        self.hotWaterBtn.titleLabel.font = [UIFont systemFontOfSize:19];
        self.modelSettingLabel.font = [UIFont systemFontOfSize:16];
        self.deviceModelLabel.font = [UIFont systemFontOfSize:15];
        self.settingTlabel.font = [UIFont systemFontOfSize:16];
    }
}

#pragma mark - CollectionViewDelegate / DataSource

- (void) registerCollectionNib
{
    UINib *xib = [UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil];
    [self.CollectionView registerNib:xib forCellWithReuseIdentifier:CollectionViewCellID];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellID forIndexPath:indexPath];
    [collectionViewCell setTemperatureWithT:80];
    return collectionViewCell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 计算当前页数
    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.pageVC.currentPage = page;
}

#pragma mark - UITapGestureRecognizer
- (IBAction)pushModeVC:(UITapGestureRecognizer *)sender {
    SettingModelViewController *settingModelVC = [[SettingModelViewController alloc] init];
    [self.navigationController pushViewController:settingModelVC animated:YES];
}

#pragma mark -- ButtonClick

/**
 *  点击了采暖按钮
 */
- (IBAction)warmOneselfBtnClick:(UIButton *)sender {
    self.hotWaterBtn.selected = NO;
    self.warmOneselfBtn.selected = YES;
    HFInstance *instance = [HFInstance sharedHFInstance];
    instance.deviceFunState = heating_fun;
    [self updateByMode];
    self.deviceModelLabel.text = [instance.deviceHeatingModelArray objectAtIndex:instance.heating_select_model];
}

/**
 *  点击了热水
 */
- (IBAction)hotWaterBtnClick:(UIButton *)sender {
    self.warmOneselfBtn.selected = NO;
    self.hotWaterBtn.selected = YES;
    HFInstance *instance = [HFInstance sharedHFInstance];
    instance.deviceFunState = hotwater_fun;
    [self updateByMode];
    self.deviceModelLabel.text = [instance.deviceHotwaterModelArray objectAtIndex:instance.hotwater_select_model];
}

#pragma mark - 懒加载
- (NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

@end
