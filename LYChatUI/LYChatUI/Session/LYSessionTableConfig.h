//
//  LYSessionTableConfig.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import <UIKit/UIKit.h>
#import "LYSessionRefreshControl.h"
#import "LYSessionDataSource.h"

@class LYSessionViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol LYSessionTableConfigDelegate <NSObject>

@optional

/**
 * 下拉加载更多
 */
- (void)didPullUp;

@end

@interface LYSessionTableConfig : NSObject

@property (nonatomic, strong) LYSessionRefreshControl *refreshControl;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) id<LYSessionTableConfigDelegate> delegate;

/**
 * 设置
 */
- (void)setup:(LYSessionViewController *)vc dataSourceManager:(LYSessionDataSource *)dataSource;

@end

NS_ASSUME_NONNULL_END
