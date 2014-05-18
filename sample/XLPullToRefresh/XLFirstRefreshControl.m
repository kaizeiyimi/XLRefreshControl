//
//  XLFirstRefreshControl.m
//  XLPullToRefresh
//
//  Created by 王凯 on 14-5-17.
//  Copyright (c) 2014年 王凯. All rights reserved.
//

#import "XLFirstRefreshControl.h"

@interface XLFirstRefreshControl () <XLRefreshControl>

@property (nonatomic, weak) UILabel *label;

@end

@implementation XLFirstRefreshControl

- (void)refreshControlSetup
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    label.center = CGPointMake(CGRectGetMidX(self.bounds), 20);
    [self addSubview:label];
    self.label = label;
}

- (CGFloat)refreshControlThreshold
{
    return 50;
}

- (void)refreshControlDidChangeYOffsetWithPercent:(CGFloat)percent
{
    if (self.refreshState == XLRefreshControlStateEndingRefresh) {
        self.label.text = @"～finish loading～";
    } else if (self.refreshState == XLRefreshControlStateNotReady) {
        self.label.text = [NSString stringWithFormat:@"pull to %d", (NSInteger)(percent * 100)];
    } else if (self.refreshState == XLRefreshControlStateReady) {
        self.label.text = @"release to refresh";
    } else if (self.refreshState == XLRefreshControlStateRefreshing) {
        self.label.text = @"loading...";
    }
}

@end
