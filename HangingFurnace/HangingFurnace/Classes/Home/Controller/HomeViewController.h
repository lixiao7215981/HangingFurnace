//
//  HomeViewController.h
//  HangingFurnace
//
//  Created by 李晓 on 15/9/1.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "BaseViewController.h"
#import "HomTopView.h"
#import "TCircleView.h"
@interface HomeViewController : BaseViewController

@property (weak, nonatomic) IBOutlet HomTopView *homeTopView;

@property (weak, nonatomic) IBOutlet TCircleView *circleView;

@end