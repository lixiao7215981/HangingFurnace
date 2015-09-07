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

@interface HomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *homeBtnH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *T_setH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *S_setH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *F_setH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *State_setH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewH;


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
    
    // 适配
    [self setScreenDisplay];
    

}

- (void)setScreenDisplay
{
    if (IS_IPHONE_5_OR_LESS) {
        _homeBtnH.constant = 40;
        _T_setH.constant = 80;
        _S_setH.constant = 40;
        _F_setH.constant = 40;
        _State_setH.constant = 50;
        _bottomViewH.constant = 80 + 40*3;
    }else if (IS_IPHONE_6){
        _homeBtnH.constant = 54;
        _T_setH.constant = 95;
        _S_setH.constant = 54;
        _F_setH.constant = 54;
        _State_setH.constant = 60;
    }else if (IS_IPHONE_6P){
        _homeBtnH.constant = 60;
        _T_setH.constant = 100;
        _S_setH.constant = 60;
        _F_setH.constant = 60;
        _State_setH.constant = 65;
    }
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
    HomeCollectionViewCell *collectionViewCell = (HomeCollectionViewCell *)[self.CollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [collectionViewCell updateConstraints];
    
    kFrameLog(collectionViewCell.frame);
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
