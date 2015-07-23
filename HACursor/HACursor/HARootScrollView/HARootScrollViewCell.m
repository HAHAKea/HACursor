//
//  HARootScrollViewCell.m
//  HARootScrollView
//
//  Created by haha on 15/7/23.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "HARootScrollViewCell.h"
#import "HARootScrollView.h"

@interface HARootScrollViewCell()

@end

@implementation HARootScrollViewCell

+ (id)cellWithRootScrollView:(HARootScrollView *)rootScrollView{
    static NSString *cellID = @"CELL";
    HARootScrollViewCell *cell = [rootScrollView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[HARootScrollViewCell alloc] init];
        cell.identifier = cellID;
        cell.backgroundColor = [UIColor yellowColor];
    }
    return cell;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setpageViewInCell:(UIView *)pageView{
    if (self.subviews.count) {
       [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    [self addSubview:pageView];
    [self layoutIfNeeded];
}

- (void)layoutSubviews{
    UIView *pageView =  self.subviews[0];
    pageView.frame = self.bounds;
}
@end
