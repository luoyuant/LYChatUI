//
//  LYSessionDataSource.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/7.
//

#import "LYSessionDataSource.h"
#import "LYSessionViewController.h"
#import "LYSessionTimestampMessage.h"
#import "LYChatConfig.h"

@interface LYSessionDataSource ()

/**
 * 会话对象
 */
@property (nonatomic, weak) LYSession *session;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) LYChatConfig *config;

@end

@implementation LYSessionDataSource

#pragma mark - Getter

- (NSMutableArray<LYSessionMessage *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray<LYSessionMessage *> *)messageArray {
    if (!_messageArray) {
        _messageArray = [NSMutableArray array];
    }
    return _messageArray;
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
    _config = vc.sessionManager.config;
}

#pragma mark - LYSessionDataSourceProtocol

/**
 * 列表最前插入消息
 * @param messages 插入消息，消息顺序为时间戳从小到大
 * @param checkOrder 是否对将要插入的消息排序，如果已确认时间戳是从小到大则不必要在排序
 */
- (void)insertMessages:(NSArray<LYSessionMessage *> *)messages checkOrder:(BOOL)checkOrder {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimeInterval firstTimestamp = self.messageArray.firstObject.timestamp;
        NSArray<LYSessionMessage *> *orderMessages = messages;
        if (checkOrder) {
            orderMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(LYSessionMessage * _Nonnull obj1, LYSessionMessage * _Nonnull obj2) {
                return obj1.timestamp < obj2.timestamp ? NSOrderedAscending : NSOrderedDescending;
            }];
        }
        for (NSInteger i = orderMessages.count - 1; i >= 0; i--) {
            LYSessionMessage *message = orderMessages[i];
            if (firstTimestamp > 0 && firstTimestamp - message.timestamp < self.config.showTimestampWithTimeInterval) {
                if ([self.dataArray.firstObject isKindOfClass:[LYSessionTimestampMessage class]]) {
                    [self.dataArray removeObjectAtIndex:0];
                }
            }
            [self.dataArray insertObject:message atIndex:0];
            
            //添加时间戳
            firstTimestamp = message.timestamp;
            LYSessionTimestampMessage *timestampMessage = [LYSessionTimestampMessage new];
            timestampMessage.config = message.config;
            timestampMessage.timestamp = message.timestamp;
            [self.dataArray addObject:timestampMessage];
            
            [self.messageArray addObject:message];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    });
}

/**
 * 列表末尾添加消息
 * @param messages 添加消息
 * @param scrollToBottom 是否滚动到底部
 */
- (void)appendMessages:(NSArray<LYSessionMessage *> *)messages scrollToBottom:(BOOL)scrollToBottom {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimeInterval previousTimestamp = 0;
        if (self.messageArray.count > 0) {
            for (NSInteger i = self.dataArray.count - 2; i >= 0; i--) {
                LYSessionMessage *msg = self.dataArray[i];
                if ([msg isKindOfClass:[LYSessionTimestampMessage class]]) {
                    previousTimestamp = msg.timestamp;
                    break;
                }
            }
        }
        for (NSInteger i = 0; i < messages.count; i++) {
            LYSessionMessage *message = messages[i];
            if (message.timestamp - previousTimestamp >= self.config.showTimestampWithTimeInterval) {
                LYSessionTimestampMessage *timestampMessage = [LYSessionTimestampMessage new];
                timestampMessage.config = message.config;
                timestampMessage.timestamp = message.timestamp;
                [self.dataArray addObject:timestampMessage];
                previousTimestamp = message.timestamp;
            }
            [self.dataArray addObject:message];
        }
        [self.messageArray addObjectsFromArray:messages];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if (scrollToBottom) {
                [self tableViewScrollToBottom];
            }
        });
    });
}

#pragma mark - Public Method

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
