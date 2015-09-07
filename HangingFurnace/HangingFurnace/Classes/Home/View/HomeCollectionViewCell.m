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


@end
