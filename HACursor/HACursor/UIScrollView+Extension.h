//
//  UIScrollView+Extension.h
//  HACursor
//
//  Created by haha on 15/7/22.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (Extension)
@property (nonatomic, strong) NSMutableDictionary *pageViewDic;

- (void)setpageViewDicWithItemkeys:(NSArray *)itemKeys AndPageViews:(NSArray *)pageViews;
- (NSMutableDictionary *)getPageViewDic;
@end
