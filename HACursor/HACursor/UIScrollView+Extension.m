//
//  UIScrollView+Extension.m
//  HACursor
//
//  Created by haha on 15/7/22.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "UIScrollView+Extension.h"

@implementation UIScrollView (Extension)
@dynamic pageViewDic;

- (void)setpageViewDicWithItemkeys:(NSArray *)itemKeys AndPageViews:(NSArray *)pageViews{
    pageViews = [NSMutableDictionary dictionary];
    for (int i = 0; i < itemKeys.count; i++) {
        UIView *view = pageViews[i];
        [self.pageViewDic setObject:view forKey:itemKeys[i]];
    }
}

- (NSMutableDictionary *)getPageViewDic{
    return self.pageViewDic;
}
@end
