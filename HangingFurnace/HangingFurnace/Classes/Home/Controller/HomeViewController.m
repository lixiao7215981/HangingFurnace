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
#import "ModeSettingCellView.h"

@interface HomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,ASValueTrackingSliderDelegate>
{
    TempretureSetModel *_TModel;
    WhichMode _currentSelectedMode;//当前选择的是“取暖”还是“热水”
}

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
/***  模式设定Cell */
@property (weak, nonatomic) IBOutlet ModeSettingCellView *modeSettingCellView;
/*** 首页的CollectionView */
@property (weak, nonatomic) IBOutlet HomeCollectionView *CollectionView;



/*** 用户所有设备的Array */
@property (nonatomic,strong) NSMutableArray *dataList;

@end

@implementation HomeViewController

static NSString *CollectionViewCellID = @"HomeCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCenterView:^UIView *{
        return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kefeng"]];
    }];
    // 注册CollectionViewCell
    [self registerCollectionNib];
    //设置温度指示
    [self setTSliderView];
    // 适配
    [self setScreenDisplay];
    
    [self.dataList addObject:@(1)];
    [self.dataList addObject:@(2)];
    
}


#pragma mark -----------温度指示
-(void)setTSliderView
{
    self.tempretureSliderView.delegate = self;
    [self.tempretureSliderView customeSliderView];
    
    _currentSelectedMode = ModeHange;//默认选择壁挂炉
    [self updateByMode:_currentSelectedMode];
    
    // 模型Model
    _TModel = [[TempretureSetModel alloc] init];
    _TModel.hangTemp = @(40.0);
    _TModel.hotWaterTemp = @(60.0);
}

-(void)updateByMode:(WhichMode)mode
{
    NSArray *colorHang = [NSArray arrayWithObjects:kRGBColor(113, 173, 197, 0.8),kRGBColor(144, 180, 91, 0.8),[UIColor colorWithHue:0.15 saturation:0.9 brightness:0.9 alpha:1.0], kRGBColor(164, 80, 5, 0.9),[UIColor colorWithHue:0.0 saturation:0.8 brightness:1.0 alpha:1.0], nil];//蓝,绿，黄，浅红，红
    NSArray *positionHang = @[@20, @30, @40, @50, @70];
    
    NSArray *colorsWarmer = [NSArray arrayWithObjects:kRGBColor(113, 173, 197, 0.8),[UIColor colorWithHue:0.0 saturation:0.8 brightness:1.0 alpha:1.0], nil];
    NSArray *positionWarmer = @[@20,  @70];
    
    if (mode == ModeHange) { //壁挂炉
        self.tempretureSliderView.minimumValue = 20.0;
        self.tempretureSliderView.maximumValue = 80.0;
        self.tempretureSliderView.value = [_TModel.hangTemp floatValue];
        [self.tempretureSliderView setPopUpViewAnimatedColors:colorHang withPositions:positionHang];
    }else{ //热水器
        self.tempretureSliderView.minimumValue = 30.0;
        self.tempretureSliderView.maximumValue = 60.0;
        self.tempretureSliderView.value = [_TModel.hotWaterTemp floatValue];
        [self.tempretureSliderView setPopUpViewAnimatedColors:colorsWarmer withPositions:positionWarmer];
    }
}


#pragma mark -ASValueTrackingSliderDelegate
-(void)sliderDidHidePopUpView:(ASValueTrackingSlider *)slider
{
    //存储设定的值
    if (_currentSelectedMode == ModeHange) {
        _TModel.hangTemp = [NSNumber numberWithFloat:slider.value];
    }else{
        _TModel.hotWaterTemp = [NSNumber numberWithFloat:slider.value];
    }
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
    }else if (IS_IPHONE_6P){
        _homeBtnH.constant = HomeiPhone6plus_3;
        _T_setH.constant = HomeiPhone6plus_1;
        _S_setH.constant = HomeiPhone6plus_3;
        _F_setH.constant = HomeiPhone6plus_3;
        _State_setH.constant = HomeiPhone6plus_State;
        _bottomViewH.constant = HomeiPhone6plus_1 + HomeiPhone6plus_3*3;
        _T_colorImgViewH.constant = HomeiPhone6plus_T_colorsettingimg;
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
    //    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
}

#pragma mark - UITapGestureRecognizer
- (IBAction)pushModeVC:(UITapGestureRecognizer *)sender {
    //     [self.navigationController pushViewController:[[ModeSetTableViewController alloc] init] animated:YES];
}

#pragma mark -- ButtonClick

- (IBAction)warmOneselfBtnClick:(UIButton *)sender {
    self.hotWaterBtn.selected = NO;
    self.warmOneselfBtn.selected = YES;
    _currentSelectedMode = ModeHange;
    [self updateByMode:_currentSelectedMode];
}

- (IBAction)hotWaterBtnClick:(UIButton *)sender {
    self.warmOneselfBtn.selected = NO;
    self.hotWaterBtn.selected = YES;
    _currentSelectedMode = ModeHotWater;
    [self updateByMode:_currentSelectedMode];
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
