//
//  HARootScrollView.h
//  HARootScrollView
//
//  Created by haha on 15/7/23.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HARootScrollViewCell.h"

typedef enum{
    HARootScrollViewMarginTypeTop,
    HARootScrollViewMarginTypeBottom,
    HARootScrollViewMarginTypeLeft,
    HARootScrollViewMarginTypeRight
} HARootScrollViewMarginType;

@class HARootScrollView;

/**
 * rootScrollView的数据方法
 */
@protocol HARootScrollViewDateSource <NSObject>
@required
- (NSUInteger)numberOfCellInRootScrollView:(HARootScrollView *)rootScrollView;
- (HARootScrollViewCell *)rootScrollView:(HARootScrollView *)rootScrollView AtIndex:(NSUInteger)index;
@end

/**
 * rootScrollView的代理方法
 */
@protocol HARootScrollViewDelegate <NSObject>
@optional
- (void)rootScrollView:(HARootScrollView *)rootScrollView didSelectAtIndex:(NSUInteger)index;

- (CGFloat)rootScrollView:(HARootScrollView *)rootScrollView marginForType:(HARootScrollViewMarginType)type;
@end

@interface HARootScrollView : UIScrollView

@property (nonatomic, weak) id <HARootScrollViewDateSource>rootScrollViewDateSource;
@property (nonatomic, weak) id <HARootScrollViewDelegate>rootScrollViewDelegate;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) CGFloat rootScrollWidth;
@property (nonatomic, assign) CGFloat rootScrollHeight;

- (void)reloadPageViews;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
@end
