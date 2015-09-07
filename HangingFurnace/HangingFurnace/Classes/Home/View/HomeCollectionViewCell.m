//
//  HomeCollectionViewCell.m
//  HangingFurnace
//
//  Created by 李晓 on 15/9/6.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "HomeCollectionViewCell.h"
#import "TCircleView.h"

@interface HomeCollectionViewCell ()
{
    NSTimer *_timer;
}
@property (strong, nonatomic) TCircleView *circleView;

@end

@implementation HomeCollectionViewCell

- (void)awakeFromNib {
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat CirWH =  0;
    CGFloat CirX = 0;
    CGFloat CirY = 0;
    if (IS_IPHONE_4_OR_LESS) {
        CirWH =  self.height - 10;
        CirY = 15;
    }else if (IS_IPHONE_5){
        CirWH =  self.height - 5;
        CirY = 15;
    }else if (IS_IPHONE_6){
        CirWH =  self.height - 25;
        CirY = 5;
    }else if (IS_IPHONE_6P){
        CirWH =  self.height -40;
        CirY = 0;
    }
    CirX = self.width * 0.5 - CirWH *0.5;
    _circleView = [[TCircleView alloc] initWithFrame:CGRectMake(CirX, CirY, CirWH, CirWH)];
    [self addSubview:_circleView];
}

- (void) setTemperatureWithT:(double) t
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(setPersentageWith:) userInfo:@(t) repeats:YES];
}

- (void) setPersentageWith:(NSTimer *) params
{
    CGFloat end = [params.userInfo floatValue]/100;
    static CGFloat progress = 15 / 100;
    // 循环
    if (progress <= end){
        progress += 0.01;
        self.circleView.persentage = progress;
    }else{
        [_timer invalidate];
    }
    // 进度数字
    NSString *progressStr = [NSString stringWithFormat:@"%.0f", progress * 100];
    NSLog(@"%@",progressStr);
}



@end
