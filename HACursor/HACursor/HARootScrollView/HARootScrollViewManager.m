//
//  HARootScrollViewManager.m
//  HARootScrollView
//
//  Created by haha on 15/7/23.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "HARootScrollViewManager.h"
#import "HARootScrollViewCell.h"

@implementation HARootScrollViewManager

- (void)setPageViews:(NSMutableArray *)pageViews{
    _pageViews = pageViews;
    [self.rootScrollView reloadPageViews];
}

- (id)initWithRootScrollView:(HARootScrollView *)rootScrollView{
    self = [super init];
    if (self) {
        self.rootScrollView = rootScrollView;
    }
    return self;
}

- (NSUInteger)numberOfCellInRootScrollView:(HARootScrollView *)rootScrollView{
    return self.pageViews.count;
}

- (CGFloat)rootScrollView:(HARootScrollView *)rootScrollView marginForType:(HARootScrollViewMarginType)type{
    return self.margin;
}

- (HARootScrollViewCell *)rootScrollView:(HARootScrollView *)rootScrollView AtIndex:(NSUInteger)index{
    HARootScrollViewCell *cell = [HARootScrollViewCell cellWithRootScrollView:rootScrollView];
    UIView *pageView = self.pageViews[index];
    [cell setpageViewInCell:pageView];
    return cell;
}
@end
