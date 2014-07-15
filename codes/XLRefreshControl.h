//
//  XLRefreshControl.h
//  XLPullToRefresh
//
//  Created by 王凯 on 14-5-4.
//  Copyright (c) 2014年 王凯. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 refresh control state. stands for current state of refresh control.
 for example: the threshold is 50.
 'None': the refrsh control is not refreshing and the height of refresh control is 0.
 'NotReady': the refresh control is not refreshing and the height of refresh control is between 0 to 50.
 'ready':the height of refresh control is bigger than 50 and ready for refreshing.
 'Refreshing': the refresh control is in refreshing state.
 'ending refresh': the refresh control is ending the refreshing state.
 */
typedef NS_ENUM(NSInteger, XLRefreshControlState) {
    XLRefreshControlStateNone = 0,
    XLRefreshControlStateNotReady,
    XLRefreshControlStateReady,
    XLRefreshControlStateRefreshing,
    XLRefreshControlStateEndingRefresh,
};

#pragma mark - XLRefreshControl protocol
// Child class should confirm to this protocol to custom its behavior.

@class XLRefreshControl;

@protocol XLRefreshControl <NSObject>

/// use this method to setup your UI element for refresh control.
- (void)refreshControlSetup;

///return the value to tell refresh control the trigger threshold.
- (CGFloat)refreshControlThreshold;

///use this method to update the UI of refresh control. You should checkout the refreshState to act correctly.
- (void)refreshControlDidChangeYOffsetWithPercent:(CGFloat)percent;

@end

#pragma mark - XLRefreshControl class
@interface XLRefreshControl : UIControl

@property (nonatomic, assign, readonly) XLRefreshControlState refreshState;

///tells wheather the refresh control is refreshing.
@property (nonatomic, assign, readonly) BOOL isRefreshing;

///config whether the refresh control should increase scroll contentInsets while refreshing. default is YES.
@property (nonatomic, assign) BOOL shouldIncreaseScrollViewInsetsTopWhenRefreshing;

///the refresh block. Refresh control will only trigger block if this is set while the target-action mode will be abandoned.
@property (nonatomic, copy) dispatch_block_t refreshBlock;

///trigger the refresh
- (void)beginRefreshing;

///end the refresh
- (void)endRefreshing;

@end
