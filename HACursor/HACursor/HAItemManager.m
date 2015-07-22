//
//  HAItemManager.m
//  HAScrollNavBar
//
//  Created by haha on 15/7/16.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "HAItemManager.h"


#define scrollNavBarUpdate @"scrollNavBarUpdate"
#define rootScrollerUpdate @"rootScrollerUpdate"

@interface HAItemManager()
@property (nonatomic, strong) NSMutableArray *titles;
@end

@implementation HAItemManager
- (NSMutableArray *)titles{
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

+ (id)shareitemManager{
    static HAItemManager *manger = nil;
    if (manger == nil) {
        manger = [[HAItemManager alloc]init];
    }
    return manger;
}

- (void)setItemTitles:(NSMutableArray *)titles{
    _titles = titles;
    self.scrollNavBar.itemKeys = titles;
    self.sortItemView.itemKeys = titles;
}

- (void)removeTitle:(NSString *)title{
    [self.titles removeObject:title];
}

- (void)printTitles{
    NSLog(@"********************************");
    for (NSString *title in self.titles) {
        NSLog(@"HAItemManager ---> %@",title);
    }
}
@end
