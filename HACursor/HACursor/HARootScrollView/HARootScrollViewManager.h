//
//  HARootScrollViewManager.h
//  HARootScrollView
//
//  Created by haha on 15/7/23.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HARootScrollView.h"

@interface HARootScrollViewManager : NSObject <HARootScrollViewDateSource, HARootScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, weak) HARootScrollView *rootScrollView;
@property (nonatomic, assign) CGFloat margin;

- (id)initWithRootScrollView:(HARootScrollView *)rootScrollView;

@end
