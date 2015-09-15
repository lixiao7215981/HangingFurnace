//
//  AppDelegate.m
//  HangingFurnace
//
//  Created by 李晓 on 15/8/31.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "AppDelegate.h"
#import <PgySDK/PgyManager.h>
#import <SMS_SDK/SMS_SDK.h>
#import <SkywareUIInstance.h>
#import "UserLoginViewController.h"

#define SMS_SDKAppKey    @"a6137b7d9ee4"
#define SMS_SDKAppSecret  @"df67c3d2a08511a78582b4ce0c2b7184"
#define PGY_SDKAppKey  @"e7366e1d2769f9f8a8820f6f8b3274bf"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    UserLoginViewController *loginRegister = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateInitialViewController];
    self.window.rootViewController = loginRegister;
    self.navigationController = (UINavigationController *)loginRegister;
    [self.window makeKeyAndVisible];
    
    UIApplication *app = [UIApplication sharedApplication];
    [app setStatusBarHidden:NO];
    [app setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    // 设置 App_id
    SkywareInstanceModel *skywareInstance = [SkywareInstanceModel sharedSkywareInstanceModel];
    skywareInstance.app_id = 8;
    
    SkywareUIInstance *UIM = [SkywareUIInstance sharedSkywareUIInstance];
    UIM.All_button_bgColor = kSystemBtnBGColor;
    UIM.All_view_bgColor = kSystemLoginViewBackageColor;
    
    LXFrameWorkInstance *LXM = [LXFrameWorkInstance sharedLXFrameWorkInstance];
    LXM.NavigationBar_bgColor = kRGBColor(200, 31, 2, 1);
    LXM.NavigationBar_textColor = [UIColor whiteColor];
    LXM.backState = writeBase;
    
    
    
    // 启动ShareSDK 的短信功能
    [SMS_SDK registerApp:SMS_SDKAppKey withSecret:SMS_SDKAppSecret];
    [SMS_SDK enableAppContactFriends:NO];
    
    //关闭用户反馈功能
    [[PgyManager sharedPgyManager] setEnableFeedback:NO];
    // 蒲公英启动
    [[PgyManager sharedPgyManager] startManagerWithAppId:PGY_SDKAppKey];
    // 检查更新
    [[PgyManager sharedPgyManager] checkUpdate];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
