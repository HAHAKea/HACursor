//
//  HACursor.m
//  HAScrollNavBar
//
//  Created by haha on 15/7/6.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "HACursor.h"
#import "HAScrollNavBar.h"
#import "UIView+Extension.h"
#import "HASortItemView.h"
#import "HASortButton.h"
#import "UIColor+RGBA.h"
#import "HAItemManager.h"
#import "HARootScrollView.h"

#define navLineHeight 6
#define StaticItemIndex 3
#define SortItemViewY -360
#define SortItemViewMoveToY -70
#define HAScrollItemIndex @"index"
#define defBackgroundColor [UIColor blackColor]
#define iconName(file) [@"icons.bundle" stringByAppendingPathComponent:file]

@interface HACursor()<UIScrollViewDelegate>

#warning 使用带缓存机制的scrollView
//@property (nonatomic, weak) UIScrollView *rootScrollView;
@property (nonatomic, strong) HARootScrollView *rootScrollView;

@property (nonatomic, strong) UIView *navLine;
@property (nonatomic, strong) HAScrollNavBar *scrollNavBar;
@property (nonatomic, strong) HASortItemView *sortItmView;
@property (nonatomic, strong) UIButton *sortButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, assign) BOOL showNarLine;
@property (nonatomic, assign) BOOL isDrag;
@property (nonatomic, assign) BOOL isRefash;
@property (nonatomic, assign) CGFloat oldOffset;
@property (nonatomic, assign) CGFloat navBarH;
@property (nonatomic, assign) NSInteger oldBtnIndex;
@end

@implementation HACursor

#pragma -mark 懒加载
- (UIView *)navLine{
    if (!_navLine) {
        _navLine = [[UIView alloc]init];
        _navLine.backgroundColor = [UIColor redColor];
        _navLine.hidden = YES;
    }
    return _navLine;
}

- (UILabel *)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc]init];
        _tipsLabel.text = @"栏目切换";
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.font = [UIFont systemFontOfSize:22];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.hidden = YES;
    }
    return _tipsLabel;
}

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc]init];
        _confirmButton.layer.cornerRadius = 5;
        _confirmButton.alpha = 0;
        _confirmButton.adjustsImageWhenDisabled = NO;
        _confirmButton.layer.borderWidth = 1.0;
        _confirmButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _confirmButton.backgroundColor = [UIColor grayColor];
        [_confirmButton setTitle:@"排序删除" forState:UIControlStateNormal];
        [_confirmButton setTitle:@"完成" forState:UIControlStateSelected];
        [_confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (HARootScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[HARootScrollView alloc]init];
        _rootScrollView.pagingEnabled = YES;
        _rootScrollView.backgroundColor = [UIColor cyanColor];
        //_rootScrollView.margin = 20;
    }
    return _rootScrollView;
}

- (void)setPageViews:(NSMutableArray *)pageViews{
    _pageViews = pageViews;
    
    self.scrollNavBar.pageViews = pageViews;
    _scrollNavBar.rootScrollView = self.rootScrollView;
}


- (HAScrollNavBar *)scrollNavBar{
    if (!_scrollNavBar) {
        _scrollNavBar = [[HAScrollNavBar alloc]init];
        _scrollNavBar.backgroundColor = [UIColor redColor];
        _scrollNavBar.delegate = self;
    }
    return _scrollNavBar;
}

- (UIButton *)sortButton{
    if (!_sortButton) {
        _sortButton = [[UIButton alloc]init];
        _sortButton.adjustsImageWhenDisabled = NO;
        [_sortButton setImage:[UIImage imageNamed:iconName(@"icon_more.png")] forState:UIControlStateNormal];
        [_sortButton addTarget:self action:@selector(sortButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _sortButton.hidden = YES;
    }
    return _sortButton;
}

- (HASortItemView *)sortItmView{
    if (!_sortItmView) {
        _sortItmView = [[HASortItemView alloc]init];
        _sortItmView.hidden = YES;
        _sortItmView.userInteractionEnabled = YES;
        _sortItmView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    }
    return _sortItmView;
}

#pragma -mark 属性配置
- (void)setShowNarLine:(BOOL)showNarLine{
    _showNarLine = showNarLine;
    if (showNarLine) {
        self.navLine.hidden = NO;
    }else{
        self.navLine.hidden = YES;
    }
}

- (void)setShowSortbutton:(BOOL)showSortbutton{
    _showSortbutton = showSortbutton;
    self.scrollNavBar.isShowSortButton = showSortbutton;
    if (showSortbutton) {
        self.sortButton.hidden = NO;
    }else{
        self.sortButton.hidden = YES;
    }
}

- (void)setNavLineColor:(UIColor *)navLineColor{
    _navLineColor = navLineColor;
    _navLine.layer.cornerRadius = 2;
    self.navLine.backgroundColor = navLineColor;
}

- (void)setRootScrollViewHeight:(CGFloat)rootScrollViewHeight{
    _rootScrollViewHeight = rootScrollViewHeight;
    CGRect rect = self.frame;
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    if (self.navBarH == 0 ) {
        self.navBarH = h;
        h = h + self.rootScrollViewHeight;
    }
    CGRect frameChanged = CGRectMake(x, y, w, h);
    [self setFrame:frameChanged];
}

/*
- (void)setRootScrollView:(UIScrollView *)rootScrollView{
    _rootScrollView = rootScrollView;
    self.scrollNavBar.rootScrollView = rootScrollView;
    [self addSubview:rootScrollView];
    [self insertSubview:rootScrollView atIndex:0];
    CGRect rect = self.frame;
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    if (self.navBarH == 0 ) {
        self.navBarH = h;
        h = h + self.rootScrollView.height;
    }
    CGRect frameChanged = CGRectMake(x, y, w, h);
    [self setFrame:frameChanged];
}
*/
- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:[UIColor clearColor]];
    self.scrollNavBar.backgroundColor = backgroundColor;
    self.sortButton.backgroundColor = backgroundColor;
}

- (void)setTitles:(NSArray *)titles{
    BOOL isHaveSameTitle = [self checkisHaveSameItem:titles];
    NSAssert(!isHaveSameTitle, @"错误！！！不可以包含相同的标题");
    _titles = titles;

#warning -----titles的赋值操作只对HAItemManager进行
    [[HAItemManager shareitemManager] setScrollNavBar:self.scrollNavBar];
    [[HAItemManager shareitemManager] setSortItemView:self.sortItmView];
    [[HAItemManager shareitemManager] setItemTitles:(NSMutableArray *)titles];
}

- (void)setTitleNormalColor:(UIColor *)titleNormalColor{
    _titleNormalColor = titleNormalColor;
    self.scrollNavBar.titleNormalColor = titleNormalColor;
}

- (void)setTitleSelectedColor:(UIColor *)titleSelectedColor{
    _titleSelectedColor = titleSelectedColor;
    self.scrollNavBar.titleSelectedColor = titleSelectedColor;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage{
    _backgroundImage = backgroundImage;
    self.scrollNavBar.backgroundImage = backgroundImage;
}

- (void)setIsGraduallyChangColor:(BOOL)isGraduallyChangColor{
    _isGraduallyChangColor = isGraduallyChangColor;
    self.scrollNavBar.isGraduallyChangColor = isGraduallyChangColor;
}

- (void)setIsGraduallyChangFont:(BOOL)isGraduallyChangFont{
    _isGraduallyChangColor = isGraduallyChangFont;
    self.scrollNavBar.isGraduallyChangFont = isGraduallyChangFont;
}

- (void)setMinFontSize:(NSInteger)minFontSize{
    _minFontSize = minFontSize;
    self.scrollNavBar.minFontSize = minFontSize;
}

- (void)setMaxFontSize:(NSInteger)maxFontSize{
    _maxFontSize = maxFontSize;
    self.scrollNavBar.maxFontSize = maxFontSize;
}

#pragma -mark 初始化
- (void)setup{
    [self addSubview:self.rootScrollView];
    [self addSubview:self.sortItmView];
    [self addSubview:self.scrollNavBar];
    [self addSubview:self.navLine];
    [self addSubview:self.sortButton];
    [self addSubview:self.confirmButton];
    [self addSubview:self.tipsLabel];
    
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
    if (!self.backgroundColor) {
        self.backgroundColor = defBackgroundColor;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setIndex:) name:HAScrollItemIndex object:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithTitles:(NSArray *)titles AndPageViews:(NSMutableArray *)pageViews{
    self = [super init];
    if (self) {
        self.titles = titles;
        self.pageViews = pageViews;
        [self setup];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat rootScrollViewX = 0;
    CGFloat rootScrollViewY = self.navBarH;
    CGFloat rootScrollViewW = self.width;
    CGFloat rootScrollViewH = self.rootScrollViewHeight;
    self.rootScrollView.frame = CGRectMake(rootScrollViewX, rootScrollViewY, rootScrollViewW, rootScrollViewH);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.rootScrollView reloadPageViews];
    });
    
    if (self.showSortbutton) {
        //显示排序按钮的布局
        CGFloat scrollX = 0;
        CGFloat scrollY = 0;
        CGFloat scrollH = 45;
        self.navBarH = scrollH;
        CGFloat scrollW = self.width - scrollH;
        self.scrollNavBar.frame = CGRectMake(scrollX, scrollY, scrollW, scrollH);
        
        CGFloat sortItemX = 0;
        CGFloat sortItemY = SortItemViewY;
        CGFloat sortItemW = self.width;
        CGFloat sortItemH = 300;
        self.sortItmView.frame = CGRectMake(sortItemX, sortItemY, sortItemW, sortItemH);
        
        CGFloat sortBtX = scrollW;
        CGFloat sortBtY = scrollY;
        CGFloat sortBtW = scrollH;
        CGFloat sortBtH = sortBtW;
        self.sortButton.frame = CGRectMake(sortBtX, sortBtY, sortBtW, sortBtH);
        
        CGFloat confirmW = 60;
        CGFloat confirmH = 20;
        CGFloat confirmX = 0.7 * self.width;
        CGFloat confirmY = self.navBarH/ 2 - confirmH / 2 ;
        self.confirmButton.frame = CGRectMake(confirmX, confirmY, confirmW, confirmH);
        
        CGFloat tipsW = 90;
        CGFloat tipsH = self.navBarH;
        CGFloat tipsX = - 2 * tipsW;
        CGFloat tipsY = 0;
        self.tipsLabel.frame = CGRectMake(tipsX, tipsY, tipsW, tipsH);
    }else{
        //不显示排序按钮的布局
        CGFloat scrollX = 0;
        CGFloat scrollY = 0;
        CGFloat scrollH = 45;
        self.navBarH = scrollH;
        CGFloat scrollW = self.width;
        self.scrollNavBar.frame = CGRectMake(scrollX, scrollY, scrollW, scrollH);
    }
    
    if (self.showNarLine) {
        CGFloat lineX = 0;
        CGFloat lineY = self.height - navLineHeight;
        CGFloat lineW = self.scrollNavBar.itemW;
        CGFloat lineH = navLineHeight;
        self.navLine.frame = CGRectMake(lineX, lineY, lineW, lineH);
    }
}

#pragma -mark 业务逻辑
- (void)setIndex:(NSNotification *)notif{
    if (self.showNarLine) {
        NSInteger index = [notif.object integerValue];
        self.oldBtnIndex = index;
        
        [self.navLine removeFromSuperview];
        [self addSubview:self.navLine];
        
        self.navLine.x = [self getNavLineOffset];
        self.navLine.x = [self tranlateXWithButtonIndex:index];
    
        [self.navLine removeFromSuperview];
        [self.scrollNavBar.currectItem addSubview:self.navLine];
        self.navLine.x = 0;
    }
}

- (CGFloat)tranlateXWithButtonIndex:(NSInteger)index{
    CGFloat offset = 0.0;
    NSInteger detal = self.scrollNavBar.itemKeys.count - StaticItemIndex - 1;
    if (self.titles.count * self.scrollNavBar.itemW > self.scrollNavBar.width) {
        CGFloat detalX = 0;
        if (index < StaticItemIndex) {
            offset = index * self.scrollNavBar.itemW;
        }else if(index > detal){
            detalX = self.scrollNavBar.contentSize.width - self.scrollNavBar.width;
            if (self.showSortbutton) {
                offset = ((index - detal + StaticItemIndex - 2) * self.scrollNavBar.itemW) - self.height;
            }else{
                offset = (index - detal + StaticItemIndex - 2) * self.scrollNavBar.itemW ;
            }
        }else{
            detalX = self.scrollNavBar.currectItem.centerX - self.centerX;
            if (self.showSortbutton) {
                offset = self.centerX - self.height / 2;
            }else{
                offset = self.centerX;
            }
        }
    }else{
        offset = index * self.scrollNavBar.itemW;
    }
    return offset;
}

- (CGFloat)getNavLineOffset{
    CGFloat offset = 0;
    if (self.isRefash) {
        offset = self.oldOffset;
        self.isRefash = NO;
    }else{
        offset = [self tranlateXWithButtonIndex:self.scrollNavBar.oldItem.tag];
    }
    return offset;
}

- (void)sortButtonClick{
    CGFloat duration = 0.8;
    CGFloat damp = 0.3;
    CGFloat velocity = 0.5;
    self.sortButton.enabled = NO;
    NSString *title = self.scrollNavBar.currectItem.titleLabel.text;
    self.sortItmView.selectButtonTitle = title;
    //显示排序菜单
    if (!self.sortButton.isSelected) {
        self.sortItmView.hidden = NO;
        self.confirmButton.hidden = NO;
        self.tipsLabel.hidden = NO;
        self.rootScrollView.userInteractionEnabled = NO;
        self.scrollNavBar.userInteractionEnabled = NO;
        self.scrollNavBar.isItemHiddenAfterDelet = YES;
        
        [self.scrollNavBar hiddenAllItems];
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damp initialSpringVelocity:velocity options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.sortItmView.y = SortItemViewMoveToY;
            self.sortButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            
            self.sortButton.enabled = YES;
            [UIView animateWithDuration:0.2 animations:^{
                self.confirmButton.alpha = 1;
            }];
            [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.6 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.tipsLabel.x = self.width * 0.1;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }else{
        //隐藏排序菜单
        if (self.sortItmView.isScareing) {
            [self.sortItmView itemsStopScare];
            self.confirmButton.selected = !self.confirmButton.selected;
        }
        
        self.scrollNavBar.isItemHiddenAfterDelet = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.confirmButton.alpha = 0;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.6 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.tipsLabel.x = - 2 * self.tipsLabel.width;
            } completion:^(BOOL finished) {
                
            }];
            [self.scrollNavBar showAllItems];
        }];
        
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damp initialSpringVelocity:velocity options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.sortItmView.y = SortItemViewY + self.navBarH / 2;
            self.sortButton.imageView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.sortItmView.hidden = YES;
            self.sortButton.enabled = YES;
            self.confirmButton.hidden = YES;
            self.tipsLabel.hidden = YES;
            self.rootScrollView.userInteractionEnabled = YES;
            self.scrollNavBar.userInteractionEnabled = YES;
        }];
    }
    self.sortButton.selected = !self.sortButton.isSelected;
}

- (BOOL)checkisHaveSameItem:(NSArray *)titles{
    for (int i = 0; i < titles.count; i++) {
        NSString *title1 = titles[i];
        for (int j = 0; j < titles.count; j++) {
            NSString *title2 = titles[j];
            if (j != i && [title1 isEqualToString:title2]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma -mark UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.isDrag = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.isDrag = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isDrag) {
        CGRect rect = [self.scrollNavBar.currectItem convertRect:self.scrollNavBar.currectItem.frame toView:self];
        self.oldOffset = rect.origin.x - (self.oldBtnIndex * self.scrollNavBar.itemW);
        self.isRefash = YES;
    }
}

- (void)confirmButtonClick{
    if (!self.confirmButton.isSelected) {
        [self.sortItmView itemsScare];
    }else{
        [self.sortItmView itemsStopScare];
    }
    [self.confirmButton setSelected:!self.confirmButton.isSelected];
}

@end

