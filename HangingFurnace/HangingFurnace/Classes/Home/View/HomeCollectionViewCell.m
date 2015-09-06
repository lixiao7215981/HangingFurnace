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

@property (weak, nonatomic) IBOutlet TCircleView *circleView;

@end

@implementation HomeCollectionViewCell

- (void)awakeFromNib {
    
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    kFrameLog(self.circleView.frame);
}


@end
