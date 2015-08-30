//
//  HAAnimationTool.h
//  test2
//
//  Created by haha on 15/8/30.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAAnimationTool : NSObject
/** 普通动画*/
+ (void)animateWithAnimations:(void (^)(void))animator;

/** 普通动画带完成操作*/
+ (void)animateWithAnimations:(void (^)(void))animator Completion:(void (^)(BOOL finished))completion;

/** 弹性动画*/
+ (void)springAnimateWithAnimations:(void (^)(void))animator completion:(void (^)(BOOL finished))completion;
@end
