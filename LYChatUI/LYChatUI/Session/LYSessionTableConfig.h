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

@interface LYSessionTableConfig : NSObject

@property (nonatomic, strong) LYSessionRefreshControl *refreshControl;

@property (nonatomic, weak) UITableView *tableView;

- (void)setup:(LYSessionViewController *)vc dataSourceManager:(LYSessionDataSource *)dataSource;

@end

NS_ASSUME_NONNULL_END
