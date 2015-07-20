//
//  HAScrollNavBar.m
//  HAScrollNavBar
//
//  Created by haha on 15/5/2.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "HAScrollNavBar.h"
#import "UIView+Extension.h"
#import "UIColor+RGBA.h"
#import "HAItemManager.h"

#define ItemWidth 75
#define FontMinSize 15
#define FontDetLeSize 10
#define FontDefSize 16
#define StaticItemIndex 3
#define scrollNavBarUpdate @"scrollNavBarUpdate"
#define HAScrollItemIndex @"index"
#define rootScrollUpdateAfterSort @"updateAfterSort"
#define moveToSelectedItem @"moveToSelectedItem"
#define moveToTop @"moveToTop"

@interface HAScrollNavBar()<UIScrollViewDelegate>

@property (nonatomic, weak) UIButton *firstButton;
@property (nonatomic, weak) UIButton *secButton;

@property (nonatomic, strong) NSMutableArray *itemsArray;
@property (nonatomic, strong) NSMutableArray *tmpItemsTitles;
@property (nonatomic, strong) NSMutableDictionary *tmpItemsDic;
@property (nonatomic, strong) NSMutableDictionary *tmpPageViewDic;

@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGFloat lastXpoint;
@property (nonatomic, assign) NSInteger currctIndex;
@property (nonatomic, assign) CGFloat red1;
@property (nonatomic, assign) CGFloat green1;
@property (nonatomic, assign) CGFloat blue1;
@property (nonatomic, assign) CGFloat alpha1;
@property (nonatomic, assign) CGFloat red2;
@property (nonatomic, assign) CGFloat green2;
@property (nonatomic, assign) CGFloat blue2;
@property (nonatomic, assign) CGFloat alpha2;
@end

@implementation HAScrollNavBar

- (NSMutableArray *)itemsArray{
    if (!_itemsArray) {
        _itemsArray = [NSMutableArray array];
    }
    return _itemsArray;
}

- (NSMutableArray *)tmpItemsTitles{
    if (!_tmpItemsTitles) {
        _tmpItemsTitles = [NSMutableArray arrayWithArray:_titles];
    }
    return _tmpItemsTitles;
}

- (NSMutableDictionary *)tmpPageViewDic{
    if (!_tmpPageViewDic) {
        _tmpPageViewDic = [NSMutableDictionary dictionary];
        for (int i = 0; i < self.titles.count; i++) {
            [_tmpPageViewDic setObject:self.pageViews[i] forKey:self.titles[i]];
        }
    }
    return _tmpPageViewDic;
}

- (NSMutableDictionary *)tmpItemsDic{
    if (!_tmpItemsDic) {
        _tmpItemsDic = [NSMutableDictionary dictionary];
        for (int i = 0; i < self.titles.count; i++) {
            UIButton *button = self.itemsArray[i];
            [_tmpItemsDic setObject:button forKey:self.titles[i]];
        }
    }
    return _tmpItemsDic;
}

- (void)setTitles:(NSMutableArray *)titles{
    _titles = titles;
    self.contentSize = CGSizeMake(titles.count * ItemWidth, 0);
    [self setupItems];
}

- (void)setOffsetX:(CGFloat)offsetX{
    _offsetX = self.contentOffset.x;
}

- (void)setRootScrollView:(UIScrollView *)rootScrollView{
    _rootScrollView = rootScrollView;
    rootScrollView.delegate = self;
    
    self.x = rootScrollView.x;
    self.y = rootScrollView.y - self.height;
}

- (void)setTitleNormalColor:(UIColor *)titleNormalColor{
    _titleNormalColor = titleNormalColor;
    for (UIButton *button in self.itemsArray) {
        [button setTitleColor:titleNormalColor forState:UIControlStateNormal];
    }
    RGBA rgba = RGBAFromUIColor(titleNormalColor);
    self.red1 = rgba.r;
    self.green1 = rgba.g;
    self.blue1 = rgba.b;
    self.alpha1 = rgba.a;
}

- (void)setTitleSelectedColor:(UIColor *)titleSelectedColor{
    _titleSelectedColor = titleSelectedColor;
    RGBA rgba = RGBAFromUIColor(titleSelectedColor);
    self.red2 = rgba.r;
    self.green2 = rgba.g;
    self.blue2 = rgba.b;
    self.alpha2 = rgba.a;
}

- (void)setIsGraduallyChangColor:(BOOL)isGraduallyChangColor{
    _isGraduallyChangColor = isGraduallyChangColor;
    if (!isGraduallyChangColor) {
        for (UIButton *button in self.itemsArray) {
            [button setTitleColor:self.titleSelectedColor forState:UIControlStateSelected];
        }
    }
}

- (void)setMinFontSize:(NSInteger)minFontSize{
    if (minFontSize > 0) {
        _minFontSize = minFontSize;
    }else{
        _minFontSize = FontMinSize;
    }
}

- (void)setMaxFontSize:(NSInteger)maxFontSize{
    if (maxFontSize > 0) {
        _maxFontSize = maxFontSize;
    }else{
        _maxFontSize = FontMinSize + FontDetLeSize;
    }
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)initNotificationCenter{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitles:) name:scrollNavBarUpdate object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateAfterSort) name:rootScrollUpdateAfterSort object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moeToSelectedItem:) name:moveToSelectedItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moeToTop:) name:moveToTop object:nil];
}

- (void)removeNotificationCenter{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:scrollNavBarUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:moveToTop object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:moveToSelectedItem object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:rootScrollUpdateAfterSort object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup{
    self.isGraduallyChangColor = YES;
    self.isGraduallyChangFont = YES;
    self.userInteractionEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    [self initNotificationCenter];
}

- (void)moeToTop:(NSNotification *)notificion{
    UIButton * button1 = [self.tmpItemsDic objectForKey:[[[HAItemManager shareitemManager] getItemTitles] objectAtIndex:1]];
    [self buttonClick:button1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIButton * button2 = [self.tmpItemsDic objectForKey:[[[HAItemManager shareitemManager] getItemTitles] objectAtIndex:0]];
        [self buttonClick:button2];
    });
}

- (void)moeToSelectedItem:(NSNotification *)notificion{
    UIButton * button = [self.tmpItemsDic objectForKey:notificion.object];
    [self buttonClick:button];
}

- (void)updateAfterSort{
    [self updatePageViewAfterSort];
    [self updateTitlesAfterSort];
}

- (void)updatePageViewAfterSort{
    int i = 0;
    for (NSString *key in [[HAItemManager shareitemManager] getItemTitles]) {
        UIView * pageView = [self.tmpPageViewDic objectForKey:key];
        [self.pageViews replaceObjectAtIndex:i withObject:pageView];
        i++;
    }
   
    [self layoutPageView];
     [self refreshItemTag];
}

- (void)updateTitlesAfterSort{
    int i = 0;
    self.isItemHiddenAfterDelet = YES;
    for (NSString *key in [[HAItemManager shareitemManager] getItemTitles]) {
         UIButton * button = [self.tmpItemsDic objectForKey:key];
        [self.itemsArray replaceObjectAtIndex:i withObject:button];
        i++;
    }
    [self layoutButtons];
    [self refreshItemTag];
}

- (void)deletButtonWithTite:(NSString *)title{
    UIButton *deletBtn = nil;
    for (UIButton *item in self.itemsArray) {
        if ([item.titleLabel.text isEqualToString:title]) {
            deletBtn = item;
        }
    }
    if (deletBtn) {
        deletBtn.hidden = YES;
        [self.itemsArray removeObject:deletBtn];
        [self.tmpItemsTitles removeObject:title];
        NSInteger itemsCount = self.itemsArray.count;
        if (itemsCount * ItemWidth < self.width) {
            self.contentSize = CGSizeMake(self.width, 0);
        }else{
            self.contentSize = CGSizeMake(self.tmpItemsTitles.count * ItemWidth, 0);
        }
    }
    [self refreshItemTag];
    [self layoutButtons];
}

- (void)deletPageViewWithTitle:(NSString *)title{
    [self.tmpPageViewDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:title]) {
            UIView *view = obj;
            view.hidden = YES;
            [self.pageViews removeObject:obj];
        }
    }];
    self.rootScrollView.contentSize = CGSizeMake(self.pageViews.count * self.rootScrollView.width, 0);
    [self layoutPageView];
}

- (void)layoutPageView{
    for (int i = 0; i < self.pageViews.count; i++) {
        UIView *view = self.pageViews[i];
        view.x = i * self.rootScrollView.width;
        view.y = 0;
        view.width = self.rootScrollView.width;
        view.height = self.rootScrollView.height;
    }
}

- (void)updateTitles:(NSNotification *)notification{
    NSLog(@"updateTitles: titles ---> %@",notification.object);
    [self deletButtonWithTite:notification.object];
    [self deletPageViewWithTitle:notification.object];
}

- (void)refreshItemTag{
    NSLog(@"refreshItemTag --> %ld",[[HAItemManager shareitemManager] getItemTitles].count);
    for (int i = 0; i < [[HAItemManager shareitemManager] getItemTitles].count; i++) {
        UIButton *button = self.itemsArray[i];
        button.tag = i;
    }
}

- (void)layoutButtons{
    CGFloat buttonW = ItemWidth;
    NSInteger itemsCount = self.itemsArray.count;
    if (itemsCount * ItemWidth < self.width) {
        CGFloat width = self.isShowSortButton ? (self.width - self.height) : self.width;
        buttonW = width / (itemsCount - 1);
    }
    CGFloat buttonH = self.height;
    CGFloat buttonY = self.isItemHiddenAfterDelet ? self.height : 0;
    for (NSInteger i = 0; i < itemsCount; i++) {
        if (i != itemsCount) {
            CGFloat buttonX = i * buttonW;
            UIButton *button = self.itemsArray[i];
            button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
            self.itemW = buttonW;
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self layoutButtons];
}

- (void)printItemsMessage{
    for (UIButton *button in self.itemsArray) {
        NSLog(@"name ---> %@ itemCount --->%ld",button.titleLabel.text, self.itemsArray.count);
    }
}

- (void)setupItems{
    [self.itemsArray removeAllObjects];
    
    NSInteger itensCount = self.titles.count;
    for (NSInteger i = 0; i < itensCount; i++) {
        UIButton *button = [[UIButton alloc]init];
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont systemFontOfSize:FontDefSize];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.itemsArray addObject:button];
        [self addSubview:button];
        button.tag = i;
        if (i == 0) {
            button.selected = YES;
            [button setTitleColor:self.titleSelectedColor forState:UIControlStateSelected];
            if (self.maxFontSize) {
                button.titleLabel.font = [UIFont systemFontOfSize:self.maxFontSize];
            }else{
                button.titleLabel.font = [UIFont systemFontOfSize:FontDetLeSize + FontMinSize];
            }
            _currectItem = button;
        }
    }
    //占位按钮，主要作用是防止按钮的数组越界
    UIButton *placeholeButton = [[UIButton alloc]init];
    [self.itemsArray addObject:placeholeButton];
}

- (void)refreshItemTitles{
    NSInteger i = 0;
    for (NSString *title in [[HAItemManager shareitemManager] getItemTitles]) {
        UIButton *button = self.itemsArray[i];
        NSLog(@"%@",title);
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateSelected];
        i++;
    }
}

- (void)buttonClick:(UIButton *)button{
    _oldItem = _currectItem;
    _currectItem.selected = NO;
    button.selected = YES;
    _currectItem = button;
    
    CGFloat offX = button.tag * self.rootScrollView.width;
    [self buttonMoveAnimationWithIndex:button.tag];
    [self.rootScrollView setContentOffset:CGPointMake(offX, 0) animated:YES];
}

- (void)setSelectItemWithIndex:(NSInteger)index{
    _oldItem = _currectItem;
    _currectItem.selected = NO;
    UIButton *button = self.itemsArray[index];
    button.selected = YES;
    _currectItem = button;
    [self buttonMoveAnimationWithIndex:index];
}

- (void)buttonMoveAnimationWithIndex:(NSInteger)index{
    UIButton *selectButton = self.itemsArray[index];
    if (self.titles.count * self.itemW > self.width) {
        if (index < StaticItemIndex) {
            //x < 2 :前两个
            [self setContentOffset:CGPointMake(0, 0) animated:YES];
        }else if(index > self.itemsArray.count - StaticItemIndex - 1) {
            // x >= 8 - 3 - 1;
            [self setContentOffset:CGPointMake(self.contentSize.width - self.width, 0) animated:YES];
        }else{
            [self setContentOffset:CGPointMake(selectButton.center.x - self.center.x, 0) animated:YES];
        }
    }else{
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)changeButtonFontWithOffset:(CGFloat)offset andWidth:(CGFloat)width{
    self.firstButton.titleLabel.font = [UIFont systemFontOfSize:FontDefSize];
    self.secButton.titleLabel.font = [UIFont systemFontOfSize:FontDefSize];
    
    [self.firstButton setTitleColor:self.titleNormalColor forState:UIControlStateNormal];
    [self.secButton setTitleColor:self.titleNormalColor forState:UIControlStateNormal];
    
    CGFloat p = fmod(offset, width) /width;
    NSInteger index = offset / width;
    self.currctIndex = index;
    if (self.isGraduallyChangFont) {
        self.firstButton = self.itemsArray[index];
        self.secButton = self.itemsArray[index+1];
        
        CGFloat fontSize1;
        CGFloat fontSize2;
        if (self.maxFontSize) {
            fontSize1 = (1- p) * (self.maxFontSize - self.minFontSize) + self.minFontSize;
            fontSize2 = p * (self.maxFontSize - self.minFontSize) + self.minFontSize;
        }else{
            fontSize1 = (1- p) * FontDetLeSize + FontMinSize;
            fontSize2 = p * FontDetLeSize + FontMinSize;
        }
        self.firstButton.titleLabel.font = [UIFont systemFontOfSize:fontSize1];
        self.secButton.titleLabel.font = [UIFont systemFontOfSize:fontSize2];
    }
    
    if (self.isGraduallyChangColor) {
        CGFloat redTemp1 = ((self.red2 - self.red1) * (1-p)) + self.red1;
        CGFloat greenTemp1 = ((self.green2 - self.green1) * (1 - p)) + self.green1;
        CGFloat blueTemp1 = ((self.blue2 - self.blue1) * (1 - p)) + self.blue1;
        
        CGFloat redTemp2 = ((self.red2 - self.red1) * p) + self.red1;
        CGFloat greenTemp2 = ((self.green2 - self.green1) * p) + self.green1;
        CGFloat blueTemp2 = ((self.blue2 - self.blue1) * p) + self.blue1;
        
        [self.firstButton setTitleColor:[UIColor colorWithRed:redTemp1 green:greenTemp1 blue:blueTemp1 alpha:1] forState:UIControlStateNormal];
        [self.secButton setTitleColor:[UIColor colorWithRed:redTemp2 green:greenTemp2 blue:blueTemp2 alpha:1] forState:UIControlStateNormal];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self changeButtonFontWithOffset:scrollView.contentOffset.x andWidth:self.rootScrollView.width];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger num = targetContentOffset->x / _rootScrollView.frame.size.width;
    [self setSelectItemWithIndex:num];
    [[NSNotificationCenter defaultCenter] postNotificationName:HAScrollItemIndex object:[NSNumber numberWithInteger:num]];
}

- (void)hiddenAllItems{
    for (int i = 0; i < self.itemsArray.count; i++) {
        UIButton *button = self.itemsArray[i];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                button.y = 2 * self.height;
            } completion:nil];
        });
    }
}

- (void)showAllItems{
    for (int i = 0; i < self.itemsArray.count; i++) {
        UIButton *button = self.itemsArray[i];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                button.y = 0;
            } completion:nil];
        });
    }
}

- (void)dealloc{
    [self removeNotificationCenter];
}
@end
