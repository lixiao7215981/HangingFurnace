//
//  ModeSettingCellView.m
//  HangingFurnace
//
//  Created by ybyao07 on 15/9/7.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "ModeSettingCellView.h"
#import "UIColor+Category.h"

@interface ModeSettingCellView()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMarginH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMarginH;
@end
@implementation ModeSettingCellView


-(void)awakeFromNib
{
    if (IS_IPHONE_5_OR_LESS) {
        _topMarginH.constant = 4;
        _bottomMarginH.constant = 4;
    }else if (IS_IPHONE_6){
        _topMarginH.constant = 8;
        _bottomMarginH.constant = 8;
    }else if (IS_IPHONE_6P){
        _topMarginH.constant = 12;
        _bottomMarginH.constant = 12;
    }
}



- (void)drawRect:(CGRect)rect {
    //增加底部分割线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context,     [UIColor colorWithHexString:@"dadada"].CGColor); CGContextStrokeRect(context, CGRectMake(20, rect.size.height, SCREEN_WIDTH - 40, 0.5));
}


@end
