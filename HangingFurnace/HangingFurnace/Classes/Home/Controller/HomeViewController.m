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

@interface HomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,ASValueTrackingSliderDataSource,ASValueTrackingSliderDelegate>
{
    NSTimer *_timer;
    
    TempretureSetModel *_TModel;
    
    WhichMode _currentSelectedMode;//当前选择的是“壁挂炉”还是“热水器”
}

/*** 首页的温度指示View ***/
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *tempretureSliderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *homeBtnH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *T_setH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *S_setH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *F_setH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *State_setH;


/*** 首页的CollectionView */
@property (weak, nonatomic) IBOutlet HomeCollectionView *CollectionView;
/*** 用户所有设备的Array */
@property (nonatomic,strong) NSMutableArray *dataList;

@end

@implementation HomeViewController

static NSString *CollectionViewCellID = @"HomeCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"kefeng"];
    
    // 模拟下载进度
//    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(setPersentageWith:) userInfo:@(80.5) repeats:YES];
    
    
    [self registerCollectionNib];
    
    [self.dataList addObject:@(1)];
    [self.dataList addObject:@(2)];
    
    [self setTSliderView];
    
    [self setScreenDisplay];
    
}
-(void)setTSliderView
{
//    self.tempretureSliderView.dataSource = self;
    self.tempretureSliderView.delegate = self;
    [self.tempretureSliderView customeSliderView];

    _currentSelectedMode = ModeHange;//默认选择壁挂炉
    [self updateByMode:_currentSelectedMode];
    
    _TModel = [[TempretureSetModel alloc] init];
    _TModel.hangTemp = @(40.0);
    _TModel.hotWaterTemp = @(60.0);

}

-(void)updateByMode:(WhichMode)mode
{
    NSArray *colorHang = [NSArray arrayWithObjects:myColor(113, 173, 197, 0.8),myColor(144, 180, 91, 0.8),[UIColor colorWithHue:0.15 saturation:0.9 brightness:0.9 alpha:1.0], myColor(164, 80, 5, 0.9),[UIColor colorWithHue:0.0 saturation:0.8 brightness:1.0 alpha:1.0], nil];//蓝,绿，黄，浅红，红
    NSArray *positionHang = @[@20, @30, @40, @50, @70];
    
    NSArray *colorsWarmer = [NSArray arrayWithObjects:myColor(113, 173, 197, 0.8),[UIColor colorWithHue:0.0 saturation:0.8 brightness:1.0 alpha:1.0], nil];
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


- (void)setScreenDisplay
{
//    if () {
//        <#statements#>
//    }
}

- (void) setPersentageWith:(NSTimer *) params
{
    CGFloat end = [params.userInfo floatValue]/100;
    static CGFloat progress = 15 / 100;
    // 循环
    if (progress <= end){
        progress += 0.01;
        //            self.circleView.persentage = progress;
    }else{
        [_timer invalidate];
    }
    // 进度数字
    NSString *progressStr = [NSString stringWithFormat:@"%.0f", progress * 100];
    NSLog(@"%@",progressStr);
}


#pragma mark --在壁挂炉和取暖之间切换
- (IBAction)modeButtonClicked:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"壁挂炉"]) {
        _currentSelectedMode = ModeHange;
    }else{
        _currentSelectedMode = ModeHotWater;
    }
    [self updateByMode:_currentSelectedMode];
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
    
    return collectionViewCell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 计算当前页数
    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
}

#pragma mark - 懒加载
- (NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}


#pragma mark - ASValueTrackingSliderDataSource--暂时未用
- (NSString *)slider:(ASValueTrackingSlider *)slider stringForValue:(float)value;
{
    value = roundf(value);
    NSString *s;
    if (value < 30.0) {
        s = @"❄️Brrr!⛄️";
    } else if (value > 40.0 && value < 50.0) {
        s = [NSString stringWithFormat:@"😎 %@ 😎", [slider.numberFormatter stringFromNumber:@(value)]];
    } else if (value >= 70.0) {
        s = @"I’m Melting!";
    }
    return s;
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
@end
