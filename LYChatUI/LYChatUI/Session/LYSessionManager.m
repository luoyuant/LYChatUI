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

- (LYSessionTableConfig *)tableConfig {
    if (!_tableConfig) {
        _tableConfig = [LYSessionTableConfig new];
    }
    return _tableConfig;
}

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
