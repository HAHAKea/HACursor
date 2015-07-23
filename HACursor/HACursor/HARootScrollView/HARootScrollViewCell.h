//
//  HARootScrollViewCell.h
//  HARootScrollView
//
//  Created by haha on 15/7/23.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HARootScrollView;

@interface HARootScrollViewCell : UIView

@property (nonatomic, copy) NSString *identifier;

+ (instancetype)cellWithRootScrollView:(HARootScrollView *)rootScrollView;
- (void)setpageViewInCell:(UIView *)pageView;

@end
