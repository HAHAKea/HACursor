//
//  HASortItemView.m
//  HAScrollNavBar
//
//  Created by haha on 15/7/6.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "HASortItemView.h"
#import "UIView+Extension.h"
#import "HASortButton.h"
#import "HAItemManager.h"

#define ItemW 50
#define ItemH 30
#define MarginH 25
#define RowNum 4
#define scrollNavBarUpdate @"scrollNavBarUpdate"
#define rootScrollUpdateAfterSort @"updateAfterSort"
#define moveToSelectedItem @"moveToSelectedItem"
#define moveToTop @"moveToTop"

@interface HASortItemView()

@property (nonatomic, weak) HASortButton *selectButton;
@property (nonatomic, weak) HASortButton *otherButton;

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *tmpTitles;
@property (nonatomic, strong) NSMutableArray *positionViews;
@property (nonatomic, strong) NSMutableDictionary *itemsDic;

@property (nonatomic, assign) CGRect oldItemFrame;
@property (nonatomic, assign) CGRect newItemFrame;
@property (nonatomic, assign) CGRect tmpRect;

@end

@implementation HASortItemView

- (NSMutableDictionary *)itemsDic{
    if (!_itemsDic) {
        _itemsDic = [NSMutableDictionary dictionary];
    }
    return _itemsDic;
}

- (NSMutableArray *)items{
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)setSelectButtonTitle:(NSString *)selectButtonTitle{
    _selectButtonTitle = selectButtonTitle;
    for (HASortButton *button in self.items) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if ([button.titleLabel.text isEqualToString:selectButtonTitle]) {
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }
}

- (NSMutableArray *)tmpTitles{
    if (!_tmpTitles) {
        _tmpTitles = [NSMutableArray arrayWithArray:_titles];
    }
    return _tmpTitles;
}

- (NSMutableArray *)positionViews{
    if (!_positionViews) {
        _positionViews = [NSMutableArray array];
    }
    return _positionViews;
}

- (void)setTitles:(NSArray *)titles{
    _titles = titles;
    int num = 0;
    self.userInteractionEnabled = YES;
    for (int i = 0; i < self.titles.count; i++) {
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor grayColor];
        view.layer.cornerRadius = 5;
        [self.positionViews addObject:view];
        [self addSubview:view];
    }
    for (NSString *title in titles) {
        HASortButton *item = [[HASortButton alloc]init];
        item.tag = num;
        [item addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        [item setTitle:title forState:UIControlStateNormal];
        [self.items addObject:item];
        [self.itemsDic setObject:item forKey:title];
        [self addSubview:item];
        num++;
    }
}

- (HASortButton *)getSortButtonWithTitle:(NSString *)title{
    return [self.itemsDic objectForKey:title];
}

- (void)layoutItemsAfterDeletItem:(HASortButton *)item{
    int index = (int)[self.tmpTitles indexOfObject:item.titleLabel.text];
    for (int i = index; i < self.tmpTitles.count-1; i++) {
        UIView *view = self.positionViews[i];
        HASortButton *nextButton = [self getSortButtonWithTitle:self.tmpTitles[i + 1]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                nextButton.frame = view.frame;
            }];
        });
    }
    
    UIView *lastView = [self.positionViews lastObject];
    [UIView animateWithDuration:0.3 animations:^{
        item.alpha = 0;
        lastView.alpha = 0;
    }completion:^(BOOL finished) {
        
    }];
    
    item.hidden = YES;
    lastView.hidden = YES;
    [self.tmpTitles removeObjectAtIndex:index];
    [self.positionViews removeLastObject];
    [self.itemsDic removeObjectForKey:item.titleLabel.text];
    [[HAItemManager shareitemManager] setItemTitles:self.tmpTitles];
    [[NSNotificationCenter defaultCenter] postNotificationName:scrollNavBarUpdate object:item.titleLabel.text];
    if ([item.titleLabel.text isEqualToString:self.selectButtonTitle]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:moveToTop object:item.titleLabel.text];
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:moveToSelectedItem object:self.selectButtonTitle];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longGesture{
    if (self.isScareing) return;
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [longGesture locationInView:longGesture.view];
        [self.itemsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HASortButton *button, BOOL *stop) {
            CGRect rect = button.frame;
            if (CGRectContainsPoint(rect, location)){
                *stop = YES;
                [button itemShake];
                self.selectButton = button;
                self.oldItemFrame = self.selectButton.frame;
                self.tmpRect = self.oldItemFrame;
                [UIView animateWithDuration:0.3 animations:^{
                    self.selectButton.center = location;
                    self.selectButton.alpha = 0.8;
                }];
            }
        }];
    }else if (longGesture.state == UIGestureRecognizerStateChanged){
        //获取当前长按的点
        CGPoint location = [longGesture locationInView:longGesture.view];
        //设置为选择按钮的中心位置
        self.selectButton.center = location;
        
        //遍历按钮frame的数组
        [self.itemsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HASortButton *button, BOOL *stop) {
            self.otherButton = button;
            //CGRectIntersectsRect(self.selectButton.frame, self.otherButton.frame)
            if (CGRectContainsPoint(self.otherButton.frame, self.selectButton.center) && self.selectButton != self.otherButton) {
                *stop = YES;
                
                self.tmpRect = self.otherButton.frame;
                [UIView animateWithDuration:0.3 animations:^{
                    self.otherButton.frame = CGRectMake(self.oldItemFrame.origin.x, self.oldItemFrame.origin.y, self.oldItemFrame.size.width, self.oldItemFrame.size.height);
                }];
                self.oldItemFrame = self.tmpRect;
                
                NSInteger num1 = [self.tmpTitles indexOfObject:self.selectButton.titleLabel.text];
                NSInteger num2 = [self.tmpTitles indexOfObject:self.otherButton.titleLabel.text];
                [self.tmpTitles exchangeObjectAtIndex:num1 withObjectAtIndex:num2];
            }else{
                self.tmpRect = self.oldItemFrame;
            }
        }];
    
    }else if (longGesture.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.3 animations:^{
            self.selectButton.frame = self.tmpRect;
            self.selectButton.alpha = 1;
        }];
        [self.selectButton itemStop];
        //排列完成后，将排列好的标题数组发给管理者
        [[HAItemManager shareitemManager] setItemTitles:self.tmpTitles];
        [[NSNotificationCenter defaultCenter]postNotificationName:rootScrollUpdateAfterSort object:nil];
       [[NSNotificationCenter defaultCenter]postNotificationName:moveToSelectedItem object:self.selectButtonTitle];
    }
}

- (void)itemsScare{
    self.isScareing = YES;
    for (int i = 0; i < self.items.count; i++) {
        HASortButton *item = self.items[i];
        [item itemShakeWithItem];
    }
}

- (void)itemsStopScare{
     self.isScareing = NO;
    for (int i = 0; i < self.items.count; i++) {
        HASortButton *item = self.items[i];
        [item itemStopWithItem];
    }
}

- (void)itemClick:(HASortButton *)item{
    if (item.isScareing) {
        [self layoutItemsAfterDeletItem:item];
    }else{
        [item itemlittleScare];
    }
}

- (void)setup{
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    longGesture.minimumPressDuration = 1.0;
    [self addGestureRecognizer:longGesture];
    self.tmpRect = self.oldItemFrame;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.titles.count == 0) return;
    int count = 0;
    NSInteger col = self.titles.count % RowNum == 0 ? self.titles.count / RowNum : (self.titles.count / RowNum) + 1;
    CGFloat margin = (self.width - (RowNum * ItemW)) / (RowNum + 1);
    for (int i = 0; i < col ; i++) {
        CGFloat itemY = (i + 1)* MarginH + ItemH * i + 110;
        for (int j = 0; j < RowNum ; j++) {
            if (count >= self.titles.count) {
                break;
            }
            CGFloat itemX = (j + 1)* margin + ItemW * j;
            HASortButton *button = self.items[count];
            UIView *view = self.positionViews[count];
            
            CGRect frame = CGRectMake(itemX, itemY, ItemW, ItemH);
            button.frame = frame;
            view.frame = frame;
            count++;
        }
    }
}
@end
