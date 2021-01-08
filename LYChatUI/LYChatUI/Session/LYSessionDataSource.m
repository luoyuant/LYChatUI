//
//  LYSessionDataSource.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/7.
//

#import "LYSessionDataSource.h"
#import "LYSessionViewController.h"
#import "LYSessionTimestampMessage.h"
#import "LYChatGlobalConfig.h"

@interface LYSessionDataSource ()

/**
 * 会话对象
 */
@property (nonatomic, weak) LYSession *session;

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation LYSessionDataSource

#pragma mark - Getter

- (NSMutableArray<LYSessionMessage *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - Setup

- (void)setup:(LYSessionViewController *)vc {
    _session = vc.session;
    _tableView = vc.tableView;
}

#pragma mark - LYSessionDataSourceProtocol

- (void)getLocalData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *avatarImage = [UIImage imageNamed:@"avatar"];
        
        NSTimeInterval timestamp = 1619985025000;
        NSTimeInterval lastTimestamp = 0;
        
        for (NSInteger i = 0; i < 10; i++) {
            if (timestamp - lastTimestamp >= [LYChatGlobalConfig shared].showTimestampWithTimeInterval) {
                LYSessionTimestampMessage *timestampMessage = [LYSessionTimestampMessage new];
                timestampMessage.timestamp = timestamp;
                [self.dataArray addObject:timestampMessage];
                lastTimestamp = timestamp;
            }
            LYSessionMessage *model = [LYSessionMessage new];
            model.session = self.session;
            model.timestamp = timestamp;
            model.user = [LYChatUserModel userWithUserId:@"hl123" nickname:@"神尾观铃" avatarImage:avatarImage];
            model.contentText = @"庭院深深深几许？杨柳堆烟，帘幕无重数，玉勒雕鞍游冶处，楼高不见章台路。";
            [self.dataArray addObject:model];
            
            timestamp += 60 * 1000;
        }
        
        LYSessionMessage *model = [LYSessionMessage new];
        model.session = self.session;
        model.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        model.contentText = @"庭院深深深几许？杨柳堆烟，帘幕无重数，玉勒雕鞍游冶处，楼高不见章台路。";
        [self.dataArray addObject:model];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self tableViewScrollToBottom];
        });
    });
}

/**
 * 滚动到底部
 */
- (void)tableViewScrollToBottom {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger row = [self.tableView numberOfRowsInSection:0] - 1;
        if (row > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:false];
        }
    });
}

@end
