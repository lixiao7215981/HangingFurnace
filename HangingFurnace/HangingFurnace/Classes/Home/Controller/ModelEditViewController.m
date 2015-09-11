//
//  ModelEditViewController.m
//  HangingFurnace
//
//  Created by 李晓 on 15/9/8.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "ModelEditViewController.h"

#define timeTableH 240
#define btn_cell_Margin 20;

@interface ModelEditViewController ()
{
    UIButton *_topBtn;
    UIImageView *_centerImg;
}
@end

@implementation ModelEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:self.navtext];
    
    [self setTopTitle];
    [self setCenterTableCellView];
    [self setBottomState];
    [self addTimePoint];
}

- (void) setTopTitle
{
    UIButton *btn = [UIButton newAutoLayoutView];
    _topBtn = btn;
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"壁挂炉开启关闭时间" forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"model_edit_time"] forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [self.view addSubview:btn];
    [btn autoSetDimensionsToSize:CGSizeMake(self.view.width, 25)];
    [btn autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [btn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:90];
}

- (void) setCenterTableCellView
{
    UIImageView *imageView = [UIImageView newAutoLayoutView];
    _centerImg = imageView;
    imageView.image = [UIImage imageNamed:@"time_table"];
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15];
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15];
    [imageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_topBtn withOffset:30];
    [imageView autoSetDimension:ALDimensionHeight toSize:240];
}

- (void) setBottomState
{
    UIView *bottomView = [UIView newAutoLayoutView];
    [self.view addSubview:bottomView];
    [bottomView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_centerImg withOffset:40];
    [bottomView autoSetDimensionsToSize:CGSizeMake(240, 20)];
    [bottomView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    UIButton *redBtn = [UIButton newAutoLayoutView];
    redBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [redBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [redBtn setTitle:@"红色为开启时间" forState:UIControlStateNormal];
    [redBtn setImage:[UIImage imageNamed:@"redBtn"] forState:UIControlStateNormal];
    redBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [bottomView addSubview:redBtn];
    [redBtn autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeRight];
    [redBtn autoSetDimension:ALDimensionWidth toSize:120];
    
    UIButton *writeBtn = [UIButton newAutoLayoutView];
    writeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [writeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [writeBtn setTitle:@"其他为关闭时间" forState:UIControlStateNormal];
    [writeBtn setImage:[UIImage imageNamed:@"writeBtn"] forState:UIControlStateNormal];
    writeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [bottomView addSubview:writeBtn];
    [writeBtn autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeLeft];
    [writeBtn autoSetDimension:ALDimensionWidth toSize:120];
}

- (void) addTimePoint
{
    NSInteger rowCount = 6;  // 行数
    NSInteger colCount = 4;  //列数
    
    CGFloat timeTableW = self.view.width - 30;   // 表格宽度
    CGFloat timeTableCellH = timeTableH / colCount ; // 表格一个Cell 的高度
    
    CGFloat  viewW = timeTableCellH - btn_cell_Margin;  // Point 的宽度
    CGFloat  viewH = viewW;                             // Point 的高度
    
    CGFloat rowMargin = (timeTableW - rowCount * viewW) / (rowCount + 1);   // 行间距
    CGFloat colMargin = btn_cell_Margin;                                    // 列间距
    
    for (int i = 0; i < 24; i++) {
        int row = i / rowCount;
        int col = i % rowCount;
        
        CGFloat appX = col * (viewW + rowMargin) + rowMargin;
        CGFloat appY = 0;
        if (row == 0) {
            appY = 10;
        }else{
            appY = row * timeTableCellH + colMargin * 0.5;
        }
        
        UIButton *point = [[UIButton alloc] init];
        [point addTarget:self action:@selector(pointBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [point setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        [point setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [point setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [point setBackgroundImage:[UIImage imageNamed:@"point_select"] forState:UIControlStateSelected];
        point.layer.cornerRadius = 20;
        point.clipsToBounds = YES;
        point.userInteractionEnabled = self.isEdit;
        point.frame = CGRectMake(appX,appY, viewW, viewH);
        [_centerImg addSubview:point];
        
        [self.dateArray enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
            NSInteger j = [title integerValue];
            if (i == j) {
                point.selected = YES;
            }
        }];
    }
}

- (void)pointBtnClick:(UIButton *) point
{
    point.selected = !point.selected;
}

@end
