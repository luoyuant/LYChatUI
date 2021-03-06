//
//  LYSessionManager.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import "LYSessionManager.h"
#import "LYSessionViewController.h"

@implementation LYSessionManager

#pragma mark - Getter

/**
 * 设置
 */
- (LYChatConfig *)config {
    if (!_config) {
        _config = [LYChatConfig shared];
    }
    return _config;
}

/**
 * tableView管理
 */
- (LYSessionTableConfig *)tableConfig {
    if (!_tableConfig) {
        _tableConfig = [LYSessionTableConfig new];
    }
    return _tableConfig;
}

/**
 * 数据源
 */
- (LYSessionDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [LYSessionDataSource new];
    }
    return _dataSource;
}

#pragma mark - setup

- (void)setup:(LYSessionViewController *)vc {
    [self.tableConfig setup:vc dataSourceManager:self.dataSource];
    [self.dataSource setup:vc];
}

@end
