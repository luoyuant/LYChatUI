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

@optional


@end

@interface LYSessionDataSource : NSObject <LYSessionDataSourceProtocol>

/**
 * 数据源
 */
@property (nonatomic, strong) NSMutableArray<LYSessionMessage *> *dataArray;

- (void)setup:(LYSessionViewController *)vc;

@end

NS_ASSUME_NONNULL_END