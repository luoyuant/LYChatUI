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
#import "LYChatConfig.h"
#import "LYSessionTextContentView.h"

@interface LYSessionTableConfig () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) LYSessionViewController *sessionViewController;

@property (nonatomic, weak) LYSessionDataSource *dataSource;

@property (nonatomic, weak) LYChatConfig *config;

@end

@implementation LYSessionTableConfig

#pragma mark - Getter

- (LYSessionRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[LYSessionRefreshControl alloc] init];
        _refreshControl.titleLabel.text = @"加载中...";
        _refreshControl.titleLabel.font = _config.fontConfig.refreshControlTitleFont;
        _refreshControl.titleLabel.textColor = _config.colorConfig.refreshControlTitleColor;
    }
    return _refreshControl;
}

#pragma mark - setup

- (void)setup:(LYSessionViewController *)vc dataSourceManager:(nonnull LYSessionDataSource *)dataSource {
    self.tableView = vc.tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.sessionViewController = vc;
    self.dataSource = dataSource;
    self.config = vc.sessionManager.config;
    
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
        LYSessionMessageModel *message = _dataSource.dataArray[indexPath.row];
        return [message.layout cellHeightForCellWidth:tableView.bounds.size.width model:message];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _dataSource.dataArray.count) {
        LYSessionMessageModel *message = _dataSource.dataArray[indexPath.row];
        NSString *identifier = NSStringFromClass(message.layout.cellClass);
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            [tableView registerClass:message.layout.cellClass forCellReuseIdentifier:identifier];
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        }
        cell.contentView.backgroundColor = tableView.backgroundColor;
        
        if ([cell isKindOfClass:[LYSessionCell class]]) {
            LYSessionCell *sessionCell = (LYSessionCell *)cell;
            sessionCell.delegate = self.sessionViewController;
            if ([sessionCell.sessionContentView isKindOfClass:[LYSessionTextContentView class]]) {
                ((LYSessionTextContentView *)sessionCell.sessionContentView).contentLabel.selectionDelegate = self.sessionViewController;
            }
            sessionCell.message = message;
        } else if ([cell isKindOfClass:[LYSessionTimestampCell class]] && [message isKindOfClass:[LYSessionTimestampMessage class]]) {
            LYSessionTimestampCell *timestampCell = (LYSessionTimestampCell *)cell;
            timestampCell.model = (LYSessionTimestampMessage *)message;
        }
        
        return cell;
    }
    return [UITableViewCell new];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self didPullUp:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self didPullUp:scrollView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)didPullUp:(UIScrollView *)scrollView {
    if (!self.refreshControl.refreshing && scrollView.contentOffset.y <= -self.tableView.contentInset.top) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didScrollToTop:)]) {
            [self.delegate didScrollToTop:scrollView];
        }
    }
}

@end
