//
//  AppDelegate.m
//  HACursor
//
//  Created by haha on 15/7/20.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ViewController *vc1 = [[ViewController alloc] init];
    vc1.title = @"测试程序1";
    vc1.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    
    self.window.rootViewController = vc1;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
