//
//  TCircleView+BaseConfiguration.m
//  2015-06-29-圆形渐变进度条
//
//  Created by TangJR on 7/1/15.
//  Copyright (c) 2015 tangjr. All rights reserved.
//

#import "TCircleView+BaseConfiguration.h"
#import <UIColor+Category.h>
#define DEGREES_TO_RADOANS(x) (M_PI * (x) / 180.0) // 将角度转为弧度

@implementation TCircleView (BaseConfiguration)

+ (UIColor *)startColor {
    return [UIColor yellowColor];
}

+ (UIColor *)centerColor {
    return [UIColor colorWithRed:208/255.0 green:106/255.0 blue:9/255 alpha:1.0];
}

+ (UIColor *)endColor {
    return [UIColor redColor];
}

+ (UIColor *)backgroundColor {
//    return [UIColor colorWithHex:0x2682D5 alpha:0.5];
    return [UIColor colorWithHexString:@"d9d9d9"];
}

+ (CGFloat)lineWidth {
    return 4;
}

+ (CGFloat)startAngle {
    
    return DEGREES_TO_RADOANS(-91);
}

+ (CGFloat)endAngle {
    
    return DEGREES_TO_RADOANS(-89);
}

@end
