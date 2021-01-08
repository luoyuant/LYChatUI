//
//  LYSessionManager.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import <Foundation/Foundation.h>
#import "LYSessionTableConfig.h"
#import "LYSessionDataSource.h"

@class LYSessionViewController;

NS_ASSUME_NONNULL_BEGIN

@interface LYSessionManager : NSObject

/**
 * tableView管理
 */
@property (nonatomic, strong) LYSessionTableConfig *tableConfig;

/**
 * 数据源
 */
@property (nonatomic, strong) LYSessionDataSource *dataSource;

- (void)setup:(LYSessionViewController *)vc;

@end

NS_ASSUME_NONNULL_END
