//
//  HASortItemView.h
//  HAScrollNavBar
//
//  Created by haha on 15/7/6.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HASortButton;
@interface HASortItemView : UIView

@property (nonatomic, copy) NSString *selectButtonTitle;
@property (nonatomic, strong) NSMutableArray *itemKeys;
@property (nonatomic, assign) BOOL isScareing;

- (void)itemsScare;
- (void)itemsStopScare;
- (void)layoutItemsAfterDeletItem:(HASortButton *)item;

@end
