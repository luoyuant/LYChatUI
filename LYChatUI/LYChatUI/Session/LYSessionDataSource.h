//
//  LYSessionDataSource.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/7.
//

#import <UIKit/UIKit.h>
#import "LYSessionMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class LYSessionViewController;


@protocol LYSessionDataSourceProtocol <NSObject>

@required

/**
 * 列表最前插入消息
 * @param messages 插入消息，消息顺序为时间戳从小到大
 * @param checkOrder 是否对将要插入的消息排序，如果已确认时间戳是从小到大则不必要在排序
 */
- (void)insertMessages:(NSArray<LYSessionMessage *> *)messages checkOrder:(BOOL)checkOrder;

/**
 * 列表末尾添加消息
 * @param messages 添加消息
 * @param scrollToBottom 是否滚动到底部
 */
- (void)appendMessages:(NSArray<LYSessionMessage *> *)messages scrollToBottom:(BOOL)scrollToBottom;


@optional


@end

@interface LYSessionDataSource : NSObject <LYSessionDataSourceProtocol>

/**
 * 数据源，包含时间戳数据
 */
@property (nonatomic, strong) NSMutableArray<LYSessionMessage *> *dataArray;

/**
 * 消息列表，不包含时间戳数据
 */
@property (nonatomic, strong) NSMutableArray<LYSessionMessage *> *messageArray;

/**
 * 设置
 */
- (void)setup:(LYSessionViewController *)vc;

/**
 * 滚动到底部
 */
- (void)tableViewScrollToBottom:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
