//
//  HATestView.m
//  HAScrollNavBar
//
//  Created by haha on 15/7/19.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "HATestView.h"
#import "UIView+Extension.h"

@implementation HATestView
- (instancetype)init
{
    self = [super init];
    if (self) {
        UILabel *label = [[UILabel alloc]init];
        label.font = [UIFont systemFontOfSize:65];
        
        label.textAlignment = NSTextAlignmentCenter;
        self.label = label;
        [self addSubview:label];
        
        self.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.label.width = self.width;
    self.label.height = self.height;
    self.label.x = 0;
    self.label.y = 0;
}
@end
