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
 * 获取本地数据
 */
- (void)getLocalData;

/**
 * 插入消息
 * 不检查顺序
 * @param atIndex 插入下标
 */
- (void)insertMessages:(NSArray<LYSessionMessage *> *)messages atIndex:(NSInteger)atIndex;

/**
 * 添加消息
 * 不检查顺序
 */
- (void)addMessages:(NSArray<LYSessionMessage *> *)messages;

/**
 * 添加消息
 * @param checkOrder 是否检查顺序
 */
- (void)addMessages:(NSArray<LYSessionMessage *> *)messages checkOrder:(BOOL)checkOrder;

@optional


@end

@interface LYSessionDataSource : NSObject <LYSessionDataSourceProtocol>

/**
 * 数据源
 */
@property (nonatomic, strong) NSMutableArray<LYSessionMessage *> *dataArray;

/**
 * 设置
 */
- (void)setup:(LYSessionViewController *)vc;

@end

NS_ASSUME_NONNULL_END
