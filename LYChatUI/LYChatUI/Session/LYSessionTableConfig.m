//
//  LYSessionTableConfig.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import "LYSessionTableConfig.h"
#import "LYSessionViewController.h"
#import "LYSessionTimestampMessage.h"
#import "LYSessionCell.h"
#import "LYSessionTimestampCell.h"
#import "LYChatGlobalConfig.h"

@interface LYSessionTableConfig () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) LYSessionDataSource *dataSource;

@end

@implementation LYSessionTableConfig

#pragma mark - Getter

- (LYSessionRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[LYSessionRefreshControl alloc] init];
        _refreshControl.titleLabel.text = @"加载中...";
        _refreshControl.titleLabel.font = [LYChatGlobalConfig shared].fontConfig.refreshControlTitleFont;
        _refreshControl.titleLabel.textColor = [LYChatGlobalConfig shared].colorConfig.refreshControlTitleColor;
    }
    return _refreshControl;
}

#pragma mark - setup

- (void)setup:(LYSessionViewController *)vc dataSourceManager:(nonnull LYSessionDataSource *)dataSource {
    self.tableView = vc.tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.dataSource = dataSource;
    
    self.tableView.lyChatRefreshControl = self.refreshControl;
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _dataSource.dataArray.count) {
        LYSessionMessage *message = _dataSource.dataArray[indexPath.row];
        return [message.layout cellHeightForCellWidth:tableView.bounds.size.width model:message];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _dataSource.dataArray.count) {
        LYSessionMessage *model = _dataSource.dataArray[indexPath.row];
        NSString *identifier = NSStringFromClass(model.layout.cellClass);
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            [tableView registerClass:model.layout.cellClass forCellReuseIdentifier:identifier];
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        }
        cell.contentView.backgroundColor = tableView.backgroundColor;
        
        if ([cell isKindOfClass:[LYSessionCell class]]) {
            ((LYSessionCell *)cell).model = model;
        } else if ([cell isKindOfClass:[LYSessionTimestampCell class]] && [model isKindOfClass:[LYSessionTimestampMessage class]]) {
            ((LYSessionTimestampCell *)cell).model = (LYSessionTimestampMessage *)model;
        }
        
        return cell;
    }
    return [UITableViewCell new];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.refreshControl.refreshing && scrollView.contentOffset.y <= -self.tableView.contentInset.top) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPullUp)]) {
            [self.delegate didPullUp];
        }
    }
}

- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView {
    
}

@end
