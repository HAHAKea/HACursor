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
    
    ViewController *vc2 = [[ViewController alloc] init];
    vc2.title = @"测试程序2";
    vc2.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:2];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    
    ViewController *vc3 = [[ViewController alloc] init];
    vc3.title = @"测试程序3";
    vc3.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:3];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    
    UITabBarController *tabVc = [[UITabBarController alloc] init];
    [tabVc setViewControllers:@[nav1,nav2,nav3]];
    
    self.window.rootViewController = tabVc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
