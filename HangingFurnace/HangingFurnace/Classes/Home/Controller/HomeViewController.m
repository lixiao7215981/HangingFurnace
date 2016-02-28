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
#import "DeviceData.h"
#import "UtilConversion.h"
#import "DeviceStatusConst.h"
#import "SendCommandManager.h"
#import "DeviceData.h"
#import <NSString+Extension.h>
#import <AddDeviceViewController.h>

@interface HomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,ASValueTrackingSliderDelegate,UIAlertViewDelegate>

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

@property (nonatomic,assign) BOOL willScroll;

@property (nonatomic,strong) SkywareDeviceInfoModel *currentSkywareInfo;//当前设备 -- 用于在多个设备之间切换

@end

@implementation HomeViewController

static NSString *CollectionViewCellID = @"HomeCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBarBtn];
    // 冬季模式下默认为采暖 测试默认是地暖
//    HFInstance *instance = [HFInstance sharedHFInstance];
//    instance.heatingState = heating_floor;
//    [self warmOneselfBtnClick:nil];
    // 注册CollectionViewCell
    [self registerCollectionNib];
    //设置温度指示
    [self setTSliderView];
    // 适配
    [self setScreenDisplay];
//    [self downloadDeviceList];
    
    [kNotificationCenter addObserver:self selector:@selector(MQTTMessage:) name:kSkywareNotificationCenterCurrentDeviceMQTT object:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self downloadDeviceList];
}
-(void)viewWillDisappear:(BOOL)animated
{
    _willScroll = NO;
    if (self.dataList.count) {
        SkywareDeviceInfoModel *deviceInfo = [self.dataList objectAtIndex:self.pageVC.currentPage];
        NSString *key = [NSString stringWithFormat:@"%@-currrentDeviceIndex", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
        [[NSUserDefaults standardUserDefaults] setObject:deviceInfo.device_mac  forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(int)getCurrentDeviceIndex
{
    NSString *key = [NSString stringWithFormat:@"%@-currrentDeviceIndex", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    NSString *deviceMac = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    for (int i = 0 ; i < self.dataList.count; i++) {
        SkywareDeviceInfoModel *deviceInfo = [self.dataList objectAtIndex:i];
        if ([deviceInfo.device_mac isEqualToString:deviceMac]) {
            return i;
            break;
        }
    }
    return 0;//如果没有找到则认为是第一个
}

/**
 *  获取设备列表
 */
-(void)downloadDeviceList
{
    [SVProgressHUD showInfoWithStatus:@"加载中..."];
    [SkywareDeviceManager DeviceGetAllDevicesSuccess:^(SkywareResult *result) {
        [SVProgressHUD dismiss];
        if ([result.message intValue] == 200) {
            SkywareSDKManager *manager = [SkywareSDKManager sharedSkywareSDKManager];
            // 订阅所有设备
            [SkywareNotificationCenter subscribeUserBindDevices];
            
            [self.dataList removeAllObjects];
            [manager.bind_Devices_Array enumerateObjectsUsingBlock:^(SkywareDeviceInfoModel* obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DeviceData *deviceM = [[DeviceData alloc] initWithBase64String: [obj.device_data[@"bin"] toHexStringFromBase64String]];
                obj.device_data = deviceM;
                [self.dataList addObject:obj];
            }];
           
             manager.currentDevice =  [self.dataList objectAtIndex:[self getCurrentDeviceIndex]];
            
            self.pageVC.numberOfPages = self.dataList.count;
            if (self.dataList.count>1) {
                self.pageVC.hidden = NO;
            }else{
                self.pageVC.hidden = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initViewAfterLoadedData];
            });
        }
    } failure:^(SkywareResult *result) {
        [SVProgressHUD dismiss];
        if([result.message intValue] == 404) {//没有设备
//            [self.dataList removeAllObjects];
//            self.pageVC.numberOfPages = 1;
//            self.pageVC.hidden = YES;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                                [self initViewAfterLoadedData];
//                            });
#warning  test 添加假设备
            NSString *sourceStr = @"20011010210100411f4215";
            NSData* sampleData = [sourceStr dataUsingEncoding:NSUTF8StringEncoding]; //开机，夏季
            NSString * base64String = [sampleData base64EncodedStringWithOptions:0];
            NSDictionary *dictionaryOne = @{@"device_id":@"100435",@"device_mac":@"111",@"device_sn":@"123456",@"device_name":@"我的房间",
                                            @"device_online":@"1",
                                            @"device_data":base64String,
                                            };
            SkywareDeviceInfoModel *dev = [SkywareDeviceInfoModel objectWithKeyValues:dictionaryOne];
            NSDictionary *dictionaryTwo = @{@"device_id":@"100435",@"device_mac":@"111",@"device_sn":@"123456",@"device_name":@"我的卧室",
                                            @"device_online":@"1",
                                            @"device_data":base64String,
                                            };
            SkywareDeviceInfoModel *devTwo = [SkywareDeviceInfoModel objectWithKeyValues:dictionaryTwo];
            
            NSData* dataFromString = [[NSData alloc] initWithBase64EncodedString:base64String options:0];//base64解码
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
            dev.device_data = [[DeviceData alloc] initWithBase64String:hexStr];
            devTwo.device_data = [[DeviceData alloc] initWithBase64String:hexStr];
            [self.dataList insertObject:dev atIndex:0];
            _currentSkywareInfo = self.dataList.firstObject;
            self.pageVC.numberOfPages= self.dataList.count;
            self.pageVC.hidden = YES;
//用来测试
            [self.CollectionView reloadData];//刷新CollectionView

        }else{
            [SVProgressHUD showErrorWithStatus:@"获取设备列表失败"];
        }
    }];
}

- (void)setNavBarBtn
{
//    [self setCenterView:^UIView *{
//        return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kefeng"]];
//    }];
    [self setNavTitle:@"Kefeng"];
    
    [self setLeftBtnWithImage:[UIImage imageNamed:@"menu"] orTitle:nil ClickOption:^{
        UserMenuViewController *menu = [[UserMenuViewController alloc] init];
        [MainDelegate.navigationController pushViewController:menu animated:YES];
    }];
    
    [self setRightBtnWithImage:[UIImage imageNamed:@"addDevice"] orTitle:nil ClickOption:^{
        AddDeviceViewController *add = [[AddDeviceViewController alloc] init];
        add.addDevice = YES;
    
        [MainDelegate.navigationController pushViewController:add animated:YES];
    }];
}

//下载完设备列表后刷新界面
-(void)initViewAfterLoadedData
{
    if (self.dataList.count > 0) {
        _currentSkywareInfo = [self.dataList objectAtIndex:self.pageVC.currentPage];
        DeviceData *deviceData = _currentSkywareInfo.device_data;
        [self updatePowerStatus:_currentSkywareInfo];//更新开关按钮
        [self updateTempretureByMode:deviceData]; //更新温度指示
        [self.CollectionView reloadData];//刷新CollectionView
        //设置模式
        [self deviceModeChange];
    }else{//添加设备
        [self.btnPower setImage:[UIImage imageNamed:@"addDevice"] forState:UIControlStateNormal];
    }
}

- (void)deviceModeChange
{
    HFInstance *instance = ((DeviceData *)_currentSkywareInfo.device_data).totalInstance;
    if (instance.deviceFunState == heating_fun) {
        [self warmOneselfBtnClick:nil];
    }else if (instance.deviceFunState == hotwater_fun){
        [self hotWaterBtnClick:nil];
    }
}


-(void)updatePowerStatus:(SkywareDeviceInfoModel *)skywareInfo
{
    if ([skywareInfo.device_online boolValue]) {
        DeviceData *deviceData = (DeviceData *)skywareInfo.device_data;
        if ([deviceData.btnPower boolValue]) { //设备开机
            [self setDevicePowerButton:_btnPower withDefalutImage:@"home_power_on" PressedImage:@"home_power_on_down"];
        }else{
            [self setDevicePowerButton:_btnPower withDefalutImage:@"home_power_off" PressedImage:@"home_power_off_down"];
        }
    }else{ //设备不在线
        [self.btnPower setImage:[UIImage imageNamed:@"off_line"] forState:UIControlStateNormal];
    }
}
#pragma mark -----------温度指示
-(void)setTSliderView
{
    self.tempretureSliderView.delegate = self;
    [self.tempretureSliderView customeSliderView];
}


-(void)updateTempretureByMode:(DeviceData *)deviceData
{
    //    NSArray *colorHang = [NSArray arrayWithObjects:kRGBColor(113, 173, 197, 0.8),kRGBColor(144, 180, 91, 0.8),[UIColor colorWithHue:0.15 saturation:0.9 brightness:0.9 alpha:1.0], kRGBColor(164, 80, 5, 0.9),[UIColor colorWithHue:0.0 saturation:0.8 brightness:1.0 alpha:1.0], nil];//蓝,绿，黄，浅红，红
    //    NSArray *positionHang = @[@20, @30, @40, @50, @70];
    //
    //    NSArray *colorsWarmer = [NSArray arrayWithObjects:kRGBColor(113, 173, 197, 0.8),[UIColor colorWithHue:0.0 saturation:0.8 brightness:1.0 alpha:1.0], nil];
    //    NSArray *positionWarmer = @[@20,  @70];
    //        [self.tempretureSliderView setPopUpViewAnimatedColors:colorsWarmer withPositions:positionWarmer];
    HFInstance *instance = deviceData.totalInstance;
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
    DeviceData *deviceData = (DeviceData *)_currentSkywareInfo.device_data;
    HFInstance *instance = deviceData.totalInstance;
    instance.defaultTem = (NSInteger)slider.value;
    //发送指令
    [SendCommandManager sendSettingTempretureCmd:_currentSkywareInfo];
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
    }else if (IS_IPHONE_6_OR_6S){
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
    }else if (IS_IPHONE_6P_OR_6PS){
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


#pragma mark - MQTT 消息推送
- (void)MQTTMessage:(NSNotification *)not
{
    SkywareMQTTModel *model = [not.userInfo objectForKey:kSkywareMQTTuserInfoKey];
    [self updateMQTTDeviceStatus:model];
}
/**
 *  MQTT 更新当前设备状态（根据当前设备的mac）
 */
-(void)updateMQTTDeviceStatus:(SkywareMQTTModel *)MqttM
{
    SkywareDeviceInfoModel *deviceInfo = nil;
    if (MqttM.mac && [self.dataList count]>0)
    {
        for (int i=0; i<self.dataList.count; i++) {
            deviceInfo= (SkywareDeviceInfoModel *)[self.dataList objectAtIndex:i];
            if ([deviceInfo.device_mac isEqualToString:MqttM.mac]) {
                if (MqttM.device_online == 0) { //设备掉线的时候才返回
                    deviceInfo.device_online =[NSString stringWithFormat:@"%d",MqttM.device_online] ;
                }else{
                    deviceInfo.device_online = @"1";////掉线之后再上线
                }
                deviceInfo.device_data = [[DeviceData alloc] initWithBase64String:[[MqttM.data firstObject] toHexStringFromBase64String]];
                //刷新Cell界面
                dispatch_async(dispatch_get_main_queue(), ^{
                    HomeCollectionViewCell *collectionCell = (HomeCollectionViewCell *) [self.CollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    collectionCell.skywareInfo = deviceInfo;
                    //只更新当前设备首页信息---ybyao07
                    SkywareDeviceInfoModel *currentDevice = [self.dataList objectAtIndex:self.pageVC.currentPage];
                    if ([currentDevice.device_mac isEqualToString:MqttM.mac]) {
                        [self initViewAfterLoadedData];
                    }
                });
            }
        }
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
    if (self.dataList.count) {
        return self.dataList.count;
    }else
    {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellID forIndexPath:indexPath];
    if (self.dataList.count > 0) {
        if (_willScroll) {
        }else{
            collectionViewCell.skywareInfo = self.dataList[indexPath.row];
        }
    }
    return collectionViewCell;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _willScroll = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 计算当前页数
    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.pageVC.currentPage = page;
    SkywareSDKManager *manager = [SkywareSDKManager sharedSkywareSDKManager];
    manager.currentDevice = [self.dataList objectAtIndex:page];
    [self initViewAfterLoadedData];
    NSLog(@"----------切换下一个设备--------");
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",indexPath.row);
}

#pragma mark - UITapGestureRecognizer
- (IBAction)pushModeVC:(UITapGestureRecognizer *)sender {
    SettingModelViewController *settingModelVC = [[SettingModelViewController alloc] init];
    settingModelVC.skywareInfo = _currentSkywareInfo;
    [self.navigationController pushViewController:settingModelVC animated:YES];
}

#pragma mark -- ButtonClick
/**
 *  点击了采暖按钮
 */
- (IBAction)warmOneselfBtnClick:(UIButton *)sender {
    DeviceData *deviceData = _currentSkywareInfo.device_data;
    self.hotWaterBtn.selected = NO;
    self.warmOneselfBtn.selected = YES;
    HFInstance *instance = deviceData.totalInstance;
    instance.deviceFunState = heating_fun;
    [self updateTempretureByMode:deviceData];
    self.deviceModelLabel.text = [instance.deviceHeatingModelArray objectAtIndex:instance.heating_select_model];
    [SendCommandManager sendModeCmd:_currentSkywareInfo];
}

/**
 *  点击了热水
 */
- (IBAction)hotWaterBtnClick:(UIButton *)sender {
    DeviceData *deviceData = _currentSkywareInfo.device_data;
    self.warmOneselfBtn.selected = NO;
    self.hotWaterBtn.selected = YES;
    HFInstance *instance = deviceData.totalInstance;
    instance.deviceFunState = hotwater_fun;
    [self updateTempretureByMode:deviceData];
    self.deviceModelLabel.text = [instance.deviceHotwaterModelArray objectAtIndex:instance.hotwater_select_model];
    [SendCommandManager sendModeCmd:_currentSkywareInfo];
}


/**
 *  开关机，wifi,添加设备
 *
 *  @param sender 开关机按钮
 */
- (IBAction)changePower:(UIButton *)sender {
    long index = self.pageVC.currentPage;
    if (self.dataList.count) {
        if ( index < self.dataList.count ) {
            SkywareDeviceInfoModel *deviceInfo = [self.dataList objectAtIndex:index];
            if (deviceInfo.device_online.boolValue) {
                [SendCommandManager sendDeviceOpenCloseCmd:deviceInfo];
            }else{
                //设备不在线
                [self showAlterView];
            }
        }
    }else{
        //直接进入添加设备界面
        AddDeviceViewController *add = [[AddDeviceViewController alloc] init];
        add.addDevice = YES;
        [MainDelegate.navigationController pushViewController:add animated:YES];
    }
}
/**
 *  设备不在线
 */
-(void)showAlterView
{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备已离线" message:DeviceOffLine delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新配置WiFi",@"刷新", nil];
    [view show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { //重新配网
        AddDeviceViewController *add = [[AddDeviceViewController alloc] init];
        add.addDevice = NO;
        [self.navigationController pushViewController: add animated:YES];
    }
    if (buttonIndex == 2) { //刷新
        [self downloadDeviceList];
    }
}

-(void)setDevicePowerButton:(UIButton *)powerBtn withDefalutImage:(NSString *)defaultImage PressedImage:(NSString *)pressedImage
{
    [powerBtn setImage:[UIImage imageNamed:defaultImage] forState:UIControlStateNormal];
    [powerBtn setImage:[UIImage imageNamed:pressedImage] forState:UIControlStateHighlighted];
}

- (void)MQTTnewMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos
{
    NSLog(@"--Cell_MQTT:%@",[data JSONString]);
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
