//
//  XLRefreshControl.m
//  XLPullToRefresh
//
//  Created by 王凯 on 14-5-4.
//  Copyright (c) 2014年 王凯. All rights reserved.
//

#import "XLRefreshControl.h"

@interface XLRefreshControl () <XLRefreshControl>

@property (nonatomic, assign) XLRefreshControlState refreshState;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isEndingRefreshing;

@property (nonatomic, assign) BOOL shouldProtectRefreshingState;

@property (nonatomic, weak) UILabel *label;

@end

@implementation XLRefreshControl

static const CGFloat kXL_RefreshControlScrollViewOffsetCorrection = 8.0;

- (void)beginRefreshing
{
    if (!self.isRefreshing) {
        //内容的偏移加上刷新控件后也不会显示控件则不需要动画
        if ([self XL_SuperScrollView].contentInset.top + [self XL_SuperScrollView].contentOffset.y > [self refreshControlThreshold]) {
            self.isRefreshing = YES;
        } else if (self.refreshState == XLRefreshControlStateNone) {    //如果加上控件后会显示出控件则动画过渡
            [[self XL_SuperScrollView] setContentOffset:CGPointMake(0, -([self XL_SuperScrollView].contentInset.top + [self refreshControlThreshold])) animated:YES];
        }
    }
}

- (void)endRefreshing
{
    if (self.isRefreshing) {
        self.isRefreshing = NO;
    }
}

- (void)setIsRefreshing:(BOOL)isRefreshing
{
    if (_isRefreshing != isRefreshing) {
        _isRefreshing = isRefreshing;
        if (isRefreshing) {
            //改变contentInset并保持偏移量
            if (self.refreshBlock) {
                self.refreshBlock();
            } else {
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            CGPoint contentOffset = [self XL_SuperScrollView].contentOffset;
            UIEdgeInsets insets = [self XL_SuperScrollView].contentInset;
            insets.top += [self refreshControlThreshold];
            [self XL_SuperScrollView].contentInset = insets;
            [self XL_SuperScrollView].contentOffset = contentOffset;
        } else {
            self.isEndingRefreshing = YES;
            CGPoint contentOffset = [self XL_SuperScrollView].contentOffset;
            CGFloat height = CGRectGetHeight(self.bounds);
            UIEdgeInsets insets = [self XL_SuperScrollView].contentInset;
            insets.top -= [self refreshControlThreshold];
            [self XL_SuperScrollView].contentInset = insets;
            
            if (height > 0) {
                [self XL_SuperScrollView].contentOffset = contentOffset;
                contentOffset.y = - insets.top;
                [UIView animateWithDuration:0.25 animations:^{
                    [self XL_SuperScrollView].contentOffset = contentOffset;
                } completion:^(BOOL finished) {
                    self.isEndingRefreshing = NO;
                }];
            } else {
                self.isEndingRefreshing = NO;
            }
        }
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (![self.superview isKindOfClass:[UIScrollView class]]) {
        [self removeFromSuperview];
        return;
    }
    [self.superview sendSubviewToBack:self];
    [self xl_RefreshControlReset];
    [self XL_UpdateFrame];
    [self refreshControlSetup];
    [self.superview addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
    [self.superview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.superview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self.superview removeObserver:self forKeyPath:@"contentInset"];
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    [self.superview removeObserver:self forKeyPath:@"frame"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self XL_UpdateFrame];
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGFloat height = [self XL_AppropriateHeightWithExternalHeight:0];
        //更新偏移量位置状态
        if (self.isRefreshing) {
            self.refreshState = XLRefreshControlStateRefreshing;
        } else if (self.isEndingRefreshing) {
            self.refreshState = XLRefreshControlStateEndingRefresh;
        } else if (height == 0) {
            self.refreshState = XLRefreshControlStateNone;
        } else if (height <= [self refreshControlThreshold] + kXL_RefreshControlScrollViewOffsetCorrection) {
            self.refreshState = XLRefreshControlStateNotReady;
            if (self.shouldProtectRefreshingState) { //特殊逻辑
                self.shouldProtectRefreshingState = NO;
            }
        } else if (height > [self refreshControlThreshold] + kXL_RefreshControlScrollViewOffsetCorrection) {
            self.refreshState = XLRefreshControlStateReady;
        }
        
        //trigger refresh
        if (height >= [self refreshControlThreshold] && ![self XL_SuperScrollView].isTracking && !self.isRefreshing && !self.isEndingRefreshing && !self.shouldProtectRefreshingState) {
            self.isRefreshing = YES;
        }
        
        //更新拉动比例
        CGFloat percent = (height / [self refreshControlThreshold]);
        percent = percent > 1 ? 1 : percent;
        [self refreshControlDidChangeYOffsetWithPercent:percent];
    }
}

#pragma mark - private methods
- (void)xl_RefreshControlReset
{
    self.shouldProtectRefreshingState = YES;
    self.isEndingRefreshing = NO;
    self.refreshState = XLRefreshControlStateNone;
}

- (UIScrollView *)XL_SuperScrollView
{
    return (UIScrollView *)self.superview;
}

- (void)XL_UpdateFrame
{
    CGFloat height = [self XL_AppropriateHeightWithExternalHeight:(self.isRefreshing ? [self refreshControlThreshold] : 0)];
    self.frame = CGRectMake(0, - height, CGRectGetWidth([self XL_SuperScrollView].frame), height);
}

- (CGFloat)XL_AppropriateHeightWithExternalHeight:(CGFloat)externalHeight
{
    CGFloat height = -[self XL_SuperScrollView].contentOffset.y - [self XL_SuperScrollView].contentInset.top + externalHeight;
    height = height > 0 ? height : 0;
    return height;
}

#pragma mark - XLRefreshControl default implement
- (void)refreshControlSetup
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    label.center = CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetHeight(label.frame) / 2 - 5);
    [self addSubview:label];
    self.label = label;
}

- (CGFloat)refreshControlThreshold
{
    return 40;
}

- (void)refreshControlDidChangeYOffsetWithPercent:(CGFloat)percent
{
    if (self.refreshState == XLRefreshControlStateEndingRefresh) {
        self.label.text = @"加载完毕";
    } else if (self.refreshState == XLRefreshControlStateNotReady) {
        self.label.text = [NSString stringWithFormat:@"%d", (NSInteger)(percent * 100)];
    } else if (self.refreshState == XLRefreshControlStateReady) {
        self.label.text = @"松开刷新";
    } else if (self.refreshState == XLRefreshControlStateRefreshing) {
        self.label.text = @"正在努力加载";
    }
}

@end
