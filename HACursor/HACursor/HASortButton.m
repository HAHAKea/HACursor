//
//  HASortButton.m
//  HAScrollNavBar
//
//  Created by haha on 15/7/10.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "HASortButton.h"
#import "UIView+Extension.h"

#define angle2Radian(angle) ((angle) / 180.0 * M_PI)
#define deletItemW                             15
#define iconName(file) [@"icons.bundle"        stringByAppendingPathComponent:file]

@interface HASortButton()

@property (nonatomic, strong) UIImageView *deletIcon;

@end

@implementation HASortButton

- (UIImageView *)deletIcon{
    if (!_deletIcon) {
        _deletIcon = [[UIImageView alloc]init];
        _deletIcon.image = [UIImage imageNamed:iconName(@"icon_delet.png")];
        _deletIcon.layer.cornerRadius = deletItemW / 2;
        _deletIcon.alpha = 0;
    }
    return _deletIcon;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:126/255.0 green:222/255.0 blue:184/255.0 alpha:0.6].CGColor;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.backgroundColor = [UIColor colorWithRed:31/255.0 green:192/255.0 blue:120/255.0 alpha:0.6];
    [self addSubview:self.deletIcon];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat deletW = deletItemW;
    CGFloat deletH = deletW;
    self.deletIcon.frame = CGRectMake(0, 0, deletW, deletH);
    self.deletIcon.centerX = 2;
    self.deletIcon.centerY = 2;
    self.deletIcon.userInteractionEnabled = YES;
}

- (void)itemlittleScare{
    self.isScareing = NO;
    CAKeyframeAnimation  *keyAnima = [CAKeyframeAnimation animation];
    keyAnima.keyPath = @"transform.rotation";
    // 度数 / 180 * M_PI
    keyAnima.values = @[@(-angle2Radian(5)), @(angle2Radian(5)), @(-angle2Radian(5)),@(angle2Radian(0))];
    keyAnima.removedOnCompletion = NO;
    keyAnima.fillMode = kCAFillModeForwards;
    keyAnima.duration = 0.1;
    // 设置动画重复的次数
    keyAnima.repeatCount = 6;
    
    // 2.添加核心动画
    [self.layer addAnimation:keyAnima forKey:nil];
}

- (void)itemStopWithItem{
    [self itemStop];
    [UIView animateWithDuration:0.3 animations:^{
        self.deletIcon.alpha = 0;
    }];
}

- (void)itemShake{
    self.isScareing = YES;
    // 1.创建核心动画
    CAKeyframeAnimation  *keyAnima = [CAKeyframeAnimation animation];
    keyAnima.keyPath = @"transform.rotation";
    // 度数 / 180 * M_PI
    keyAnima.values = @[@(-angle2Radian(5)), @(angle2Radian(5)), @(-angle2Radian(5))];
    
    keyAnima.removedOnCompletion = NO;
    keyAnima.fillMode = kCAFillModeForwards;
    keyAnima.duration = 0.1;
    
    // 设置动画重复的次数
    keyAnima.repeatCount = MAXFLOAT;
    // 2.添加核心动画
    [self.layer addAnimation:keyAnima forKey:nil];
}

- (void)itemStop{
    self.isScareing = NO;
    CAKeyframeAnimation  *keyAnima = [CAKeyframeAnimation animation];
    keyAnima.keyPath = @"transform.rotation";
    // 度数 / 180 * M_PI
    keyAnima.values = @[@(-angle2Radian(5)), @(angle2Radian(5)), @(-angle2Radian(5)),@(angle2Radian(0))];
    keyAnima.removedOnCompletion = NO;
    keyAnima.fillMode = kCAFillModeForwards;
    keyAnima.duration = 0.1;
    // 设置动画重复的次数
    keyAnima.repeatCount = 4;
    
    // 2.添加核心动画
    [self.layer addAnimation:keyAnima forKey:nil];
}

- (void)itemShakeWithItem{
    [self itemShake];
    [UIView animateWithDuration:0.3 animations:^{
        self.deletIcon.alpha = 1;
    }];
}

@end
