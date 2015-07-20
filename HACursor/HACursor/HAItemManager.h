//
//  HAItemManager.h
//  HAScrollNavBar
//
//  Created by haha on 15/7/16.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAItemManager : NSObject
+ (id)shareitemManager;

- (void)setItemTitles:(NSMutableArray *)titles;
- (NSMutableArray *)getItemTitles;
- (void)printTitles;
@end
