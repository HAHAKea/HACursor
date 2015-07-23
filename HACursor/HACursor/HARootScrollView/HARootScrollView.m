//
//  HARootScrollView.m
//  HARootScrollView
//
//  Created by haha on 15/7/23.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "HARootScrollView.h"
#import "UIView+Extension.h"
#import "HARootScrollViewManager.h"

#define HARootScrollViewDefaultMargin 0

@interface HARootScrollView()

@property (nonatomic, strong) NSMutableArray *pageViewFrames;
@property (nonatomic, strong) NSMutableDictionary *displayingPageViews;
@property (nonatomic, strong) NSMutableSet *reusePageViews;
@property (nonatomic, strong) HARootScrollViewManager *manager;
@end

@implementation HARootScrollView

- (NSMutableArray *)pageViewFrames{
    if (!_pageViewFrames) {
        _pageViewFrames = [NSMutableArray array];
    }
    return _pageViewFrames;
}

- (NSMutableDictionary *)displayingPageViews{
    if (!_displayingPageViews) {
        _displayingPageViews = [NSMutableDictionary dictionary];
    }
    return _displayingPageViews;
}

- (NSMutableSet *)reusePageViews{
    if (!_reusePageViews) {
        _reusePageViews = [NSMutableSet set];
    }
    return _reusePageViews;
}

- (void)setPageViews:(NSMutableArray *)pageViews{
    _pageViews = pageViews;
    self.manager.pageViews = pageViews;
}

- (void)setMargin:(CGFloat)margin{
    _margin = margin;
    self.manager.margin = margin;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [[HARootScrollViewManager alloc]initWithRootScrollView:self];
        self.rootScrollViewDateSource = _manager;
        self.rootScrollViewDelegate = _manager;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [self reloadPageViews];
}

- (void)cleanDate{
    [self.displayingPageViews.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingPageViews removeAllObjects];
    [self.pageViewFrames removeAllObjects];
    [self.reusePageViews removeAllObjects];
}

- (void)reloadPageViews{
    [self cleanDate];
    NSUInteger numberOfCells = [self.rootScrollViewDateSource numberOfCellInRootScrollView:self];
    if (numberOfCells == 0 || self.width == 0 || self.height == 0) return;
    
    CGFloat topMargin = [self marginForType:HARootScrollViewMarginTypeTop];
    CGFloat bottomMargin = [self marginForType:HARootScrollViewMarginTypeBottom];
    CGFloat leftMargin = [self marginForType:HARootScrollViewMarginTypeLeft];
    CGFloat rightMargin = [self marginForType:HARootScrollViewMarginTypeRight];
    
    CGFloat cellWidth = self.width - leftMargin - rightMargin;
    CGFloat cellHeght = self.height - topMargin - bottomMargin;
    CGFloat cellY = bottomMargin;
    
    for (int i = 0; i < numberOfCells; i++) {
        CGFloat cellX = i * (self.width) + leftMargin;
        CGRect cellFrame = CGRectMake(cellX, cellY, cellWidth, cellHeght);
        NSValue *cellFrameValue = [NSValue valueWithCGRect:cellFrame];
        [self.pageViewFrames addObject:cellFrameValue];
    }
    self.contentSize = CGSizeMake(self.width * numberOfCells, 0);
    NSLog(@"pageViewFrames ---> count %ld",self.pageViews.count);
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier{
    __block HARootScrollViewCell *reusableCell = nil;
    [self.reusePageViews enumerateObjectsUsingBlock:^(HARootScrollViewCell *cell, BOOL *stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    if (reusableCell) {
        [self.reusePageViews removeObject:reusableCell];
    }
    return reusableCell;
}

- (CGFloat)marginForType:(HARootScrollViewMarginType)type
{
    if ([self.rootScrollViewDelegate respondsToSelector:@selector(rootScrollView: marginForType:)]) {
        return [self.rootScrollViewDelegate rootScrollView:self marginForType:type];
    } else {
        return HARootScrollViewDefaultMargin;
    }
}

/**
 *  判断一个frame有无显示在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame
{
    return (CGRectGetMaxX(frame) > self.contentOffset.x) &&
    (CGRectGetMinX(frame) < self.contentOffset.x + self.bounds.size.width);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    NSUInteger numberOfCells = self.pageViewFrames.count;
    for (int i = 0; i < numberOfCells; i++) {
        CGRect cellFrame = [self.pageViewFrames[i] CGRectValue];
        HARootScrollViewCell *cell = self.displayingPageViews[@(i)];
        if ([self isInScreen:cellFrame]) {
            if (cell == nil) {
                cell = [self.rootScrollViewDateSource rootScrollView:self AtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                // 存放到字典中
                self.displayingPageViews[@(i)] = cell;
            }
        }else{
            if (cell) {
                // 从scrollView和字典中移除
                [cell removeFromSuperview];
                [self.displayingPageViews removeObjectForKey:@(i)];
                // 存放进缓存池
                [self.reusePageViews addObject:cell];
            }
        }
    }
}

@end
