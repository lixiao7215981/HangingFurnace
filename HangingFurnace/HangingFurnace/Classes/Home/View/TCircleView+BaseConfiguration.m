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
    
    return [UIColor greenColor];
}

+ (UIColor *)centerColor {
    
    return [UIColor yellowColor];
}

+ (UIColor *)endColor {
    
    return [UIColor redColor];
}

+ (UIColor *)backgroundColor {
//    return [UIColor colorWithHex:0x2682D5 alpha:0.5];
//    return [UIColor colorWithHexString:@"2682D5"];
    return [UIColor lightGrayColor];
}

+ (CGFloat)lineWidth {
    
    return 4;
}

+ (CGFloat)startAngle {
    
    return DEGREES_TO_RADOANS(-90);
}

+ (CGFloat)endAngle {
    
    return DEGREES_TO_RADOANS(-89);
}

@end
