//
//  XLViewController.m
//  XLPullToRefresh
//
//  Created by 王凯 on 14-5-4.
//  Copyright (c) 2014年 王凯. All rights reserved.
//

#import "XLViewController.h"

#import "XLRefreshControl.h"
#import "XLFirstRefreshControl.h"

@interface XLViewController ()

@property (nonatomic, weak) XLRefreshControl *refresh;

@end

@implementation XLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //the XLRefreshControl provide a very simple behavior. You can use XLRefreshControl directly or make a child class to custom.
    XLRefreshControl *refresh = [[XLRefreshControl alloc]init];
    
    //a very simple child class which shows how to custom refresh control.
//    XLRefreshControl *refresh = [[XLFirstRefreshControl alloc]init];
    
    //you can use it just as apple does.
    [refresh addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    //or you can use block. NOTICE: if you use block, the target-action mode (see above) will be abandoned.
    __weak XLRefreshControl *theRefresh = refresh;
    refresh.refreshBlock = ^{
        NSLog(@"trigger using block mode.");    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [theRefresh endRefreshing];
        });
    };
    
    [self.tableView addSubview:refresh];
    self.refresh = refresh;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refresh beginRefreshing];
    });
}

- (void)refreshData
{
    NSLog(@"trigger using target-action mode.");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refresh endRefreshing];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    return cell;
}

@end
