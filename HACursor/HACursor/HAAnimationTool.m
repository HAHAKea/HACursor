//
//  HAAnimationTool.m
//  test2
//
//  Created by haha on 15/8/30.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "HAAnimationTool.h"
#import <UIKit/UIKit.h>

#define HAAnimationToolDuration       0.5
#define HAAnimationToolSpringDuration 0.7
#define HAAnimationToolDamp           0.3
#define HAAnimationToolVelocity       0.3

@implementation HAAnimationTool

+ (void)animateWithAnimations:(void (^)(void))animator{
    [UIView animateWithDuration:HAAnimationToolDuration animations:animator];
}

+ (void)animateWithAnimations:(void (^)(void))animator Completion:(void (^)(BOOL))completion{
    [UIView animateWithDuration:HAAnimationToolDuration animations:animator completion:completion];
}

+ (void)springAnimateWithAnimations:(void (^)(void))animator completion:(void (^)(BOOL))completion{
    [UIView animateWithDuration:HAAnimationToolSpringDuration delay:0 usingSpringWithDamping:HAAnimationToolDamp initialSpringVelocity:HAAnimationToolVelocity options:UIViewAnimationOptionBeginFromCurrentState animations:animator completion:completion];
}

@end
