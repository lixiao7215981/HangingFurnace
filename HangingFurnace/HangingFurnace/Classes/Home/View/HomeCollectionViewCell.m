//
//  HomeCollectionViewCell.m
//  HangingFurnace
//
//  Created by 李晓 on 15/9/6.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "HomeCollectionViewCell.h"
#import "TCircleView.h"
#import "SendCommandManager.h"

@interface HomeCollectionViewCell ()
{
    NSTimer *_timer;
    UILabel *_centerLabel;
    UILabel *_topLabel;
    UILabel *_bottomLabel;
    CGFloat progress;
}

/***  设备的名称 */
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
/***  转圈的圆 */
@property (strong, nonatomic) TCircleView *circleView;
/***  切换季节的按钮 */
@property (weak, nonatomic) IBOutlet UIButton *seasonBtn;


/***  Cell加载完成后的高度 */
@property (nonatomic,assign) CGFloat selfH;
/***  圆圈的宽高 */
@property (nonatomic,assign) CGFloat LoopWH;
/***  温度 Label 字体 */
@property (nonatomic,assign) CGFloat centerFont;
/***  水压 Label 字体 */
@property (nonatomic,assign) CGFloat topBottomFont;

@property (nonatomic,strong) DeviceData *currentDeviceData;
@end

@implementation HomeCollectionViewCell

+ (void)load
{
    Method existing = class_getInstanceMethod(self, @selector(layoutSubviews));
    Method new = class_getInstanceMethod(self, @selector(_autolayout_replacementLayoutSubviews));
    method_exchangeImplementations(existing, new);
}

/**
 *  切换季节
 *  default  ： 冬季
 *  selected ： 夏季
 */
- (IBAction)switchSeason:(UIButton *)sender {
    sender.selected = !sender.selected;
    _currentDeviceData.seasonWinter = sender.selected;
    [SendCommandManager sendSeasonChangeCmd:_skywareInfo];
}

- (void)_autolayout_replacementLayoutSubviews
{
    [super layoutSubviews];
    [self _autolayout_replacementLayoutSubviews]; // not recursive due to method swizzling
    [super layoutSubviews];
}

- (void)awakeFromNib {
    // 默认大小
    progress = 15 / 100;
    CGFloat CirX = kWindowWidth * 0.5 - self.LoopWH *0.5;
    CGFloat CirY = 7;
    _circleView = [[TCircleView alloc] initWithFrame:CGRectMake(CirX, CirY, self.LoopWH, self.LoopWH)];
    [self addSubview:_circleView];
    _topLabel = [UILabel newAutoLayoutView];
    _topLabel.text = @"壁炉温度";
    [self addSubview:_topLabel];
    _centerLabel = [UILabel newAutoLayoutView];
    [self addSubview:_centerLabel];
    _bottomLabel = [UILabel newAutoLayoutView];
    _bottomLabel.text = @"水压2.3bar";
    _centerLabel.text = @"26°";
    [self addSubview:_bottomLabel];
    //如果没有设备 --则显示“未添加设备，无法设定模式”
    if (_skywareInfo == nil) {
        _deviceName.text = @"未添加设备，无法设定模式";
    }
}


//根据模型跟新视图----当前水温，当前气压，夏季（冬季），
-(void)setSkywareInfo:(SkywareDeviceInfoModel *)skywareInfo
{
    _skywareInfo = skywareInfo;
    if (_skywareInfo) {
        _currentDeviceData = skywareInfo.device_data;
        _deviceName.text = skywareInfo.device_name;
        _seasonBtn.selected = !_currentDeviceData.seasonWinter;
        _bottomLabel.text =[NSString stringWithFormat:@"水压%.1lfbar",_currentDeviceData.currentPressure];//当前水压
        [self setTemperatureWithT:_currentDeviceData.currentTempreture];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    _topLabel.font = [UIFont systemFontOfSize:self.topBottomFont];
    [_topLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:_circleView];
    [_topLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_circleView withOffset:- self.LoopWH *0.25];
    
    _centerLabel.font = [UIFont systemFontOfSize:self.centerFont];
    [_centerLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:_circleView withOffset:10];
    [_centerLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_circleView];
    
    _bottomLabel.font = [UIFont systemFontOfSize:self.topBottomFont];
    [_bottomLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:_circleView];
    [_bottomLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_circleView withOffset:self.LoopWH*0.25];
}

- (void) setTemperatureWithT:(double) t
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(setPersentageWith:) userInfo:@(t) repeats:YES];
}

- (void) setPersentageWith:(NSTimer *) params
{
    CGFloat end = [params.userInfo floatValue]/100;
    if (progress <= end){
        progress += 0.008;
        _circleView.persentage = progress;
    }else{
        [_timer invalidate];
    }
    // 进度数字
    NSString *progressStr = [NSString stringWithFormat:@"%.0f°", progress * 100];
    _centerLabel.text = progressStr;
}


#pragma mark - Method

- (CGFloat)selfH
{
    if (_selfH == 0) {
        CGFloat bottomViewH = 0;
        if (IS_IPHONE_4_OR_LESS) {
            bottomViewH = HomeiPhone5s_or_less_1 + HomeiPhone5s_or_less_3*3;
            _selfH = kWindowHeight - HomeiPhone5s_or_less_State - bottomViewH - 64;
        }else if (IS_IPHONE_5_OR_5S){
            bottomViewH = HomeiPhone5s_or_less_1 + HomeiPhone5s_or_less_3*3;
            _selfH = kWindowHeight - HomeiPhone5s_or_less_State - bottomViewH - 64;
        }else if (IS_IPHONE_6_OR_6S){
            bottomViewH = HomeiPhone6_1 + HomeiPhone6_3*3;
            _selfH = kWindowHeight - HomeiPhone6_State - bottomViewH - 64;
        }else if (IS_IPHONE_6P_OR_6PS){
            bottomViewH = HomeiPhone6plus_1 + HomeiPhone6plus_3*3;
            _selfH = kWindowHeight - HomeiPhone6plus_State - bottomViewH - 64;
        }
    }
    return _selfH;
}

- (CGFloat)LoopWH
{
    if (_LoopWH == 0) {
        if (IS_IPHONE_4_OR_LESS) {
            _LoopWH =  self.selfH - 10;
        }else if (IS_IPHONE_5_OR_5S){
            _LoopWH =  self.selfH - 5;
        }else if (IS_IPHONE_6_OR_6S){
            _LoopWH =  self.selfH - 15;
        }else if (IS_IPHONE_6P_OR_6PS){
            _LoopWH =  self.selfH - 10;
        }
    }
    return _LoopWH;
}

- (CGFloat)centerFont
{
    if (_centerFont == 0) {
        if (IS_IPHONE_4_OR_LESS) {
            _centerFont = 60;
        }else if (IS_IPHONE_5_OR_5S){
            _centerFont = 90;
        }else if (IS_IPHONE_6_OR_6S){
            _centerFont = 90;
        }else if (IS_IPHONE_6P_OR_6PS){
            _centerFont = 100;
        }
    }
    return _centerFont;
}

- (CGFloat)topBottomFont
{
    if (_topBottomFont == 0) {
        if (IS_IPHONE_4_OR_LESS) {
            _topBottomFont = 9;
        }else if (IS_IPHONE_5_OR_5S){
            _topBottomFont = 13;
        }else if (IS_IPHONE_6_OR_6S){
            _topBottomFont = 13;
        }else if (IS_IPHONE_6P_OR_6PS){
            _topBottomFont = 20;
        }
    }
    return _topBottomFont;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self switchSeason:self.seasonBtn];
//}

@end
