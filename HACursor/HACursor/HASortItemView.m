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

@property (nonatomic, strong) NSMutableArray *positionViews;
@property (nonatomic, strong) NSMutableDictionary *itemsDic;
@property (nonatomic, strong) NSMutableArray *tmpKeys;

@property (nonatomic, assign) CGRect oldItemFrame;
@property (nonatomic, assign) CGRect newItemFrame;
@property (nonatomic, assign) CGRect tmpRect;
@property (nonatomic, assign) BOOL isMoving;
@property (nonatomic, assign) BOOL isChange;
@end

@implementation HASortItemView

- (NSMutableArray *)tmpKeys{
    if (!_tmpKeys) {
        _tmpKeys = [NSMutableArray arrayWithArray:self.itemKeys];
    }
    return _tmpKeys;
}

- (NSMutableDictionary *)itemsDic{
    if (!_itemsDic) {
        _itemsDic = [NSMutableDictionary dictionary];
    }
    return _itemsDic;
}

- (void)setItemKeys:(NSMutableArray *)itemKeys{
    _itemKeys = itemKeys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupPositionViewsAndItemsWithKeys:itemKeys];
    });
}

- (void)setupPositionViewsAndItemsWithKeys:(NSArray *)keys{
    int num = 0;
    self.userInteractionEnabled = YES;
    for (int i = 0; i < keys.count; i++) {
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        view.layer.cornerRadius = 5;
        [self.positionViews addObject:view];
        [self addSubview:view];
    }
    for (NSString *title in keys) {
        HASortButton *item = [[HASortButton alloc]init];
        item.tag = num;
        [item addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        [item setTitle:title forState:UIControlStateNormal];
        [self.itemsDic setObject:item forKey:title];
        [self addSubview:item];
        num++;
    }
}

- (void)setSelectButtonTitle:(NSString *)selectButtonTitle{
    _selectButtonTitle = selectButtonTitle;
    
    [self.itemsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HASortButton *button, BOOL *stop) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if ([key isEqualToString:selectButtonTitle]) {
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }];
}

- (NSMutableArray *)positionViews{
    if (!_positionViews) {
        _positionViews = [NSMutableArray array];
    }
    return _positionViews;
}

- (HASortButton *)getSortButtonWithTitle:(NSString *)title{
    return [self.itemsDic objectForKey:title];
}

- (void)layoutItemsAfterDeletItem:(HASortButton *)item{
    if (self.itemKeys.count == 1) return;
    int index = (int)[self.tmpKeys indexOfObject:item.titleLabel.text];
    for (int i = index; i < self.tmpKeys.count-1; i++) {
        UIView *view = self.positionViews[i];
        HASortButton *nextButton = [self getSortButtonWithTitle:self.tmpKeys[i + 1]];
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
    [self.tmpKeys removeObject:item.titleLabel.text];
    [self.positionViews removeLastObject];
    [self.itemsDic removeObjectForKey:item.titleLabel.text];

    [[HAItemManager shareitemManager] setItemTitles:self.tmpKeys];
    [[HAItemManager shareitemManager] printTitles];
    [[NSNotificationCenter defaultCenter] postNotificationName:scrollNavBarUpdate object:item.titleLabel.text];
    if ([item.titleLabel.text isEqualToString:self.selectButtonTitle]) {
         [[NSNotificationCenter defaultCenter] postNotificationName:moveToTop object:item.titleLabel.text];
        [self setSelectButtonTitle:[self.itemKeys firstObject]];
    }else{
         [[NSNotificationCenter defaultCenter] postNotificationName:moveToSelectedItem object:self.selectButtonTitle];
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
                }];
            }
        }];
    }else if (longGesture.state == UIGestureRecognizerStateChanged){
        //获取当前长按的点
        CGPoint location = [longGesture locationInView:longGesture.view];
        //设置为选择按钮的中心位置
        self.selectButton.center = location;
        //遍历按钮frame的数组
        if (self.isMoving) return;
        [self.itemsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HASortButton *button, BOOL *stop) {
            self.otherButton = button;
            if (CGRectContainsPoint(self.selectButton.frame, self.otherButton.center) && self.selectButton != self.otherButton) {
                *stop = YES;
                
                self.isMoving = YES;
                NSInteger selectBtnIndex = [self.tmpKeys indexOfObject:self.selectButton.titleLabel.text];
                NSInteger otherBtnIndex = [self.tmpKeys indexOfObject:self.otherButton.titleLabel.text];
                NSLog(@"selectBtnIndex %ld  --- > otherBtnIndex %ld" ,selectBtnIndex, otherBtnIndex);
                
                self.tmpRect = self.otherButton.frame;
                [self animationBetweenSelectItemIndex:selectBtnIndex AndOtherItemIndex:otherBtnIndex];
                self.oldItemFrame = self.tmpRect;
            }else{
                self.tmpRect = self.oldItemFrame;
            }
        }];
    
    }else if (longGesture.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.3 animations:^{
            self.selectButton.frame = self.tmpRect;
        }];
        [self.selectButton itemStop];
        //排列完成后，将排列好的标题数组发给管理者
        [[HAItemManager shareitemManager] setItemTitles:self.tmpKeys];
        [[HAItemManager shareitemManager] printTitles];
        [[NSNotificationCenter defaultCenter] postNotificationName:scrollNavBarUpdate object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:moveToSelectedItem object:self.selectButtonTitle];
    }
}

- (void)animationBetweenSelectItemIndex:(NSInteger)selectIndex AndOtherItemIndex:(NSInteger)otherIndex{
    NSMutableArray *needMoveItem = [NSMutableArray array];
    NSMutableArray *positionView = [NSMutableArray array];
    if (selectIndex < otherIndex) {
        for (int i = (int)selectIndex + 1; i <= otherIndex; i++) {
            HASortButton *item = [self.itemsDic objectForKey:self.tmpKeys[i]];
            [needMoveItem addObject:item];
            UIView *view = self.positionViews[i - 1];
            [positionView addObject:view];
        }
        int j = 0;
        for (HASortButton *item in needMoveItem) {
            UIView *view = positionView[j];
            [UIView animateWithDuration:0.3 animations:^{
                item.frame = view.frame;
            }completion:^(BOOL finished) {
                if (j == needMoveItem.count - 1) {
                    self.isMoving = NO;
                }
            }];
            j++;
        }
        NSInteger num1 = [self.tmpKeys indexOfObject:self.selectButton.titleLabel.text];
        NSInteger num2 = [self.tmpKeys indexOfObject:self.otherButton.titleLabel.text];
        [self.tmpKeys removeObjectAtIndex:num1];
        [self.tmpKeys insertObject:self.selectButton.titleLabel.text atIndex:num2];
    }else{
        for (int i = (int)otherIndex; i < selectIndex; i++) {
            HASortButton *item = [self.itemsDic objectForKey:self.tmpKeys[i]];
            [needMoveItem addObject:item];
            UIView *view = self.positionViews[i+ 1];
            [positionView addObject:view];
            NSLog(@"%@",item.titleLabel.text);
        }
        int j = (int)needMoveItem.count-1;
        for (int i = j; i >= 0; i--) {
            UIView *view = positionView[i];
            HASortButton *item = needMoveItem[i];
            [UIView animateWithDuration:0.3 animations:^{
                item.frame = view.frame;
            }completion:^(BOOL finished) {
                if (i == 0) {
                    self.isMoving = NO;
                }
            }];
        }
        NSInteger num1 = [self.tmpKeys indexOfObject:self.selectButton.titleLabel.text];
        NSInteger num2 = [self.tmpKeys indexOfObject:self.otherButton.titleLabel.text];
        [self.tmpKeys removeObjectAtIndex:num1];
        [self.tmpKeys insertObject:self.selectButton.titleLabel.text atIndex:num2];
    }
   
}

- (void)itemsScare{
    self.isScareing = YES;
    [self.itemsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HASortButton *item, BOOL *stop) {
        [item itemShakeWithItem];
    }];
}

- (void)itemsStopScare{
     self.isScareing = NO;
    [self.itemsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HASortButton *item, BOOL *stop) {
        [item itemStopWithItem];
    }];
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

- (HASortButton *)getSortButtonWithKeyIndex:(NSInteger)index{
    return [self.itemsDic objectForKey:self.itemKeys[index]];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.itemKeys.count == 0) return;
    int count = 0;
    NSInteger col = self.itemKeys.count % RowNum == 0 ? self.itemKeys.count / RowNum : (self.itemKeys.count / RowNum) + 1;
    CGFloat margin = (self.width - (RowNum * ItemW)) / (RowNum + 1);
    for (int i = 0; i < col ; i++) {
        CGFloat itemY = (i + 1)* MarginH + ItemH * i + 110;
        for (int j = 0; j < RowNum ; j++) {
            if (count >= self.itemKeys.count) {
                break;
            }
            CGFloat itemX = (j + 1)* margin + ItemW * j;
            HASortButton *button = [self getSortButtonWithKeyIndex:count];
            UIView *view = self.positionViews[count];
            
            CGRect frame = CGRectMake(itemX, itemY, ItemW, ItemH);
            button.frame = frame;
            view.frame = frame;
            count++;
        }
    }
}
@end
